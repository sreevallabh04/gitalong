from __future__ import annotations

from supabase import Client

from ..database import get_supabase_client


class RepoSwipeRepository:
    """DAO for the public.repo_swipes table."""

    def __init__(self, client: Client | None = None):
        self._db: Client = client or get_supabase_client()

    def record_repo_swipe(
        self,
        *,
        user_id: str,
        repo_id: int,
        action: str,
        repo_full_name: str,
        repo_name: str,
        repo_owner: str,
        repo_url: str,
        repo_description: str | None = None,
        repo_language: str | None = None,
        repo_stars: int = 0,
        repo_forks: int = 0,
    ) -> dict:
        payload = {
            "user_id": user_id,
            "repo_id": repo_id,
            "action": action,
            "repo_full_name": repo_full_name,
            "repo_name": repo_name,
            "repo_owner": repo_owner,
            "repo_url": repo_url,
            "repo_description": repo_description,
            "repo_language": repo_language,
            "repo_stars": repo_stars,
            "repo_forks": repo_forks,
        }
        resp = (
            self._db.table("repo_swipes")
            .upsert(payload, on_conflict="user_id,repo_id")
            .execute()
        )
        return resp.data[0] if resp and resp.data else payload

    def get_repo_swipe_history(
        self,
        *,
        user_id: str,
        limit: int = 200,
        action: str | None = None,
    ) -> list[dict]:
        query = (
            self._db.table("repo_swipes")
            .select(
                "id, repo_id, action, repo_full_name, repo_name, repo_owner, repo_url, "
                "repo_description, repo_language, repo_stars, repo_forks, swiped_at"
            )
            .eq("user_id", user_id)
            .order("swiped_at", desc=True)
            .limit(limit)
        )
        if action:
            query = query.eq("action", action)
        resp = query.execute()
        return resp.data or []

