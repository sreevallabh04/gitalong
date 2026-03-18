from fastapi import APIRouter, Depends, HTTPException, status
import logging

from ...core.auth import verify_token
from ...repositories.user_repository import UserRepository
from ...services.github_service import GitHubService
from ...models.user import UserProfile, UserSummary
from ...database import get_supabase_client

logger = logging.getLogger(__name__)
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


@router.delete("/me", status_code=status.HTTP_200_OK)
async def delete_account(user_id: str = Depends(verify_token)):
    """
    Fully delete the authenticated user's account:
      1. Delete notifications
      2. Delete messages (sent + received)
      3. Delete matches containing this user
      4. Delete swipes (given + received)
      5. Delete github_cache row
      6. Delete public.users row
      7. Delete auth.users row via admin API
    """
    db = get_supabase_client()  # service-role client

    try:
        # 1. Notifications
        db.table("notifications").delete().eq("user_id", user_id).execute()

        # 2. Messages (sender or receiver)
        db.table("messages").delete().or_(
            f"sender_id.eq.{user_id},receiver_id.eq.{user_id}"
        ).execute()

        # 3. Matches — uses UUID[] column, need to find matches containing user
        matches_resp = db.table("matches").select("id").contains("users", [user_id]).execute()
        match_ids = [row["id"] for row in (matches_resp.data or [])]
        if match_ids:
            db.table("matches").delete().in_("id", match_ids).execute()

        # 4. Swipes (as swiper or as target)
        db.table("swipes").delete().or_(
            f"swiper_id.eq.{user_id},swiped_user_id.eq.{user_id}"
        ).execute()

        # 5. GitHub cache
        db.table("github_cache").delete().eq("id", user_id).execute()

        # 6. Public users row
        db.table("users").delete().eq("id", user_id).execute()

        # 7. Auth user (admin API via service role)
        db.auth.admin.delete_user(user_id)

        logger.info("Account fully deleted for user %s", user_id)
        return {"status": "deleted", "user_id": user_id}

    except Exception as exc:
        logger.exception("Error during account deletion for user %s", user_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Account deletion failed: {type(exc).__name__}: {exc}",
        )

