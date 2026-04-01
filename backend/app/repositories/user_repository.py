from __future__ import annotations
from typing import Optional
from supabase import Client

from ..models.user import UserProfile
from ..database import get_supabase_client


class UserRepository:
    """
    Data Access Object for the public.users table.
    All DB calls go through here — no raw Supabase calls in services.
    """

    def __init__(self, client: Client | None = None):
        self._db: Client = client or get_supabase_client()

    def get_by_id(self, user_id: str) -> Optional[UserProfile]:
        resp = (
            self._db.table("users")
            .select("*")
            .eq("id", user_id)
            .maybe_single()
            .execute()
        )
        if resp.data is None:
            return None
        return UserProfile(**resp.data)

    def get_candidates(
        self,
        exclude_ids: list[str],
        limit: int = 100,
    ) -> list[UserProfile]:
        """Fetch candidate users with at least 1 public repo."""
        # Supabase Python SDK: use not_.in_()
        query = self._db.table("users").select("*").gt("public_repos", 0)
        if exclude_ids:
            query = query.not_.in_("id", exclude_ids)
        resp = query.limit(limit).execute()
        return [UserProfile(**row) for row in (resp.data or [])]

    def bulk_get_by_ids(self, user_ids: list[str]) -> list[UserProfile]:
        if not user_ids:
            return []
        resp = (
            self._db.table("users")
            .select("*")
            .in_("id", user_ids)
            .execute()
        )
        return [UserProfile(**row) for row in (resp.data or [])]

    def update_languages(self, user_id: str, languages: list[str]) -> None:
        self._db.table("users").update({"languages": languages}).eq("id", user_id).execute()
