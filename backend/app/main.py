"""
Main FastAPI application for GitAlong Backend.

Production-ready FastAPI application with comprehensive middleware, error handling,
and API documentation.
"""

import time
from contextlib import asynccontextmanager
from typing import Any

from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException
import structlog
import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

from app.core.config import settings
from app.core.database import init_db, close_db
from app.api.v1.api import api_router
from app.core.logging import setup_logging

# Setup logging
setup_logging()
logger = structlog.get_logger()

# Setup Sentry for error tracking
if settings.SENTRY_DSN:
    sentry_sdk.init(
        dsn=settings.SENTRY_DSN,
        integrations=[FastApiIntegration()],
        traces_sample_rate=0.1,
        environment=settings.ENVIRONMENT,
    )

# Rate limiter
limiter = Limiter(key_func=get_remote_address)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager."""
    # Startup
    logger.info("Starting GitAlong Backend", version=settings.APP_VERSION)
    
    # Initialize database
    try:
        await init_db()
        logger.info("Database initialized successfully")
    except Exception as e:
        logger.error("Failed to initialize database", error=str(e))
        raise
    
    yield
    
    # Shutdown
    logger.info("Shutting down GitAlong Backend")
    await close_db()


# Create FastAPI application
app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.APP_VERSION,
    description="""
    # GitAlong Backend API
    
    A production-ready FastAPI backend for GitAlong - the GitHub-powered developer matching platform.
    
    ## Features
    
    * 🔐 **Authentication & Authorization** - JWT-based auth with GitHub OAuth
    * 👥 **User Management** - Comprehensive user profiles with GitHub integration
    * 🤝 **Matching System** - ML-powered developer matching and recommendations
    * 💬 **Messaging** - Real-time chat and communication
    * 📊 **Analytics** - GitHub activity tracking and insights
    * 🚀 **Project Management** - Project creation and collaboration tools
    
    ## Authentication
    
    Most endpoints require authentication. Include your JWT token in the Authorization header:
    
    ```
    Authorization: Bearer <your-jwt-token>
    ```
    
    ## Rate Limiting
    
    API requests are rate-limited to ensure fair usage. Limits are applied per IP address.
    
    ## Error Handling
    
    The API returns consistent error responses with appropriate HTTP status codes and error messages.
    """,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    docs_url="/docs" if settings.DEBUG else None,
    redoc_url="/redoc" if settings.DEBUG else None,
    lifespan=lifespan,
)

# Add rate limiting
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Add trusted host middleware for production
if settings.is_production():
    app.add_middleware(
        TrustedHostMiddleware,
        allowed_hosts=["*"]  # Configure with your domain in production
    )


@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    """Add processing time header to responses."""
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    response.headers["X-Process-Time"] = str(process_time)
    return response


@app.middleware("http")
async def log_requests(request: Request, call_next):
    """Log all incoming requests."""
    start_time = time.time()
    
    # Log request
    logger.info(
        "Incoming request",
        method=request.method,
        url=str(request.url),
        client_ip=request.client.host if request.client else None,
        user_agent=request.headers.get("user-agent"),
    )
    
    response = await call_next(request)
    
    # Log response
    process_time = time.time() - start_time
    logger.info(
        "Request completed",
        method=request.method,
        url=str(request.url),
        status_code=response.status_code,
        process_time=process_time,
    )
    
    return response


@app.exception_handler(StarletteHTTPException)
async def http_exception_handler(request: Request, exc: StarletteHTTPException):
    """Handle HTTP exceptions."""
    logger.warning(
        "HTTP exception",
        status_code=exc.status_code,
        detail=exc.detail,
        url=str(request.url),
    )
    
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": {
                "type": "http_error",
                "code": exc.status_code,
                "message": exc.detail,
                "timestamp": time.time(),
            }
        },
    )


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """Handle validation exceptions."""
    logger.warning(
        "Validation error",
        errors=exc.errors(),
        url=str(request.url),
    )
    
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "error": {
                "type": "validation_error",
                "code": 422,
                "message": "Validation error",
                "details": exc.errors(),
                "timestamp": time.time(),
            }
        },
    )


@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    """Handle general exceptions."""
    logger.error(
        "Unhandled exception",
        error=str(exc),
        error_type=type(exc).__name__,
        url=str(request.url),
        exc_info=True,
    )
    
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "error": {
                "type": "internal_error",
                "code": 500,
                "message": "Internal server error",
                "timestamp": time.time(),
            }
        },
    )


# Health check endpoint
@app.get("/health")
@limiter.limit("10/minute")
async def health_check(request: Request):
    """Health check endpoint."""
    return {
        "status": "healthy",
        "version": settings.APP_VERSION,
        "environment": settings.ENVIRONMENT,
        "timestamp": time.time(),
    }


# Root endpoint
@app.get("/")
async def root():
    """Root endpoint with API information."""
    return {
        "message": "Welcome to GitAlong Backend API",
        "version": settings.APP_VERSION,
        "docs_url": "/docs" if settings.DEBUG else None,
        "health_check": "/health",
        "api_v1": settings.API_V1_STR,
    }


# Include API router
app.include_router(api_router, prefix=settings.API_V1_STR)


if __name__ == "__main__":
    import uvicorn
    
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.DEBUG,
        log_level=settings.LOG_LEVEL.lower(),
    )
