# 🚀 GitAlong Production Deployment Guide

## Overview
This guide covers deploying GitAlong to production with enterprise-grade security, scalability, and reliability.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   Flutter Web   │    │   Mobile Apps   │
│   (iOS/Android) │    │   (PWA)         │    │   (iOS/Android) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Nginx Proxy   │
                    │   (SSL/TLS)     │
                    └─────────────────┘
                                 │
                    ┌─────────────────┐
                    │  FastAPI Backend│
                    │  (ML Matching)  │
                    └─────────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         │                       │                       │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   PostgreSQL    │    │     Redis       │    │   Firebase      │
│   (Database)    │    │   (Cache/Queue) │    │   (Auth/Storage)│
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📋 Prerequisites

### 1. Domain and SSL
- Register domain: `gitalong.com`
- Set up SSL certificates (Let's Encrypt or commercial)
- Configure DNS records

### 2. Cloud Infrastructure
- **Recommended**: Google Cloud Platform or AWS
- **Minimum specs**:
  - 2 vCPUs, 4GB RAM per service
  - 50GB SSD storage
  - Load balancer with SSL termination

### 3. Firebase Project
- Create Firebase project
- Enable Authentication, Firestore, Storage
- Download service account key
- Configure OAuth providers

### 4. GitHub OAuth App
- Create GitHub OAuth application
- Set redirect URI: `https://gitalong.com/oauth/callback`
- Note Client ID and Client Secret

## 🔧 Environment Setup

### 1. Create Environment File
```bash
cp .env.example .env.production
```

### 2. Configure Production Environment
```env
# App Configuration
APP_NAME=GitAlong
ENVIRONMENT=production
ENABLE_ANALYTICS=true
ENABLE_DEBUG_LOGGING=false
API_TIMEOUT_SECONDS=30

# GitHub OAuth
GITHUB_CLIENT_ID=your_production_github_client_id
GITHUB_CLIENT_SECRET=your_production_github_client_secret
GITHUB_REDIRECT_URI=https://gitalong.com/oauth/callback

# Database
DATABASE_URL=postgresql+asyncpg://gitalong_user:secure_password@localhost/gitalong
REDIS_URL=redis://:secure_redis_password@localhost:6379

# Firebase (from service account)
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_PRIVATE_KEY_ID=your_private_key_id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your_client_id
FIREBASE_AUTH_URI=https://accounts.google.com/o/oauth2/auth
FIREBASE_TOKEN_URI=https://oauth2.googleapis.com/token
FIREBASE_AUTH_PROVIDER_X509_CERT_URL=https://www.googleapis.com/oauth2/v1/certs
FIREBASE_CLIENT_X509_CERT_URL=https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xxxxx%40your-project.iam.gserviceaccount.com

# Security
JWT_SECRET=your_very_long_random_jwt_secret
ENCRYPTION_KEY=your_32_character_encryption_key

# Monitoring
SENTRY_DSN=your_sentry_dsn
MIXPANEL_TOKEN=your_mixpanel_token
```

## 🐳 Docker Deployment

### 1. Build Images
```bash
# Build backend
docker build -f backend/Dockerfile -t gitalong-backend ./backend

# Build web app
docker build -f Dockerfile.web -t gitalong-web .

# Build mobile apps (separate process)
flutter build apk --release
flutter build ios --release
```

### 2. Deploy with Docker Compose
```bash
# Start production stack
docker-compose -f docker-compose.prod.yml --env-file .env.production up -d

# Check status
docker-compose -f docker-compose.prod.yml ps

# View logs
docker-compose -f docker-compose.prod.yml logs -f backend
```

### 3. Database Migration
```bash
# Run database migrations
docker-compose -f docker-compose.prod.yml exec backend python -m alembic upgrade head

# Verify database connection
docker-compose -f docker-compose.prod.yml exec backend python -c "from main import get_db; print('Database OK')"
```

## 🔒 Security Configuration

### 1. Nginx Configuration
Create `nginx/nginx.conf`:
```nginx
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server backend:8000;
    }

    upstream web {
        server web:80;
    }

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=web:10m rate=30r/s;

    server {
        listen 80;
        server_name gitalong.com www.gitalong.com;
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name gitalong.com www.gitalong.com;

        ssl_certificate /etc/nginx/ssl/gitalong.com.crt;
        ssl_certificate_key /etc/nginx/ssl/gitalong.com.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
        ssl_prefer_server_ciphers off;

        # Security headers
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

        # API routes
        location /api/ {
            limit_req zone=api burst=20 nodelay;
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Web app
        location / {
            limit_req zone=web burst=50 nodelay;
            proxy_pass http://web;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

### 2. Firewall Configuration
```bash
# UFW firewall rules
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable
```

### 3. SSL Certificate (Let's Encrypt)
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d gitalong.com -d www.gitalong.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

## 📊 Monitoring & Analytics

### 1. Application Monitoring
```bash
# Install monitoring tools
docker run -d \
  --name prometheus \
  -p 9090:9090 \
  -v ./prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus

docker run -d \
  --name grafana \
  -p 3000:3000 \
  grafana/grafana
```

### 2. Log Aggregation
```bash
# ELK Stack or similar
docker run -d \
  --name elasticsearch \
  -p 9200:9200 \
  elasticsearch:8.11.0

docker run -d \
  --name kibana \
  -p 5601:5601 \
  kibana:8.11.0
```

### 3. Health Checks
```bash
# Create health check script
cat > health_check.sh << 'EOF'
#!/bin/bash
curl -f https://gitalong.com/api/health || exit 1
curl -f https://gitalong.com/ || exit 1
EOF

chmod +x health_check.sh

# Add to crontab
*/5 * * * * /path/to/health_check.sh
```

## 🔄 CI/CD Pipeline

### 1. GitHub Actions Workflow
Create `.github/workflows/deploy.yml`:
```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter test
      - run: flutter analyze

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to server
        uses: appleboy/ssh-action@v0.1.5
        with:
          host: ${{ secrets.HOST }}
          username: ${{ secrets.USERNAME }}
          key: ${{ secrets.KEY }}
          script: |
            cd /opt/gitalong
            git pull origin main
            docker-compose -f docker-compose.prod.yml down
            docker-compose -f docker-compose.prod.yml build
            docker-compose -f docker-compose.prod.yml up -d
            docker system prune -f
```

### 2. Automated Testing
```bash
# Backend tests
cd backend
pytest tests/ -v --cov=app --cov-report=html

# Frontend tests
flutter test
flutter drive --target=test_driver/app.dart
```

## 📈 Performance Optimization

### 1. Database Optimization
```sql
-- Create indexes
CREATE INDEX idx_user_profiles_skills ON user_profiles USING GIN(skills);
CREATE INDEX idx_swipe_history_swiper ON swipe_history(swiper_id, timestamp);
CREATE INDEX idx_matches_user ON matches(contributor_id, project_owner_id);

-- Optimize queries
ANALYZE user_profiles;
ANALYZE swipe_history;
ANALYZE matches;
```

### 2. Caching Strategy
```python
# Redis caching in backend
import redis
import json

redis_client = redis.Redis(host='localhost', port=6379, db=0)

def get_cached_user(user_id: str):
    cached = redis_client.get(f"user:{user_id}")
    if cached:
        return json.loads(cached)
    return None

def cache_user(user_id: str, user_data: dict):
    redis_client.setex(f"user:{user_id}", 3600, json.dumps(user_data))
```

### 3. CDN Configuration
```bash
# Configure CloudFlare or similar CDN
# Add DNS records pointing to your server
# Enable caching for static assets
# Configure SSL/TLS settings
```

## 🚨 Disaster Recovery

### 1. Backup Strategy
```bash
# Database backup
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
docker-compose -f docker-compose.prod.yml exec postgres pg_dump -U gitalong_user gitalong > backup_$DATE.sql
gzip backup_$DATE.sql
aws s3 cp backup_$DATE.sql.gz s3://gitalong-backups/

# Add to crontab
0 2 * * * /path/to/backup.sh
```

### 2. Recovery Procedures
```bash
# Database restore
gunzip backup_20231201_020000.sql.gz
docker-compose -f docker-compose.prod.yml exec -T postgres psql -U gitalong_user gitalong < backup_20231201_020000.sql

# Service restart
docker-compose -f docker-compose.prod.yml restart backend
```

## 📱 Mobile App Deployment

### 1. iOS App Store
```bash
# Build for App Store
flutter build ios --release --no-codesign
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release archive -archivePath build/Runner.xcarchive
xcodebuild -exportArchive -archivePath build/Runner.xcarchive -exportOptionsPlist exportOptions.plist -exportPath build/ios
```

### 2. Google Play Store
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

## 🔍 Post-Deployment Checklist

- [ ] SSL certificate is valid and auto-renewing
- [ ] All services are running and healthy
- [ ] Database migrations completed successfully
- [ ] Firebase configuration is correct
- [ ] GitHub OAuth is working
- [ ] Rate limiting is active
- [ ] Monitoring and alerting are set up
- [ ] Backups are running
- [ ] Mobile apps are published
- [ ] Performance testing completed
- [ ] Security scan passed
- [ ] Documentation is updated

## 🆘 Troubleshooting

### Common Issues

1. **Database Connection Failed**
   ```bash
   docker-compose -f docker-compose.prod.yml logs postgres
   docker-compose -f docker-compose.prod.yml exec postgres psql -U gitalong_user -d gitalong -c "SELECT 1;"
   ```

2. **Redis Connection Failed**
   ```bash
   docker-compose -f docker-compose.prod.yml logs redis
   docker-compose -f docker-compose.prod.yml exec redis redis-cli ping
   ```

3. **Backend API Errors**
   ```bash
   docker-compose -f docker-compose.prod.yml logs backend
   curl -f https://gitalong.com/api/health
   ```

4. **SSL Certificate Issues**
   ```bash
   sudo certbot certificates
   sudo certbot renew --dry-run
   ```

## 📞 Support

For production deployment support:
- Email: support@gitalong.com
- Documentation: https://docs.gitalong.com
- Status page: https://status.gitalong.com

---

**Remember**: Always test in staging environment before deploying to production! 