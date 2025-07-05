import React from 'react';
import { motion } from 'framer-motion';
import { ArrowRight, Github, Smartphone, Brain, MessageCircle, Zap, Users, TrendingUp } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

export const AnimatedHero: React.FC = () => {
  const navigate = useNavigate();
  const { currentUser } = useAuth();

  const floatingElements = [
    { icon: Github, delay: 0, x: -20, y: -10 },
    { icon: Brain, delay: 0.5, x: 20, y: -15 },
    { icon: MessageCircle, delay: 1, x: -15, y: 10 },
    { icon: Users, delay: 1.5, x: 15, y: 5 },
    { icon: TrendingUp, delay: 2, x: 0, y: -20 },
  ];

  const handleGetStartedClick = () => {
    if (currentUser) {
      navigate('/search');
    } else {
      // Trigger signup modal - this would need to be handled by parent component
      // For now, navigate to search page
      navigate('/search');
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
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden">
      {/* Animated background elements */}
      <div className="absolute inset-0">
        {floatingElements.map((element, index) => (
          <motion.div
            key={index}
            initial={{ opacity: 0, scale: 0 }}
            animate={{ 
              opacity: [0.3, 0.6, 0.3], 
              scale: [1, 1.1, 1],
              x: [0, element.x, 0],
              y: [0, element.y, 0]
            }}
            transition={{
              duration: 6,
              delay: element.delay,
              repeat: Infinity,
              ease: "easeInOut"
            }}
            className="absolute"
            style={{
              left: `${50 + element.x}%`,
              top: `${50 + element.y}%`,
            }}
          >
            <div className="w-16 h-16 bg-[#2EA043]/20 rounded-full flex items-center justify-center backdrop-blur-sm">
              <element.icon className="w-8 h-8 text-[#2EA043]" />
            </div>
          </motion.div>
        ))}
      </div>

      {/* Gradient orbs */}
      <div className="absolute top-20 left-20 w-72 h-72 bg-[#2EA043]/10 rounded-full blur-3xl"></div>
      <div className="absolute bottom-20 right-20 w-96 h-96 bg-blue-500/10 rounded-full blur-3xl"></div>
      <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-64 h-64 bg-purple-500/10 rounded-full blur-3xl"></div>

      <div className="relative z-10 text-center px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto">
        {/* Badge */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          className="inline-flex items-center px-4 py-2 bg-[#2EA043]/20 border border-[#2EA043] rounded-full text-[#2EA043] text-sm font-medium mb-8"
        >
          <Zap className="w-4 h-4 mr-2" />
          AI-Powered Matching Engine
        </motion.div>

        {/* Main heading */}
        <motion.h1
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1, delay: 0.2 }}
          className="text-5xl md:text-7xl lg:text-8xl font-bold mb-6 gradient-text leading-tight"
        >
          Match.
          <br />
          <span className="text-[#2EA043]">Collaborate.</span>
          <br />
          Contribute.
        </motion.h1>

        {/* Subtitle */}
        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.4 }}
          className="text-xl md:text-2xl text-gray-300 mb-12 max-w-4xl mx-auto leading-relaxed"
        >
          The AI-powered way to find perfect open-source collaborators. 
          Swipe through projects, match with maintainers, and build the future together.
        </motion.p>

        {/* CTA Buttons */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.8 }}
          className="flex flex-col sm:flex-row gap-4 justify-center items-center"
        >
          <button 
            onClick={handleGetStartedClick}
            className="btn-primary group"
          >
            Get Started Free
            <ArrowRight className="w-5 h-5 ml-2 group-hover:translate-x-1 transition-transform" />
          </button>
          <button 
            onClick={handleDownloadAppClick}
            className="btn-secondary"
          >
            <Smartphone className="w-5 h-5 mr-2" />
            Download App
          </button>
        </motion.div>
      </div>

      {/* Scroll indicator */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 1, delay: 1.5 }}
        className="absolute bottom-8 left-1/2 transform -translate-x-1/2"
      >
        <motion.div
          animate={{ y: [0, 10, 0] }}
          transition={{ duration: 2, repeat: Infinity }}
          className="w-6 h-10 border-2 border-gray-400 rounded-full flex justify-center"
        >
          <motion.div
            animate={{ y: [0, 12, 0] }}
            transition={{ duration: 2, repeat: Infinity }}
            className="w-1 h-3 bg-gray-400 rounded-full mt-2"
          />
        </motion.div>
      </motion.div>
    </section>
  );
}; 