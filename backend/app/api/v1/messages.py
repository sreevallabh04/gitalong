"""
Messages API
=============
GET  /api/v1/matches/{match_id}/messages  — Fetch messages for a match.
POST /api/v1/matches/{match_id}/messages  — Send a message in a match.
PUT  /api/v1/matches/{match_id}/messages/read — Mark all messages as read.
"""
import logging
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel

from ...core.auth import verify_token
from ...repositories.match_repository import MatchRepository
from ...repositories.message_repository import MessageRepository

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/matches", tags=["messages"])


class MessageOut(BaseModel):
    id: str
    match_id: str
    sender_id: str
    receiver_id: str
    content: str
    type: str = "text"
    sent_at: str
    is_read: bool = False


class MessageListResponse(BaseModel):
    messages: list[MessageOut]
    count: int


class SendMessageRequest(BaseModel):
    receiver_id: str
    content: str
    type: str = "text"


class SendMessageResponse(BaseModel):
    message: MessageOut
    status: str = "sent"


def _verify_match_membership(match_id: str, user_id: str) -> dict:
    """Verify user is part of the match. Returns match data or raises 403."""
    match_repo = MatchRepository()
    row = match_repo.get_match_by_id(match_id)
    if row is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Match not found.")
    if user_id not in row.get("users", []):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not part of this match.")
    return row


@router.get("/{match_id}/messages", response_model=MessageListResponse)
async def get_messages(
    match_id: str,
    limit: int = Query(default=50, ge=1, le=200),
    before: str | None = Query(default=None, description="ISO timestamp cursor for pagination"),
    user_id: str = Depends(verify_token),
):
    """Fetch messages for a match (newest first)."""
    _verify_match_membership(match_id, user_id)

    msg_repo = MessageRepository()
    rows = msg_repo.get_messages(match_id, limit, before)

    messages = [
        MessageOut(
            id=str(row["id"]),
            match_id=match_id,
            sender_id=row["sender_id"],
            receiver_id=row["receiver_id"],
            content=row["content"],
            type=row.get("type", "text"),
            sent_at=str(row["sent_at"]),
            is_read=row.get("is_read", False),
        )
        for row in rows
    ]

    return MessageListResponse(messages=messages, count=len(messages))


@router.post(
    "/{match_id}/messages",
    response_model=SendMessageResponse,
    status_code=status.HTTP_201_CREATED,
)
async def send_message(
    match_id: str,
    body: SendMessageRequest,
    user_id: str = Depends(verify_token),
):
    """Send a message in a match."""
    match_data = _verify_match_membership(match_id, user_id)

    # Verify receiver is the other user in the match
    users_list = match_data.get("users", [])
    if body.receiver_id not in users_list:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Receiver is not part of this match.",
        )
    if body.receiver_id == user_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot send message to yourself.",
        )

    if not body.content.strip():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Message content cannot be empty.",
        )

    msg_repo = MessageRepository()
    row = msg_repo.send_message(
        match_id=match_id,
        sender_id=user_id,
        receiver_id=body.receiver_id,
        content=body.content.strip(),
        msg_type=body.type,
    )

    message = MessageOut(
        id=str(row["id"]),
        match_id=match_id,
        sender_id=user_id,
        receiver_id=body.receiver_id,
        content=body.content.strip(),
        type=body.type,
        sent_at=str(row.get("sent_at", "")),
        is_read=False,
    )

    return SendMessageResponse(message=message)


@router.put("/{match_id}/messages/read", status_code=status.HTTP_200_OK)
async def mark_messages_read(
    match_id: str,
    user_id: str = Depends(verify_token),
):
    """Mark all unread messages in a match as read for the authenticated user."""
    _verify_match_membership(match_id, user_id)

    msg_repo = MessageRepository()
    count = msg_repo.mark_as_read(match_id, user_id)

    return {"status": "ok", "marked_read": count}
