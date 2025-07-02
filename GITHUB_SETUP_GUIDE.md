# GitHub API Integration Setup Guide

## 🔧 Step 1: Create GitHub OAuth App

1. **Go to GitHub Settings**
   - Visit: https://github.com/settings/developers
   - Click "OAuth Apps" → "New OAuth App"

2. **Fill in OAuth App Details**
   ```
   Application name: GitAlong
   Homepage URL: https://your-app-domain.com (or http://localhost:3000 for dev)
   Application description: Find your perfect open source match
   Authorization callback URL: https://your-app-domain.com/auth/callback
   ```

3. **For Development Testing**
   ```
   Homepage URL: http://localhost:3000
   Authorization callback URL: http://localhost:3000/auth/callback
   ```

4. **Get Your Credentials**
   - After creating the app, you'll get:
     - `Client ID` (public)
     - `Client Secret` (keep private!)

## 🔐 Step 2: Provide Credentials

Create a `.env` file in your project root and add:

```env
# GitHub OAuth
GITHUB_CLIENT_ID=your_client_id_here
GITHUB_CLIENT_SECRET=your_client_secret_here

# GitHub API (optional - for higher rate limits)
GITHUB_PERSONAL_ACCESS_TOKEN=your_personal_token_here
```

## 🛡️ Step 3: Security Setup

### For Production:
- Add `.env` to `.gitignore`
- Use Firebase Remote Config or environment variables
- Never commit secrets to git

### For Development:
- Use the `.env` file locally
- Share credentials securely (not in chat/email)

## 📋 What to Share with Developer:

**Safe to share:**
- Client ID (this is public anyway)
- OAuth app name and description

**Share securely:**
- Client Secret
- Personal Access Token (if using)

## 🔗 Useful Links:
- [GitHub OAuth Apps Documentation](https://docs.github.com/en/developers/apps/building-oauth-apps)
- [GitHub API Documentation](https://docs.github.com/en/rest)
- [Creating Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) 