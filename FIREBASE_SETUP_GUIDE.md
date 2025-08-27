# 🔥 Firebase Setup Guide for GitAlong

## **Project Configuration**
- **Project ID**: `gitalong-c8075`
- **Project Name**: GitAlong
- **Region**: Default (us-central1)

## **Step 1: Enable GitHub Authentication**

1. Go to [Firebase Console](https://console.firebase.google.com/project/gitalong-c8075)
2. Navigate to **Authentication** → **Sign-in method**
3. Click on **GitHub** provider
4. **Enable** the provider
5. Add your credentials:
   - **Client ID**: `Ov23liqdqoZ88pfzPSnY`
   - **Client Secret**: `c9aee11b9fa27492e73d7a1433e94b9cb7299efe`

## **Step 2: Add Authorized Domains**

In Firebase Console → **Authentication** → **Settings** → **Authorized domains**, add:
- `gitalong.app`
- `www.gitalong.app`
- `gitalong.vercel.app`
- `localhost`

## **Step 3: Configure GitHub OAuth App**

1. Go to [GitHub Developer Settings](https://github.com/settings/developers)
2. Find your OAuth App or create a new one
3. Update the settings:
   - **Application name**: GitAlong
   - **Homepage URL**: `https://gitalong.app`
   - **Authorization callback URL**: `https://gitalong-c8075.firebaseapp.com/__/auth/handler`

## **Step 4: Android Configuration**

1. In Firebase Console → **Project Settings** → **Your apps** → **Android app**
2. Add SHA-1 and SHA-256 fingerprints:
   ```bash
   # Get debug fingerprints
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
3. Download the updated `google-services.json`
4. Replace `android/app/google-services.json`

## **Step 5: iOS Configuration**

1. In Firebase Console → **Project Settings** → **Your apps** → **iOS app**
2. Verify bundle ID: `com.gitalong.app`
3. Download `GoogleService-Info.plist`
4. Add to `ios/Runner/`
5. Update `ios/Runner/Info.plist` with URL schemes

## **Step 6: Web Configuration**

Your web app is already configured with the correct environment variables:

```env
VITE_FIREBASE_API_KEY=AIzaSyBytVrwbv4D2pLCgMYrxB-56unop4W6QpE
VITE_FIREBASE_AUTH_DOMAIN=gitalong-c8075.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=gitalong-c8075
VITE_FIREBASE_STORAGE_BUCKET=gitalong-c8075.firebasestorage.app
VITE_FIREBASE_MESSAGING_SENDER_ID=267802124592
VITE_FIREBASE_APP_ID=1:267802124592:web:2a53ff6d5d0e5eae4d28f5
VITE_FIREBASE_MEASUREMENT_ID=G-5BZKJKTNKJ
VITE_GITHUB_CLIENT_ID=Ov23liqdqoZ88pfzPSnY
VITE_GITHUB_CLIENT_SECRET=c9aee11b9fa27492e73d7a1433e94b9cb7299efe
```

## **Step 7: Test the Implementation**

### **Flutter App**
```bash
flutter run
# Click "Continue with GitHub" button
# Verify authentication works
```

### **Web App**
```bash
npm run dev
# Navigate to https://gitalong.vercel.app
# Test GitHub sign-in
```

## **Troubleshooting**

### **Common Issues:**

1. **"GitHub sign-in is not enabled"**
   - Ensure GitHub provider is enabled in Firebase Console
   - Verify Client ID and Secret are correct

2. **"Popup blocked"**
   - Disable popup blockers
   - Use redirect method as fallback

3. **"Invalid redirect URI"**
   - Verify callback URL matches exactly: `https://gitalong-c8075.firebaseapp.com/__/auth/handler`
   - Check GitHub OAuth App settings

4. **"Domain not authorized"**
   - Add your domains to Firebase authorized domains list

## **Security Notes**

- ✅ Keep your Client Secret secure
- ✅ Use environment variables in production
- ✅ The `.env` file should not be committed to version control
- ✅ Add `.env` to your `.gitignore` file

## **Next Steps**

1. Test both Flutter and web implementations
2. Configure proper error handling and loading states
3. Add user profile management
4. Implement sign-out functionality
5. Set up analytics and monitoring

---

**🎉 Setup Complete!** Your Firebase GitHub authentication is now ready for production use.
