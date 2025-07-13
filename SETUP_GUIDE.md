# 🚀 GitAlong Hybrid Backend Setup Guide

## 📋 Prerequisites

- **Flutter SDK** 3.24.5+
- **Python** 3.11+
- **Docker** and **Docker Compose**
- **Firebase Project** with Authentication and Firestore enabled
- **GitHub OAuth App** configured

## 🔧 Step 1: Firebase Setup

### 1.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project: `gitalong-c8075`
3. Enable Authentication with GitHub and Google providers
4. Enable Firestore Database
5. Enable Cloud Functions (for future use)

### 1.2 Configure Authentication
```bash
# In Firebase Console > Authentication > Sign-in method
# Enable GitHub provider
GitHub Client ID: your_github_client_id
GitHub Client Secret: your_github_client_secret

# Enable Google provider
# Add your domain to authorized domains
```

### 1.3 Download Service Account Key
1. Go to Project Settings > Service Accounts
2. Click "Generate New Private Key"
3. Save as `firebase-service-account.json` in project root

## 🔧 Step 2: Environment Configuration

### 2.1 Flutter Environment (.env)
```env
# App Configuration
APP_NAME=GitAlong
ENVIRONMENT=development
ENABLE_ANALYTICS=true
ENABLE_DEBUG_LOGGING=true

# Firebase Configuration
FIREBASE_PROJECT_ID=gitalong-c8075
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_APP_ID=your_firebase_app_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id

# FastAPI Backend
FASTAPI_BASE_URL=http://localhost:8000
FASTAPI_API_KEY=your_api_key_here

# GitHub OAuth
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret
GITHUB_REDIRECT_URI=com.gitalong.app://oauth/callback
```

### 2.2 FastAPI Environment (.env)
```env
# Firebase Admin SDK
FIREBASE_PROJECT_ID=gitalong-c8075
FIREBASE_PRIVATE_KEY_ID=your_private_key_id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@gitalong-c8075.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your_client_id
FIREBASE_AUTH_URI=https://accounts.google.com/o/oauth2/auth
FIREBASE_TOKEN_URI=https://oauth2.googleapis.com/token
FIREBASE_AUTH_PROVIDER_X509_CERT_URL=https://www.googleapis.com/oauth2/v1/certs
FIREBASE_CLIENT_X509_CERT_URL=https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xxxxx%40gitalong-c8075.iam.gserviceaccount.com

# Database (for future use)
DATABASE_URL=postgresql://postgres:password@localhost:5432/gitalong
REDIS_URL=redis://localhost:6379

# Security
SECRET_KEY=your_secret_key_here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

## 🔧 Step 3: Backend Setup

### 3.1 Install Python Dependencies
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 3.2 Run FastAPI Backend
```bash
# Development
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Production
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```

### 3.3 Test Backend Health
```bash
curl http://localhost:8000/health
# Expected response: {"status": "healthy", "service": "GitAlong API"}
```

## 🔧 Step 4: Flutter App Setup

### 4.1 Install Dependencies
```bash
flutter pub get
```

### 4.2 Configure Firebase
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your platforms
flutterfire configure --project=gitalong-c8075
```

### 4.3 Run the App
```bash
# Make sure FastAPI backend is running first
flutter run
```

## 🔧 Step 5: Docker Setup (Optional)

### 5.1 Build and Run with Docker
```bash
# Build and start all services
docker-compose up --build

# Run only backend services
docker-compose up api postgres redis

# Run with monitoring
docker-compose --profile monitoring up
```

### 5.2 Production Deployment
```bash
# Run with production profile
docker-compose --profile production up -d
```

## 🔧 Step 6: Testing the Integration

### 6.1 Test Authentication Flow
1. Open the Flutter app
2. Sign in with GitHub
3. Check Firebase Console > Authentication for new user
4. Check FastAPI logs for user sync

### 6.2 Test ML Recommendations
```bash
# Test with curl (replace with actual Firebase token)
curl -X POST "http://localhost:8000/recommendations" \
  -H "Authorization: Bearer YOUR_FIREBASE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "test_user_id",
    "max_recommendations": 5
  }'
```

### 6.3 Test Swipe Recording
```bash
curl -X POST "http://localhost:8000/swipe" \
  -H "Authorization: Bearer YOUR_FIREBASE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "swiper_id": "user1",
    "target_id": "user2",
    "direction": "right",
    "target_type": "user",
    "timestamp": "2024-01-01T00:00:00Z"
  }'
```

## 🔧 Step 7: Production Deployment

### 7.1 Environment Variables
Set all production environment variables:
```bash
# Flutter app
FASTAPI_BASE_URL=https://api.gitalong.com
ENVIRONMENT=production
ENABLE_DEBUG_LOGGING=false

# FastAPI backend
DATABASE_URL=postgresql://user:pass@prod-db:5432/gitalong
REDIS_URL=redis://prod-redis:6379
```

### 7.2 SSL Certificate
```bash
# Generate SSL certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/private.key \
  -out nginx/ssl/certificate.crt
```

### 7.3 Deploy to Cloud
```bash
# Deploy to your preferred cloud provider
# Example: Google Cloud Run
gcloud run deploy gitalong-api \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

## 🔧 Step 8: Monitoring Setup

### 8.1 Health Checks
```bash
# Backend health
curl https://api.gitalong.com/health

# Database health
docker-compose exec postgres pg_isready

# Redis health
docker-compose exec redis redis-cli ping
```

### 8.2 Logs Monitoring
```bash
# View FastAPI logs
docker-compose logs -f api

# View Flutter app logs
flutter logs
```

## 🔧 Step 9: Database Migration (Future)

### 9.1 PostgreSQL Setup
```sql
-- Create tables for critical data
CREATE TABLE match_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(255) NOT NULL,
    target_id VARCHAR(255) NOT NULL,
    direction VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    metadata JSONB
);

CREATE TABLE user_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(255) NOT NULL,
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL,
    recorded_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_match_history_user_id ON match_history(user_id);
CREATE INDEX idx_user_analytics_user_id ON user_analytics(user_id);
```

### 9.2 Data Migration Script
```python
# migration_script.py
import asyncio
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

async def migrate_data():
    # Migrate critical data from Firebase to PostgreSQL
    # This will be implemented when scaling to 10K+ users
    pass
```

## 🔧 Step 10: Security Checklist

### ✅ Authentication
- [ ] Firebase Auth configured
- [ ] GitHub OAuth working
- [ ] Token validation implemented
- [ ] Session management secure

### ✅ API Security
- [ ] All endpoints require authentication
- [ ] CORS properly configured
- [ ] Rate limiting implemented
- [ ] Input validation active

### ✅ Data Protection
- [ ] Environment variables secured
- [ ] Service account key protected
- [ ] HTTPS enforced
- [ ] Database encrypted

### ✅ Monitoring
- [ ] Health checks working
- [ ] Error logging configured
- [ ] Performance monitoring active
- [ ] Security alerts enabled

## 🚨 Troubleshooting

### Common Issues

#### 1. Firebase Token Verification Fails
```bash
# Check service account configuration
cat firebase-service-account.json

# Verify environment variables
echo $FIREBASE_PROJECT_ID
```

#### 2. FastAPI Connection Refused
```bash
# Check if backend is running
curl http://localhost:8000/health

# Check Docker logs
docker-compose logs api
```

#### 3. Flutter App Can't Connect
```bash
# Check environment variables
flutter run --dart-define=FASTAPI_BASE_URL=http://localhost:8000

# Check network connectivity
ping localhost
```

#### 4. CORS Errors
```bash
# Update CORS configuration in FastAPI
# Add your domain to allow_origins
```

## 📚 Additional Resources

- [Firebase Admin SDK Documentation](https://firebase.google.com/docs/admin/setup)
- [FastAPI Security Guide](https://fastapi.tiangolo.com/tutorial/security/)
- [Flutter Firebase Integration](https://firebase.flutter.dev/)
- [Docker Compose Reference](https://docs.docker.com/compose/)

## 🎯 Next Steps

1. **Test the complete flow** - Authentication → User Sync → ML Recommendations
2. **Monitor performance** - Check response times and error rates
3. **Scale gradually** - Add PostgreSQL when user base grows
4. **Implement advanced features** - Real-time notifications, advanced analytics
5. **Security audit** - Regular security reviews and updates

---

**Your hybrid backend is now ready for production! The combination of Firebase's real-time capabilities and FastAPI's ML power provides a solid foundation for GitAlong's growth.** 🚀 