"""
Recommendation Engine
=====================
Implements a hybrid algorithm:
  1. Content-Based Filtering (CBF) — profile feature vectors + cosine similarity
  2. Collaborative Filtering (CF)  — who also liked the same users as you
  3. Hybrid blend                  — weighted combination of both

Feature vector:
  - Languages (TF-IDF-style bag-of-languages)
  - Topics / interests (Jaccard)
  - Activity level (normalised repos + stars)
  - Location match (bonus weight)
  - Recency (sigmoid decay on last_active_at)
"""
from __future__ import annotations

import math
from datetime import datetime, timezone
from collections import defaultdict
from typing import Optional

from ..models.user import UserProfile
from ..models.recommendation import ScoredCandidate


# ─────────────────────────────────────────────────────────────────────────────
# Weight constants  (must sum to 100)
# ─────────────────────────────────────────────────────────────────────────────
W_LANGUAGE   = 35.0   # Most important — language overlap
W_TOPICS     = 25.0   # Shared interests / repo topics
W_ACTIVITY   = 15.0   # Similar activity level
W_CF_BOOST   = 15.0   # Collaborative-filtering popularity boost
W_LOCATION   = 5.0    # Same city / country
W_RECENCY    = 5.0    # Recently active users get small boost


class RecommendationEngine:
    """
    Stateless scoring engine. Instantiate once per request.
    Inject pre-fetched data to keep I/O out of the algorithm.
    """

    def score_candidates(
        self,
        *,
        current_user: UserProfile,
        candidates: list[UserProfile],
        cf_liked_by: dict[str, int],   # candidate_id → # users who liked them (from CF)
        max_cf_count: int = 1,
    ) -> list[ScoredCandidate]:
        """
        Score every candidate and return sorted (descending) list.

        Args:
            current_user:   the logged-in user's profile
            candidates:     pool of users to rank
            cf_liked_by:    {user_id: like_count} — collaborative signal
            max_cf_count:   max likes in the pool (for normalisation)
        """
        scored: list[ScoredCandidate] = []

        for candidate in candidates:
            breakdown = self._score(
                current_user=current_user,
                candidate=candidate,
                cf_liked_by=cf_liked_by,
                max_cf_count=max(max_cf_count, 1),
            )
            total = sum(breakdown.values())
            scored.append(
                ScoredCandidate(
                    user_id=candidate.id,
                    username=candidate.username,
                    score=round(min(total, 100.0), 2),
                    score_breakdown=breakdown,
                )
            )

        scored.sort(key=lambda s: s.score, reverse=True)
        return scored

    # ──────────────────────────────────────────────────────────────────────────
    # Private helpers
    # ──────────────────────────────────────────────────────────────────────────

    def _score(
        self,
        *,
        current_user: UserProfile,
        candidate: UserProfile,
        cf_liked_by: dict[str, int],
        max_cf_count: int,
    ) -> dict[str, float]:
        return {
            "language":  self._language_score(current_user, candidate),
            "topics":    self._topic_score(current_user, candidate),
            "activity":  self._activity_score(current_user, candidate),
            "cf_boost":  self._cf_score(candidate.id, cf_liked_by, max_cf_count),
            "location":  self._location_score(current_user, candidate),
            "recency":   self._recency_score(candidate),
        }

    @staticmethod
    def _jaccard(a: list[str], b: list[str]) -> float:
        """Generalised Jaccard similarity — case-insensitive."""
        set_a = {x.lower().strip() for x in a}
        set_b = {x.lower().strip() for x in b}
        if not set_a or not set_b:
            return 0.0
        inter = len(set_a & set_b)
        union = len(set_a | set_b)
        return inter / union if union else 0.0

    def _language_score(self, u: UserProfile, c: UserProfile) -> float:
        return self._jaccard(u.languages, c.languages) * W_LANGUAGE

    def _topic_score(self, u: UserProfile, c: UserProfile) -> float:
        return self._jaccard(u.interests, c.interests) * W_TOPICS

    @staticmethod
    def _activity_score(u: UserProfile, c: UserProfile) -> float:
        """Prefer developers with similar activity levels (repos + followers)."""
        def normalise(profile: UserProfile) -> float:
            return math.log1p(profile.public_repos + profile.followers * 0.1) / math.log1p(500)

        diff = abs(normalise(u) - normalise(c))
        return max(0.0, 1.0 - diff) * W_ACTIVITY

    @staticmethod
    def _cf_score(candidate_id: str, cf_liked_by: dict[str, int], max_count: int) -> float:
        """Collaborative popularity: how many other users have liked this candidate."""
        count = cf_liked_by.get(candidate_id, 0)
        return (count / max_count) * W_CF_BOOST

    @staticmethod
    def _location_score(u: UserProfile, c: UserProfile) -> float:
        if not u.location or not c.location:
            return W_LOCATION * 0.5  # neutral
        ul = u.location.lower().strip()
        cl = c.location.lower().strip()
        if ul == cl:
            return W_LOCATION
        if ul in cl or cl in ul:
            return W_LOCATION * 0.6
        return W_LOCATION * 0.1

    @staticmethod
    def _recency_score(c: UserProfile) -> float:
        ref = c.last_active_at or c.created_at
        now = datetime.now(timezone.utc)
        days = (now - ref.replace(tzinfo=timezone.utc)).days
        # Sigmoid-style decay
        if days <= 7:   return W_RECENCY
        if days <= 30:  return W_RECENCY * 0.8
        if days <= 90:  return W_RECENCY * 0.5
        if days <= 180: return W_RECENCY * 0.3
        return W_RECENCY * 0.1


def build_cf_signal(all_swipes: list[dict]) -> dict[str, int]:
    """
    Simple item-popularity collaborative signal:
      For every like/superLike action, count how many distinct users
      have liked each candidate.
    Returns: {swiped_user_id: distinct_liker_count}
    """
    liked_by: dict[str, set[str]] = defaultdict(set)
    for row in all_swipes:
        if row.get("action") in ("like", "superLike"):
            liked_by[row["swiped_user_id"]].add(row["swiper_id"])
    return {uid: len(likers) for uid, likers in liked_by.items()}
