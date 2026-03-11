from __future__ import annotations
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field


class UserProfile(BaseModel):
    """User profile as stored in Supabase public.users table."""

    id: str
    username: str
    email: str
    name: Optional[str] = None
    bio: Optional[str] = None
    avatar_url: Optional[str] = None
    location: Optional[str] = None
    company: Optional[str] = None
    website_url: Optional[str] = None
    github_url: Optional[str] = None
    followers: int = 0
    following: int = 0
    public_repos: int = 0
    languages: list[str] = Field(default_factory=list)
    interests: list[str] = Field(default_factory=list)
    created_at: datetime
    last_active_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class UserSummary(BaseModel):
    """Lightweight user card for recommendation responses."""

    id: str
    username: str
    name: Optional[str] = None
    bio: Optional[str] = None
    avatar_url: Optional[str] = None
    location: Optional[str] = None
    public_repos: int = 0
    followers: int = 0
    languages: list[str] = Field(default_factory=list)
    interests: list[str] = Field(default_factory=list)
    match_score: Optional[float] = Field(None, description="0–100 compatibility score")
