import React, { useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { Menu, X, LogIn, Search } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { UserMenu } from './UserMenu';
import { AuthModal } from './AuthModal';
import appIcon from '../assets/app_icon.jpg';

export const Navigation: React.FC = () => {
  const [isOpen, setIsOpen] = useState(false);
  const [showAuthModal, setShowAuthModal] = useState(false);
  const [authMode, setAuthMode] = useState<'login' | 'signup'>('login');
  const location = useLocation();
  const navigate = useNavigate();
  const { currentUser } = useAuth();

  const isActive = (path: string) => location.pathname === path;

  const navItems = [
    { path: '/', label: 'Home' },
    { path: '/search', label: 'Search' },
    { path: '/about', label: 'About' },
    { path: '/contact', label: 'Contact' },
    { path: '/login', label: 'Maintainer Login' },
  ];

  const handleAuthClick = (mode: 'login' | 'signup') => {
    setAuthMode(mode);
    setShowAuthModal(true);
  };

  const handleGetStartedClick = () => {
    if (currentUser) {
      navigate('/search');
    } else {
      handleAuthClick('signup');
    }
  };

  const handleDownloadAppClick = () => {
    // Mock app store links - in real app, these would link to actual app stores
    const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent);
    const isAndroid = /Android/.test(navigator.userAgent);
    
    if (isIOS) {
      window.open('https://apps.apple.com/app/gitalong', '_blank');
    } else if (isAndroid) {
      window.open('https://play.google.com/store/apps/details?id=com.gitalong.app', '_blank');
    } else {
      // Default to iOS for desktop users
      window.open('https://apps.apple.com/app/gitalong', '_blank');
    }
  };

  return (
    <>
      <nav className="glass border-b border-[#30363D] sticky top-0 z-40">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-20">
            <div className="flex items-center">
              <Link to="/" className="flex items-center space-x-3 text-white hover:text-[#2EA043] transition-all duration-300 group">
                <div className="relative">
                  <img src={appIcon} alt="Gitalong Logo" className="h-16 w-16 rounded-2xl border-2 border-[#30363D] shadow-lg bg-[#161B22] object-cover group-hover:border-[#2EA043] transition-all duration-300" />
                  <div className="absolute inset-0 bg-gradient-to-r from-[#2EA043]/20 to-transparent rounded-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                </div>
                <span className="text-2xl font-bold">Gitalong</span>
              </Link>
            </div>
            
            {/* Desktop Navigation */}
            <div className="hidden md:block">
              <div className="ml-10 flex items-baseline space-x-6">
                {navItems.map((item) => (
                  <Link
                    key={item.path}
                    to={item.path}
                    className={`px-4 py-2 rounded-xl text-sm font-medium transition-all duration-300 ${
                      isActive(item.path)
                        ? 'text-[#2EA043] bg-[#2EA043]/10 border border-[#2EA043]/20'
                        : 'text-gray-300 hover:text-white hover:bg-[#30363D] hover:scale-105'
                    }`}
                  >
                    {item.label}
                  </Link>
                ))}
              </div>
            </div>

            {/* Auth Section */}
            <div className="hidden md:flex items-center space-x-4">
              {currentUser ? (
                <UserMenu />
              ) : (
                <>
                  <button
                    onClick={() => handleAuthClick('login')}
                    className="flex items-center px-4 py-2 text-gray-300 hover:text-white transition-all duration-300 hover:scale-105"
                  >
                    <LogIn className="h-4 w-4 mr-2" />
                    Sign In
                  </button>
                  <button
                    onClick={() => handleAuthClick('signup')}
                    className="btn-primary"
                  >
                    Sign Up
                  </button>
                </>
              )}
            </div>

            {/* Mobile menu button */}
            <div className="md:hidden">
              <button
                onClick={() => setIsOpen(!isOpen)}
                className="inline-flex items-center justify-center p-3 rounded-xl text-gray-300 hover:text-white hover:bg-[#30363D] focus:outline-none focus:ring-2 focus:ring-inset focus:ring-[#2EA043] transition-all duration-300"
              >
                {isOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
              </button>
            </div>
          </div>
        </div>

        {/* Mobile Navigation */}
        {isOpen && (
          <div className="md:hidden">
            <div className="px-4 pt-4 pb-6 space-y-2 bg-[#161B22] border-t border-[#30363D]">
              {navItems.map((item) => (
                <Link
                  key={item.path}
                  to={item.path}
                  onClick={() => setIsOpen(false)}
                  className={`block px-4 py-3 rounded-xl text-base font-medium transition-all duration-300 ${
                    isActive(item.path)
                      ? 'text-[#2EA043] bg-[#2EA043]/10 border border-[#2EA043]/20'
                      : 'text-gray-300 hover:text-white hover:bg-[#30363D]'
                  }`}
                >
                  {item.label}
                </Link>
              ))}
              
              {/* Mobile Auth */}
              <div className="border-t border-[#30363D] pt-4 mt-4">
                {currentUser ? (
                  <div className="px-4 py-2">
                    <UserMenu />
                  </div>
                ) : (
                  <div className="space-y-3">
                    <button
                      onClick={() => {
                        handleAuthClick('login');
                        setIsOpen(false);
                      }}
                      className="block w-full text-left px-4 py-3 text-gray-300 hover:text-white hover:bg-[#30363D] rounded-xl transition-all duration-300"
                    >
                      Sign In
                    </button>
                    <button
                      onClick={() => {
                        handleAuthClick('signup');
                        setIsOpen(false);
                      }}
                      className="block w-full text-left px-4 py-3 btn-primary"
                    >
                      Sign Up
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>
        )}
      </nav>

      {/* Auth Modal */}
      <AuthModal
        isOpen={showAuthModal}
        onClose={() => setShowAuthModal(false)}
        initialMode={authMode}
      />
    </>
  );
};