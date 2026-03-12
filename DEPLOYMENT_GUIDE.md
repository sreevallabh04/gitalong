# GitAlong: Production Deployment Guide 🚀

This guide provides the step-by-step roadmap to take GitAlong from a local development environment to a public, production-ready cloud application.

---

## Phase 1: Deploy the Python Backend 🐍
Since we have a `Dockerfile` ready, we can deploy the backend to platforms like **Render**, **Railway**, or **Fly.io** in minutes.

### Step 1: Push to GitHub
Ensure your latest backend changes are pushed to your repository.
```bash
git add .
git commit -m "chore: prepare for production deployment"
git push origin main
```

### Step 2: Create a Web Service (e.g., on Render)
1.  Log in to [Render.com](https://render.com) and click **"New + Web Service"**.
2.  Connect your GitHub repository.
3.  Select the **`backend`** folder as the root directory.
4.  **Runtime**: Select **Docker**.
5.  **Environment Variables**: This is critical. Add the following from your local `.env`:
    -   `SUPABASE_URL`
    -   `SUPABASE_ANON_KEY`
    -   `SUPABASE_SERVICE_ROLE_KEY` (Keep this secret!)
    -   `DEBUG=false`
    -   `ALLOWED_ORIGINS=*` (Or your specific domain)
6.  Click **Deploy**. Render will give you a public URL like `https://gitalong-api.onrender.com`.

---

## Phase 2: Configure Supabase for Production ☁️

### Step 1: Update Auth Redirects
You must tell Supabase that your app is no longer just running on `localhost`.
1.  Go to **Supabase Dashboard → Authentication → URL Configuration**.
2.  Add your deep-link callback to **Redirect URLs**: `app.gitalong://login-callback/`.

### Step 2: Verify RLS
Ensure all tables (`users`, `swipes`, `matches`, `messages`) have **Row-Level Security (RLS)** enabled. You can use the `supabase_schema.sql` file in this repo to verify the policies are correctly applied.

---

## Phase 3: Transition the Flutter App 📱

### Step 1: Update Production URL
Update your Flutter `.env` file to point to your new live backend.
```env
# lib/.env
BACKEND_URL=https://your-api-url.onrender.com
# Use the live Supabase keys (they remain same usually)
```

### Step 2: Generate Release Icons
Run the launcher icons command to ensure your "GitAlong" logo appears on the home screen.
```bash
flutter pub run flutter_launcher_icons
```

---

## Phase 4: Publishing to the Stores 🛒

### Android (Play Store)
1.  **Generate a Keystore**: Run the `keytool` command to create a secure signing key.
2.  **Configure `key.properties`**: Link your app to the keystore.
3.  **Build App Bundle**:
    ```bash
    flutter build appbundle --release --obfuscate --split-debug-info=./debug-info
    ```
4.  Upload the `.aab` file to **Google Play Console**.

### iOS (App Store)
1.  **Xcode Configuration**: Ensure the "Bundle Identifier" is unique and your "Signing & Capabilities" are set to your Apple Developer team.
2.  **Build Archive**:
    ```bash
    flutter build ipa --release
    ```
3.  Use **Transporter** or Xcode to upload the build to **App Store Connect**.

---

## 🛠️ Maintenance & Monitoring
-   **Sentry/LogRocket**: Consider adding these to tracked Flutter crashes in production.
-   **Supabase Logs**: Monitor the "API" tab in Supabase to see if any RLS policies are blocking real users.
-   **Render Metrics**: Watch for CPU/Memory spikes on your Python backend during high-traffic match sessions.

---
*Generated for the GitAlong Project - March 2026*
