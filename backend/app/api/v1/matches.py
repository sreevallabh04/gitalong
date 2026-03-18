"""
Matches API
===========
GET    /api/v1/matches           — List the authenticated user's matches.
GET    /api/v1/matches/{id}      — Get a single match by ID.
DELETE /api/v1/matches/{id}      — Unmatch (delete a match).
"""
import logging
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel

from ...core.auth import verify_token
from ...repositories.match_repository import MatchRepository
from ...repositories.user_repository import UserRepository
from ...models.user import UserSummary

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/matches", tags=["matches"])


class MatchUserSummary(BaseModel):
    id: str
    username: str
    name: str | None = None
    avatar_url: str | None = None
    bio: str | None = None
    languages: list[str] = []


class MatchResponse(BaseModel):
    id: str
    other_user: MatchUserSummary
    matched_at: str
    last_message: str | None = None
    last_message_at: str | None = None
    is_read: bool = True


class MatchListResponse(BaseModel):
    matches: list[MatchResponse]
    count: int
    next_cursor: str | None = None
    has_more: bool = False


@router.get("", response_model=MatchListResponse)
async def list_matches(
    limit: int = Query(default=50, ge=1, le=200),
    before: str | None = Query(default=None, description="ISO timestamp cursor for pagination"),
    user_id: str = Depends(verify_token),
):
    """Return matches for the authenticated user with cursor pagination."""
    match_repo = MatchRepository()
    user_repo = UserRepository()

    # Fetch one extra to detect if there are more
    rows = match_repo.get_matches_for_user(user_id, limit + 1, before=before)
    has_more = len(rows) > limit
    rows = rows[:limit]
    matches = []

    for row in rows:
        users_list = row.get("users", [])
        other_id = next((uid for uid in users_list if uid != user_id), None)
        if other_id is None:
            continue

        other_user = user_repo.get_by_id(other_id)
        if other_user is None:
            continue

        matches.append(MatchResponse(
            id=str(row["id"]),
            other_user=MatchUserSummary(
                id=other_user.id,
                username=other_user.username,
                name=other_user.name,
                avatar_url=other_user.avatar_url,
                bio=other_user.bio,
                languages=other_user.languages or [],
            ),
            matched_at=str(row["matched_at"]),
            last_message=row.get("last_message"),
            last_message_at=str(row["last_message_at"]) if row.get("last_message_at") else None,
            is_read=row.get("is_read", True),
        ))

    next_cursor = matches[-1].matched_at if has_more and matches else None

    return MatchListResponse(
        matches=matches,
        count=len(matches),
        next_cursor=next_cursor,
        has_more=has_more,
    )


@router.get("/{match_id}", response_model=MatchResponse)
async def get_match(
    match_id: str,
    user_id: str = Depends(verify_token),
):
    """Return a specific match by ID."""
    match_repo = MatchRepository()
    user_repo = UserRepository()

    row = match_repo.get_match_by_id(match_id)
    if row is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Match not found.")

    users_list = row.get("users", [])
    if user_id not in users_list:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not part of this match.")

    other_id = next((uid for uid in users_list if uid != user_id), None)
    other_user = user_repo.get_by_id(other_id) if other_id else None

    if other_user is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Matched user not found.")

    return MatchResponse(
        id=str(row["id"]),
        other_user=MatchUserSummary(
            id=other_user.id,
            username=other_user.username,
            name=other_user.name,
            avatar_url=other_user.avatar_url,
            bio=other_user.bio,
            languages=other_user.languages or [],
        ),
        matched_at=str(row["matched_at"]),
        last_message=row.get("last_message"),
        last_message_at=str(row["last_message_at"]) if row.get("last_message_at") else None,
        is_read=row.get("is_read", True),
    )


@router.delete("/{match_id}", status_code=status.HTTP_204_NO_CONTENT)
async def unmatch(
    match_id: str,
    user_id: str = Depends(verify_token),
):
    """Delete a match (unmatch)."""
    match_repo = MatchRepository()
    row = match_repo.get_match_by_id(match_id)

    if row is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Match not found.")

    users_list = row.get("users", [])
    if user_id not in users_list:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not part of this match.")

    match_repo.delete_match(match_id)
    logger.info("Match %s deleted by user %s", match_id, user_id)
