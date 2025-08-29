"""
Project document for MongoDB (Beanie).
"""

from typing import List, Optional
from beanie import Document, Link
from pydantic import Field

from app.models.user import User


class Project(Document):
    title: str
    description: Optional[str] = None
    short_description: Optional[str] = None

    project_type: str
    status: str = "active"
    visibility: str = "public"

    github_url: Optional[str] = None
    github_repo_id: Optional[int] = None
    github_stars: int = 0
    github_forks: int = 0
    github_language: Optional[str] = None

    technologies: List[str] = Field(default_factory=list)
    languages: List[str] = Field(default_factory=list)
    frameworks: List[str] = Field(default_factory=list)
    databases: List[str] = Field(default_factory=list)

    team_size: int = 1
    max_team_size: Optional[int] = None
    is_recruiting: bool = False
    required_skills: List[str] = Field(default_factory=list)
    preferred_skills: List[str] = Field(default_factory=list)

    owner: Link[User]

    class Settings:
        name = "projects"
        indexes = ["owner"]
