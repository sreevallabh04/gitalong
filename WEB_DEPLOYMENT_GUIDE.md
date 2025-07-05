# GitAlong Web Deployment Guide 🚀

This guide will help you deploy the GitAlong web app to Firebase Hosting with all the necessary configurations for a production-ready application.

## 📋 Prerequisites

Before deploying, ensure you have the following installed:

- **Flutter SDK** (3.24.5+)
- **Firebase CLI** (`npm install -g firebase-tools`)
- **Node.js** (for Firebase CLI)
- **Git** (for version control)

## 🔧 Setup Steps

### 1. Firebase Project Setup

1. **Create a Firebase Project**:
   ```bash
   # Go to Firebase Console
   https://console.firebase.google.com
   
   # Create a new project named "gitalong"
   ```

2. **Enable Firebase Services**:
   - **Authentication**: Enable Email/Password, Google, and GitHub providers
   - **Firestore Database**: Create database in production mode
   - **Hosting**: Enable Firebase Hosting
   - **Analytics**: Enable Google Analytics
   - **Storage**: Enable Cloud Storage (if needed)

3. **Configure Authentication**:
   ```bash
   # In Firebase Console > Authentication > Sign-in method
   # Enable Email/Password
   # Enable Google Sign-in
   # Enable GitHub Sign-in
   ```

### 2. Local Firebase Configuration

1. **Login to Firebase**:
   ```bash
   firebase login
   ```

2. **Initialize Firebase in your project**:
   ```bash
   firebase init hosting
   ```

3. **Configure Firebase**:
   - Select your project
   - Set public directory to `build/web`
   - Configure as single-page app: `Yes`
   - Don't overwrite `index.html`: `No`

### 3. Environment Configuration

1. **Create environment file**:
   ```bash
   cp .env.example .env
   ```

2. **Update `.env` with your Firebase config**:
   ```env
   # Firebase Configuration
   FIREBASE_PROJECT_ID=your-project-id
   FIREBASE_API_KEY=your-api-key
   FIREBASE_APP_ID=your-app-id
   FIREBASE_MESSAGING_SENDER_ID=your-sender-id
   
   # GitHub OAuth (for web)
   GITHUB_CLIENT_ID=your-github-client-id
   GITHUB_CLIENT_SECRET=your-github-client-secret
   GITHUB_REDIRECT_URI=https://your-domain.com/auth/callback
   
   # Google OAuth (for web)
   GOOGLE_CLIENT_ID=your-google-client-id
   GOOGLE_CLIENT_SECRET=your-google-client-secret
   ```

### 4. Firebase Security Rules

1. **Update Firestore Rules** (`firestore.rules`):
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Users collection
       match /users/{userId} {
         allow read: if request.auth != null;
         allow write: if request.auth != null && request.auth.uid == userId;
       }
       
       // Swipes collection
       match /swipes/{swipeId} {
         allow read, write: if request.auth != null;
       }
       
       // Matches collection
       match /matches/{matchId} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

2. **Deploy Firestore Rules**:
   ```bash
   firebase deploy --only firestore:rules
   ```

## 🚀 Deployment

### Quick Deployment

Use the provided deployment script:

```bash
# Make the script executable
chmod +x scripts/deploy_web.sh

# Run deployment
./scripts/deploy_web.sh
```

### Manual Deployment

1. **Build the web app**:
   ```bash
   flutter clean
   flutter pub get
   flutter build web --release --web-renderer canvaskit
   ```

2. **Deploy to Firebase**:
   ```bash
   firebase deploy --only hosting
   ```

## 🌐 Domain Configuration

### Custom Domain Setup

1. **Add Custom Domain**:
   ```bash
   # In Firebase Console > Hosting > Add custom domain
   # Add your domain: gitalong.app
   ```

2. **DNS Configuration**:
   ```
   # Add these DNS records to your domain provider:
   
   # A record
   gitalong.app -> 151.101.1.195
   gitalong.app -> 151.101.65.195
   
   # CNAME record
   www.gitalong.app -> gitalong.web.app
   ```

3. **SSL Certificate**:
   - Firebase automatically provisions SSL certificates
   - Wait 24-48 hours for certificate activation

### Subdomain Configuration

For staging/development environments:

```bash
# Create staging environment
firebase hosting:channel:create staging

# Deploy to staging
firebase deploy --only hosting:staging
```

## 📊 Analytics & Monitoring

### Google Analytics Setup

1. **Create GA4 Property**:
   - Go to Google Analytics
   - Create new GA4 property for "GitAlong"

2. **Configure Firebase Analytics**:
   ```dart
   // In your app initialization
   await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
   ```

3. **Track Custom Events**:
   ```dart
   await FirebaseAnalytics.instance.logEvent(
     name: 'user_sign_up',
     parameters: {
       'method': 'email',
     },
   );
   ```

### Performance Monitoring

1. **Enable Performance Monitoring**:
   ```bash
   # In Firebase Console > Performance
   # Enable automatic performance monitoring
   ```

2. **Custom Traces**:
   ```dart
   final trace = FirebasePerformance.instance.newTrace('user_journey');
   await trace.start();
   // ... your code ...
   await trace.stop();
   ```

## 🔒 Security Configuration

### Content Security Policy

Add to your `web/index.html`:

```html
<meta http-equiv="Content-Security-Policy" 
      content="default-src 'self'; 
               script-src 'self' 'unsafe-inline' 'unsafe-eval' https://www.googletagmanager.com;
               style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
               font-src 'self' https://fonts.gstatic.com;
               img-src 'self' data: https:;
               connect-src 'self' https://api.gitalong.app https://firestore.googleapis.com;">
```

### Security Headers

Configure in `firebase.json`:

```json
{
  "hosting": {
    "headers": [
      {
        "source": "**",
        "headers": [
          {
            "key": "X-Content-Type-Options",
            "value": "nosniff"
          },
          {
            "key": "X-Frame-Options",
            "value": "DENY"
          },
          {
            "key": "X-XSS-Protection",
            "value": "1; mode=block"
          },
          {
            "key": "Referrer-Policy",
            "value": "strict-origin-when-cross-origin"
          }
        ]
      }
    ]
  }
}
```

## 🧪 Testing

### Pre-deployment Tests

```bash
# Run all tests
flutter test

# Run web-specific tests
flutter test --platform chrome

# Test web build locally
flutter run -d chrome --web-renderer canvaskit
```

### Post-deployment Tests

1. **Functionality Tests**:
   - User registration/login
   - Profile creation/editing
   - Swipe functionality
   - Chat features
   - Push notifications

2. **Performance Tests**:
   - Page load times
   - Image optimization
   - Bundle size analysis

3. **Cross-browser Testing**:
   - Chrome, Firefox, Safari, Edge
   - Mobile browsers

## 📈 Monitoring & Maintenance

### Performance Monitoring

1. **Lighthouse Audits**:
   ```bash
   # Install Lighthouse
   npm install -g lighthouse
   
   # Run audit
   lighthouse https://gitalong.app --output html --output-path ./lighthouse-report.html
   ```

2. **Bundle Analysis**:
   ```bash
   # Analyze web bundle
   flutter build web --analyze-size
   ```

### Error Monitoring

1. **Firebase Crashlytics**:
   ```dart
   // Enable crash reporting
   await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
   ```

2. **Custom Error Tracking**:
   ```dart
   FirebaseCrashlytics.instance.recordError(
     error,
     stackTrace,
     reason: 'User action failed',
   );
   ```

## 🔄 CI/CD Pipeline

### GitHub Actions

Create `.github/workflows/web-deploy.yml`:

```yaml
name: Deploy Web App

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.5'
      - run: flutter test
      - run: flutter build web --release

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.5'
      - run: flutter build web --release
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          projectId: gitalong
          channelId: live
```

## 🚨 Troubleshooting

### Common Issues

1. **Build Failures**:
   ```bash
   # Clear cache
   flutter clean
   flutter pub get
   
   # Check for dependency conflicts
   flutter pub deps
   ```

2. **Deployment Failures**:
   ```bash
   # Check Firebase CLI
   firebase --version
   
   # Re-login to Firebase
   firebase logout
   firebase login
   ```

3. **Performance Issues**:
   - Enable code splitting
   - Optimize images
   - Use lazy loading
   - Implement caching strategies

### Support

- **Firebase Documentation**: https://firebase.google.com/docs
- **Flutter Web**: https://flutter.dev/web
- **GitHub Issues**: Report issues in the project repository

## 🎉 Success Metrics

After deployment, monitor these key metrics:

- **Page Load Time**: < 3 seconds
- **First Contentful Paint**: < 1.5 seconds
- **Lighthouse Score**: > 90
- **Uptime**: > 99.9%
- **Error Rate**: < 0.1%

---

**Your GitAlong web app is now ready for production! 🚀**

For additional support or questions, please refer to the project documentation or create an issue in the repository. 