from __future__ import annotations

import logging
from dataclasses import dataclass
from datetime import datetime, timezone

import numpy as np

from ..repositories.ml_model_repository import MlModelRepository
from ..repositories.swipe_repository import SwipeRepository
from ..repositories.user_repository import UserRepository
from .ml_features import extract_pair_features
from .recommendation_engine import build_cf_signal

logger = logging.getLogger(__name__)


@dataclass(frozen=True)
class TrainResult:
    model_name: str
    version: int
    trained_at: str
    n_rows: int
    n_users: int
    n_pos: int
    auc: float | None
    feature_names: list[str]


class MlTrainer:
    def __init__(
        self,
        *,
        model_repo: MlModelRepository | None = None,
        swipe_repo: SwipeRepository | None = None,
        user_repo: UserRepository | None = None,
        model_name: str = "logreg_v1",
    ):
        self._model_repo = model_repo or MlModelRepository()
        self._swipes = swipe_repo or SwipeRepository()
        self._users = user_repo or UserRepository()
        self._model_name = model_name

    def retrain(self, *, limit: int = 20000, superlike_weight: float = 3.0) -> TrainResult:
        try:
            from sklearn.linear_model import LogisticRegression
            from sklearn.metrics import roc_auc_score
        except ImportError as exc:
            raise RuntimeError(
                "scikit-learn is required to retrain the ML model. "
                "Install it in an environment with supported Python wheels "
                "(e.g. Python 3.12)."
            ) from exc

        rows = self._swipes.get_training_swipes(limit=limit)
        if not rows:
            raise ValueError("No swipe data available for training.")

        # CF signal from all swipes (cheap, already used elsewhere)
        cf_signal = build_cf_signal(self._swipes.get_all_swipes())
        max_cf = max(cf_signal.values(), default=1)

        # Build feature rows
        X: list[list[float]] = []
        y: list[int] = []
        sample_w: list[float] = []

        # Cache user profiles to avoid repeated DB calls
        user_cache: dict[str, object] = {}

        def get_user(uid: str):
            if uid in user_cache:
                return user_cache[uid]
            prof = self._users.get_by_id(uid)
            user_cache[uid] = prof
            return prof

        feature_names: list[str] | None = None

        for r in rows:
            viewer_id = r.get("swiper_id")
            cand_id = r.get("swiped_user_id")
            action = r.get("action")
            if not viewer_id or not cand_id or action not in ("like", "dislike", "superLike"):
                continue

            viewer = get_user(viewer_id)
            cand = get_user(cand_id)
            if viewer is None or cand is None:
                continue

            feats = extract_pair_features(
                viewer,
                cand,
                cf_count=int(cf_signal.get(cand_id, 0)),
                max_cf=max_cf,
            )
            if feature_names is None:
                feature_names = list(feats.keys())
            x_row = [float(feats[k]) for k in feature_names]

            X.append(x_row)
            label = 1 if action in ("like", "superLike") else 0
            y.append(label)
            sample_w.append(superlike_weight if action == "superLike" else 1.0)

        if not X:
            raise ValueError("No usable training rows after filtering.")

        Xn = np.asarray(X, dtype=np.float32)
        yn = np.asarray(y, dtype=np.int32)
        wn = np.asarray(sample_w, dtype=np.float32)

        # Simple time-aware split:
        # rows are fetched newest-first, so we train on the oldest ~80%
        # and keep newest ~20% as validation.
        split = max(1, int(len(yn) * 0.8))
        X_train, X_val = Xn[:split], Xn[split:]
        y_train, y_val = yn[:split], yn[split:]
        w_train, w_val = wn[:split], wn[split:]

        if len(np.unique(y_train)) < 2:
            # For tiny MVP datasets, fallback to training on all rows
            # when the split accidentally collapses to one class.
            if len(np.unique(yn)) < 2:
                raise ValueError(
                    "Not enough class diversity in data. "
                    "Need both like/superLike and dislike labels."
                )
            X_train, y_train, w_train = Xn, yn, wn
            X_val = np.asarray([], dtype=np.float32).reshape(0, Xn.shape[1])
            y_val = np.asarray([], dtype=np.int32)
            w_val = np.asarray([], dtype=np.float32)

        clf = LogisticRegression(
            penalty="l2",
            C=1.0,
            solver="lbfgs",
            max_iter=500,
        )
        clf.fit(X_train, y_train, sample_weight=w_train)

        auc: float | None = None
        try:
            if len(y_val) > 0 and len(np.unique(y_val)) > 1:
                p = clf.predict_proba(X_val)[:, 1]
                auc = float(roc_auc_score(y_val, p, sample_weight=w_val))
        except Exception:
            auc = None

        # Persist weights
        trained_at = datetime.now(timezone.utc).isoformat()
        latest = self._model_repo.get_latest_params(self._model_name)
        version = int((latest or {}).get("version") or 0) + 1

        w_map = {name: float(coef) for name, coef in zip(feature_names or [], clf.coef_[0])}
        b = float(clf.intercept_[0])

        payload = {
            "b": b,
            "w": w_map,
        }
        schema = {
            "model": "logistic_regression",
            "features": feature_names or [],
            "label": "like_or_superlike",
            "superlike_weight": superlike_weight,
        }
        self._model_repo.upsert_params(
            model_name=self._model_name,
            version=version,
            trained_at_iso=trained_at,
            weights=payload,
            feature_schema=schema,
        )

        n_pos = int(yn.sum())
        logger.info(
            "ML retrain complete model=%s v=%s rows=%s pos=%s auc=%s",
            self._model_name,
            version,
            len(yn),
            n_pos,
            auc,
        )

        return TrainResult(
            model_name=self._model_name,
            version=version,
            trained_at=trained_at,
            n_rows=int(len(yn)),
            n_users=len(user_cache),
            n_pos=n_pos,
            auc=auc,
            feature_names=feature_names or [],
        )

