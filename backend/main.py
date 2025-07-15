#!/usr/bin/env python3
"""
GitAlong ML Matching Engine
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
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.feature_extraction.text import TfidfVectorizer
import asyncio
import uvicorn
import firebase_admin
from firebase_admin import credentials, auth

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize Firebase Admin SDK
try:
    # Use service account key if available
    if os.path.exists("firebase-service-account.json"):
        cred = credentials.Certificate("firebase-service-account.json")
        firebase_admin.initialize_app(cred)
        logger.info("✅ Firebase Admin SDK initialized with service account")
    else:
        # Use environment variables for deployment
        firebase_admin.initialize_app()
        logger.info("✅ Firebase Admin SDK initialized with environment variables")
except Exception as e:
    logger.error(f"❌ Failed to initialize Firebase Admin SDK: {e}")
    raise

# Initialize FastAPI app
app = FastAPI(
    title="GitAlong API",
    description="ML-powered matching and analytics backend for GitAlong",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://gitalong.com",
        "https://app.gitalong.com",
        "http://localhost:3000",
        "http://localhost:8080"
    ],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["*"],
)

# Security
security = HTTPBearer()

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

class UserProfile(BaseModel):
    id: str
    name: str
    bio: Optional[str] = ""
    tech_stack: List[str] = []
    github_handle: Optional[str] = ""
    role: str = "contributor"  # contributor or maintainer
    skills: List[str] = []
    github_stats: Optional[Dict[str, Any]] = {}
    location: Optional[str] = ""
    
class SwipeHistory(BaseModel):
    swiper_id: str
    target_id: str
    direction: str  # "left" or "right"
    timestamp: datetime

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
    model_version: str = "1.0.0"
    analytics: Optional[Dict[str, Any]] = None

# In-memory storage (replace with database in production)
user_profiles: Dict[str, UserProfile] = {}
swipe_history: List[SwipeHistory] = []
cached_embeddings: Dict[str, np.ndarray] = {}

# Firebase token verification
async def verify_firebase_token(authorization: str = Header(...)) -> str:
    """Verify Firebase ID token and return user ID"""
    try:
        # Extract token from Authorization header
        if not authorization.startswith("Bearer "):
            raise HTTPException(status_code=401, detail="Invalid authorization header")
        
        token = authorization.replace("Bearer ", "")
        
        # Verify token with Firebase
        decoded_token = auth.verify_id_token(token)
        user_id = decoded_token['uid']
        
        logger.info(f"✅ Token verified for user: {user_id}")
        return user_id
        
    except Exception as e:
        logger.error(f"❌ Token verification failed: {e}")
        raise HTTPException(status_code=401, detail="Invalid token")

# Health check endpoint
@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "service": "GitAlong API",
        "version": "1.0.0"
    }

# User sync endpoint
@app.post("/users/sync")
async def sync_user(
    request: UserSyncRequest,
    verified_user_id: str = Depends(verify_firebase_token)
):
    """Sync user data from Firebase to FastAPI backend"""
    try:
        # Verify the user_id matches the token
        if request.user_id != verified_user_id:
            raise HTTPException(status_code=403, detail="User ID mismatch")
        
        # Store user data (in production, this would go to a database)
        user_data = {
            "user_id": request.user_id,
            "email": request.email,
            "display_name": request.display_name,
            "photo_url": request.photo_url,
            "profile_data": request.profile_data,
            "github_data": request.github_data,
            "auth_provider": request.auth_provider,
            "last_sync": request.last_sync,
            "synced_at": datetime.now().isoformat()
        }
        
        # In production, store in database
        # await database.users.upsert(user_data)
        
        logger.info(f"✅ User synced: {request.user_id}")
        
        return {
            "success": True,
            "user_id": request.user_id,
            "synced_at": datetime.now().isoformat()
        }
        
    except Exception as e:
        logger.error(f"❌ User sync failed: {e}")
        raise HTTPException(status_code=500, detail="Failed to sync user")

# Update user profile
@app.put("/users/profile")
async def update_user_profile(
    request: UserProfileRequest,
    verified_user_id: str = Depends(verify_firebase_token)
):
    """Update user profile in FastAPI backend"""
    try:
        if request.user_id != verified_user_id:
            raise HTTPException(status_code=403, detail="User ID mismatch")
        
        # Update user profile (in production, this would update database)
        profile_data = request.dict()
        profile_data["updated_at"] = datetime.now().isoformat()
        
        # In production, update database
        # await database.users.update(request.user_id, profile_data)
        
        logger.info(f"✅ Profile updated: {request.user_id}")
        
        return {
            "success": True,
            "user_id": request.user_id,
            "updated_at": datetime.now().isoformat()
        }
        
    except Exception as e:
        logger.error(f"❌ Profile update failed: {e}")
        raise HTTPException(status_code=500, detail="Failed to update profile")

# ML recommendations endpoint
@app.post("/recommendations")
async def get_recommendations(
    request: RecommendationRequest,
    verified_user_id: str = Depends(verify_firebase_token)
):
    """Get ML-powered recommendations for user"""
    try:
        if request.user_id != verified_user_id:
            raise HTTPException(status_code=403, detail="User ID mismatch")

        # Find the requesting user's profile
        user = user_profiles.get(request.user_id)
        if not user:
            raise HTTPException(status_code=404, detail="User profile not found")

        # Prepare candidate profiles (exclude self and excluded users)
        candidates = [
            u for uid, u in user_profiles.items()
            if uid != request.user_id and uid not in request.exclude_user_ids
        ]
        if not candidates:
            return {
                "recommendations": [],
                "total_count": 0,
                "user_id": request.user_id,
                "generated_at": datetime.now().isoformat()
            }

        # Compute tech stack overlap
        def tech_overlap(a, b):
            set_a = set(a or [])
            set_b = set(b or [])
            if not set_a or not set_b:
                return 0.0
            return len(set_a & set_b) / len(set_a | set_b)

        # Compute bio similarity using sentence transformer
        user_bio_emb = sentence_transformer.encode([user.bio or ""])[0]
        candidate_bios = [c.bio or "" for c in candidates]
        candidate_bio_embs = sentence_transformer.encode(candidate_bios)
        bio_similarities = cosine_similarity([user_bio_emb], candidate_bio_embs)[0]

        # Score and rank candidates
        scored = []
        for idx, c in enumerate(candidates):
            overlap = tech_overlap(user.tech_stack, c.tech_stack)
            bio_sim = float(bio_similarities[idx])
            # Simple average for now
            overall = 0.6 * overlap + 0.4 * bio_sim
            scored.append({
                "id": c.id,
                "name": c.name,
                "bio": c.bio,
                "tech_stack": c.tech_stack,
                "skills": c.skills,
                "similarity_score": overall,
                "tech_overlap_score": overlap,
                "bio_similarity_score": bio_sim
            })
        # Sort by overall score
        scored.sort(key=lambda x: x["similarity_score"], reverse=True)
        top = scored[:request.max_recommendations]
        return {
            "recommendations": top,
            "total_count": len(top),
            "user_id": request.user_id,
            "generated_at": datetime.now().isoformat()
        }
    except Exception as e:
        logger.error(f"❌ Recommendations failed: {e}")
        raise HTTPException(status_code=500, detail="Failed to get recommendations")

# Record swipe endpoint
@app.post("/swipe")
async def record_swipe(
    request: SwipeRequest,
    verified_user_id: str = Depends(verify_firebase_token)
):
    """Record user swipe for ML training"""
    try:
        if request.swiper_id != verified_user_id:
            raise HTTPException(status_code=403, detail="User ID mismatch")
        
        # Store swipe data for ML training
        swipe_data = {
            "swiper_id": request.swiper_id,
            "target_id": request.target_id,
            "direction": request.direction,
            "target_type": request.target_type,
            "timestamp": request.timestamp,
            "recorded_at": datetime.now().isoformat()
        }
        
        # In production, store in database for ML training
        # await database.swipes.insert(swipe_data)
        
        logger.info(f"✅ Swipe recorded: {request.swiper_id} -> {request.target_id} ({request.direction})")
        
        return {
            "success": True,
            "swipe_id": f"{request.swiper_id}_{request.target_id}_{datetime.now().timestamp()}",
            "recorded_at": datetime.now().isoformat()
        }
        
    except Exception as e:
        logger.error(f"❌ Swipe recording failed: {e}")
        raise HTTPException(status_code=500, detail="Failed to record swipe")

# Match suggestions endpoint
@app.get("/matches/suggestions")
async def get_match_suggestions(
    user_id: str,
    limit: int = 10,
    verified_user_id: str = Depends(verify_firebase_token)
):
    """Get match suggestions for user"""
    try:
        if user_id != verified_user_id:
            raise HTTPException(status_code=403, detail="User ID mismatch")
        
        # In production, this would query your ML model or database
        mock_suggestions = [
            {
                "id": "match_1",
                "contributor_id": user_id,
                "project_id": "project_1",
                "project_owner_id": "owner_1",
                "created_at": datetime.now().isoformat(),
                "status": "active",
                "confidence_score": 0.92
            },
            {
                "id": "match_2",
                "contributor_id": user_id,
                "project_id": "project_2", 
                "project_owner_id": "owner_2",
                "created_at": datetime.now().isoformat(),
                "status": "active",
                "confidence_score": 0.87
            }
        ][:limit]
        
        logger.info(f"✅ Match suggestions generated for user: {user_id}")
        
    return {
            "suggestions": mock_suggestions,
            "total_count": len(mock_suggestions),
            "user_id": user_id,
            "generated_at": datetime.now().isoformat()
        }
        
    except Exception as e:
        logger.error(f"❌ Match suggestions failed: {e}")
        raise HTTPException(status_code=500, detail="Failed to get match suggestions")

# Analytics endpoint
@app.get("/analytics")
async def get_analytics(
    user_id: Optional[str] = None,
    metric: Optional[str] = None,
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    verified_user_id: str = Depends(verify_firebase_token)
):
    """Get analytics data"""
    try:
        # If user_id is provided, verify it matches the token
        if user_id and user_id != verified_user_id:
            raise HTTPException(status_code=403, detail="User ID mismatch")
        
        # In production, this would query your analytics database
        mock_analytics = {
            "user_id": user_id or verified_user_id,
            "metrics": {
                "total_matches": 15,
                "successful_connections": 8,
                "response_rate": 0.53,
                "avg_response_time": 2.3,
                "top_skills": ["Flutter", "Python", "React"],
                "active_projects": 5
            },
            "period": {
                "start_date": start_date or (datetime.now() - timedelta(days=30)).isoformat(),
                "end_date": end_date or datetime.now().isoformat()
            },
            "generated_at": datetime.now().isoformat()
        }
        
        logger.info(f"✅ Analytics retrieved for user: {user_id or verified_user_id}")
        
        return mock_analytics
        
    except Exception as e:
        logger.error(f"❌ Analytics failed: {e}")
        raise HTTPException(status_code=500, detail="Failed to get analytics")

# Session tracking endpoint
@app.post("/analytics/session")
async def track_session(
    request: Dict[str, Any],
    verified_user_id: str = Depends(verify_firebase_token)
):
    """Track user session analytics"""
    try:
        session_data = {
            "user_id": verified_user_id,
            "email": request.get("email"),
            "timestamp": request.get("timestamp"),
            "platform": request.get("platform", "flutter"),
            "recorded_at": datetime.now().isoformat()
        }
        
        # In production, store in analytics database
        # await database.sessions.insert(session_data)
        
        logger.info(f"✅ Session tracked for user: {verified_user_id}")
        
        return {"success": True}
        
    except Exception as e:
        logger.error(f"❌ Session tracking failed: {e}")
        raise HTTPException(status_code=500, detail="Failed to track session")

# Populate with sample data for testing
async def populate_sample_data():
    """Populate with sample user data for testing"""
    sample_users = [
        UserProfile(
            id="user1",
            name="Alex Chen",
            bio="Full-stack developer passionate about React and Node.js. Love contributing to open source projects.",
            tech_stack=["JavaScript", "TypeScript", "React", "Node.js", "Docker"],
            role="contributor",
            github_stats={"public_repos": 25, "followers": 150, "contributions_last_year": 280}
        ),
        UserProfile(
            id="user2", 
            name="Sarah Kim",
            bio="Mobile app developer specializing in Flutter. Looking for exciting projects to collaborate on.",
            tech_stack=["Dart", "Flutter", "Firebase", "Python"],
            role="contributor",
            github_stats={"public_repos": 18, "followers": 89, "contributions_last_year": 195}
        ),
        UserProfile(
            id="user3",
            name="Mike Rodriguez", 
            bio="Open source maintainer of several popular Python libraries. Always looking for contributors.",
            tech_stack=["Python", "Django", "PostgreSQL", "Docker", "Kubernetes"],
            role="maintainer",
            github_stats={"public_repos": 42, "followers": 320, "contributions_last_year": 450}
        )
    ]
    
    for user in sample_users:
        user_profiles[user.id] = user
    
    logger.info("🌱 Populated sample data")

@app.on_event("startup")
async def startup_event():
    """Initialize the application"""
    logger.info("🚀 Starting GitAlong ML Matching Engine")
    await populate_sample_data()
    logger.info("✅ Startup complete - Ready to match developers!")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
 