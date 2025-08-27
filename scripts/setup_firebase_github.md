# Firebase GitHub Authentication Setup Guide

## Step 1: Configure Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `gitalong-c8075`
3. Navigate to **Authentication** → **Sign-in method**
4. Click on **GitHub** provider
5. Enable it and add your credentials:
   - **Client ID**: `Ov23liqdqoZ88pfzPSnY`
   - **Client Secret**: `c9aee11b9fa27492e73d7a1433e94b9cb7299efe`

## Step 2: Configure GitHub OAuth App

1. Go to [GitHub Developer Settings](https://github.com/settings/developers)
2. Find your OAuth App or create a new one
3. Update the settings:
   - **Application name**: GitAlong
   - **Homepage URL**: `https://gitalong.app`
   - **Authorization callback URL**: `https://gitalong-c8075.firebaseapp.com/__/auth/handler`

## Step 3: Add Authorized Domains

In Firebase Console → Authentication → Settings → Authorized domains, add:
- `gitalong.app`
- `www.gitalong.app`
- `gitalong.vercel.app`
- `localhost`

## Step 4: Test the Implementation

### Flutter App (Mobile)
The current implementation will:
- Try to use GitHub OAuth redirect on mobile
- Fall back to demo user if redirect fails
- Use popup authentication on web

### Web App (Next.js/Vercel)
For your web app at `https://gitalong.app`, implement:

```javascript
// firebase-config.js
import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';

const firebaseConfig = {
  apiKey: "AIzaSyBytVrwbv4D2pLCgMYrxB-56unop4W6QpE",
  authDomain: "gitalong-c8075.firebaseapp.com",
  projectId: "gitalong-c8075",
  storageBucket: "gitalong-c8075.firebasestorage.app",
  messagingSenderId: "267802124592",
  appId: "1:267802124592:web:2a53ff6d5d0e5eae4d28f5",
  measurementId: "G-5BZKJKTNKJ"
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
```

```javascript
// github-auth.js
import { signInWithPopup, GithubAuthProvider } from 'firebase/auth';
import { auth } from './firebase-config';

export const signInWithGitHub = async () => {
  const provider = new GithubAuthProvider();
  provider.addScope('user:email');
  provider.addScope('read:user');
  
  try {
    const result = await signInWithPopup(auth, provider);
    console.log('GitHub sign-in successful:', result.user);
    // Redirect to dashboard
    window.location.href = '/dashboard';
    return result;
  } catch (error) {
    console.error('GitHub sign-in failed:', error);
    throw error;
  }
};

export const signOut = async () => {
  try {
    await auth.signOut();
    console.log('Sign-out successful');
  } catch (error) {
    console.error('Sign-out failed:', error);
    throw error;
  }
};
```

## Step 5: Handle Authentication State

```javascript
// auth-state.js
import { onAuthStateChanged } from 'firebase/auth';
import { auth } from './firebase-config';

export const initAuthState = (callback) => {
  return onAuthStateChanged(auth, (user) => {
    if (user) {
      console.log('User is signed in:', user.email);
      callback({ user, isAuthenticated: true });
    } else {
      console.log('User is signed out');
      callback({ user: null, isAuthenticated: false });
    }
  });
};
```

## Step 6: Add Sign-in Button to Your Web App

```jsx
// components/GitHubSignIn.jsx
import { signInWithGitHub } from '../github-auth';

export const GitHubSignIn = () => {
  const handleSignIn = async () => {
    try {
      await signInWithGitHub();
    } catch (error) {
      console.error('Sign-in error:', error);
      // Handle error (show toast, etc.)
    }
  };

  return (
    <button 
      onClick={handleSignIn}
      className="flex items-center justify-center w-full px-4 py-2 text-white bg-gray-900 rounded-md hover:bg-gray-800"
    >
      <svg className="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
        <path fillRule="evenodd" d="M10 0C4.477 0 0 4.484 0 10.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0110 4.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.203 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.942.359.31.678.921.678 1.856 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0020 10.017C20 4.484 15.522 0 10 0z" clipRule="evenodd" />
      </svg>
      Continue with GitHub
    </button>
  );
};
```

## Troubleshooting

### Common Issues:

1. **"GitHub sign-in is not enabled"**
   - Make sure GitHub provider is enabled in Firebase Console
   - Verify Client ID and Secret are correct

2. **"Popup blocked"**
   - Ensure popup blockers are disabled
   - Use redirect method as fallback

3. **"Invalid redirect URI"**
   - Verify callback URL matches exactly: `https://gitalong-c8075.firebaseapp.com/__/auth/handler`
   - Check GitHub OAuth App settings

4. **"Domain not authorized"**
   - Add your domains to Firebase authorized domains list

## Security Notes

- Keep your Client Secret secure
- Use environment variables in production
- The `.env` file should not be committed to version control
- Add `.env` to your `.gitignore` file

## Next Steps

1. Test the Flutter app with the current implementation
2. Set up the web implementation for your Next.js app
3. Configure proper error handling and loading states
4. Add user profile management
5. Implement sign-out functionality
