"""
JWT / Auth utilities
====================
Verifies Supabase JWT tokens sent by the frontend/app
in the Authorization: Bearer <token> header.

Supports both ES256 (ECDSA) and RS256 (RSA) — Supabase uses ES256
as of 2024+.
"""
from __future__ import annotations

import jwt
from jwt import PyJWKClient
from fastapi import Header, HTTPException, status
from functools import lru_cache

from ..config import get_settings


@lru_cache(maxsize=1)
def _get_jwk_client() -> PyJWKClient:
    settings = get_settings()
    uri = f"{settings.supabase_url}/auth/v1/.well-known/jwks.json"
    return PyJWKClient(uri)


def verify_token(authorization: str = Header(...)) -> str:
    """
    FastAPI dependency: extracts and verifies the Supabase JWT.
    Returns the authenticated user's UUID (sub claim).
    """
    if not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing or malformed Authorization header.",
        )
    token = authorization[7:]

    try:
        jwk_client = _get_jwk_client()
        signing_key = jwk_client.get_signing_key_from_jwt(token)

        payload = jwt.decode(
            token,
            key=signing_key.key,
            algorithms=["ES256", "RS256"],
            options={"verify_aud": False},
        )
        return payload["sub"]

    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired. Please sign in again.",
        )
    except jwt.PyJWTError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid token: {exc}",
        )
