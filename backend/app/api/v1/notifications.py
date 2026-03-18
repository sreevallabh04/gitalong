"""
Notifications API
==================
POST /api/v1/notify-match — Create a new-match notification for a user.
"""
import logging
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel

from ...core.auth import verify_token
from ...database import get_supabase_client

logger = logging.getLogger(__name__)
router = APIRouter(tags=["notifications"])


class NotifyMatchRequest(BaseModel):
    match_id: str
    notify_user_id: str
    matcher_name: str


@router.post("/notify-match", status_code=status.HTTP_201_CREATED)
async def notify_new_match(
    body: NotifyMatchRequest,
    user_id: str = Depends(verify_token),
):
    """
    Insert a notification row so the other user gets a realtime 'new_match' event.
    The Flutter app's NotificationsListener picks this up via Supabase Realtime.
    """
    if body.notify_user_id == user_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot notify yourself.",
        )

    db = get_supabase_client()
    try:
        db.table("notifications").insert({
            "user_id": body.notify_user_id,
            "type": "new_match",
            "payload": {
                "match_id": body.match_id,
                "from_user_id": user_id,
                "from_user_name": body.matcher_name,
            },
        }).execute()
    except Exception as exc:
        logger.warning("Failed to insert notification: %s", exc)
        # Non-fatal — don't break the match flow
        return {"status": "skipped", "reason": str(exc)}

    return {"status": "notified", "notify_user_id": body.notify_user_id}
