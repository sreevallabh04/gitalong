from __future__ import annotations
from supabase import Client
from ..database import get_supabase_client


class MatchRepository:
    """Data Access Object for the public.matches table."""

    def __init__(self, client: Client | None = None):
        self._db: Client = client or get_supabase_client()

    def get_matches_for_user(self, user_id: str, limit: int = 50, before: str | None = None) -> list[dict]:
        """Return matches that include `user_id`, optionally paginated via cursor."""
        query = (
            self._db.table("matches")
            .select("*")
            .contains("users", [user_id])
            .order("matched_at", desc=True)
        )
        if before:
            query = query.lt("matched_at", before)
        resp = query.limit(limit).execute()
        return resp.data or []

    def get_match_by_id(self, match_id: str) -> dict | None:
        resp = (
            self._db.table("matches")
            .select("*")
            .eq("id", match_id)
            .maybe_single()
            .execute()
        )
        return resp.data

    def create_match(self, user_id_a: str, user_id_b: str) -> dict:
        """Create a new match between two users. Returns the created row."""
        data = {
            "users": [user_id_a, user_id_b],
        }
        resp = (
            self._db.table("matches")
            .insert(data)
            .execute()
        )
        return resp.data[0] if resp.data else {}

    def check_existing_match(self, user_a: str, user_b: str) -> dict | None:
        """Check if a match already exists between two users."""
        resp = (
            self._db.table("matches")
            .select("*")
            .contains("users", [user_a])
            .contains("users", [user_b])
            .maybe_single()
            .execute()
        )
        return resp.data

    def delete_match(self, match_id: str) -> None:
        self._db.table("matches").delete().eq("id", match_id).execute()
