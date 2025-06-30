# 🔥 Firebase Configuration Guide for GitAlong

## Current Issue: Google Sign-In Error Code 10 (DEVELOPER_ERROR)

**Root Cause**: Placeholder Firebase configuration files

## Required Information Collected:
- **Package Name**: `com.example.gitalong`
- **Debug SHA-1**: `F9:38:05:08:14:4E:ED:79:17:3E:6E:45:F2:06:38:3B:C5:F8:09:39`
- **Debug SHA-256**: `82:17:D9:4C:93:11:9F:1D:8D:64:F0:05:FE:5E:47:52:90:AB:A2:81:ED:B8:CF:51:7F:2F:DA:76:1D:1F:B6:F1`

---

## 🚀 Production Setup Steps:

### 1. Firebase Project Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or use existing `gitalong-c8075`
3. Enable Google Analytics (recommended)

### 2. Add Android App

1. Click "Add app" → Android
2. **Package name**: `com.example.gitalong`
3. **App nickname**: `GitAlong Android`
4. **Debug signing certificate SHA-1**: `F9:38:05:08:14:4E:ED:79:17:3E:6E:45:F2:06:38:3B:C5:F8:09:39`

### 3. Enable Authentication

1. Go to **Authentication** → **Sign-in method**
2. Enable **Google** provider
3. Set project support email
4. Add authorized domains if needed

### 4. Enable Firestore Database

1. Go to **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development)
4. Select a location (us-central1 recommended)

### 5. Download Configuration Files

After setting up the Android app:
1. Download `google-services.json`
2. Replace the placeholder file in `android/app/google-services.json`

### 6. Update Firebase Options

Run the FlutterFire CLI to regenerate configurations:
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=gitalong-c8075
```

This will update `lib/firebase_options.dart` with real API keys.

---

## 🔒 Security Considerations:

### For Production Release:

1. **Generate Release Keystore**:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. **Get Release SHA-1**:
```bash
keytool -list -v -keystore ~/upload-keystore.jks -alias upload
```

3. **Add Release SHA-1** to Firebase project

4. **Configure Firestore Security Rules**:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Projects are readable by all authenticated users
    match /projects/{projectId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == resource.data.owner_id;
    }
    
    // Messages between matched users
    match /messages/{messageId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.data.sender_id || 
         request.auth.uid == resource.data.receiver_id);
    }
  }
}
```

---

## 🧪 Testing the Fix:

After updating the configuration files:

1. **Clean and rebuild**:
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
flutter run
```

2. **Verify in logs**:
   - Look for "Firebase initialized successfully"
   - Google Sign-In should show detailed configuration logs
   - No more "DEVELOPER_ERROR (Code 10)" messages

---

## 🚨 Common Issues & Solutions:

### Issue: "Package name mismatch"
**Solution**: Ensure package name in Firebase matches `android/app/build.gradle`

### Issue: "OAuth client not configured"
**Solution**: Verify Google Sign-In is enabled in Firebase Authentication

### Issue: "API key invalid"
**Solution**: Re-download `google-services.json` and update `firebase_options.dart`

### Issue: "Network error"
**Solution**: Check internet connectivity and Firebase project status

---

## 📱 Quick Test Configuration (Development Only):

If you need to test immediately without setting up a full Firebase project, you can use this temporary workaround:

1. Create a test Firebase project
2. Add the debug SHA-1 fingerprint
3. Download the real `google-services.json`
4. This will resolve the DEVELOPER_ERROR for testing

**⚠️ Warning**: Never use test/development Firebase projects in production! 