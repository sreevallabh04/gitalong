from __future__ import annotations
from supabase import Client
from ..database import get_supabase_client


class SwipeRepository:
    """Data Access Object for the public.swipes table."""

    def __init__(self, client: Client | None = None):
        self._db: Client = client or get_supabase_client()

    def get_swiped_user_ids(self, user_id: str) -> set[str]:
        """Return all user IDs that `user_id` has already swiped on."""
        resp = (
            self._db.table("swipes")
            .select("swiped_user_id")
            .eq("swiper_id", user_id)
            .execute()
        )
        return {row["swiped_user_id"] for row in (resp.data or [])}

    def get_likers_of(self, user_id: str) -> set[str]:
        """Return all user IDs who have liked `user_id`."""
        resp = (
            self._db.table("swipes")
            .select("swiper_id")
            .eq("swiped_user_id", user_id)
            .in_("action", ["like", "superLike"])
            .execute()
        )
        return {row["swiper_id"] for row in (resp.data or [])}

    def get_all_swipes(self) -> list[dict]:
        """Return all (swiper_id, swiped_user_id, action) rows for CF matrix."""
        resp = (
            self._db.table("swipes")
            .select("swiper_id, swiped_user_id, action")
            .execute()
        )
        return resp.data or []
