import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Github, AlertCircle, Shield, ArrowRight } from 'lucide-react';
import { AppStoreButton } from '../components/AppStoreButton';
import { useAnalytics } from '../hooks/useAnalytics';

export const MaintainerLogin: React.FC = () => {
  const [showError, setShowError] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const { trackPageView, trackMaintainerLoginAttempt } = useAnalytics();

  useEffect(() => {
    trackPageView('Maintainer Login');
  }, [trackPageView]);

  const handleGitHubLogin = () => {
    trackMaintainerLoginAttempt();
    setShowError(true);
    setTimeout(() => setShowError(false), 5000);
  };

  const handleFormSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    trackMaintainerLoginAttempt();
    setShowError(true);
    setTimeout(() => setShowError(false), 5000);
  };

  return (
    <div className="min-h-screen py-20">
      <div className="max-w-md mx-auto px-4 sm:px-6 lg:px-8">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          className="bg-[#161B22] rounded-lg border border-[#30363D] p-8"
        >
          {/* Header */}
          <div className="text-center mb-8">
            <div className="w-16 h-16 bg-[#2EA043] rounded-full flex items-center justify-center mx-auto mb-4">
              <Shield className="h-8 w-8 text-white" />
            </div>
            <h1 className="text-2xl font-bold text-white mb-2">Maintainer Portal</h1>
            <p className="text-gray-400">
              Access your project dashboard and manage contributor connections
            </p>
          </div>

          {/* Error Banner */}
          {showError && (
            <motion.div
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              className="bg-red-600/20 border border-red-600 rounded-lg p-4 mb-6 flex items-start"
            >
              <AlertCircle className="h-5 w-5 text-red-400 mr-3 mt-0.5" />
              <div>
                <p className="text-red-300 font-medium">Mobile App Required</p>
                <p className="text-red-400 text-sm mt-1">
                  Maintainer features are only available in the mobile app. Download the app to access your dashboard.
                </p>
              </div>
            </motion.div>
          )}

          {/* Login Form */}
          <div className="space-y-6">
            {/* GitHub OAuth Button */}
            <button
              onClick={handleGitHubLogin}
              className="w-full flex items-center justify-center px-4 py-3 border border-[#30363D] rounded-lg text-white hover:bg-[#30363D] transition-colors"
            >
              <Github className="h-5 w-5 mr-3" />
              Sign in with GitHub
            </button>

            <div className="relative">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-[#30363D]" />
              </div>
              <div className="relative flex justify-center text-sm">
                <span className="px-2 bg-[#161B22] text-gray-400">or</span>
              </div>
            </div>

            {/* Email Form */}
            <form onSubmit={handleFormSubmit} className="space-y-4">
              <div>
                <label htmlFor="email" className="block text-sm font-medium text-gray-300 mb-2">
                  Email address
                </label>
                <input
                  type="email"
                  id="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="w-full px-3 py-2 bg-[#0D1117] border border-[#30363D] rounded-lg text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#2EA043] focus:border-transparent"
                  placeholder="your-email@example.com"
                />
              </div>
              <div>
                <label htmlFor="password" className="block text-sm font-medium text-gray-300 mb-2">
                  Password
                </label>
                <input
                  type="password"
                  id="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full px-3 py-2 bg-[#0D1117] border border-[#30363D] rounded-lg text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#2EA043] focus:border-transparent"
                  placeholder="••••••••"
                />
              </div>
              <button
                type="submit"
                className="w-full flex items-center justify-center px-4 py-3 bg-[#2EA043] text-white rounded-lg hover:bg-[#2EA043]/90 transition-colors"
              >
                Sign in
                <ArrowRight className="h-4 w-4 ml-2" />
              </button>
            </form>
          </div>

          {/* Footer */}
          <div className="mt-8 pt-6 border-t border-[#30363D]">
            <p className="text-center text-sm text-gray-400">
              Don't have maintainer access?{' '}
              <a href="/contact" className="text-[#2EA043] hover:underline">
                Contact us
              </a>
            </p>
          </div>
        </motion.div>

        {/* Download App CTA */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.2 }}
          className="mt-8 bg-[#161B22] rounded-lg border border-[#30363D] p-6 text-center"
        >
          <h2 className="text-lg font-semibold text-white mb-4">Get the Mobile App</h2>
          <p className="text-gray-400 mb-4 text-sm">
            Access all maintainer features including project analytics, contributor management, and real-time messaging.
          </p>
          <div className="flex flex-col gap-3">
            <AppStoreButton platform="ios" className="w-full justify-center" />
            <AppStoreButton platform="android" className="w-full justify-center" />
          </div>
        </motion.div>
      </div>
    </div>
  );
};