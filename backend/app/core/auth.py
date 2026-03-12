"""
JWT / Auth utilities
====================
Verifies Supabase JWT tokens sent by the Flutter app
in the Authorization: Bearer <token> header.
"""
from __future__ import annotations

import jwt
import json
import httpx
from jwt.algorithms import RSAAlgorithm
from fastapi import Header, HTTPException, status
from functools import lru_cache

from ..config import get_settings


@lru_cache(maxsize=1)
def _get_jwks_uri() -> str:
    settings = get_settings()
    # Supabase JWKS endpoint
    return f"{settings.supabase_url}/auth/v1/.well-known/jwks.json"


@lru_cache(maxsize=1)
def _fetch_jwks() -> dict:
    uri = _get_jwks_uri()
    with httpx.Client() as client:
        resp = client.get(uri)
        resp.raise_for_status()
        return resp.json()


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
        # Decode header to get kid
        unverified_header = jwt.get_unverified_header(token)

        # Find matching key in JWKS
        jwks = _fetch_jwks()
        public_keys = {}
        for key in jwks.get("keys", []):
            if key.get("kid"):
                public_keys[key["kid"]] = RSAAlgorithm.from_jwk(json.dumps(key))

        kid = unverified_header.get("kid")
        if kid not in public_keys:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Unknown key ID in token.",
            )


        payload = jwt.decode(
            token,
            key=public_keys[kid],
            algorithms=["RS256"],
            options={"verify_aud": False},
        )
        return payload["sub"]  # Supabase user UUID

    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired.",
        )
    except jwt.PyJWTError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid token: {exc}",
        )
