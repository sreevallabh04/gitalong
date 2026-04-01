from __future__ import annotations

import math
from dataclasses import dataclass

from ..models.user import UserProfile
from ..repositories.ml_model_repository import MlModelRepository
from .ml_features import extract_pair_features


def _sigmoid(z: float) -> float:
    # numerically stable sigmoid
    if z >= 0:
        ez = math.exp(-z)
        return 1.0 / (1.0 + ez)
    ez = math.exp(z)
    return ez / (1.0 + ez)


@dataclass(frozen=True)
class MlRankResult:
    score: float
    top_reasons: list[str]
    contributions: dict[str, float]


class MlRanker:
    """
    Lightweight inference for a linear model stored in Supabase.
    If no model params exist, returns None and callers should fallback.
    """

    def __init__(
        self,
        *,
        repo: MlModelRepository | None = None,
        model_name: str = "logreg_v1",
    ):
        self._repo = repo or MlModelRepository()
        self._model_name = model_name

    def score_pair(
        self,
        *,
        viewer: UserProfile,
        candidate: UserProfile,
        cf_count: int,
        max_cf: int,
    ) -> MlRankResult | None:
        params = self._repo.get_latest_params(self._model_name)
        if not params:
            return None

        weights = params.get("weights") or {}
        w_map: dict[str, float] = weights.get("w") or {}
        b = float(weights.get("b", 0.0))

        x = extract_pair_features(viewer, candidate, cf_count=cf_count, max_cf=max_cf)

        z = b
        contributions: dict[str, float] = {}
        for k, v in x.items():
            w = float(w_map.get(k, 0.0))
            c = w * float(v)
            contributions[k] = c
            z += c

        p_like = float(_sigmoid(z))

        # top reasons = features with largest positive contribution (excluding bias)
        ranked = sorted(
            ((k, c) for k, c in contributions.items() if k != "bias"),
            key=lambda kv: kv[1],
            reverse=True,
        )
        top_reasons = [k for k, c in ranked[:3] if c > 0]

        return MlRankResult(score=p_like, top_reasons=top_reasons, contributions=contributions)

