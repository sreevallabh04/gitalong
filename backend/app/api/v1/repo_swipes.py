"""
Repo swipes API
===============
POST /api/v1/repo-swipes         — Record save/skip on a repository.
GET  /api/v1/repo-swipes/history — Return authenticated user's repo swipe history.
"""

from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel

from ...core.auth import verify_token
from ...repositories.repo_swipe_repository import RepoSwipeRepository

router = APIRouter(prefix="/repo-swipes", tags=["repo-swipes"])


class RepoSwipeRequest(BaseModel):
    repo_id: int
    action: str  # "save" | "skip"
    repo_full_name: str
    repo_name: str
    repo_owner: str
    repo_url: str
    repo_description: str | None = None
    repo_language: str | None = None
    repo_stars: int = 0
    repo_forks: int = 0


class RepoSwipeResponse(BaseModel):
    status: str


class RepoSwipeHistoryItem(BaseModel):
    id: str
    repo_id: int
    action: str
    repo_full_name: str
    repo_name: str
    repo_owner: str
    repo_url: str
    repo_description: str | None = None
    repo_language: str | None = None
    repo_stars: int = 0
    repo_forks: int = 0
    swiped_at: str


@router.post("", response_model=RepoSwipeResponse, status_code=status.HTTP_201_CREATED)
async def record_repo_swipe(
    body: RepoSwipeRequest,
    user_id: str = Depends(verify_token),
):
    if body.action not in ("save", "skip"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid action '{body.action}'. Must be 'save' or 'skip'.",
        )

    repo = RepoSwipeRepository()
    repo.record_repo_swipe(
        user_id=user_id,
        repo_id=body.repo_id,
        action=body.action,
        repo_full_name=body.repo_full_name,
        repo_name=body.repo_name,
        repo_owner=body.repo_owner,
        repo_url=body.repo_url,
        repo_description=body.repo_description,
        repo_language=body.repo_language,
        repo_stars=body.repo_stars,
        repo_forks=body.repo_forks,
    )
    return RepoSwipeResponse(status="ok")


@router.get("/history", response_model=list[RepoSwipeHistoryItem])
async def get_repo_swipe_history(
    limit: int = Query(default=200, ge=1, le=1000),
    action: str | None = Query(default=None),
    user_id: str = Depends(verify_token),
):
    if action is not None and action not in ("save", "skip"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid action filter '{action}'. Must be 'save' or 'skip'.",
        )

    repo = RepoSwipeRepository()
    rows = repo.get_repo_swipe_history(user_id=user_id, limit=limit, action=action)
    return [
        RepoSwipeHistoryItem(
            id=str(row["id"]),
            repo_id=int(row["repo_id"]),
            action=row["action"],
            repo_full_name=row["repo_full_name"],
            repo_name=row["repo_name"],
            repo_owner=row["repo_owner"],
            repo_url=row["repo_url"],
            repo_description=row.get("repo_description"),
            repo_language=row.get("repo_language"),
            repo_stars=int(row.get("repo_stars") or 0),
            repo_forks=int(row.get("repo_forks") or 0),
            swiped_at=str(row["swiped_at"]),
        )
        for row in rows
    ]

