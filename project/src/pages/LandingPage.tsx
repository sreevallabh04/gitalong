import React from 'react';
import { HeroSection } from '../components/HeroSection';
import { FeaturesSection } from '../components/FeaturesSection';
import { TestimonialsSection } from '../components/TestimonialsSection';
import { CTASection } from '../components/CTASection';
import { Footer } from '../components/Footer';

export const LandingPage: React.FC = () => {
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
      <HeroSection onGetStarted={handleDownloadApp} />
      <FeaturesSection />
      <TestimonialsSection />
      <CTASection onDownload={handleDownloadApp} />
      <Footer />
    </div>
  );
};