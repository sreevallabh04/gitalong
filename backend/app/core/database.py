"""
MongoDB (Motor + Beanie) database initialization and teardown.
"""

from typing import Sequence

from beanie import init_beanie
from motor.motor_asyncio import AsyncIOMotorClient

from app.core.config import settings

_mongo_client: AsyncIOMotorClient | None = None


async def init_db() -> None:
    global _mongo_client
    _mongo_client = AsyncIOMotorClient(settings.MONGODB_URI)
    db = _mongo_client.get_database(settings.MONGODB_DB)

    # Import models here to register with Beanie
    from app.models import (
        User,
        Project,
        Match,
        Message,
        GitHubData,
        GitHubRepository,
        GitHubContribution,
    )

    await init_beanie(database=db, document_models=[
        User,
        Project,
        Match,
        Message,
        GitHubData,
        GitHubRepository,
        GitHubContribution,
    ])


async def close_db() -> None:
    global _mongo_client
    if _mongo_client is not None:
        _mongo_client.close()
        _mongo_client = None
