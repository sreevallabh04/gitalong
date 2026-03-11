from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    # Supabase
    supabase_url: str
    supabase_anon_key: str
    supabase_service_role_key: str

    # GitHub API
    github_token: str = ""

    # App
    app_name: str = "GitAlong API"
    app_version: str = "1.0.0"
    debug: bool = False

    # CORS - Flutter app origins
    allowed_origins: list[str] = ["*"]

    # Recommendation engine
    recommendation_limit: int = 20
    candidate_pool_multiplier: int = 5  # fetch 5x more candidates before scoring

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


@lru_cache
def get_settings() -> Settings:
    return Settings()
