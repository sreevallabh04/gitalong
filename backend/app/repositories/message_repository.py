from __future__ import annotations
from supabase import Client
from ..database import get_supabase_client


class MessageRepository:
    """Data Access Object for the public.messages table."""

    def __init__(self, client: Client | None = None):
        self._db: Client = client or get_supabase_client()

    def get_messages(
        self, match_id: str, limit: int = 50, before: str | None = None
    ) -> list[dict]:
        """Return messages for a match, newest first."""
        query = (
            self._db.table("messages")
            .select("*")
            .eq("match_id", match_id)
            .order("sent_at", desc=True)
            .limit(limit)
        )
        if before:
            query = query.lt("sent_at", before)
        return query.execute().data or []

    def send_message(
        self,
        match_id: str,
        sender_id: str,
        receiver_id: str,
        content: str,
        msg_type: str = "text",
    ) -> dict:
        """Insert a message and update the match's last_message preview."""
        from datetime import datetime, timezone

        now = datetime.now(timezone.utc).isoformat()
        data = {
            "match_id": match_id,
            "sender_id": sender_id,
            "receiver_id": receiver_id,
            "content": content,
            "type": msg_type,
            "sent_at": now,
            "is_read": False,
        }
        resp = self._db.table("messages").insert(data).execute()
        row = resp.data[0] if resp.data else {}

        # Update match preview
        self._db.table("matches").update({
            "last_message": content,
            "last_message_at": now,
            "is_read": False,
        }).eq("id", match_id).execute()

        return row

    def mark_as_read(self, match_id: str, reader_id: str) -> int:
        """Mark all unread messages in a match as read for the reader."""
        resp = (
            self._db.table("messages")
            .update({"is_read": True})
            .eq("match_id", match_id)
            .eq("receiver_id", reader_id)
            .eq("is_read", False)
            .execute()
        )
        return len(resp.data) if resp.data else 0
