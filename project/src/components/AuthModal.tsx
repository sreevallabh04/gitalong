import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Github, Mail, Eye, EyeOff, AlertCircle, CheckCircle } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { useAnalytics } from '../hooks/useAnalytics';

interface AuthModalProps {
  isOpen: boolean;
  onClose: () => void;
  initialMode?: 'login' | 'signup';
}

export const AuthModal: React.FC<AuthModalProps> = ({ isOpen, onClose, initialMode = 'login' }) => {
  const [mode, setMode] = useState<'login' | 'signup' | 'reset'>(initialMode);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [displayName, setDisplayName] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const { login, signup, loginWithGitHub, loginWithGoogle, resetPassword } = useAuth();
  const { trackEvent } = useAnalytics();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    setSuccess('');

    try {
      if (mode === 'login') {
        await login(email, password);
        trackEvent('user_login', { method: 'email' });
        onClose();
      } else if (mode === 'signup') {
        await signup(email, password, displayName);
        trackEvent('user_signup', { method: 'email' });
        onClose();
      } else if (mode === 'reset') {
        await resetPassword(email);
        setSuccess('Password reset email sent! Check your inbox.');
        trackEvent('password_reset_requested');
      }
    } catch (err: any) {
      setError(err.message || 'An error occurred');
      trackEvent('auth_error', { method: 'email', error: err.code });
    } finally {
      setLoading(false);
    }
  };

  const handleGitHubLogin = async () => {
    setLoading(true);
    setError('');
    try {
      await loginWithGitHub();
      trackEvent('user_login', { method: 'github' });
      onClose();
    } catch (err: any) {
      setError(err.message || 'GitHub login failed');
      trackEvent('auth_error', { method: 'github', error: err.code });
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleLogin = async () => {
    setLoading(true);
    setError('');
    try {
      await loginWithGoogle();
      trackEvent('user_login', { method: 'google' });
      onClose();
    } catch (err: any) {
      setError(err.message || 'Google login failed');
      trackEvent('auth_error', { method: 'google', error: err.code });
    } finally {
      setLoading(false);
    }
  };

  const resetForm = () => {
    setEmail('');
    setPassword('');
    setDisplayName('');
    setError('');
    setSuccess('');
    setShowPassword(false);
  };

  const switchMode = (newMode: 'login' | 'signup' | 'reset') => {
    setMode(newMode);
    resetForm();
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4"
          onClick={onClose}
        >
          <motion.div
            initial={{ opacity: 0, scale: 0.95, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: 20 }}
            className="bg-[#161B22] rounded-lg border border-[#30363D] p-8 w-full max-w-md"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Header */}
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-2xl font-bold text-white">
                {mode === 'login' ? 'Sign In' : mode === 'signup' ? 'Create Account' : 'Reset Password'}
              </h2>
              <button
                onClick={onClose}
                className="text-gray-400 hover:text-white transition-colors"
              >
                <X className="h-6 w-6" />
              </button>
            </div>

            {/* Error/Success Messages */}
            {error && (
              <div className="bg-red-600/20 border border-red-600 rounded-lg p-3 mb-4 flex items-center">
                <AlertCircle className="h-4 w-4 text-red-400 mr-2" />
                <span className="text-red-300 text-sm">{error}</span>
              </div>
            )}

            {success && (
              <div className="bg-green-600/20 border border-green-600 rounded-lg p-3 mb-4 flex items-center">
                <CheckCircle className="h-4 w-4 text-green-400 mr-2" />
                <span className="text-green-300 text-sm">{success}</span>
              </div>
            )}

            {/* OAuth Buttons */}
            {mode !== 'reset' && (
              <div className="space-y-3 mb-6">
                <button
                  onClick={handleGitHubLogin}
                  disabled={loading}
                  className="w-full flex items-center justify-center px-4 py-3 border border-[#30363D] rounded-lg text-white hover:bg-[#30363D] transition-colors disabled:opacity-50"
                >
                  <Github className="h-5 w-5 mr-3" />
                  Continue with GitHub
                </button>
                <button
                  onClick={handleGoogleLogin}
                  disabled={loading}
                  className="w-full flex items-center justify-center px-4 py-3 border border-[#30363D] rounded-lg text-white hover:bg-[#30363D] transition-colors disabled:opacity-50"
                >
                  <svg className="h-5 w-5 mr-3" viewBox="0 0 24 24">
                    <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                    <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                    <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                    <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                  </svg>
                  Continue with Google
                </button>

                <div className="relative">
                  <div className="absolute inset-0 flex items-center">
                    <div className="w-full border-t border-[#30363D]" />
                  </div>
                  <div className="relative flex justify-center text-sm">
                    <span className="px-2 bg-[#161B22] text-gray-400">or</span>
                  </div>
                </div>
              </div>
            )}

            {/* Form */}
            <form onSubmit={handleSubmit} className="space-y-4">
              {mode === 'signup' && (
                <div>
                  <label htmlFor="displayName" className="block text-sm font-medium text-gray-300 mb-2">
                    Display Name
                  </label>
                  <input
                    type="text"
                    id="displayName"
                    value={displayName}
                    onChange={(e) => setDisplayName(e.target.value)}
                    className="w-full px-3 py-2 bg-[#0D1117] border border-[#30363D] rounded-lg text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#2EA043] focus:border-transparent"
                    placeholder="Your name"
                    required
                  />
                </div>
              )}

              <div>
                <label htmlFor="email" className="block text-sm font-medium text-gray-300 mb-2">
                  Email
                </label>
                <input
                  type="email"
                  id="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="w-full px-3 py-2 bg-[#0D1117] border border-[#30363D] rounded-lg text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#2EA043] focus:border-transparent"
                  placeholder="your@email.com"
                  required
                />
              </div>

              {mode !== 'reset' && (
                <div>
                  <label htmlFor="password" className="block text-sm font-medium text-gray-300 mb-2">
                    Password
                  </label>
                  <div className="relative">
                    <input
                      type={showPassword ? 'text' : 'password'}
                      id="password"
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      className="w-full px-3 py-2 pr-10 bg-[#0D1117] border border-[#30363D] rounded-lg text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#2EA043] focus:border-transparent"
                      placeholder="••••••••"
                      required
                      minLength={6}
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword(!showPassword)}
                      className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-white"
                    >
                      {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                    </button>
                  </div>
                </div>
              )}

              <button
                type="submit"
                disabled={loading}
                className="w-full flex items-center justify-center px-4 py-3 bg-[#2EA043] text-white rounded-lg hover:bg-[#2EA043]/90 transition-colors disabled:opacity-50"
              >
                {loading ? (
                  <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                ) : (
                  <>
                    <Mail className="h-4 w-4 mr-2" />
                    {mode === 'login' ? 'Sign In' : mode === 'signup' ? 'Create Account' : 'Send Reset Email'}
                  </>
                )}
              </button>
            </form>

            {/* Footer Links */}
            <div className="mt-6 text-center text-sm">
              {mode === 'login' && (
                <div className="space-y-2">
                  <button
                    onClick={() => switchMode('reset')}
                    className="text-[#2EA043] hover:underline"
                  >
                    Forgot your password?
                  </button>
                  <div>
                    <span className="text-gray-400">Don't have an account? </span>
                    <button
                      onClick={() => switchMode('signup')}
                      className="text-[#2EA043] hover:underline"
                    >
                      Sign up
                    </button>
                  </div>
                </div>
              )}

              {mode === 'signup' && (
                <div>
                  <span className="text-gray-400">Already have an account? </span>
                  <button
                    onClick={() => switchMode('login')}
                    className="text-[#2EA043] hover:underline"
                  >
                    Sign in
                  </button>
                </div>
              )}

              {mode === 'reset' && (
                <div>
                  <span className="text-gray-400">Remember your password? </span>
                  <button
                    onClick={() => switchMode('login')}
                    className="text-[#2EA043] hover:underline"
                  >
                    Sign in
                  </button>
                </div>
              )}
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
};