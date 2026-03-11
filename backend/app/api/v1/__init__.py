from fastapi import APIRouter
from .health import router as health_router
from .recommendations import router as rec_router
from .users import router as users_router

api_router = APIRouter(prefix="/api/v1")

api_router.include_router(health_router)
api_router.include_router(rec_router)
api_router.include_router(users_router)
