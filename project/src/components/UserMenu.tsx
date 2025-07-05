import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { User, LogOut, Settings, Github } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { useAnalytics } from '../hooks/useAnalytics';

export const UserMenu: React.FC = () => {
  const [isOpen, setIsOpen] = useState(false);
  const { currentUser, logout } = useAuth();
  const { trackEvent } = useAnalytics();

  const handleLogout = async () => {
    try {
      await logout();
      trackEvent('user_logout');
      setIsOpen(false);
    } catch (error) {
      console.error('Logout error:', error);
    }
  };

  if (!currentUser) return null;

  const displayName = currentUser.displayName || currentUser.email?.split('@')[0] || 'User';
  const avatarUrl = currentUser.photoURL;

  return (
    <div className="relative">
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="flex items-center space-x-2 text-gray-300 hover:text-white transition-colors"
      >
        {avatarUrl ? (
          <img
            src={avatarUrl}
            alt={displayName}
            className="w-8 h-8 rounded-full border border-[#30363D]"
          />
        ) : (
          <div className="w-8 h-8 bg-[#2EA043] rounded-full flex items-center justify-center">
            <User className="h-4 w-4 text-white" />
          </div>
        )}
        <span className="hidden md:block font-medium">{displayName}</span>
      </button>

      <AnimatePresence>
        {isOpen && (
          <>
            {/* Backdrop */}
            <div
              className="fixed inset-0 z-40"
              onClick={() => setIsOpen(false)}
            />
            
            {/* Menu */}
            <motion.div
              initial={{ opacity: 0, scale: 0.95, y: -10 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.95, y: -10 }}
              className="absolute right-0 mt-2 w-64 bg-[#161B22] border border-[#30363D] rounded-lg shadow-xl z-50"
            >
              {/* User Info */}
              <div className="p-4 border-b border-[#30363D]">
                <div className="flex items-center space-x-3">
                  {avatarUrl ? (
                    <img
                      src={avatarUrl}
                      alt={displayName}
                      className="w-12 h-12 rounded-full border border-[#30363D]"
                    />
                  ) : (
                    <div className="w-12 h-12 bg-[#2EA043] rounded-full flex items-center justify-center">
                      <User className="h-6 w-6 text-white" />
                    </div>
                  )}
                  <div>
                    <p className="text-white font-semibold">{displayName}</p>
                    <p className="text-gray-400 text-sm">{currentUser.email}</p>
                  </div>
                </div>
              </div>

              {/* Menu Items */}
              <div className="py-2">
                <button
                  onClick={() => {
                    setIsOpen(false);
                    // Navigate to profile settings
                  }}
                  className="w-full flex items-center px-4 py-2 text-gray-300 hover:text-white hover:bg-[#21262D] transition-colors"
                >
                  <Settings className="h-4 w-4 mr-3" />
                  Settings
                </button>
                
                {currentUser.providerData.some(provider => provider.providerId === 'github.com') && (
                  <a
                    href={`https://github.com/${currentUser.reloadUserInfo?.screenName || ''}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="w-full flex items-center px-4 py-2 text-gray-300 hover:text-white hover:bg-[#21262D] transition-colors"
                    onClick={() => setIsOpen(false)}
                  >
                    <Github className="h-4 w-4 mr-3" />
                    View GitHub Profile
                  </a>
                )}
              </div>

              {/* Logout */}
              <div className="border-t border-[#30363D] py-2">
                <button
                  onClick={handleLogout}
                  className="w-full flex items-center px-4 py-2 text-red-400 hover:text-red-300 hover:bg-[#21262D] transition-colors"
                >
                  <LogOut className="h-4 w-4 mr-3" />
                  Sign Out
                </button>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </div>
  );
};