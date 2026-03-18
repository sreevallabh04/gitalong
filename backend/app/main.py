"""
GitAlong FastAPI Application
"""
import logging
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from starlette.middleware.base import BaseHTTPMiddleware

from .config import get_settings
from .api.v1 import api_router

logger = logging.getLogger(__name__)
settings = get_settings()
logger.warning("GitAlong API starting")
logger.warning("  SUPABASE_URL: %s", settings.supabase_url)
logger.warning("  SUPABASE_ANON_KEY: %s...%s", settings.supabase_anon_key[:10], settings.supabase_anon_key[-6:])
logger.warning("  SUPABASE_SERVICE_ROLE_KEY: %s...%s", settings.supabase_service_role_key[:10], settings.supabase_service_role_key[-6:])
logger.warning("  ALLOWED_ORIGINS: %s", settings.allowed_origins)

CORS_HEADERS = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
    "Access-Control-Allow-Headers": "Authorization, Content-Type, Accept",
    "Access-Control-Max-Age": "600",
}


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

# ── Routes ───────────────────────────────────────────────────────────────────
app.include_router(api_router)


@app.get("/", tags=["root"])
async def root():
    return {
        "name": settings.app_name,
        "version": settings.app_version,
        "docs": "/docs",
    }
