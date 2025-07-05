import React, { useState } from 'react';
import { HeroSection } from '../components/HeroSection';
import { FeaturesSection } from '../components/FeaturesSection';
import { TestimonialsSection } from '../components/TestimonialsSection';
import { CTASection } from '../components/CTASection';
import { Footer } from '../components/Footer';
import { AuthModal } from '../components/AuthModal';
import { useAuth } from '../contexts/AuthContext';

export const LandingPage: React.FC = () => {
  const [showAuthModal, setShowAuthModal] = useState(false);
  const [authMode, setAuthMode] = useState<'login' | 'signup'>('signup');
  const { currentUser } = useAuth();

  const handleGetStartedClick = () => {
    if (currentUser) {
      // If user is signed in, they can access app features
      // For now, just show a message or redirect to app download
      alert('Download the GitAlong app to access all features!');
    } else {
      setAuthMode('signup');
      setShowAuthModal(true);
    }
  };

  const handleDownloadApp = () => {
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
    <div className="min-h-screen">
      <HeroSection onGetStarted={handleGetStartedClick} />
      <FeaturesSection />
      <TestimonialsSection />
      <CTASection onDownload={handleDownloadApp} />
      <Footer />
      
      {/* Auth Modal */}
      <AuthModal
        isOpen={showAuthModal}
        onClose={() => setShowAuthModal(false)}
        initialMode={authMode}
      />
    </div>
  );
};