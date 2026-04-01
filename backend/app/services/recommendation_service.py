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
from datetime import datetime, timezone

from ..repositories.user_repository import UserRepository
from ..repositories.swipe_repository import SwipeRepository
from ..models.recommendation import RecommendationResponse, ScoredCandidate
from .heavy_recommendation_engine import HeavyRecommendationEngine
from .recommendation_engine import build_cf_signal
from ..config import get_settings
from .ml_ranker import MlRanker


class RecommendationService:

    def __init__(
        self,
        user_repo: UserRepository | None = None,
        swipe_repo: SwipeRepository | None = None,
    ):
        self._users = user_repo or UserRepository()
        self._swipes = swipe_repo or SwipeRepository()
        self._engine = HeavyRecommendationEngine()
        self._settings = get_settings()

    async def get_recommendations(
        self,
        user_id: str,
        limit: int | None = None,
        filters: dict | None = None,
    ) -> RecommendationResponse:
        limit = limit or self._settings.recommendation_limit
        multiplier = self._settings.candidate_pool_multiplier
        filters = filters or {}

        # 1. Current user profile
        current_user = self._users.get_by_id(user_id)
        if current_user is None:
            raise ValueError(f"User '{user_id}' not found in database.")

        # 2. Already-swiped IDs (exclude from pool)
        swiped_ids = self._swipes.get_swiped_user_ids(user_id)
        exclude_ids = list(swiped_ids | {user_id})
        # Users who already liked this viewer (and are not yet swiped back)
        # should surface earlier in the stack (Bumble-style), without
        # explicitly exposing that signal in the UI payload.
        inbound_likers = self._swipes.get_likers_of(user_id)

        # 3. Candidate pool
        candidates = self._users.get_candidates(
            exclude_ids=exclude_ids,
            limit=limit * multiplier * (3 if self._has_active_filters(filters) else 1),
        )

        # Optional strict filtering mode: hard constraints before ranking.
        # Default behavior is soft preference boost.
        filter_mode = (filters.get("filter_mode") or "soft").lower()
        if filter_mode == "strict":
            candidates = self._apply_filters(candidates, filters)

        if not candidates:
            return RecommendationResponse(
                user_id=user_id,
                recommendations=[],
                total=0,
                algorithm="heavy_ml_hybrid_v2"
            )

        # 4. Collaborative-filtering signal
        all_swipes = self._swipes.get_all_swipes()
        cf_signal = build_cf_signal(all_swipes)
        max_cf = max(cf_signal.values(), default=1)

        # 5. Score candidates (baseline)
        scored: list[ScoredCandidate] = self._engine.score_candidates(
            current_user=current_user,
            candidates=candidates,
            cf_liked_by=cf_signal,
            max_cf_count=max_cf,
        )

        # Optional ML re-ranking (like-probability)
        ml_reasons: dict[str, list[str]] = {}
        ml_scores: dict[str, float] = {}
        pref_scores: dict[str, float] = {}
        if self._has_active_filters(filters) and filter_mode == "soft":
            pref_scores = {cand.id: self._preference_score(cand, filters) for cand in candidates}
        if self._settings.ml_ranking_enabled:
            ranker = MlRanker(model_name=self._settings.ml_model_name)
            for cand in candidates:
                res = ranker.score_pair(
                    viewer=current_user,
                    candidate=cand,
                    cf_count=int(cf_signal.get(cand.id, 0)),
                    max_cf=max_cf,
                )
                if res is None:
                    ml_scores = {}
                    ml_reasons = {}
                    break
                ml_scores[cand.id] = res.score
                ml_reasons[cand.id] = res.top_reasons

            if ml_scores:
                scored.sort(
                    key=lambda s: (
                        (ml_scores.get(s.user_id, 0.0) * 0.8) + (pref_scores.get(s.user_id, 0.0) * 0.2),
                        s.score,
                    ),
                    reverse=True,
                )
        elif pref_scores:
            scored.sort(
                key=lambda s: (((s.score / 100.0) * 0.8) + (pref_scores.get(s.user_id, 0.0) * 0.2), s.score),
                reverse=True,
            )

        # Silent "liked-you" prioritization:
        # keep existing rank order inside each group, but move inbound likers
        # to the front so mutual matches happen naturally via card flow.
        if inbound_likers:
            scored.sort(key=lambda s: s.user_id in inbound_likers, reverse=True)


        # 6. Fetch full profiles for top-N results
        top_ids = [s.user_id for s in scored[:limit]]
        score_map = {s.user_id: s.score for s in scored}

        top_users = self._users.bulk_get_by_ids(top_ids)

        # Preserve ranking order from engine
        id_order = {uid: i for i, uid in enumerate(top_ids)}
        top_users.sort(key=lambda u: id_order.get(u.id, 999))

        recommendations = []
        for u in top_users:
            rec_dict = u.model_dump()
            rec_dict["match_score"] = score_map.get(u.id, 0.0)
            # Find the breakdown for this specific user
            for s in scored:
                if s.user_id == u.id:
                    rec_dict["score_breakdown"] = s.score_breakdown
                    break
            if ml_scores:
                rec_dict["ml_like_prob"] = round(float(ml_scores.get(u.id, 0.0)), 6)
                rec_dict["ml_top_reasons"] = ml_reasons.get(u.id, [])
            if pref_scores:
                rec_dict["filter_preference_score"] = round(float(pref_scores.get(u.id, 0.0)), 6)
            recommendations.append(rec_dict)

        return RecommendationResponse(
            user_id=user_id,
            recommendations=recommendations,
            total=len(recommendations),
            algorithm=("ml_logreg_rerank_v1" if ml_scores else "heavy_ml_hybrid_v2")
        )

    @staticmethod
    def _has_active_filters(filters: dict) -> bool:
        return bool(
            filters.get("languages")
            or filters.get("interests")
            or filters.get("location")
            or filters.get("min_followers") is not None
            or filters.get("min_public_repos") is not None
            or filters.get("active_within_days") is not None
        )

    def _apply_filters(self, candidates: list, filters: dict) -> list:
        lang_filters = {l.strip().lower() for l in (filters.get("languages") or []) if l and l.strip()}
        int_filters = {i.strip().lower() for i in (filters.get("interests") or []) if i and i.strip()}
        location_filter = (filters.get("location") or "").strip().lower()
        min_followers = filters.get("min_followers")
        min_public_repos = filters.get("min_public_repos")
        active_within_days = filters.get("active_within_days")

        def match(candidate) -> bool:
            candidate_langs = {l.strip().lower() for l in (candidate.languages or []) if l and l.strip()}
            candidate_interests = {i.strip().lower() for i in (candidate.interests or []) if i and i.strip()}

            if lang_filters and not (candidate_langs & lang_filters):
                return False
            if int_filters and not (candidate_interests & int_filters):
                return False
            if location_filter:
                c_loc = (candidate.location or "").lower()
                if location_filter not in c_loc:
                    return False
            if min_followers is not None and int(candidate.followers or 0) < int(min_followers):
                return False
            if min_public_repos is not None and int(candidate.public_repos or 0) < int(min_public_repos):
                return False
            if active_within_days is not None:
                ref = candidate.last_active_at or candidate.created_at
                if ref.tzinfo is None:
                    ref = ref.replace(tzinfo=timezone.utc)
                days = (datetime.now(timezone.utc) - ref).days
                if days > int(active_within_days):
                    return False
            return True

        return [c for c in candidates if match(c)]

    def _preference_score(self, candidate, filters: dict) -> float:
        lang_filters = {l.strip().lower() for l in (filters.get("languages") or []) if l and l.strip()}
        int_filters = {i.strip().lower() for i in (filters.get("interests") or []) if i and i.strip()}
        location_filter = (filters.get("location") or "").strip().lower()
        min_followers = filters.get("min_followers")
        min_public_repos = filters.get("min_public_repos")
        active_within_days = filters.get("active_within_days")

        score = 0.0
        used = 0

        if lang_filters:
            used += 1
            candidate_langs = {l.strip().lower() for l in (candidate.languages or []) if l and l.strip()}
            score += 1.0 if (candidate_langs & lang_filters) else 0.0

        if int_filters:
            used += 1
            candidate_interests = {i.strip().lower() for i in (candidate.interests or []) if i and i.strip()}
            score += 1.0 if (candidate_interests & int_filters) else 0.0

        if location_filter:
            used += 1
            c_loc = (candidate.location or "").lower()
            score += 1.0 if location_filter in c_loc else 0.0

        if min_followers is not None:
            used += 1
            score += min(1.0, float(candidate.followers or 0) / max(float(min_followers), 1.0))

        if min_public_repos is not None:
            used += 1
            score += min(1.0, float(candidate.public_repos or 0) / max(float(min_public_repos), 1.0))

        if active_within_days is not None:
            used += 1
            ref = candidate.last_active_at or candidate.created_at
            if ref.tzinfo is None:
                ref = ref.replace(tzinfo=timezone.utc)
            days = max(0, (datetime.now(timezone.utc) - ref).days)
            score += 1.0 if days <= int(active_within_days) else 0.0

        if used == 0:
            return 0.0
        return score / used

