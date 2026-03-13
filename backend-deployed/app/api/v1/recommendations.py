import logging
from fastapi import APIRouter, Depends, HTTPException, Query, status

from ...core.auth import verify_token
from ...services.recommendation_service import RecommendationService
from ...models.recommendation import RecommendationResponse

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/recommendations", tags=["recommendations"])


@router.get("", response_model=RecommendationResponse)
async def get_recommendations(
    limit: int = Query(default=20, ge=1, le=100, description="Number of profiles to return"),
    user_id: str = Depends(verify_token),
) -> RecommendationResponse:
    """
    Return personalised developer recommendations for the authenticated user.

    **Authentication**: Supabase JWT in `Authorization: Bearer <token>` header.

    The response is ordered best-match first and includes a `match_score` (0–100)
    and a `score_breakdown` per candidate.
    """
    try:
        service = RecommendationService()
        return await service.get_recommendations(user_id=user_id, limit=limit)
    except ValueError as exc:
        logger.warning("Recommendations ValueError for user %s: %s", user_id, exc)
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(exc),
        )
    except Exception as exc:
        logger.exception("Recommendations failed for user %s", user_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Recommendation engine error: {type(exc).__name__}: {exc}",
        )
