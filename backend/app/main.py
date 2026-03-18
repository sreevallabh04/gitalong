"""
GitAlong FastAPI Application
"""
import logging
import time
from collections import defaultdict
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from starlette.middleware.base import BaseHTTPMiddleware

from .config import get_settings
from .api.v1 import api_router

logger = logging.getLogger(__name__)
settings = get_settings()
logger.info("GitAlong API starting")
logger.info("  SUPABASE_URL: %s", settings.supabase_url)
logger.info("  SUPABASE_ANON_KEY present: %s", bool(settings.supabase_anon_key))
logger.info("  SUPABASE_SERVICE_ROLE_KEY present: %s", bool(settings.supabase_service_role_key))
logger.info("  ALLOWED_ORIGINS: %s", settings.allowed_origins)

CORS_HEADERS = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
    "Access-Control-Allow-Headers": "Authorization, Content-Type, Accept",
    "Access-Control-Max-Age": "600",
}

# ── Rate Limiter ─────────────────────────────────────────────────────────────
RATE_LIMIT_MAX_REQUESTS = 60   # per window
RATE_LIMIT_WINDOW_SECONDS = 60


class RateLimiterMiddleware(BaseHTTPMiddleware):
    """Simple in-memory rate limiter per client IP."""

    def __init__(self, app, max_requests: int = RATE_LIMIT_MAX_REQUESTS, window: int = RATE_LIMIT_WINDOW_SECONDS):
        super().__init__(app)
        self.max_requests = max_requests
        self.window = window
        self._requests: dict[str, list[float]] = defaultdict(list)

    async def dispatch(self, request: Request, call_next):
        client_ip = request.client.host if request.client else "unknown"
        now = time.time()

        # Clean old entries
        self._requests[client_ip] = [
            t for t in self._requests[client_ip] if now - t < self.window
        ]

        if len(self._requests[client_ip]) >= self.max_requests:
            return JSONResponse(
                status_code=429,
                content={"detail": "Too many requests. Please try again later."},
                headers={**CORS_HEADERS, "Retry-After": str(self.window)},
            )

        self._requests[client_ip].append(now)
        return await call_next(request)


class CORSMiddleware(BaseHTTPMiddleware):
    """
    Custom CORS middleware that guarantees headers on every response,
    including error responses and exceptions — unlike Starlette's built-in
    CORSMiddleware which can miss them on unhandled errors or cold starts.
    """

    async def dispatch(self, request: Request, call_next):
        if request.method == "OPTIONS":
            return JSONResponse(content={"ok": True}, headers=CORS_HEADERS)

        try:
            response = await call_next(request)
        except Exception as exc:
            logger.exception("Unhandled exception — returning 500 with CORS headers")
            response = JSONResponse(
                status_code=500,
                content={"detail": f"{type(exc).__name__}: {exc}"},
            )

        for key, value in CORS_HEADERS.items():
            response.headers[key] = value

        return response


app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    description=(
        "GitAlong backend: hybrid ML recommendation engine "
        "for matching developers by GitHub activity."
    ),
    docs_url="/docs",
    redoc_url="/redoc",
)

app.add_middleware(CORSMiddleware)
app.add_middleware(RateLimiterMiddleware)

# ── Routes ───────────────────────────────────────────────────────────────────
app.include_router(api_router)


@app.get("/", tags=["root"])
async def root():
    return {
        "name": settings.app_name,
        "version": settings.app_version,
        "docs": "/docs",
    }

