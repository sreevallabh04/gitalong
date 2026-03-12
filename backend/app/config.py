from pydantic_settings import BaseSettings
from pydantic import field_validator
from functools import lru_cache
from typing import List, Union


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
    allowed_origins: Union[str, List[str]] = ["*"]

    @field_validator("allowed_origins", mode="before")
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> List[str]:
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",") if i.strip()]
        return v

    # Recommendation engine
    recommendation_limit: int = 20
    candidate_pool_multiplier: int = 5  # fetch 5x more candidates before scoring

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


@lru_cache
def get_settings() -> Settings:
    return Settings()
