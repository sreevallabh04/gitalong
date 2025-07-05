import React, { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { User, Settings, LogOut, ChevronDown } from 'lucide-react';
import { auth } from '../lib/firebase';
import { signOut } from 'firebase/auth';
import { useAuth } from '../contexts/AuthContext';

export const UserMenu: React.FC = () => {
  const [isOpen, setIsOpen] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);
  const { currentUser } = useAuth();

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleSignOut = async () => {
    try {
      await signOut(auth);
      setIsOpen(false);
    } catch (error) {
      console.error('Error signing out:', error);
    }
  };

  if (!currentUser) return null;

  return (
    <div className="relative" ref={menuRef}>
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="flex items-center space-x-2 px-4 py-2 text-gray-300 hover:text-white transition-all duration-300 hover:scale-105"
      >
        <div className="w-8 h-8 bg-gradient-to-r from-[#2EA043] to-[#3FB950] rounded-full flex items-center justify-center">
          <User className="h-4 w-4 text-white" />
        </div>
        <span className="hidden md:block text-sm font-medium">
          {currentUser.email?.split('@')[0] || 'User'}
        </span>
        <ChevronDown className={`h-4 w-4 transition-transform duration-200 ${isOpen ? 'rotate-180' : ''}`} />
      </button>

      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ opacity: 0, y: -10, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -10, scale: 0.95 }}
            className="absolute right-0 mt-2 w-48 bg-[#161B22] border border-[#30363D] rounded-xl shadow-2xl z-50"
          >
            <div className="py-2">
              {/* User Info */}
              <div className="px-4 py-3 border-b border-[#30363D]">
                <p className="text-white font-medium text-sm">
                  {currentUser.displayName || currentUser.email?.split('@')[0] || 'User'}
                </p>
                <p className="text-gray-400 text-xs">
                  {currentUser.email}
                </p>
              </div>

              {/* Menu Items */}
              <div className="py-1">
                <button className="w-full flex items-center px-4 py-2 text-sm text-gray-300 hover:text-white hover:bg-[#0D1117] transition-colors duration-200">
                  <User className="h-4 w-4 mr-3" />
                  Profile
                </button>
                
                <button className="w-full flex items-center px-4 py-2 text-sm text-gray-300 hover:text-white hover:bg-[#0D1117] transition-colors duration-200">
                  <Settings className="h-4 w-4 mr-3" />
                  Settings
                </button>
                
                <div className="border-t border-[#30363D] my-1"></div>
                
                <button
                  onClick={handleSignOut}
                  className="w-full flex items-center px-4 py-2 text-sm text-red-400 hover:text-red-300 hover:bg-[#0D1117] transition-colors duration-200"
                >
                  <LogOut className="h-4 w-4 mr-3" />
                  Sign Out
                </button>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};