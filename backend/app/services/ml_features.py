from __future__ import annotations

import math
from datetime import datetime, timezone

from ..models.user import UserProfile


def _safe_lower_set(values: list[str] | None) -> set[str]:
    if not values:
        return set()
    return {v.strip().lower() for v in values if v and v.strip()}


def _jaccard(a: set[str], b: set[str]) -> float:
    if not a or not b:
        return 0.0
    inter = len(a & b)
    union = len(a | b)
    return inter / union if union else 0.0


def _recency_days(profile: UserProfile) -> int:
    ref = profile.last_active_at or profile.created_at
    now = datetime.now(timezone.utc)
    if ref.tzinfo is None:
        ref = ref.replace(tzinfo=timezone.utc)
    return max(0, (now - ref).days)


def extract_pair_features(
    viewer: UserProfile,
    candidate: UserProfile,
    *,
    cf_count: int = 0,
    max_cf: int = 1,
) -> dict[str, float]:
    """
    Deterministic, cheap feature set used by both ML trainer and inference.
    Keep this stable: changing features requires bumping feature_schema/version.
    """
    viewer_lang = _safe_lower_set(viewer.languages)
    cand_lang = _safe_lower_set(candidate.languages)
    viewer_topics = _safe_lower_set(viewer.interests)
    cand_topics = _safe_lower_set(candidate.interests)

    lang_j = _jaccard(viewer_lang, cand_lang)
    topic_j = _jaccard(viewer_topics, cand_topics)

    lang_inter = len(viewer_lang & cand_lang)
    topic_inter = len(viewer_topics & cand_topics)

    # Activity-ish signals (log-scaled, stable ranges)
    v_follow = math.log1p(max(0, viewer.followers))
    c_follow = math.log1p(max(0, candidate.followers))
    v_repos = math.log1p(max(0, viewer.public_repos))
    c_repos = math.log1p(max(0, candidate.public_repos))

    # Similarity on activity scale: 1 - normalized absolute delta
    follow_sim = 1.0 - (abs(v_follow - c_follow) / max(v_follow, c_follow, 1e-6))
    repos_sim = 1.0 - (abs(v_repos - c_repos) / max(v_repos, c_repos, 1e-6))

    # Candidate quality proxies
    cand_has_avatar = 1.0 if bool(candidate.avatar_url) else 0.0
    cand_has_bio = 1.0 if bool(candidate.bio and candidate.bio.strip()) else 0.0

    # Recency buckets (candidate only)
    days = _recency_days(candidate)
    rec_le_7 = 1.0 if days <= 7 else 0.0
    rec_le_30 = 1.0 if days <= 30 else 0.0
    rec_le_90 = 1.0 if days <= 90 else 0.0

    cf_norm = float(cf_count) / float(max(max_cf, 1))

    return {
        # overlaps
        "lang_jaccard": float(lang_j),
        "topic_jaccard": float(topic_j),
        "lang_intersection": float(lang_inter),
        "topic_intersection": float(topic_inter),
        # activity similarity
        "followers_sim": float(max(0.0, min(1.0, follow_sim))),
        "repos_sim": float(max(0.0, min(1.0, repos_sim))),
        # quality proxies
        "cand_has_avatar": float(cand_has_avatar),
        "cand_has_bio": float(cand_has_bio),
        # recency
        "cand_rec_le_7d": float(rec_le_7),
        "cand_rec_le_30d": float(rec_le_30),
        "cand_rec_le_90d": float(rec_le_90),
        # CF popularity
        "cf_norm": float(max(0.0, min(1.0, cf_norm))),
        # bias
        "bias": 1.0,
    }

