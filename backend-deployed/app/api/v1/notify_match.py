"""
POST /api/v1/notify-match: notify the other user when a match is created.
Backend inserts a row into public.notifications so the other user sees "You matched with X!" in-app.
"""
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel

from ...core.auth import verify_token
from ...database import get_supabase_client

router = APIRouter(prefix="/notify-match", tags=["notify-match"])


class NotifyMatchBody(BaseModel):
    match_id: str
    notify_user_id: str
    matcher_name: str


@router.post("", status_code=status.HTTP_204_NO_CONTENT)
async def notify_match(
    body: NotifyMatchBody,
    caller_id: str = Depends(verify_token),
):
    """
    Called by the app after a match is created in Supabase.
    Inserts a notification for the other user so they see "You matched with {matcher_name}!" in-app.
    """
    supabase = get_supabase_client()

    # Optional: validate that the match exists and involves both users
    match_row = (
        supabase.table("matches")
        .select("id, users")
        .eq("id", body.match_id)
        .limit(1)
        .execute()
    )
    if not match_row.data or len(match_row.data) == 0:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Match not found.",
        )
    users = match_row.data[0].get("users") or []
    if caller_id not in users or body.notify_user_id not in users:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Match does not involve caller and notify_user_id.",
        )

    payload = {
        "match_id": body.match_id,
        "from_user_id": caller_id,
        "from_user_name": body.matcher_name,
    }
    supabase.table("notifications").insert(
        {
            "user_id": body.notify_user_id,
            "type": "new_match",
            "payload": payload,
            "read_at": None,
        }
    ).execute()
    return
