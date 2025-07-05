import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { ArrowRight, Github, Smartphone, Brain, MessageCircle } from 'lucide-react';
import { ContributionGraph } from '../components/ContributionGraph';
import { AppStoreButton } from '../components/AppStoreButton';
import { AnimatedHero } from '../components/AnimatedHero';
import { FeaturesSection } from '../components/FeaturesSection';
import { useAnalytics } from '../hooks/useAnalytics';
import { useAuth } from '../contexts/AuthContext';

export const LandingPage: React.FC = () => {
  const [email, setEmail] = useState('');
  const [showToast, setShowToast] = useState(false);
  const { trackPageView, trackWaitlistSignup } = useAnalytics();
  const { currentUser } = useAuth();

  useEffect(() => {
    trackPageView('Landing Page');
  }, [trackPageView]);

  const handleWaitlistSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    trackWaitlistSignup(email);
    setShowToast(true);
    setEmail('');
    setTimeout(() => setShowToast(false), 3000);
  };

  return (
    <div className="min-h-screen relative">
      <ContributionGraph />
      
      {/* Hero Section */}
      <AnimatedHero />

      {/* Features Section */}
      <FeaturesSection />

      {/* Mobile App Showcase */}
      <section className="py-24 relative overflow-hidden">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            viewport={{ once: true }}
            className="text-center mb-16"
          >
            <h2 className="text-4xl md:text-6xl font-bold gradient-text mb-6">
              Experience the future of
              <br />
              <span className="text-[#2EA043]">collaboration</span>
            </h2>
            <p className="text-xl text-gray-300 max-w-3xl mx-auto">
              Download our mobile app for the complete GitAlong experience with real-time notifications and offline support.
            </p>
          </motion.div>

          <div className="flex flex-col lg:flex-row items-center justify-center gap-16">
            {/* Mobile Mockup */}
            <motion.div
              initial={{ opacity: 0, x: -50 }}
              whileInView={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8, delay: 0.2 }}
              viewport={{ once: true }}
              className="relative"
            >
              <div className="w-80 h-96 bg-[#21262D] rounded-3xl shadow-2xl p-6 border border-[#30363D] relative overflow-hidden">
                {/* Phone frame */}
                <div className="absolute inset-0 bg-gradient-to-b from-[#2EA043]/20 to-transparent rounded-3xl"></div>
                
                <div className="relative z-10">
                  <div className="flex items-center justify-between mb-4">
                    <div className="flex space-x-2">
                      <div className="w-3 h-3 bg-red-500 rounded-full"></div>
                      <div className="w-3 h-3 bg-yellow-500 rounded-full"></div>
                      <div className="w-3 h-3 bg-green-500 rounded-full"></div>
                    </div>
                    <span className="text-white text-sm font-bold">Gitalong</span>
                  </div>
                  
                  <div className="bg-[#161B22] rounded-xl p-4 mb-4 border border-[#30363D]">
                    <div className="flex items-center mb-3">
                      <div className="w-12 h-12 bg-gradient-to-r from-[#2EA043] to-[#238636] rounded-full flex items-center justify-center">
                        <Github className="h-6 w-6 text-white" />
                      </div>
                      <div className="ml-3">
                        <h3 className="text-lg font-semibold text-white">React Native</h3>
                        <p className="text-gray-400 text-sm">Mobile Framework</p>
                      </div>
                    </div>
                    <div className="space-y-2 mb-4">
                      <div className="flex items-center text-sm text-gray-300">
                        <span className="w-2 h-2 bg-[#2EA043] rounded-full mr-2"></span>
                        95% skill match
                      </div>
                      <div className="flex items-center text-sm text-gray-300">
                        <span className="w-2 h-2 bg-blue-500 rounded-full mr-2"></span>
                        1.2k contributors needed
                      </div>
                    </div>
                    <div className="flex gap-3">
                      <button className="flex-1 py-2 bg-red-600 text-white rounded-lg text-sm font-medium hover:bg-red-700 transition-colors">
                        Pass
                      </button>
                      <button className="flex-1 py-2 bg-gradient-to-r from-[#2EA043] to-[#238636] text-white rounded-lg text-sm font-medium hover:shadow-lg transition-all">
                        Match
                      </button>
                    </div>
                  </div>
                </div>
                
                {/* Floating elements */}
                <motion.div
                  animate={{ y: [0, -20, 0] }}
                  transition={{ duration: 2, repeat: Infinity }}
                  className="absolute -top-4 -right-4 w-8 h-8 bg-[#2EA043] rounded-full opacity-30"
                />
                <motion.div
                  animate={{ y: [0, 20, 0] }}
                  transition={{ duration: 2, repeat: Infinity, delay: 1 }}
                  className="absolute -bottom-4 -left-4 w-6 h-6 bg-blue-500 rounded-full opacity-30"
                />
              </div>
            </motion.div>

            {/* Download Section */}
            <motion.div
              initial={{ opacity: 0, x: 50 }}
              whileInView={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8, delay: 0.4 }}
              viewport={{ once: true }}
              className="text-center lg:text-left"
            >
              <h3 className="text-3xl font-bold text-white mb-6">
                Available on all platforms
              </h3>
              <p className="text-gray-300 mb-8 max-w-md">
                Download our mobile app for the complete GitAlong experience with real-time notifications, offline support, and seamless GitHub integration.
              </p>
              
              <div className="flex flex-col sm:flex-row gap-4 justify-center lg:justify-start">
                <AppStoreButton platform="ios" />
                <AppStoreButton platform="android" />
              </div>

              {/* Waitlist Form - Only show if not authenticated */}
              {!currentUser && (
                <motion.div
                  initial={{ opacity: 0, y: 20 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.8, delay: 0.6 }}
                  viewport={{ once: true }}
                  className="mt-8"
                >
                  <form onSubmit={handleWaitlistSubmit} className="flex gap-2 max-w-md">
                    <input
                      type="email"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      placeholder="Enter your email for early access"
                      className="input-modern flex-1"
                      required
                    />
                    <button
                      type="submit"
                      className="btn-primary"
                    >
                      Join Waitlist
                    </button>
                  </form>
                </motion.div>
              )}
            </motion.div>
          </div>
        </div>
      </section>

      {/* Toast notification */}
      {showToast && (
        <motion.div
          initial={{ opacity: 0, y: 50 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: 50 }}
          className="fixed bottom-4 right-4 bg-[#2EA043] text-white px-6 py-3 rounded-lg shadow-lg z-50"
        >
          Thanks for joining our waitlist! We'll notify you when we launch.
        </motion.div>
      )}
    </div>
  );
};