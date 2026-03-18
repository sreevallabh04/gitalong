"""
Swipes API
==========
POST /api/v1/swipes          — Record a swipe (like / dislike / superLike)
                                Automatically creates a match if mutual.
GET  /api/v1/swipes/history  — Return the authenticated user's swipe history.
"""
import logging
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel

from ...core.auth import verify_token
from ...repositories.swipe_repository import SwipeRepository
from ...repositories.match_repository import MatchRepository

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/swipes", tags=["swipes"])


class SwipeRequest(BaseModel):
    swiped_user_id: str
    action: str  # "like" | "dislike" | "superLike"


class SwipeResponse(BaseModel):
    status: str
    matched: bool = False
    match_id: str | None = None


class SwipeHistoryItem(BaseModel):
    id: str
    swiped_user_id: str
    action: str
    swiped_at: str


@router.post("", response_model=SwipeResponse, status_code=status.HTTP_201_CREATED)
async def record_swipe(
    body: SwipeRequest,
    user_id: str = Depends(verify_token),
):
    """
    Record a swipe action.

    If the action is `like` or `superLike` AND the other user has already
    liked the caller, a match is automatically created and returned.
    """
    if body.action not in ("like", "dislike", "superLike"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid action '{body.action}'. Must be 'like', 'dislike', or 'superLike'.",
        )

    if body.swiped_user_id == user_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot swipe on yourself.",
        )

    swipe_repo = SwipeRepository()
    match_repo = MatchRepository()

    # Upsert swipe (insert or update if already exists)
    try:
        swipe_repo.record_swipe(user_id, body.swiped_user_id, body.action)
    except Exception as exc:
        logger.warning("Swipe insert error (likely duplicate): %s", exc)
        # If unique constraint violation, update instead
        swipe_repo.update_swipe(user_id, body.swiped_user_id, body.action)

    # Check for mutual like → create match
    matched = False
    match_id = None

    if body.action in ("like", "superLike"):
        likers = swipe_repo.get_likers_of(user_id)
        if body.swiped_user_id in likers:
            # Check if match already exists
            existing = match_repo.check_existing_match(user_id, body.swiped_user_id)
            if existing is None:
                new_match = match_repo.create_match(user_id, body.swiped_user_id)
                match_id = new_match.get("id")
                matched = True
                logger.info(
                    "Match created between %s and %s (match_id=%s)",
                    user_id, body.swiped_user_id, match_id,
                )
            else:
                match_id = str(existing["id"])
                matched = True

    return SwipeResponse(status="ok", matched=matched, match_id=match_id)


@router.get("/history", response_model=list[SwipeHistoryItem])
async def get_swipe_history(
    limit: int = Query(default=50, ge=1, le=200),
    user_id: str = Depends(verify_token),
):
    """Return the authenticated user's recent swipe history."""
    swipe_repo = SwipeRepository()
    rows = swipe_repo.get_swipe_history(user_id, limit)
    return [
        SwipeHistoryItem(
            id=str(row["id"]),
            swiped_user_id=row["swiped_user_id"],
            action=row["action"],
            swiped_at=str(row["swiped_at"]),
        )
        for row in rows
    ]
