"""
User document for MongoDB (Beanie).
"""

from typing import List, Optional
from beanie import Document
from pydantic import BaseModel, Field


class User(Document):
    email: str
    username: str
    hashed_password: Optional[str] = None
    is_active: bool = True
    is_verified: bool = False
    is_premium: bool = False

    first_name: Optional[str] = None
    last_name: Optional[str] = None
    bio: Optional[str] = None
    avatar_url: Optional[str] = None
    location: Optional[str] = None
    website: Optional[str] = None

    github_username: Optional[str] = None
    github_access_token: Optional[str] = None
    github_id: Optional[int] = None

    skills: List[str] = Field(default_factory=list)
    interests: List[str] = Field(default_factory=list)
    preferred_languages: List[str] = Field(default_factory=list)
    experience_level: Optional[str] = None

    looking_for: Optional[str] = None
    availability: Optional[str] = None
    remote_preference: Optional[str] = None

    email_notifications: bool = True
    push_notifications: bool = True
    profile_visibility: str = "public"

    class Settings:
        name = "users"
        indexes = ["email", "username", "github_username"]

    @property
    def full_name(self) -> str:
        if self.first_name and self.last_name:
            return f"{self.first_name} {self.last_name}"
        return self.first_name or self.username

    @property
    def is_github_connected(self) -> bool:
        return bool(self.github_username and self.github_access_token)

    @property
    def profile_completion_percentage(self) -> int:
        fields = [
            self.email, self.username, self.first_name, self.last_name,
            self.bio, self.location, self.skills, self.interests,
            self.github_username
        ]
        total = len(fields)
        completed = sum(1 for f in fields if f)
        return int((completed / total) * 100)
