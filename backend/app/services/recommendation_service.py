"""
RecommendationService
=====================
Orchestrates the full recommendation pipeline:
  1. Load current user profile from DB
  2. Load swiped user IDs (to exclude)
  3. Fetch candidate pool
  4. Build CF signal from all swipes
  5. Run hybrid scoring engine
  6. Return top-N ranked users
"""
from __future__ import annotations

from ..repositories.user_repository import UserRepository
from ..repositories.swipe_repository import SwipeRepository
from ..models.recommendation import RecommendationResponse, ScoredCandidate
from .recommendation_engine import RecommendationEngine, build_cf_signal
from ..config import get_settings


class RecommendationService:

    def __init__(
        self,
        user_repo: UserRepository | None = None,
        swipe_repo: SwipeRepository | None = None,
    ):
        self._users = user_repo or UserRepository()
        self._swipes = swipe_repo or SwipeRepository()
        self._engine = RecommendationEngine()
        self._settings = get_settings()

    async def get_recommendations(
        self,
        user_id: str,
        limit: int | None = None,
    ) -> RecommendationResponse:
        limit = limit or self._settings.recommendation_limit
        multiplier = self._settings.candidate_pool_multiplier

        # 1. Current user profile
        current_user = self._users.get_by_id(user_id)
        if current_user is None:
            raise ValueError(f"User '{user_id}' not found in database.")

        # 2. Already-swiped IDs (exclude from pool)
        swiped_ids = self._swipes.get_swiped_user_ids(user_id)
        exclude_ids = list(swiped_ids | {user_id})

        # 3. Candidate pool
        candidates = self._users.get_candidates(
            exclude_ids=exclude_ids,
            limit=limit * multiplier,
        )

        if not candidates:
            return RecommendationResponse(
                user_id=user_id,
                recommendations=[],
                total=0,
            )

        # 4. Collaborative-filtering signal
        all_swipes = self._swipes.get_all_swipes()
        cf_signal = build_cf_signal(all_swipes)
        max_cf = max(cf_signal.values(), default=1)

        # 5. Score candidates
        scored: list[ScoredCandidate] = self._engine.score_candidates(
            current_user=current_user,
            candidates=candidates,
            cf_liked_by=cf_signal,
            max_cf_count=max_cf,
        )

        # 6. Fetch full profiles for top-N results
        top_ids = [s.user_id for s in scored[:limit]]
        score_map = {s.user_id: s.score for s in scored}

        top_users = self._users.bulk_get_by_ids(top_ids)

        # Preserve ranking order from engine
        id_order = {uid: i for i, uid in enumerate(top_ids)}
        top_users.sort(key=lambda u: id_order.get(u.id, 999))

        recommendations = [
            {
                **u.model_dump(),
                "match_score": score_map.get(u.id, 0.0),
            }
            for u in top_users
        ]

        return RecommendationResponse(
            user_id=user_id,
            recommendations=recommendations,
            total=len(recommendations),
        )
