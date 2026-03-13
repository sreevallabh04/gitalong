from __future__ import annotations
import httpx
from ..config import get_settings


class GitHubService:
    """
    Fetches developer data from the GitHub REST API.
    Uses a Personal Access Token for higher rate limits.
    """

    BASE = "https://api.github.com"

    def __init__(self):
        settings = get_settings()
        headers = {"Accept": "application/vnd.github+json"}
        if settings.github_token:
            headers["Authorization"] = f"Bearer {settings.github_token}"
        self._client = httpx.AsyncClient(
            base_url=self.BASE,
            headers=headers,
            timeout=10.0,
        )

    async def get_user(self, username: str) -> dict:
        resp = await self._client.get(f"/users/{username}")
        resp.raise_for_status()
        return resp.json()

    async def get_repos(self, username: str, per_page: int = 100) -> list[dict]:
        resp = await self._client.get(
            f"/users/{username}/repos",
            params={"per_page": per_page, "sort": "updated"},
        )
        resp.raise_for_status()
        return resp.json()

    async def get_top_languages(self, username: str) -> list[str]:
        """Return languages sorted by usage across all repos."""
        repos = await self.get_repos(username)
        lang_counts: dict[str, int] = {}
        for repo in repos:
            lang = repo.get("language")
            if lang:
                lang_counts[lang] = lang_counts.get(lang, 0) + 1
        return sorted(lang_counts, key=lang_counts.get, reverse=True)  # type: ignore

    async def get_topics(self, username: str) -> list[str]:
        repos = await self.get_repos(username)
        topics: set[str] = set()
        for repo in repos:
            topics.update(repo.get("topics", []))
        return list(topics)

    async def calculate_developer_score(self, username: str) -> dict:
        """
        Returns a dict with:
            total_stars, total_forks, total_commits (approx),
            public_repos, languages, topics, activity_score
        """
        try:
            user = await self.get_user(username)
            repos = await self.get_repos(username)
        except httpx.HTTPError:
            return {
                "total_stars": 0, "total_forks": 0, "total_commits": 0,
                "public_repos": 0, "languages": [], "topics": [],
                "activity_score": 0.0,
            }

        total_stars = sum(r.get("stargazers_count", 0) for r in repos)
        total_forks = sum(r.get("forks_count", 0) for r in repos)

        lang_counts: dict[str, int] = {}
        topics: set[str] = set()
        for repo in repos:
            lang = repo.get("language")
            if lang:
                lang_counts[lang] = lang_counts.get(lang, 0) + 1
            topics.update(repo.get("topics", []))

        languages = sorted(lang_counts, key=lang_counts.get, reverse=True)  # type: ignore

        # Activity score: 0-100 based on stars, repos, followers
        activity_score = min(
            100.0,
            (total_stars * 2 + user.get("public_repos", 0) * 3 + user.get("followers", 0)) / 10,
        )

        return {
            "total_stars": total_stars,
            "total_forks": total_forks,
            "total_commits": 0,  # Requires separate API call per repo
            "public_repos": user.get("public_repos", 0),
            "language_count": len(lang_counts),
            "languages": languages[:10],
            "topics": list(topics)[:20],
            "activity_score": round(activity_score, 2),
        }
