#!/usr/bin/env python3
"""
GitAlong ML Matching Engine - PRODUCTION READY
AI-powered matching service for connecting developers based on:
- Tech stack overlap
- Bio semantic similarity  
- GitHub contribution patterns
- Swipe history collaborative filtering
"""

import os
import json
import logging
import numpy as np
from datetime import datetime, timedelta
from typing import List, Dict, Optional, Any
from pydantic import BaseModel, Field
from fastapi import FastAPI, HTTPException, Depends, Query, Header, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi_limiter import FastAPILimiter
from fastapi_limiter.depends import RateLimiter
import redis.asyncio as redis
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.feature_extraction.text import TfidfVectorizer
import asyncio
import uvicorn
import firebase_admin
from firebase_admin import credentials, auth
import asyncpg
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import Column, String, Integer, DateTime, Boolean, Text, JSON
from sqlalchemy.ext.declarative import declarative_base

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Database configuration
DATABASE_URL = os.getenv('DATABASE_URL', 'postgresql+asyncpg://user:password@localhost/gitalong')
REDIS_URL = os.getenv('REDIS_URL', 'redis://localhost:6379')

# Initialize Firebase Admin SDK
try:
    if os.path.exists("firebase-service-account.json"):
        cred = credentials.Certificate("firebase-service-account.json")
        firebase_admin.initialize_app(cred)
        logger.info("✅ Firebase Admin SDK initialized with service account")
    else:
        firebase_admin.initialize_app()
        logger.info("✅ Firebase Admin SDK initialized with environment variables")
except Exception as e:
    logger.error(f"❌ Failed to initialize Firebase Admin SDK: {e}")
    raise

# Initialize FastAPI app
app = FastAPI(
    title="GitAlong API",
    description="ML-powered matching and analytics backend for GitAlong",
    version="2.0.0",
    docs_url="/docs" if os.getenv('ENVIRONMENT') != 'production' else None,
    redoc_url="/redoc" if os.getenv('ENVIRONMENT') != 'production' else None,
)

# Security middleware
app.add_middleware(
    TrustedHostMiddleware, 
    allowed_hosts=["*"] if os.getenv('ENVIRONMENT') == 'development' else [
        "gitalong.com", 
        "api.gitalong.com", 
        "app.gitalong.com"
    ]
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://gitalong.com",
        "https://app.gitalong.com",
        "http://localhost:3000",
        "http://localhost:8080"
    ] if os.getenv('ENVIRONMENT') == 'production' else ["*"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["*"],
)

# Security
security = HTTPBearer()

# Database models
Base = declarative_base()

class UserProfile(Base):
    __tablename__ = "user_profiles"
    
    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    bio = Column(Text)
    tech_stack = Column(JSON, default=list)
    github_handle = Column(String)
    role = Column(String, default="contributor")
    skills = Column(JSON, default=list)
    github_stats = Column(JSON, default=dict)
    location = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class SwipeHistory(Base):
    __tablename__ = "swipe_history"
    
    id = Column(String, primary_key=True)
    swiper_id = Column(String, nullable=False)
    target_id = Column(String, nullable=False)
    direction = Column(String, nullable=False)  # "left" or "right"
    target_type = Column(String, default="user")  # "user" or "project"
    timestamp = Column(DateTime, default=datetime.utcnow)

class Match(Base):
    __tablename__ = "matches"
    
    id = Column(String, primary_key=True)
    contributor_id = Column(String, nullable=False)
    project_id = Column(String, nullable=False)
    project_owner_id = Column(String, nullable=False)
    status = Column(String, default="active")  # "active", "completed", "cancelled"
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

# Database engine
engine = create_async_engine(DATABASE_URL, echo=False)
AsyncSessionLocal = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

# Redis for caching and rate limiting
redis_client = None

# Initialize ML models
logger.info("🧠 Loading ML models...")
sentence_transformer = SentenceTransformer('all-MiniLM-L6-v2')
tfidf_vectorizer = TfidfVectorizer(max_features=1000, stop_words='english')
logger.info("✅ ML models loaded successfully")

# Pydantic models
class UserSyncRequest(BaseModel):
    user_id: str
    email: str
    display_name: Optional[str] = None
    photo_url: Optional[str] = None
    firebase_uid: str
    profile_data: Dict[str, Any] = {}
    github_data: Optional[Dict[str, Any]] = None
    auth_provider: str = "email"
    last_sync: str

class UserProfileRequest(BaseModel):
    user_id: str
    name: Optional[str] = None
    bio: Optional[str] = None
    github_handle: Optional[str] = None
    location: Optional[str] = None
    tech_stack: List[str] = []
    skills: List[str] = []
    interests: List[str] = []
    role: Optional[str] = None
    github_data: Optional[Dict[str, Any]] = None
    profile_image_url: Optional[str] = None
    is_profile_complete: bool = False

class RecommendationRequest(BaseModel):
    user_id: str
    exclude_user_ids: List[str] = []
    max_recommendations: int = 20
    include_analytics: bool = True

class SwipeRequest(BaseModel):
    swiper_id: str
    target_id: str
    direction: str  # "right" or "left"
    target_type: str = "user"  # "user" or "project"
    timestamp: str

class AnalyticsRequest(BaseModel):
    user_id: Optional[str] = None
    metric: Optional[str] = None
    start_date: Optional[str] = None
    end_date: Optional[str] = None

class MatchScore(BaseModel):
    target_user_id: str
    similarity_score: float
    tech_overlap_score: float
    bio_similarity_score: float
    github_activity_score: float
    collaborative_score: float
    overall_score: float
    match_reasons: List[str]

class MatchResponse(BaseModel):
    user_id: str
    recommendations: List[MatchScore]
    generated_at: datetime
    model_version: str = "2.0.0"
    analytics: Optional[Dict[str, Any]] = None

# Database dependency
async def get_db():
    async with AsyncSessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()

# Firebase token verification
async def verify_firebase_token(authorization: str = Header(...)) -> str:
    """Verify Firebase ID token and return user ID"""
    try:
        if not authorization.startswith("Bearer "):
            raise HTTPException(status_code=401, detail="Invalid authorization header")
        
        token = authorization.replace("Bearer ", "")
        decoded_token = auth.verify_id_token(token)
        user_id = decoded_token['uid']
        
        logger.info(f"✅ Token verified for user: {user_id}")
        return user_id
        
    except Exception as e:
        logger.error(f"❌ Token verification failed: {e}")
        raise HTTPException(status_code=401, detail="Invalid token")

# Rate limiting
@app.on_event("startup")
async def startup_event():
    global redis_client
    try:
        redis_client = redis.from_url(REDIS_URL, encoding="utf-8", decode_responses=True)
        await FastAPILimiter.init(redis_client)
        logger.info("✅ Redis and rate limiting initialized")
    except Exception as e:
        logger.error(f"❌ Failed to initialize Redis: {e}")
        raise

    # Create database tables
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    logger.info("✅ Database tables created")

# Health check endpoint
@app.get("/health")
async def health_check():
    """Health check endpoint"""
    try:
        # Check database connection
        async with AsyncSessionLocal() as session:
            await session.execute("SELECT 1")
        
        # Check Redis connection
        if redis_client:
            await redis_client.ping()
        
        return {
            "status": "healthy",
            "timestamp": datetime.now().isoformat(),
            "service": "GitAlong API",
            "version": "2.0.0",
            "database": "connected",
            "redis": "connected",
            "ml_models": "loaded"
        }
    except Exception as e:
        logger.error(f"❌ Health check failed: {e}")
        raise HTTPException(status_code=503, detail="Service unhealthy")

# User sync endpoint with rate limiting
@app.post("/users/sync")
@RateLimiter(times=10, seconds=60)
async def sync_user(
    request: UserSyncRequest,
    verified_user_id: str = Depends(verify_firebase_token),
    db: AsyncSession = Depends(get_db)
):
    """Sync user data from Firebase to FastAPI backend"""
    try:
        # Check if user profile exists
        result = await db.execute(
            "SELECT id FROM user_profiles WHERE id = :user_id",
            {"user_id": request.user_id}
        )
        existing_profile = result.fetchone()
        
        if existing_profile:
            # Update existing profile
            await db.execute(
                """
                UPDATE user_profiles 
                SET name = :name, bio = :bio, tech_stack = :tech_stack, 
                    github_handle = :github_handle, role = :role, skills = :skills,
                    github_stats = :github_stats, location = :location, updated_at = :updated_at
                WHERE id = :user_id
                """,
                {
                    "user_id": request.user_id,
                    "name": request.display_name or request.profile_data.get("name", ""),
                    "bio": request.profile_data.get("bio", ""),
                    "tech_stack": request.profile_data.get("tech_stack", []),
                    "github_handle": request.profile_data.get("github_handle", ""),
                    "role": request.profile_data.get("role", "contributor"),
                    "skills": request.profile_data.get("skills", []),
                    "github_stats": request.github_data or {},
                    "location": request.profile_data.get("location", ""),
                    "updated_at": datetime.utcnow()
                }
            )
        else:
            # Create new profile
            await db.execute(
                """
                INSERT INTO user_profiles 
                (id, name, bio, tech_stack, github_handle, role, skills, github_stats, location)
                VALUES (:user_id, :name, :bio, :tech_stack, :github_handle, :role, :skills, :github_stats, :location)
                """,
                {
                    "user_id": request.user_id,
                    "name": request.display_name or request.profile_data.get("name", ""),
                    "bio": request.profile_data.get("bio", ""),
                    "tech_stack": request.profile_data.get("tech_stack", []),
                    "github_handle": request.profile_data.get("github_handle", ""),
                    "role": request.profile_data.get("role", "contributor"),
                    "skills": request.profile_data.get("skills", []),
                    "github_stats": request.github_data or {},
                    "location": request.profile_data.get("location", "")
                }
            )
        
        await db.commit()
        logger.info(f"✅ User profile synced: {request.user_id}")
        
        return {"success": True, "message": "User profile synced successfully"}
        
    except Exception as e:
        await db.rollback()
        logger.error(f"❌ Error syncing user profile: {e}")
        raise HTTPException(status_code=500, detail="Failed to sync user profile")

# Get recommendations with ML matching
@app.post("/recommendations")
@RateLimiter(times=20, seconds=60)
async def get_recommendations(
    request: RecommendationRequest,
    verified_user_id: str = Depends(verify_firebase_token),
    db: AsyncSession = Depends(get_db)
):
    """Get ML-powered recommendations for a user"""
    try:
        # Get user profile
        result = await db.execute(
            "SELECT * FROM user_profiles WHERE id = :user_id",
            {"user_id": request.user_id}
        )
        user_profile = result.fetchone()
        
        if not user_profile:
            raise HTTPException(status_code=404, detail="User profile not found")
        
        # Get all other user profiles
        result = await db.execute(
            "SELECT * FROM user_profiles WHERE id != :user_id AND id NOT IN :exclude_ids",
            {"user_id": request.user_id, "exclude_ids": tuple(request.exclude_user_ids) or ('',)}
        )
        other_profiles = result.fetchall()
        
        recommendations = []
        
        for profile in other_profiles:
            # Calculate similarity scores
            tech_overlap = len(set(user_profile.tech_stack) & set(profile.tech_stack))
            tech_overlap_score = tech_overlap / max(len(user_profile.tech_stack), 1)
            
            # Bio similarity using sentence transformers
            if user_profile.bio and profile.bio:
                bio_embeddings = sentence_transformer.encode([user_profile.bio, profile.bio])
                bio_similarity = cosine_similarity([bio_embeddings[0]], [bio_embeddings[1]])[0][0]
            else:
                bio_similarity = 0.0
            
            # GitHub activity score
            github_score = 0.0
            if profile.github_stats:
                followers = profile.github_stats.get('followers', 0)
                repos = profile.github_stats.get('public_repos', 0)
                github_score = min((followers + repos * 10) / 1000, 1.0)
            
            # Collaborative filtering based on swipe history
            collaborative_score = await _calculate_collaborative_score(
                request.user_id, profile.id, db
            )
            
            # Overall score
            overall_score = (
                tech_overlap_score * 0.3 +
                bio_similarity * 0.25 +
                github_score * 0.2 +
                collaborative_score * 0.25
            )
            
            # Generate match reasons
            match_reasons = []
            if tech_overlap_score > 0.5:
                match_reasons.append("Strong tech stack overlap")
            if bio_similarity > 0.7:
                match_reasons.append("Similar interests and background")
            if github_score > 0.5:
                match_reasons.append("Active GitHub contributor")
            if collaborative_score > 0.6:
                match_reasons.append("Similar to users you've liked")
            
            recommendations.append(MatchScore(
                target_user_id=profile.id,
                similarity_score=overall_score,
                tech_overlap_score=tech_overlap_score,
                bio_similarity_score=bio_similarity,
                github_activity_score=github_score,
                collaborative_score=collaborative_score,
                overall_score=overall_score,
                match_reasons=match_reasons
            ))
        
        # Sort by overall score and limit
        recommendations.sort(key=lambda x: x.overall_score, reverse=True)
        recommendations = recommendations[:request.max_recommendations]
        
        return MatchResponse(
            user_id=request.user_id,
            recommendations=recommendations,
            generated_at=datetime.utcnow(),
            analytics={
                "total_profiles_analyzed": len(other_profiles),
                "recommendations_generated": len(recommendations),
                "average_score": sum(r.overall_score for r in recommendations) / len(recommendations) if recommendations else 0
            }
        )
        
    except Exception as e:
        logger.error(f"❌ Error getting recommendations: {e}")
        raise HTTPException(status_code=500, detail="Failed to get recommendations")

# Record swipe
@app.post("/swipe")
@RateLimiter(times=50, seconds=60)
async def record_swipe(
    request: SwipeRequest,
    verified_user_id: str = Depends(verify_firebase_token),
    db: AsyncSession = Depends(get_db)
):
    """Record a swipe action"""
    try:
        await db.execute(
            """
            INSERT INTO swipe_history (id, swiper_id, target_id, direction, target_type, timestamp)
            VALUES (:id, :swiper_id, :target_id, :direction, :target_type, :timestamp)
            """,
            {
                "id": f"{request.swiper_id}_{request.target_id}_{int(datetime.utcnow().timestamp())}",
                "swiper_id": request.swiper_id,
                "target_id": request.target_id,
                "direction": request.direction,
                "target_type": request.target_type,
                "timestamp": datetime.fromisoformat(request.timestamp.replace('Z', '+00:00'))
            }
        )
        
        await db.commit()
        logger.info(f"✅ Swipe recorded: {request.swiper_id} -> {request.target_id} ({request.direction})")
        
        return {"success": True, "message": "Swipe recorded successfully"}
        
    except Exception as e:
        await db.rollback()
        logger.error(f"❌ Error recording swipe: {e}")
        raise HTTPException(status_code=500, detail="Failed to record swipe")

# Analytics endpoint
@app.get("/analytics")
@RateLimiter(times=30, seconds=60)
async def get_analytics(
    user_id: Optional[str] = None,
    metric: Optional[str] = None,
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    verified_user_id: str = Depends(verify_firebase_token),
    db: AsyncSession = Depends(get_db)
):
    """Get analytics data"""
    try:
        analytics = {}
        
        if user_id:
            # User-specific analytics
            result = await db.execute(
                "SELECT COUNT(*) as swipe_count FROM swipe_history WHERE swiper_id = :user_id",
                {"user_id": user_id}
            )
            swipe_count = result.fetchone()[0]
            
            result = await db.execute(
                "SELECT COUNT(*) as match_count FROM matches WHERE contributor_id = :user_id OR project_owner_id = :user_id",
                {"user_id": user_id}
            )
            match_count = result.fetchone()[0]
            
            analytics = {
                "user_id": user_id,
                "swipe_count": swipe_count,
                "match_count": match_count,
                "match_rate": match_count / max(swipe_count, 1)
            }
        else:
            # Global analytics
            result = await db.execute("SELECT COUNT(*) FROM user_profiles")
            total_users = result.fetchone()[0]
            
            result = await db.execute("SELECT COUNT(*) FROM matches")
            total_matches = result.fetchone()[0]
            
            result = await db.execute("SELECT COUNT(*) FROM swipe_history")
            total_swipes = result.fetchone()[0]
            
            analytics = {
                "total_users": total_users,
                "total_matches": total_matches,
                "total_swipes": total_swipes,
                "match_rate": total_matches / max(total_swipes, 1)
            }
        
        return analytics
        
    except Exception as e:
        logger.error(f"❌ Error getting analytics: {e}")
        raise HTTPException(status_code=500, detail="Failed to get analytics")

async def _calculate_collaborative_score(user_id: str, target_id: str, db: AsyncSession) -> float:
    """Calculate collaborative filtering score based on similar users' preferences"""
    try:
        # Get users who liked the target user
        result = await db.execute(
            "SELECT swiper_id FROM swipe_history WHERE target_id = :target_id AND direction = 'right'",
            {"target_id": target_id}
        )
        users_who_liked = [row[0] for row in result.fetchall()]
        
        if not users_who_liked:
            return 0.0
        
        # Get current user's likes
        result = await db.execute(
            "SELECT target_id FROM swipe_history WHERE swiper_id = :user_id AND direction = 'right'",
            {"user_id": user_id}
        )
        user_likes = [row[0] for row in result.fetchall()]
        
        if not user_likes:
            return 0.0
        
        # Calculate overlap
        overlap = 0
        for liked_user in users_who_liked:
            result = await db.execute(
                "SELECT COUNT(*) FROM swipe_history WHERE swiper_id = :liked_user AND target_id IN :user_likes AND direction = 'right'",
                {"liked_user": liked_user, "user_likes": tuple(user_likes)}
            )
            overlap += result.fetchone()[0]
        
        return min(overlap / (len(users_who_liked) * len(user_likes)), 1.0) if user_likes else 0.0
        
    except Exception as e:
        logger.error(f"❌ Error calculating collaborative score: {e}")
        return 0.0

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=int(os.getenv("PORT", 8000)),
        reload=os.getenv("ENVIRONMENT") == "development"
    )
 