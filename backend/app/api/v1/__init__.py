from fastapi import APIRouter
from .health import router as health_router
from .recommendations import router as rec_router
from .users import router as users_router
from .swipes import router as swipes_router
from .matches import router as matches_router
from .messages import router as messages_router
from .notifications import router as notifications_router

api_router = APIRouter(prefix="/api/v1")

api_router.include_router(health_router)
api_router.include_router(rec_router)
api_router.include_router(users_router)
api_router.include_router(swipes_router)
api_router.include_router(matches_router)
api_router.include_router(messages_router)
api_router.include_router(notifications_router)
