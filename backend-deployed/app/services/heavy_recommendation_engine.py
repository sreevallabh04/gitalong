"""
Advanced Recommendation Engine (Heavy Edition)
==============================================
A professional-grade hybrid recommendation system using:
  1. Content-Based Filtering (CBF):
     - TF-IDF Vectorization for interests/topics
     - Weighted Jaccard Similarity for tech stacks (languages)
     - Log-normalized Activity scoring
  2. Collaborative Filtering (CF):
     - Popularity-based priors from swipe behavior
  3. Hybrid Ranking:
     - Blends tech stack, activity, and community signals
"""

import numpy as np
from datetime import datetime, timezone
from typing import List, Dict, Any

# We import these conditionally so we don't crash if install is still pending
try:
    from sklearn.feature_extraction.text import TfidfVectorizer
    from sklearn.metrics.pairwise import cosine_similarity
except ImportError:
    TfidfVectorizer = None
    cosine_similarity = None

from ..models.user import UserProfile, UserSummary
from ..models.recommendation import ScoredCandidate


class HeavyRecommendationEngine:
    """
    Advanced engine designed for project reviews.
    Includes explicit score breakdowns and ML-driven similarity.
    """

    # Scoring Weights (Total 1.0)
    W_TECH_STACK = 0.40   # Languages match
    W_INTERESTS = 0.20    # Interests/Topics (TF-IDF)
    W_ACTIVITY = 0.15     # GitHub followers/stars/repos (Log-normalized)
    W_COMMUNITY = 0.15    # CF signal (Likes from others)
    W_LOCATION = 0.05     # Shared location
    W_RECENCY = 0.05      # Active in last 7 days

    def score_candidates(
        self,
        current_user: UserProfile,
        candidates: List[UserSummary],
        cf_liked_by: Dict[str, int],  # user_id -> number of people who liked them
        max_cf_count: int = 1,
    ) -> List[ScoredCandidate]:
        if not candidates:
            return []

        scored_list = []

        # 1. Prepare TF-IDF for Interests if possible
        interest_scores = self._calculate_interest_similarity(current_user, candidates)

        for i, candidate in enumerate(candidates):
            # --- Signal 1: Tech Stack (Languages) ---
            tech_score = self._calculate_jaccard(current_user.languages, candidate.languages)

            # --- Signal 2: Interests (ML Cosine Sim) ---
            int_score = interest_scores[i]

            # --- Signal 3: Activity Level (Log-normalized) ---
            # We compare the "developer tier" of the users
            act_score = self._calculate_activity_score(current_user, candidate)

            # --- Signal 4: Community (CF - Popularity) ---
            count = cf_liked_by.get(candidate.id, 0)
            comm_score = count / max_cf_count if max_cf_count > 0 else 0.0

            # --- Signal 5: Location Bonus ---
            loc_score = 0.0
            if current_user.location and candidate.location:
                if current_user.location.lower() == candidate.location.lower():
                    loc_score = 1.0
                elif current_user.location.lower() in candidate.location.lower() or \
                     candidate.location.lower() in current_user.location.lower():
                    loc_score = 0.5

            # --- Signal 6: Recency ---
            rec_score = self._calculate_recency_score(candidate.last_active_at)

            # Blended Total (0.0 to 100.0)
            final_raw = (
                tech_score * self.W_TECH_STACK +
                int_score * self.W_INTERESTS +
                act_score * self.W_ACTIVITY +
                comm_score * self.W_COMMUNITY +
                loc_score * self.W_LOCATION +
                rec_score * self.W_RECENCY
            )

            # Multiplier for "Quality" profiles (has bio, has photo)
            multiplier = 1.0
            if candidate.bio: multiplier += 0.05
            if candidate.avatar_url: multiplier += 0.05
            
            final_score = min(100.0, final_raw * 100.0 * multiplier)

            scored_list.append(ScoredCandidate(
                user_id=candidate.id,
                username=candidate.username,
                score=round(final_score, 1),
                score_breakdown={
                    "tech_match": round(tech_score * 100, 1),
                    "interest_match": round(int_score * 100, 1),
                    "activity_level": round(act_score * 100, 1),
                    "community_popularity": round(comm_score * 100, 1),
                    "location_bonus": round(loc_score * 100, 1),
                    "recency_boost": round(rec_score * 100, 1),
                }
            ))

        # Sort by score DESC
        scored_list.sort(key=lambda x: x.score, reverse=True)
        return scored_list

    def _calculate_jaccard(self, list1: List[str], list2: List[str]) -> float:
        if not list1 or not list2:
            return 0.0
        s1 = set(l.lower() for l in list1)
        s2 = set(l.lower() for l in list2)
        intersection = s1.intersection(s2)
        union = s1.union(s2)
        return len(intersection) / len(union)

    def _calculate_interest_similarity(self, user: UserProfile, candidates: List[UserSummary]) -> List[float]:
        """
        Uses TF-IDF and Cosine Similarity to find topical overlaps.
        """
        if TfidfVectorizer is None or not user.interests:
            # Fallback to simple Jaccard if library missing
            return [self._calculate_jaccard(user.interests, c.interests) for c in candidates]

        # Combine interests into "documents"
        docs = [" ".join(user.interests)]
        for c in candidates:
            docs.append(" ".join(c.interests) if c.interests else "")

        try:
            vectorizer = TfidfVectorizer(token_pattern=r"(?u)\b\w+\b")
            tfidf_matrix = vectorizer.fit_transform(docs)
            
            # cosine_similarity returns matrix[len(docs), len(docs)]
            # We want similarity of the first doc (user) with all others
            sims = cosine_similarity(tfidf_matrix[0:1], tfidf_matrix[1:])
            return sims[0].tolist()
        except:
            # If vocab is empty or too small
            return [0.0] * len(candidates)

    def _calculate_activity_score(self, user: UserProfile, candidate: UserSummary) -> float:
        """
        Calculates if the users are in a similar "Developer Tier".
        Uses Log-normalization: log(1 + x)
        """
        def get_tier_value(u):
            # Synthetic activity metric
            val = (u.followers * 5) + (u.public_repos * 10) + (u.stars if hasattr(u, 'stars') else 0)
            return np.log1p(val)

        u_val = get_tier_value(user)
        c_val = get_tier_value(candidate)

        if u_val == 0 or c_val == 0:
            return 0.0
            
        # Similarity = 1 - (diff / max)
        diff = abs(u_val - c_val)
        sim = 1.0 - (diff / max(u_val, c_val))
        return float(max(0.0, sim))

    def _calculate_recency_score(self, last_active: datetime | None) -> float:
        if not last_active:
            return 0.0
        
        now = datetime.now(timezone.utc)
        if last_active.tzinfo is None:
            last_active = last_active.replace(tzinfo=timezone.utc)
            
        diff_days = (now - last_active).days
        
        if diff_days <= 1: return 1.0
        if diff_days <= 3: return 0.8
        if diff_days <= 7: return 0.5
        if diff_days <= 30: return 0.2
        return 0.0
