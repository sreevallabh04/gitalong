"""
Message document for MongoDB (Beanie).
"""

from typing import Optional
from beanie import Document, Link

from app.models.user import User


class Message(Document):
    content: str
    message_type: str = "text"
    attachment_url: Optional[str] = None
    attachment_type: Optional[str] = None
    attachment_size: Optional[int] = None

    sender: Link[User]
    recipient: Link[User]

    is_read: bool = False
    is_deleted: bool = False
    is_edited: bool = False
    is_system_message: bool = False

    reply_to_id: Optional[str] = None
    thread_id: Optional[str] = None

    class Settings:
        name = "messages"
        indexes = ["sender", "recipient"]
