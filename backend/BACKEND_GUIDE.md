# GitAlong Backend: File-by-File Technical Guide 📂

This document provides a comprehensive overview of the backend architecture and the specific role of each file in the GitAlong Python API.

---

## 🏗️ Core Application Structure

### `app/main.py`
The entry point of the FastAPI application. It initializes the app, configures **CORS** (allowing the Flutter frontend to connect), and includes the versioned API routers.
0l-k9

### `app/config.py`
A centralized configuration system using `pydantic-settings`. It safely loads environment variables from `.env` (like Supabase URLs and API keys) and provides a singleton `Settings` object used throughout the app.0

### `app/database.py`
Handles the connection to Supabase. It provides a cached `get_supabase_client()` function that initializes the Supabase Python SDK using the **Service Role Key** for administrative database access.

---

## 🔐 Security Layer

### `app/core/auth.py`
The security gatekeeper. It contains the `verify_token` dependency which:
1.  Extracts the **JWT** from the `Authorization` header.
2.  Fetches public RSA keys from Supabase's **JWKS** (JSON Web Key Set) endpoint.
3.  Verifies the token's signature and expiration.
4.  Returns the user's UUID (`sub`) to the API endpoints.

---

## 🛣️ API Endpoints (v1)

### `app/api/v1/health.py`
A simple diagnostic endpoint (`/api/v1/health`) used to verify that the API is alive and reachable from the mobile app.

### `app/api/v1/recommendations.py`
The primary interface for the discovery feature. It calls the `RecommendationService` to fetch personalized developer matches for the authenticated user.

### `app/api/v1/users.py`
Handles user-specific operations, such as retrieving a full profile or triggering a **GitHub Data Refresh** to update a user's latest stats.

---

## 🧠 The Intelligence Layer (Services)

### `app/services/heavy_recommendation_engine.py` (The "Brain")
Our advanced, ML-ready scoring engine. It uses:
- **Scikit-Learn (TF-IDF)** to analyze interests.
- **NumPy** for vector calculations.
- **Log-Normalization** to ensure fair activity scoring.
- It calculates a 0–100 score and provides a granular `score_breakdown`.

### `app/services/recommendation_service.py`
The orchestrator. It fetches the current user's profile, gets a pool of candidate users from the database, runs them through the `HeavyRecommendationEngine`, and formats the final response.

### `app/services/github_service.py`
Uses `httpx` (async) to communicate with the **GitHub GraphQL/REST APIs**. It calculates a "Developer Activity Score" based on repos, stars, and contribution frequency.

---

## 💾 Data Layer (Repositories & Models)

### `app/repositories/user_repository.py`
Encapsulates all Supabase queries related to the `users` table. This keeps our service logic clean and free of raw SQL or SDK calls.

### `app/repositories/swipe_repository.py`
Handles access to the `swipes` table. It retrieves a list of who the user has already swiped on (to exclude them from recommendations) and provides data for Collaborative Filtering.

### `app/models/user.py` & `app/models/recommendation.py`
Pydantic schemas that define the data structures for our API. They act as "contracts" to ensure the data sent to the Flutter app is always valid and consistent.

---

## 🛠️ DevOps & Environment
- **`.env`**: Stores sensitive secrets (Supabase keys, GitHub tokens).
- **`requirements.txt`**: Lists Python dependencies (FastAPI, Scikit-Learn, PyJWT).
- **`Dockerfile`**: Defines the container image for cloud deployment (e.g., to Render or AWS).
- **`docker-compose.yml`**: Simplifies running the API and its dependencies in a local environment.
