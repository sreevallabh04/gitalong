"""
Security module for authentication and authorization.

Handles JWT token creation/validation, password hashing, and security utilities.
"""

import secrets
from datetime import datetime, timedelta
from typing import Any, Dict, Optional, Union

from jose import JWTError, jwt
from passlib.context import CryptContext

from app.core.config import settings

# Password hashing context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# JWT configuration
ALGORITHM = settings.ALGORITHM
SECRET_KEY = settings.SECRET_KEY
ACCESS_TOKEN_EXPIRE_MINUTES = settings.ACCESS_TOKEN_EXPIRE_MINUTES
REFRESH_TOKEN_EXPIRE_DAYS = settings.REFRESH_TOKEN_EXPIRE_DAYS


def create_access_token(
    subject: Union[str, Any], expires_delta: Optional[timedelta] = None
) -> str:
    """Create JWT access token."""
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode = {"exp": expire, "sub": str(subject), "type": "access"}
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def create_refresh_token(
    subject: Union[str, Any], expires_delta: Optional[timedelta] = None
) -> str:
    """Create JWT refresh token."""
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    
    to_encode = {"exp": expire, "sub": str(subject), "type": "refresh"}
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def verify_token(token: str) -> Optional[str]:
    """Verify JWT token and return subject."""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        subject: str = payload.get("sub")
        if subject is None:
            return None
        return subject
    except JWTError:
        return None


def verify_access_token(token: str) -> Optional[str]:
    """Verify JWT access token and return subject."""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        subject: str = payload.get("sub")
        token_type: str = payload.get("type")
        
        if subject is None or token_type != "access":
            return None
        return subject
    except JWTError:
        return None


def verify_refresh_token(token: str) -> Optional[str]:
    """Verify JWT refresh token and return subject."""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        subject: str = payload.get("sub")
        token_type: str = payload.get("type")
        
        if subject is None or token_type != "refresh":
            return None
        return subject
    except JWTError:
        return None


def get_token_payload(token: str) -> Optional[Dict[str, Any]]:
    """Get JWT token payload without verification."""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except JWTError:
        return None


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a password against its hash."""
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    """Hash a password."""
    return pwd_context.hash(password)


def generate_secure_token(length: int = 32) -> str:
    """Generate a secure random token."""
    return secrets.token_urlsafe(length)


def generate_api_key() -> str:
    """Generate a secure API key."""
    return f"gitalong_{secrets.token_urlsafe(32)}"


def is_token_expired(token: str) -> bool:
    """Check if a token is expired."""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        exp = payload.get("exp")
        if exp is None:
            return True
        return datetime.utcnow() > datetime.fromtimestamp(exp)
    except JWTError:
        return True


def get_token_expiration(token: str) -> Optional[datetime]:
    """Get token expiration time."""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        exp = payload.get("exp")
        if exp is None:
            return None
        return datetime.fromtimestamp(exp)
    except JWTError:
        return None


class SecurityUtils:
    """Utility class for security operations."""
    
    @staticmethod
    def sanitize_input(input_str: str) -> str:
        """Sanitize user input to prevent injection attacks."""
        # Basic sanitization - in production, use a proper sanitization library
        return input_str.strip()
    
    @staticmethod
    def validate_email(email: str) -> bool:
        """Validate email format."""
        import re
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return bool(re.match(pattern, email))
    
    @staticmethod
    def validate_password_strength(password: str) -> bool:
        """Validate password strength."""
        if len(password) < 8:
            return False
        if not any(c.isupper() for c in password):
            return False
        if not any(c.islower() for c in password):
            return False
        if not any(c.isdigit() for c in password):
            return False
        return True
    
    @staticmethod
    def generate_otp(length: int = 6) -> str:
        """Generate a numeric OTP."""
        return ''.join(secrets.choice('0123456789') for _ in range(length))
