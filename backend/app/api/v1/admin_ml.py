import logging

from fastapi import APIRouter, Header, HTTPException, status

from ...config import get_settings
from ...services.ml_trainer import MlTrainer

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/admin", tags=["admin"])


@router.post("/retrain-ml", status_code=status.HTTP_200_OK)
async def retrain_ml(x_admin_secret: str = Header(default="")):
    """
    Retrain the lightweight ML ranker and persist weights to Supabase.

    Protected by `X-Admin-Secret` header matched against `ADMIN_RETRAIN_SECRET`.
    """
    settings = get_settings()
    if not settings.admin_retrain_secret:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Admin retrain secret not configured.",
        )
    if x_admin_secret != settings.admin_retrain_secret:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Unauthorized.",
        )

    trainer = MlTrainer(model_name=settings.ml_model_name)
    try:
        result = trainer.retrain()
    except Exception as exc:
        logger.exception("ML retrain failed")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Retrain failed: {type(exc).__name__}: {exc}",
        )

    return {
        "status": "ok",
        "model_name": result.model_name,
        "version": result.version,
        "trained_at": result.trained_at,
        "rows": result.n_rows,
        "positives": result.n_pos,
        "auc": result.auc,
        "features": result.feature_names,
    }

