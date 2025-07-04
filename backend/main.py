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
from fastapi import FastAPI, HTTPException, Depends, Query
from fastapi.middleware.cors import CORSMiddleware
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.feature_extraction.text import TfidfVectorizer
import asyncio
import uvicorn

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="GitAlong ML Matching Engine",
    description="AI-powered developer matching for open source collaboration",
    version="1.0.0"
)

# Add CORS middleware for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify Flutter app domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize ML models
logger.info("🧠 Loading ML models...")
sentence_transformer = SentenceTransformer('all-MiniLM-L6-v2')
tfidf_vectorizer = TfidfVectorizer(max_features=1000, stop_words='english')
logger.info("✅ ML models loaded successfully")

# Pydantic models for request/response
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

class MatchRequest(BaseModel):
    user_id: str
    user_profile: UserProfile
    exclude_user_ids: List[str] = []
    max_recommendations: int = Field(default=20, le=50)
    include_analytics: bool = True

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

class MatchingEngine:
    """Advanced ML-powered matching engine for developers"""
    
    def __init__(self):
        self.tech_stack_weights = {
            'JavaScript': 0.9, 'TypeScript': 0.9, 'Python': 0.9,
            'React': 0.8, 'Flutter': 0.8, 'Node.js': 0.8,
            'Docker': 0.7, 'Kubernetes': 0.7, 'AWS': 0.7,
            'Go': 0.6, 'Rust': 0.6, 'Swift': 0.6
        }
        
    def calculate_tech_overlap(self, user_stack: List[str], target_stack: List[str]) -> float:
        """Calculate weighted technology stack overlap"""
        if not user_stack or not target_stack:
            return 0.0
            
        user_set = set(stack.lower() for stack in user_stack)
        target_set = set(stack.lower() for stack in target_stack)
        
        # Calculate weighted overlap
        overlap = user_set.intersection(target_set)
        if not overlap:
            return 0.0
            
        weighted_score = sum(
            self.tech_stack_weights.get(tech.title(), 0.5) 
            for tech in overlap
        )
        
        max_possible = max(len(user_set), len(target_set)) * 0.9
        return min(weighted_score / max_possible, 1.0)
    
    def get_bio_embedding(self, bio: str, user_id: str) -> np.ndarray:
        """Get cached or compute bio embedding using sentence transformers"""
        if user_id in cached_embeddings:
            return cached_embeddings[user_id]
            
        if not bio or len(bio.strip()) < 10:
            # Default embedding for empty bios
            bio = "Software developer interested in open source collaboration"
            
        embedding = sentence_transformer.encode([bio])[0]
        cached_embeddings[user_id] = embedding
        return embedding
    
    def calculate_bio_similarity(self, user_bio: str, target_bio: str, 
                                user_id: str, target_id: str) -> float:
        """Calculate semantic similarity between user bios"""
        user_embedding = self.get_bio_embedding(user_bio, user_id)
        target_embedding = self.get_bio_embedding(target_bio, target_id)
        
        similarity = cosine_similarity([user_embedding], [target_embedding])[0][0]
        return max(0.0, similarity)  # Ensure non-negative
    
    def calculate_github_activity_score(self, user_stats: Dict, target_stats: Dict) -> float:
        """Score based on GitHub activity patterns"""
        if not user_stats or not target_stats:
            return 0.5  # Neutral score for missing data
            
        # Extract meaningful metrics
        user_metrics = {
            'repos': user_stats.get('public_repos', 0),
            'followers': user_stats.get('followers', 0),
            'contributions': user_stats.get('contributions_last_year', 0)
        }
        
        target_metrics = {
            'repos': target_stats.get('public_repos', 0),
            'followers': target_stats.get('followers', 0),
            'contributions': target_stats.get('contributions_last_year', 0)
        }
        
        # Calculate activity level similarity
        repo_similarity = 1 - abs(user_metrics['repos'] - target_metrics['repos']) / max(
            user_metrics['repos'] + target_metrics['repos'], 1
        )
        
        # Boost score for active contributors
        activity_boost = min(
            (user_metrics['contributions'] + target_metrics['contributions']) / 500, 1.0
        )
        
        return (repo_similarity * 0.7 + activity_boost * 0.3)
    
    def calculate_collaborative_score(self, user_id: str, target_id: str) -> float:
        """Collaborative filtering based on swipe patterns"""
        user_right_swipes = set()
        target_received_right_swipes = set()
        
        for swipe in swipe_history:
            if swipe.swiper_id == user_id and swipe.direction == "right":
                user_right_swipes.add(swipe.target_id)
            elif swipe.target_id == target_id and swipe.direction == "right":
                target_received_right_swipes.add(swipe.swiper_id)
        
        # Find users who both liked the target and were liked by similar users
        if not user_right_swipes:
            return 0.5  # Neutral for new users
            
        # Simple collaborative filtering
        common_preferences = 0
        for liked_user in user_right_swipes:
            if liked_user in target_received_right_swipes:
                common_preferences += 1
                
        if common_preferences > 0:
            return min(common_preferences / 5.0, 1.0)  # Cap at 1.0
        
        return 0.3  # Slight negative for no common patterns
    
    def get_match_reasons(self, tech_score: float, bio_score: float, 
                         github_score: float, collab_score: float,
                         user_profile: UserProfile, target_profile: UserProfile) -> List[str]:
        """Generate human-readable match reasons"""
        reasons = []
        
        if tech_score > 0.7:
            common_tech = set(s.lower() for s in user_profile.tech_stack) & \
                         set(s.lower() for s in target_profile.tech_stack)
            if common_tech:
                reasons.append(f"Shared expertise in {', '.join(list(common_tech)[:3])}")
        
        if bio_score > 0.8:
            reasons.append("Highly similar interests and goals")
        elif bio_score > 0.6:
            reasons.append("Similar background and interests")
            
        if github_score > 0.7:
            reasons.append("Similar GitHub activity levels")
            
        if collab_score > 0.6:
            reasons.append("Liked by developers with similar preferences")
        
        if user_profile.role != target_profile.role:
            if user_profile.role == "contributor" and target_profile.role == "maintainer":
                reasons.append("Perfect match: You're looking to contribute, they need contributors")
            else:
                reasons.append("Complementary roles for collaboration")
        
        if not reasons:
            reasons.append("Good potential for collaboration")
            
        return reasons[:3]  # Limit to top 3 reasons
    
    async def generate_recommendations(self, request: MatchRequest) -> MatchResponse:
        """Generate ML-powered user recommendations"""
        logger.info(f"🔍 Generating recommendations for user {request.user_id}")
        
        user_profile = request.user_profile
        recommendations = []
        
        # Get all potential matches (excluding self and excluded users)
        potential_matches = [
            profile for uid, profile in user_profiles.items()
            if uid != request.user_id and uid not in request.exclude_user_ids
        ]
        
        if not potential_matches:
            logger.warning(f"No potential matches found for user {request.user_id}")
            return MatchResponse(
                user_id=request.user_id,
                recommendations=[],
                generated_at=datetime.now()
            )
        
        # Calculate scores for each potential match
        for target_profile in potential_matches:
            # Calculate individual scores
            tech_score = self.calculate_tech_overlap(
                user_profile.tech_stack, target_profile.tech_stack
            )
            
            bio_score = self.calculate_bio_similarity(
                user_profile.bio or "", target_profile.bio or "",
                user_profile.id, target_profile.id
            )
            
            github_score = self.calculate_github_activity_score(
                user_profile.github_stats or {}, target_profile.github_stats or {}
            )
            
            collab_score = self.calculate_collaborative_score(
                user_profile.id, target_profile.id
            )
            
            # Calculate weighted overall score
            overall_score = (
                tech_score * 0.35 +      # Tech stack is most important
                bio_score * 0.25 +       # Bio similarity
                github_score * 0.20 +    # GitHub activity
                collab_score * 0.20      # Collaborative filtering
            )
            
            # Generate match reasons
            reasons = self.get_match_reasons(
                tech_score, bio_score, github_score, collab_score,
                user_profile, target_profile
            )
            
            recommendations.append(MatchScore(
                target_user_id=target_profile.id,
                similarity_score=bio_score,
                tech_overlap_score=tech_score,
                bio_similarity_score=bio_score,
                github_activity_score=github_score,
                collaborative_score=collab_score,
                overall_score=overall_score,
                match_reasons=reasons
            ))
        
        # Sort by overall score and take top recommendations
        recommendations.sort(key=lambda x: x.overall_score, reverse=True)
        recommendations = recommendations[:request.max_recommendations]
        
        # Generate analytics if requested
        analytics = None
        if request.include_analytics:
            analytics = {
                'total_potential_matches': len(potential_matches),
                'avg_tech_score': np.mean([r.tech_overlap_score for r in recommendations]),
                'avg_bio_score': np.mean([r.bio_similarity_score for r in recommendations]),
                'processing_time_ms': 50,  # Simulated
                'model_confidence': 'high' if len(recommendations) > 5 else 'medium'
            }
        
        logger.info(f"✅ Generated {len(recommendations)} recommendations for user {request.user_id}")
        
        return MatchResponse(
            user_id=request.user_id,
            recommendations=recommendations,
            generated_at=datetime.now(),
            analytics=analytics
        )

# Initialize matching engine
matching_engine = MatchingEngine()

# API Endpoints
@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": datetime.now(),
        "models_loaded": True,
        "version": "1.0.0"
    }

@app.post("/users/profile", response_model=Dict[str, str])
async def create_or_update_profile(profile: UserProfile):
    """Create or update user profile"""
    user_profiles[profile.id] = profile
    
    # Clear cached embeddings when profile is updated
    if profile.id in cached_embeddings:
        del cached_embeddings[profile.id]
    
    logger.info(f"📝 Updated profile for user {profile.id}")
    return {"status": "success", "user_id": profile.id}

@app.post("/recommendations", response_model=MatchResponse)
async def get_recommendations(request: MatchRequest):
    """Get ML-powered user recommendations"""
    try:
        response = await matching_engine.generate_recommendations(request)
        return response
    except Exception as e:
        logger.error(f"❌ Error generating recommendations: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to generate recommendations")

@app.post("/swipe")
async def record_swipe(swipe: SwipeHistory):
    """Record user swipe for collaborative filtering"""
    swipe_history.append(swipe)
    logger.info(f"👆 Recorded swipe: {swipe.swiper_id} -> {swipe.target_id} ({swipe.direction})")
    return {"status": "success"}

@app.get("/analytics/stats")
async def get_analytics_stats():
    """Get matching engine analytics"""
    total_users = len(user_profiles)
    total_swipes = len(swipe_history)
    right_swipes = len([s for s in swipe_history if s.direction == "right"])
    
    return {
        "total_users": total_users,
        "total_swipes": total_swipes,
        "right_swipe_rate": right_swipes / max(total_swipes, 1),
        "cached_embeddings": len(cached_embeddings),
        "model_version": "1.0.0"
    }

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

@app.get("/recommendations")
def get_recommendations(uid: str = Query(...)) -> List[str]:
    # TODO: Implement AI-powered recommendations
    return ["user1", "user2", "user3"]

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0", 
        port=8000,
        reload=True,
        log_level="info"
    )
 