from fastapi import APIRouter, Depends, Query

from ...core.auth import verify_token
from ...services.recommendation_service import RecommendationService
from ...models.recommendation import RecommendationResponse

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
    service = RecommendationService()
    return await service.get_recommendations(user_id=user_id, limit=limit)
