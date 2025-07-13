# 🔗 GitAlong Hybrid Backend Architecture

## 🎯 Overview

GitAlong uses a **hybrid backend architecture** combining Firebase and FastAPI to leverage the strengths of both platforms:

- **Firebase**: Authentication, real-time chat, push notifications, file storage
- **FastAPI**: ML matching algorithms, analytics, complex data processing
- **PostgreSQL**: Future scaling for advanced analytics and complex relationships

## 🏗️ Architecture Diagram

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │    Firebase     │    │    FastAPI      │
│                 │    │                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │   Auth UI   │◄┼────┼►│ Firebase    │ │    │ │ ML Matching │ │
│ │             │ │    │ │   Auth      │ │    │ │             │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
│                 │    │                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │   Chat UI   │◄┼────┼►│ Firestore   │ │    │ │ Analytics   │ │
│ │             │ │    │ │ Real-time   │ │    │ │             │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
│                 │    │                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │ Swipe UI    │◄┼────┼►│ Cloud       │ │    │ │ User Sync   │ │
│ │             │ │    │ │ Functions   │ │    │ │             │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🔐 Authentication Flow

### 1. User Sign-In Process
```dart
// 1. User signs in via GitHub/Google
final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

// 2. Firebase creates/updates user
final user = userCredential.user;

// 3. BackendService automatically syncs with FastAPI
await BackendService.instance._syncUserWithBackend(user);
```

### 2. Token Management
```dart
// Firebase ID token is automatically added to all FastAPI requests
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      options.headers['Authorization'] = 'Bearer $token';
    }
  }
}
```

## 📡 API Communication

### FastAPI Endpoints

#### User Management
```python
# POST /users/sync
{
  "user_id": "firebase_uid",
  "email": "user@example.com",
  "profile_data": {...},
  "github_data": {...},
  "auth_provider": "github"
}

# PUT /users/profile
{
  "user_id": "firebase_uid",
  "name": "John Doe",
  "tech_stack": ["Flutter", "Python"],
  "skills": ["Mobile Development"],
  "role": "contributor"
}
```

#### ML Matching
```python
# POST /recommendations
{
  "user_id": "firebase_uid",
  "exclude_user_ids": ["user1", "user2"],
  "max_recommendations": 20,
  "include_analytics": true
}

# POST /swipe
{
  "swiper_id": "firebase_uid",
  "target_id": "target_user_id",
  "direction": "right|left",
  "target_type": "user|project",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

#### Analytics
```python
# GET /analytics?user_id=firebase_uid&metric=matches&start_date=2024-01-01
{
  "user_id": "firebase_uid",
  "metrics": {
    "total_matches": 15,
    "successful_connections": 8,
    "response_rate": 0.53
  }
}
```

## 🔒 Security Implementation

### 1. Firebase Token Validation (FastAPI)
```python
from firebase_admin import auth, initialize_app

# Initialize Firebase Admin SDK
initialize_app()

async def verify_firebase_token(token: str):
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token['uid']
    except Exception as e:
        raise HTTPException(status_code=401, detail="Invalid token")

@app.post("/recommendations")
async def get_recommendations(
    request: RecommendationRequest,
    authorization: str = Header(...)
):
    # Extract token from Authorization header
    token = authorization.replace("Bearer ", "")
    user_id = await verify_firebase_token(token)
    
    # Process request...
```

### 2. CORS Configuration
```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://gitalong.com",
        "https://app.gitalong.com",
        "http://localhost:3000"  # Development
    ],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["*"],
)
```

### 3. Rate Limiting
```python
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter

@app.post("/swipe")
@limiter.limit("100/minute")
async def record_swipe(request: Request, swipe_data: SwipeRequest):
    # Process swipe...
```

## 🚀 Deployment Setup

### 1. Environment Variables
```env
# Flutter App (.env)
FASTAPI_BASE_URL=https://api.gitalong.com
FASTAPI_API_KEY=your_api_key_here
FIREBASE_PROJECT_ID=gitalong-c8075

# FastAPI Backend
FIREBASE_PROJECT_ID=gitalong-c8075
FIREBASE_PRIVATE_KEY_ID=your_private_key_id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@gitalong-c8075.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your_client_id
FIREBASE_AUTH_URI=https://accounts.google.com/o/oauth2/auth
FIREBASE_TOKEN_URI=https://oauth2.googleapis.com/token
FIREBASE_AUTH_PROVIDER_X509_CERT_URL=https://www.googleapis.com/oauth2/v1/certs
FIREBASE_CLIENT_X509_CERT_URL=https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xxxxx%40gitalong-c8075.iam.gserviceaccount.com
```

### 2. Firebase Service Account Setup
```bash
# Download service account key from Firebase Console
# Project Settings > Service Accounts > Generate New Private Key
# Save as firebase-service-account.json
```

### 3. FastAPI Backend Deployment
```python
# main.py
import firebase_admin
from firebase_admin import credentials

# Initialize Firebase Admin SDK
cred = credentials.Certificate("firebase-service-account.json")
firebase_admin.initialize_app(cred)

# FastAPI app setup
app = FastAPI(title="GitAlong API", version="1.0.0")
```

## 📊 Data Flow Examples

### 1. User Authentication Flow
```mermaid
sequenceDiagram
    participant U as User
    participant F as Flutter App
    participant FB as Firebase
    participant API as FastAPI

    U->>F: Sign in with GitHub
    F->>FB: Authenticate with GitHub
    FB->>F: Return Firebase user
    F->>API: Sync user data (with Firebase token)
    API->>FB: Verify Firebase token
    API->>API: Store user data
    API->>F: Confirm sync
```

### 2. ML Recommendation Flow
```mermaid
sequenceDiagram
    participant F as Flutter App
    participant FB as Firebase
    participant API as FastAPI
    participant ML as ML Engine

    F->>FB: Get current user
    F->>API: Request recommendations (with Firebase token)
    API->>FB: Verify token
    API->>ML: Get ML recommendations
    ML->>API: Return recommendations
    API->>F: Return user recommendations
```

### 3. Swipe Recording Flow
```mermaid
sequenceDiagram
    participant F as Flutter App
    participant API as FastAPI
    participant ML as ML Engine
    participant FB as Firebase

    F->>API: Record swipe (with Firebase token)
    API->>FB: Verify token
    API->>ML: Store swipe for training
    API->>FB: Update match status
    API->>F: Confirm swipe recorded
```

## 🔄 Data Synchronization

### Firebase ↔ FastAPI Sync
```dart
// Automatic sync on auth state change
_auth.authStateChanges().listen((User? user) async {
  if (user != null) {
    await _syncUserWithBackend(user);
  }
});

// Manual sync when profile updates
Future<void> updateProfile(UserModel user) async {
  // Update in Firebase
  await _firestore.collection('users').doc(user.id).set(user.toJson());
  
  // Sync to FastAPI
  await _backendService.updateUserProfile(user);
}
```

### Real-time Updates
```dart
// Listen for real-time updates from Firebase
FirebaseFirestore.instance
    .collection('matches')
    .where('participants', arrayContains: userId)
    .snapshots()
    .listen((snapshot) {
      // Handle real-time match updates
    });
```

## 📈 Scaling Strategy

### Phase 1: Firebase + FastAPI (Current)
- **Users**: 1K-10K
- **Firebase**: Auth, chat, notifications
- **FastAPI**: ML matching, analytics
- **Cost**: ~$200-700/month

### Phase 2: Add PostgreSQL (10K+ users)
```sql
-- Migration strategy for critical data
CREATE TABLE match_history (
    id UUID PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    target_id VARCHAR(255) NOT NULL,
    direction VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    metadata JSONB
);

CREATE TABLE user_analytics (
    id UUID PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL,
    recorded_at TIMESTAMP DEFAULT NOW()
);
```

### Phase 3: Microservices (100K+ users)
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Auth Service   │    │  Chat Service   │    │  ML Service     │
│                 │    │                 │    │                 │
│ • Firebase Auth │    │ • WebSocket     │    │ • FastAPI       │
│ • JWT Tokens    │    │ • Real-time     │    │ • ML Models     │
│ • Rate Limiting │    │ • Notifications │    │ • Analytics     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🛡️ Security Best Practices

### 1. Token Management
- Firebase ID tokens expire every hour
- Automatic token refresh in AuthInterceptor
- Secure token storage in Flutter Secure Storage

### 2. API Security
- All FastAPI endpoints require Firebase token validation
- Rate limiting on all endpoints
- CORS properly configured
- Input validation and sanitization

### 3. Data Protection
- Sensitive data encrypted at rest
- HTTPS for all communications
- Regular security audits
- GDPR compliance ready

## 🔧 Monitoring & Debugging

### 1. Logging Strategy
```dart
// Structured logging throughout the app
AppLogger.logger.i('🔐 User authenticated: ${user.email}');
AppLogger.logger.d('📡 FastAPI Base URL: $_baseUrl');
AppLogger.logger.success('✅ User synced with FastAPI successfully');
```

### 2. Error Handling
```dart
try {
  final recommendations = await backendService.getMLRecommendations(userId: userId);
  return recommendations;
} catch (e) {
  // Return cached results on error
  final cached = _getCachedRecommendations(userId);
  if (cached != null) {
    return cached;
  }
  rethrow;
}
```

### 3. Health Checks
```dart
// Backend health monitoring
final health = await backendService.getBackendHealth();
if (health['status'] != 'healthy') {
  // Handle backend issues
}
```

## 🚀 Production Checklist

### ✅ Authentication
- [ ] Firebase Auth configured
- [ ] GitHub OAuth working
- [ ] Token refresh working
- [ ] Session management implemented

### ✅ API Communication
- [ ] FastAPI backend deployed
- [ ] Firebase token validation working
- [ ] CORS configured
- [ ] Rate limiting implemented

### ✅ Data Sync
- [ ] User sync on auth working
- [ ] Profile updates syncing
- [ ] Real-time updates working
- [ ] Error handling implemented

### ✅ Security
- [ ] All endpoints secured
- [ ] Environment variables set
- [ ] Service account configured
- [ ] HTTPS enforced

### ✅ Monitoring
- [ ] Logging implemented
- [ ] Error tracking configured
- [ ] Health checks working
- [ ] Analytics tracking

## 📚 Additional Resources

- [Firebase Admin SDK Documentation](https://firebase.google.com/docs/admin/setup)
- [FastAPI Security Documentation](https://fastapi.tiangolo.com/tutorial/security/)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [Riverpod State Management](https://riverpod.dev/)

---

**This hybrid architecture provides the best of both worlds: Firebase's real-time capabilities and FastAPI's computational power, all while maintaining security and scalability for GitAlong's growth.** 