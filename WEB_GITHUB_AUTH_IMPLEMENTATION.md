# 🌐 Web App GitHub Authentication Implementation

## **For Next.js/Vite Application at https://gitalong.vercel.app**

### **1. Firebase Configuration**

Create `src/lib/firebase.ts`:
```typescript
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

### **2. GitHub Authentication Service**

Create `src/lib/github-auth.ts`:
```typescript
import { signInWithPopup, GithubAuthProvider, signOut as firebaseSignOut } from 'firebase/auth';
import { auth } from './firebase';

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
  } catch (error: any) {
    console.error('GitHub sign-in failed:', error);
    
    // Handle specific errors
    if (error.code === 'auth/popup-closed-by-user') {
      throw new Error('Sign-in popup was closed. Please try again.');
    } else if (error.code === 'auth/popup-blocked') {
      throw new Error('Sign-in popup was blocked. Please allow popups and try again.');
    } else if (error.code === 'auth/operation-not-allowed') {
      throw new Error('GitHub sign-in is not enabled. Please contact support.');
    } else if (error.code === 'auth/network-request-failed') {
      throw new Error('Network error. Please check your connection and try again.');
    }
    
    throw error;
  }
};

export const signOut = async () => {
  try {
    await firebaseSignOut(auth);
    console.log('Sign-out successful');
    window.location.href = '/';
  } catch (error) {
    console.error('Sign-out failed:', error);
    throw error;
  }
};

export const getCurrentUser = () => {
  return auth.currentUser;
};
```

### **3. Authentication State Hook**

Create `src/hooks/useAuth.ts`:
```typescript
import { useState, useEffect } from 'react';
import { User, onAuthStateChanged } from 'firebase/auth';
import { auth } from '../lib/firebase';

export const useAuth = () => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      setUser(user);
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  return { user, loading };
};
```

### **4. GitHub Sign-In Button Component**

Create `src/components/GitHubSignInButton.tsx`:
```tsx
import React, { useState } from 'react';
import { signInWithGitHub } from '../lib/github-auth';

interface GitHubSignInButtonProps {
  className?: string;
  children?: React.ReactNode;
}

export const GitHubSignInButton: React.FC<GitHubSignInButtonProps> = ({ 
  className = '', 
  children 
}) => {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSignIn = async () => {
    setIsLoading(true);
    setError(null);

    try {
      await signInWithGitHub();
    } catch (error: any) {
      setError(error.message);
      console.error('Sign-in error:', error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div>
      <button
        onClick={handleSignIn}
        disabled={isLoading}
        className={`flex items-center justify-center w-full px-4 py-2 text-white bg-gray-900 rounded-md hover:bg-gray-800 disabled:opacity-50 disabled:cursor-not-allowed transition-colors ${className}`}
      >
        {isLoading ? (
          <div className="flex items-center">
            <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
            Signing in...
          </div>
        ) : (
          <>
            <svg className="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M10 0C4.477 0 0 4.484 0 10.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0110 4.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.203 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.942.359.31.678.921.678 1.856 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0020 10.017C20 4.484 15.522 0 10 0z" clipRule="evenodd" />
            </svg>
            {children || 'Continue with GitHub'}
          </>
        )}
      </button>
      
      {error && (
        <div className="mt-2 text-red-600 text-sm">
          {error}
        </div>
      )}
    </div>
  );
};
```

### **5. Protected Route Component**

Create `src/components/ProtectedRoute.tsx`:
```tsx
import React from 'react';
import { useAuth } from '../hooks/useAuth';
import { useRouter } from 'next/router';

interface ProtectedRouteProps {
  children: React.ReactNode;
}

export const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ children }) => {
  const { user, loading } = useAuth();
  const router = useRouter();

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900"></div>
      </div>
    );
  }

  if (!user) {
    router.push('/login');
    return null;
  }

  return <>{children}</>;
};
```

### **6. Login Page Implementation**

Create `src/pages/login.tsx`:
```tsx
import React from 'react';
import { GitHubSignInButton } from '../components/GitHubSignInButton';
import { useAuth } from '../hooks/useAuth';
import { useRouter } from 'next/router';

export default function LoginPage() {
  const { user } = useAuth();
  const router = useRouter();

  // Redirect if already logged in
  React.useEffect(() => {
    if (user) {
      router.push('/dashboard');
    }
  }, [user, router]);

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="max-w-md w-full space-y-8">
        <div>
          <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
            Sign in to GitAlong
          </h2>
          <p className="mt-2 text-center text-sm text-gray-600">
            Connect with developers and build amazing projects together
          </p>
        </div>
        
        <div className="mt-8 space-y-6">
          <GitHubSignInButton />
          
          <div className="text-center">
            <p className="text-sm text-gray-600">
              By signing in, you agree to our{' '}
              <a href="/terms" className="text-blue-600 hover:text-blue-500">
                Terms of Service
              </a>{' '}
              and{' '}
              <a href="/privacy" className="text-blue-600 hover:text-blue-500">
                Privacy Policy
              </a>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
```

### **7. Dashboard Page**

Create `src/pages/dashboard.tsx`:
```tsx
import React from 'react';
import { ProtectedRoute } from '../components/ProtectedRoute';
import { useAuth } from '../hooks/useAuth';
import { signOut } from '../lib/github-auth';

export default function DashboardPage() {
  const { user } = useAuth();

  const handleSignOut = async () => {
    try {
      await signOut();
    } catch (error) {
      console.error('Sign-out error:', error);
    }
  };

  return (
    <ProtectedRoute>
      <div className="min-h-screen bg-gray-50">
        <nav className="bg-white shadow">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between h-16">
              <div className="flex items-center">
                <h1 className="text-xl font-semibold">GitAlong Dashboard</h1>
              </div>
              <div className="flex items-center space-x-4">
                {user && (
                  <div className="flex items-center space-x-2">
                    <img
                      src={user.photoURL || '/default-avatar.png'}
                      alt={user.displayName || 'User'}
                      className="w-8 h-8 rounded-full"
                    />
                    <span className="text-sm text-gray-700">
                      {user.displayName || user.email}
                    </span>
                  </div>
                )}
                <button
                  onClick={handleSignOut}
                  className="text-sm text-gray-600 hover:text-gray-900"
                >
                  Sign Out
                </button>
              </div>
            </div>
          </div>
        </nav>

        <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
          <div className="px-4 py-6 sm:px-0">
            <div className="border-4 border-dashed border-gray-200 rounded-lg h-96 flex items-center justify-center">
              <div className="text-center">
                <h2 className="text-2xl font-bold text-gray-900 mb-4">
                  Welcome to GitAlong!
                </h2>
                <p className="text-gray-600">
                  Start connecting with developers and building amazing projects.
                </p>
              </div>
            </div>
          </div>
        </main>
      </div>
    </ProtectedRoute>
  );
}
```

### **8. Environment Variables**

Your `.env.local` file should contain:
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

### **9. Testing the Implementation**

1. **Start the development server:**
   ```bash
   npm run dev
   ```

2. **Navigate to the login page:**
   ```
   http://localhost:3000/login
   ```

3. **Click "Continue with GitHub"**
   - Should open GitHub OAuth popup
   - After authorization, redirect to dashboard
   - User should be authenticated

4. **Test sign-out:**
   - Click "Sign Out" in dashboard
   - Should redirect to home page
   - User should be signed out

### **10. Production Deployment**

For Vercel deployment:
1. Add environment variables in Vercel dashboard
2. Deploy the application
3. Test GitHub authentication on production domain

---

**🎉 Web Implementation Complete!** Your web app now has full GitHub authentication integration.
