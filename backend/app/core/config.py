"""
Core configuration module for GitAlong Backend.

Handles environment-based configuration with proper validation and type safety.
"""

from functools import lru_cache
from typing import Any, List, Optional

from pydantic import Field
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # Application
    APP_NAME: str = "GitAlong Backend"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = Field(default=False, env="DEBUG")
    ENVIRONMENT: str = Field(default="production", env="ENVIRONMENT")

    # API
    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "GitAlong API"

    # Security
    SECRET_KEY: str = Field(..., env="SECRET_KEY")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = Field(default=30, env="ACCESS_TOKEN_EXPIRE_MINUTES")
    REFRESH_TOKEN_EXPIRE_DAYS: int = Field(default=7, env="REFRESH_TOKEN_EXPIRE_DAYS")

    # Database (MongoDB)
    MONGODB_URI: str = Field(..., env="MONGODB_URI")
    MONGODB_DB: str = Field(default="gitalong_backend", env="MONGODB_DB")

    # Redis
    REDIS_URL: str = Field(default="redis://localhost:6379", env="REDIS_URL")

    # GitHub Integration
    GITHUB_CLIENT_ID: str = Field(..., env="GITHUB_CLIENT_ID")
    GITHUB_CLIENT_SECRET: str = Field(..., env="GITHUB_CLIENT_SECRET")
    GITHUB_CALLBACK_URL: str = Field(..., env="GITHUB_CALLBACK_URL")

    # Email
    SMTP_HOST: str = Field(default="smtp.gmail.com", env="SMTP_HOST")
    SMTP_PORT: int = Field(default=587, env="SMTP_PORT")
    SMTP_USERNAME: str = Field(..., env="SMTP_USERNAME")
    SMTP_PASSWORD: str = Field(..., env="SMTP_PASSWORD")
    SMTP_TLS: bool = Field(default=True, env="SMTP_TLS")
    SMTP_SSL: bool = Field(default=False, env="SMTP_SSL")

    # CORS
    BACKEND_CORS_ORIGINS: List[str] = Field(default=[], env="BACKEND_CORS_ORIGINS")

    # Rate Limiting
    RATE_LIMIT_PER_MINUTE: int = Field(default=60, env="RATE_LIMIT_PER_MINUTE")

    # Monitoring
    SENTRY_DSN: Optional[str] = Field(default=None, env="SENTRY_DSN")
    LOG_LEVEL: str = Field(default="INFO", env="LOG_LEVEL")

    # ML & Analytics
    ML_MODEL_PATH: str = Field(default="./models", env="ML_MODEL_PATH")
    ENABLE_ML_FEATURES: bool = Field(default=True, env="ENABLE_ML_FEATURES")

    # File Upload
    UPLOAD_DIR: str = Field(default="./uploads", env="UPLOAD_DIR")
    MAX_FILE_SIZE: int = Field(default=10 * 1024 * 1024, env="MAX_FILE_SIZE")

    @staticmethod
    def _split_csv(v: Any) -> List[str]:
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",") if i.strip()]
        return v if isinstance(v, list) else []

    class Config:
        env_file = ".env"
        case_sensitive = True


@lru_cache()
def get_settings() -> Settings:
    return Settings()


settings = get_settings()


def is_development() -> bool:
    return settings.ENVIRONMENT.lower() in ["development", "dev", "local"]


def is_production() -> bool:
    return settings.ENVIRONMENT.lower() in ["production", "prod"]


def is_testing() -> bool:
    return settings.ENVIRONMENT.lower() in ["testing", "test"]
