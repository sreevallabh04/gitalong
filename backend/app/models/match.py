"""
Match document for MongoDB (Beanie).
"""

from typing import Optional
from beanie import Document, Link
from pydantic import BaseModel

from app.models.user import User
from app.models.project import Project


class Match(Document):
    user: Link[User]
    matched_user: Link[User]

    match_type: str
    status: str = "pending"
    match_score: Optional[float] = None

    user_liked: bool = False
    matched_user_liked: bool = False
    user_super_liked: bool = False
    matched_user_super_liked: bool = False

    common_skills: Optional[str] = None
    common_interests: Optional[str] = None
    common_languages: Optional[str] = None
    match_reason: Optional[str] = None

    project: Optional[Link[Project]] = None

    conversation_started: bool = False
    messages_count: int = 0

    class Settings:
        name = "matches"
        indexes = ["user", "matched_user"]

    @property
    def is_mutual_match(self) -> bool:
        return self.user_liked and self.matched_user_liked

    @property
    def is_super_match(self) -> bool:
        return self.user_super_liked or self.matched_user_super_liked
