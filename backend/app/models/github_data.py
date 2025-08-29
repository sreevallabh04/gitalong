"""
GitHub data models for GitAlong platform.

Defines models for storing comprehensive GitHub user data, repositories, and contributions.
"""

from datetime import datetime
from typing import List, Optional

from sqlalchemy import Boolean, Column, DateTime, Integer, String, Text, JSON, ForeignKey, Float
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base


class GitHubData(Base):
    """GitHub data model for storing comprehensive user GitHub information."""
    
    __tablename__ = "github_data"
    
    # Primary key
    id = Column(Integer, primary_key=True, index=True)
    
    # User relationship
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, unique=True)
    
    # GitHub user information
    github_id = Column(Integer, unique=True, nullable=False)
    github_username = Column(String(100), nullable=False)
    github_name = Column(String(200), nullable=True)
    github_email = Column(String(255), nullable=True)
    github_bio = Column(Text, nullable=True)
    github_location = Column(String(200), nullable=True)
    github_company = Column(String(200), nullable=True)
    github_blog = Column(String(500), nullable=True)
    github_twitter_username = Column(String(100), nullable=True)
    github_avatar_url = Column(String(500), nullable=True)
    github_html_url = Column(String(500), nullable=True)
    
    # GitHub statistics
    public_repos_count = Column(Integer, default=0)
    public_gists_count = Column(Integer, default=0)
    followers_count = Column(Integer, default=0)
    following_count = Column(Integer, default=0)
    
    # GitHub account details
    github_created_at = Column(DateTime(timezone=True), nullable=True)
    github_updated_at = Column(DateTime(timezone=True), nullable=True)
    github_site_admin = Column(Boolean, default=False)
    github_hireable = Column(Boolean, default=False)
    
    # GitHub activity
    total_commits = Column(Integer, default=0)
    total_stars_received = Column(Integer, default=0)
    total_forks_received = Column(Integer, default=0)
    total_issues_created = Column(Integer, default=0)
    total_pull_requests = Column(Integer, default=0)
    
    # Top languages and technologies
    top_languages = Column(JSON, default=list)  # List of language objects with name and bytes
    top_technologies = Column(JSON, default=list)  # List of technology strings
    
    # Contribution data
    contribution_graph = Column(JSON, default=dict)  # Contribution graph data
    contribution_streak = Column(Integer, default=0)  # Current contribution streak
    longest_streak = Column(Integer, default=0)  # Longest contribution streak
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    last_synced_at = Column(DateTime(timezone=True), nullable=True)
    
    # Relationships
    user = relationship("User", back_populates="github_data")
    repositories = relationship("GitHubRepository", back_populates="github_data", cascade="all, delete-orphan")
    contributions = relationship("GitHubContribution", back_populates="github_data", cascade="all, delete-orphan")
    
    def __repr__(self) -> str:
        return f"<GitHubData(id={self.id}, github_username='{self.github_username}', user_id={self.user_id})>"
    
    @property
    def github_profile_url(self) -> str:
        """Get GitHub profile URL."""
        return f"https://github.com/{self.github_username}"
    
    @property
    def is_active_contributor(self) -> bool:
        """Check if user is an active contributor."""
        return self.contribution_streak > 0
    
    @property
    def github_score(self) -> float:
        """Calculate GitHub activity score."""
        score = 0.0
        
        # Base score from followers and repos
        score += min(self.followers_count * 0.1, 50)  # Max 50 points for followers
        score += min(self.public_repos_count * 0.5, 25)  # Max 25 points for repos
        
        # Activity score
        score += min(self.total_commits * 0.01, 15)  # Max 15 points for commits
        score += min(self.total_stars_received * 0.1, 10)  # Max 10 points for stars
        
        # Contribution streak bonus
        score += min(self.contribution_streak * 0.5, 10)  # Max 10 points for streak
        
        return min(score, 100.0)
    
    def to_dict(self) -> dict:
        """Convert GitHub data to dictionary."""
        return {
            "id": self.id,
            "user_id": self.user_id,
            "github_id": self.github_id,
            "github_username": self.github_username,
            "github_name": self.github_name,
            "github_email": self.github_email,
            "github_bio": self.github_bio,
            "github_location": self.github_location,
            "github_company": self.github_company,
            "github_blog": self.github_blog,
            "github_twitter_username": self.github_twitter_username,
            "github_avatar_url": self.github_avatar_url,
            "github_html_url": self.github_html_url,
            "public_repos_count": self.public_repos_count,
            "public_gists_count": self.public_gists_count,
            "followers_count": self.followers_count,
            "following_count": self.following_count,
            "github_created_at": self.github_created_at.isoformat() if self.github_created_at else None,
            "github_updated_at": self.github_updated_at.isoformat() if self.github_updated_at else None,
            "github_site_admin": self.github_site_admin,
            "github_hireable": self.github_hireable,
            "total_commits": self.total_commits,
            "total_stars_received": self.total_stars_received,
            "total_forks_received": self.total_forks_received,
            "total_issues_created": self.total_issues_created,
            "total_pull_requests": self.total_pull_requests,
            "top_languages": self.top_languages or [],
            "top_technologies": self.top_technologies or [],
            "contribution_graph": self.contribution_graph or {},
            "contribution_streak": self.contribution_streak,
            "longest_streak": self.longest_streak,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
            "last_synced_at": self.last_synced_at.isoformat() if self.last_synced_at else None,
            "github_profile_url": self.github_profile_url,
            "is_active_contributor": self.is_active_contributor,
            "github_score": self.github_score,
        }


class GitHubRepository(Base):
    """GitHub repository model for storing detailed repository information."""
    
    __tablename__ = "github_repositories"
    
    # Primary key
    id = Column(Integer, primary_key=True, index=True)
    
    # GitHub repository information
    github_repo_id = Column(Integer, unique=True, nullable=False)
    name = Column(String(200), nullable=False)
    full_name = Column(String(300), nullable=False)
    description = Column(Text, nullable=True)
    homepage = Column(String(500), nullable=True)
    language = Column(String(100), nullable=True)
    default_branch = Column(String(100), default="main")
    
    # Repository statistics
    stars_count = Column(Integer, default=0)
    forks_count = Column(Integer, default=0)
    watchers_count = Column(Integer, default=0)
    open_issues_count = Column(Integer, default=0)
    size = Column(Integer, default=0)  # Size in KB
    
    # Repository details
    is_private = Column(Boolean, default=False)
    is_fork = Column(Boolean, default=False)
    is_archived = Column(Boolean, default=False)
    is_disabled = Column(Boolean, default=False)
    has_wiki = Column(Boolean, default=False)
    has_pages = Column(Boolean, default=False)
    has_downloads = Column(Boolean, default=False)
    has_issues = Column(Boolean, default=True)
    
    # Repository URLs
    html_url = Column(String(500), nullable=False)
    clone_url = Column(String(500), nullable=True)
    ssh_url = Column(String(500), nullable=True)
    git_url = Column(String(500), nullable=True)
    svn_url = Column(String(500), nullable=True)
    
    # Repository dates
    github_created_at = Column(DateTime(timezone=True), nullable=True)
    github_updated_at = Column(DateTime(timezone=True), nullable=True)
    github_pushed_at = Column(DateTime(timezone=True), nullable=True)
    
    # Repository topics and metadata
    topics = Column(JSON, default=list)  # List of topic strings
    license_info = Column(JSON, nullable=True)  # License information
    permissions = Column(JSON, nullable=True)  # User permissions
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Foreign keys
    github_data_id = Column(Integer, ForeignKey("github_data.id"), nullable=False)
    
    # Relationships
    github_data = relationship("GitHubData", back_populates="repositories")
    
    def __repr__(self) -> str:
        return f"<GitHubRepository(id={self.id}, name='{self.name}', full_name='{self.full_name}')>"
    
    @property
    def is_popular(self) -> bool:
        """Check if repository is popular."""
        return self.stars_count >= 100 or self.forks_count >= 50
    
    @property
    def is_active(self) -> bool:
        """Check if repository is active."""
        return not (self.is_archived or self.is_disabled)
    
    @property
    def repository_score(self) -> float:
        """Calculate repository popularity score."""
        score = 0.0
        
        # Stars and forks
        score += min(self.stars_count * 0.1, 30)  # Max 30 points for stars
        score += min(self.forks_count * 0.2, 20)  # Max 20 points for forks
        
        # Activity bonus
        if self.is_active:
            score += 10
        
        # Size bonus (indicates substantial codebase)
        score += min(self.size * 0.001, 10)  # Max 10 points for size
        
        return min(score, 100.0)
    
    def to_dict(self) -> dict:
        """Convert repository to dictionary."""
        return {
            "id": self.id,
            "github_repo_id": self.github_repo_id,
            "name": self.name,
            "full_name": self.full_name,
            "description": self.description,
            "homepage": self.homepage,
            "language": self.language,
            "default_branch": self.default_branch,
            "stars_count": self.stars_count,
            "forks_count": self.forks_count,
            "watchers_count": self.watchers_count,
            "open_issues_count": self.open_issues_count,
            "size": self.size,
            "is_private": self.is_private,
            "is_fork": self.is_fork,
            "is_archived": self.is_archived,
            "is_disabled": self.is_disabled,
            "has_wiki": self.has_wiki,
            "has_pages": self.has_pages,
            "has_downloads": self.has_downloads,
            "has_issues": self.has_issues,
            "html_url": self.html_url,
            "clone_url": self.clone_url,
            "ssh_url": self.ssh_url,
            "git_url": self.git_url,
            "svn_url": self.svn_url,
            "github_created_at": self.github_created_at.isoformat() if self.github_created_at else None,
            "github_updated_at": self.github_updated_at.isoformat() if self.github_updated_at else None,
            "github_pushed_at": self.github_pushed_at.isoformat() if self.github_pushed_at else None,
            "topics": self.topics or [],
            "license_info": self.license_info,
            "permissions": self.permissions,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
            "github_data_id": self.github_data_id,
            "is_popular": self.is_popular,
            "is_active": self.is_active,
            "repository_score": self.repository_score,
        }


class GitHubContribution(Base):
    """GitHub contribution model for storing contribution data."""
    
    __tablename__ = "github_contributions"
    
    # Primary key
    id = Column(Integer, primary_key=True, index=True)
    
    # Contribution information
    date = Column(DateTime(timezone=True), nullable=False)
    contribution_count = Column(Integer, default=0)
    contribution_type = Column(String(50), nullable=False)  # commits, issues, prs, reviews
    
    # Repository context
    repository_name = Column(String(300), nullable=True)
    repository_url = Column(String(500), nullable=True)
    
    # Contribution details
    commit_messages = Column(JSON, default=list)  # List of commit messages
    issue_titles = Column(JSON, default=list)  # List of issue titles
    pr_titles = Column(JSON, default=list)  # List of PR titles
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Foreign keys
    github_data_id = Column(Integer, ForeignKey("github_data.id"), nullable=False)
    
    # Relationships
    github_data = relationship("GitHubData", back_populates="contributions")
    
    def __repr__(self) -> str:
        return f"<GitHubContribution(id={self.id}, date='{self.date}', contribution_count={self.contribution_count})>"
    
    @property
    def is_significant_contribution(self) -> bool:
        """Check if contribution is significant."""
        return self.contribution_count >= 5
    
    @property
    def contribution_level(self) -> str:
        """Get contribution level."""
        if self.contribution_count == 0:
            return "none"
        elif self.contribution_count <= 3:
            return "low"
        elif self.contribution_count <= 7:
            return "medium"
        elif self.contribution_count <= 15:
            return "high"
        else:
            return "very_high"
    
    def to_dict(self) -> dict:
        """Convert contribution to dictionary."""
        return {
            "id": self.id,
            "date": self.date.isoformat() if self.date else None,
            "contribution_count": self.contribution_count,
            "contribution_type": self.contribution_type,
            "repository_name": self.repository_name,
            "repository_url": self.repository_url,
            "commit_messages": self.commit_messages or [],
            "issue_titles": self.issue_titles or [],
            "pr_titles": self.pr_titles or [],
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
            "github_data_id": self.github_data_id,
            "is_significant_contribution": self.is_significant_contribution,
            "contribution_level": self.contribution_level,
        }
