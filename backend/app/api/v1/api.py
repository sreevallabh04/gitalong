"""
Main API router for v1 endpoints.

Combines all API routers into a single router for the v1 API.
"""

from fastapi import APIRouter

from app.api.v1.endpoints import auth, users, projects, matches, messages, github, analytics

api_router = APIRouter()

# Include all endpoint routers
api_router.include_router(auth.router, prefix="/auth", tags=["authentication"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(projects.router, prefix="/projects", tags=["projects"])
api_router.include_router(matches.router, prefix="/matches", tags=["matches"])
api_router.include_router(messages.router, prefix="/messages", tags=["messages"])
api_router.include_router(github.router, prefix="/github", tags=["github"])
api_router.include_router(analytics.router, prefix="/analytics", tags=["analytics"])
