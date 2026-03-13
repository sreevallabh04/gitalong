from fastapi import APIRouter, Depends, HTTPException, status

from ...core.auth import verify_token
from ...repositories.user_repository import UserRepository
from ...services.github_service import GitHubService
from ...models.user import UserProfile, UserSummary

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/me", response_model=UserProfile)
async def get_me(user_id: str = Depends(verify_token)):
    """Return the authenticated user's full profile."""
    repo = UserRepository()
    profile = repo.get_by_id(user_id)
    if profile is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found.")
    return profile


@router.get("/{user_id}", response_model=UserProfile)
async def get_user(
    user_id: str,
    _caller: str = Depends(verify_token),  # ensures caller is authenticated
):
    """Return any user's public profile."""
    repo = UserRepository()
    profile = repo.get_by_id(user_id)
    if profile is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found.")
    return profile


@router.post("/me/refresh-github", response_model=dict)
async def refresh_github_stats(user_id: str = Depends(verify_token)):
    """
    Fetch latest GitHub stats for the authenticated user
    and update their languages field in the DB.
    """
    repo = UserRepository()
    profile = repo.get_by_id(user_id)
    if profile is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found.")

    github = GitHubService()
    stats = await github.calculate_developer_score(profile.username)

    # Update languages in DB
    repo.update_languages(user_id, stats["languages"])

    return {"status": "refreshed", "stats": stats}
