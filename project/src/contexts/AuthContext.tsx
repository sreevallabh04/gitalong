import React, { createContext, useContext, useEffect, useState } from 'react';
import { 
  User, 
  signInWithEmailAndPassword, 
  createUserWithEmailAndPassword,
  signInWithPopup,
  GithubAuthProvider,
  GoogleAuthProvider,
  signOut,
  onAuthStateChanged,
  sendPasswordResetEmail,
  updateProfile,
  Auth
} from 'firebase/auth';
import { auth } from '../lib/firebase';

interface AuthContextType {
  currentUser: User | null;
  loading: boolean;
  signup: (email: string, password: string, displayName?: string) => Promise<void>;
  login: (email: string, password: string) => Promise<void>;
  loginWithGitHub: () => Promise<void>;
  loginWithGoogle: () => Promise<void>;
  logout: () => Promise<void>;
  resetPassword: (email: string) => Promise<void>;
  updateUserProfile: (displayName: string) => Promise<void>;
  isFirebaseAvailable: boolean;
}

const AuthContext = createContext<AuthContextType>({
  currentUser: null,
  loading: true,
  signup: async () => {},
  login: async () => {},
  loginWithGitHub: async () => {},
  loginWithGoogle: async () => {},
  logout: async () => {},
  resetPassword: async () => {},
  updateUserProfile: async () => {},
  isFirebaseAvailable: false
});

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

interface AuthProviderProps {
  children: React.ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [isFirebaseAvailable, setIsFirebaseAvailable] = useState(false);

  useEffect(() => {
    // Check if Firebase is available
    setIsFirebaseAvailable(!!auth);
    
    if (!auth) {
      setLoading(false);
      return;
    }

    const unsubscribe = onAuthStateChanged(auth, (user) => {
      setCurrentUser(user);
      setLoading(false);
    });

    return unsubscribe;
  }, []);

  const signup = async (email: string, password: string, displayName?: string) => {
    if (!auth) throw new Error('Firebase is not available');
    const result = await createUserWithEmailAndPassword(auth, email, password);
    if (displayName && result.user) {
      await updateProfile(result.user, { displayName });
    }
  };

  const login = async (email: string, password: string) => {
    if (!auth) throw new Error('Firebase is not available');
    await signInWithEmailAndPassword(auth, email, password);
  };

  const loginWithGitHub = async () => {
    if (!auth) throw new Error('Firebase is not available');
    const provider = new GithubAuthProvider();
    provider.addScope('read:user');
    provider.addScope('user:email');
    await signInWithPopup(auth, provider);
  };

  const loginWithGoogle = async () => {
    if (!auth) throw new Error('Firebase is not available');
    const provider = new GoogleAuthProvider();
    await signInWithPopup(auth, provider);
  };

  const logout = async () => {
    if (!auth) throw new Error('Firebase is not available');
    await signOut(auth);
  };

  const resetPassword = async (email: string) => {
    if (!auth) throw new Error('Firebase is not available');
    await sendPasswordResetEmail(auth, email);
  };

  const updateUserProfile = async (displayName: string) => {
    if (!auth) throw new Error('Firebase is not available');
    if (currentUser) {
      await updateProfile(currentUser, { displayName });
    }
  };

  const value = {
    currentUser,
    loading,
    signup,
    login,
    loginWithGitHub,
    loginWithGoogle,
    logout,
    resetPassword,
    updateUserProfile,
    isFirebaseAvailable
  };

  return (
    <AuthContext.Provider value={value}>
      {!loading && children}
    </AuthContext.Provider>
  );
};