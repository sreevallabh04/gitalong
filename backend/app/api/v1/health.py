import logging
from fastapi import APIRouter

logger = logging.getLogger(__name__)
router = APIRouter()


@router.get("/health", tags=["health"])
async def health_check():
    result = {"status": "ok", "service": "GitAlong API", "database": "unknown"}

    try:
        from ...database import get_supabase_client
        client = get_supabase_client()
        resp = client.table("users").select("id").limit(1).execute()
        result["database"] = "connected"
        result["user_count_sample"] = len(resp.data) if resp.data else 0
    except Exception as exc:
        logger.exception("Health check DB probe failed")
        result["database"] = f"error: {type(exc).__name__}: {exc}"

    return result
