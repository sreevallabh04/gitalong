import React from 'react';
import { motion } from 'framer-motion';
import { ArrowRight, Download, Star, Users, Zap } from 'lucide-react';

interface HeroSectionProps {
  onGetStarted: () => void;
}

export const HeroSection: React.FC<HeroSectionProps> = ({ onGetStarted }) => {
  return (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden">
      {/* Background Effects */}
      <div className="absolute inset-0 bg-gradient-to-br from-[#0D1117] via-[#161B22] to-[#0D1117]"></div>
      <div className="absolute inset-0 bg-gradient-to-br from-[#2EA043]/5 via-transparent to-[#3FB950]/5"></div>
      
      {/* Floating Elements */}
      <motion.div
        className="absolute top-20 left-20 w-32 h-32 bg-gradient-to-r from-[#2EA043] to-[#3FB950] rounded-full opacity-20 blur-3xl"
        animate={{
          y: [0, -20, 0],
          scale: [1, 1.1, 1],
        }}
        transition={{
          duration: 4,
          repeat: Infinity,
          ease: "easeInOut"
        }}
      />
      <motion.div
        className="absolute bottom-20 right-20 w-40 h-40 bg-gradient-to-r from-[#3FB950] to-[#2EA043] rounded-full opacity-20 blur-3xl"
        animate={{
          y: [0, 20, 0],
          scale: [1, 0.9, 1],
        }}
        transition={{
          duration: 5,
          repeat: Infinity,
          ease: "easeInOut"
        }}
      />

      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          className="mb-8"
        >
          <div className="inline-flex items-center px-4 py-2 rounded-full bg-[#2EA043]/10 border border-[#2EA043]/20 text-[#2EA043] text-sm font-medium mb-6">
            <Star className="h-4 w-4 mr-2" />
            Join thousands of developers finding their perfect match
          </div>
        </motion.div>

        <motion.h1
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.2 }}
          className="text-5xl md:text-7xl font-bold mb-6 bg-gradient-to-r from-white via-gray-100 to-[#2EA043] bg-clip-text text-transparent"
        >
          Find Your Perfect
          <br />
          <span className="text-[#2EA043]">GitHub Match</span>
        </motion.h1>

        <motion.p
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.4 }}
          className="text-xl md:text-2xl text-gray-300 mb-8 max-w-3xl mx-auto leading-relaxed"
        >
          Swipe through GitHub profiles like Tinder, discover amazing developers, 
          and build incredible projects together. The future of collaborative coding starts here.
        </motion.p>

        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.6 }}
          className="flex flex-col sm:flex-row gap-4 justify-center items-center mb-12"
        >
          <button
            onClick={onGetStarted}
            className="group relative px-8 py-4 bg-gradient-to-r from-[#2EA043] to-[#3FB950] text-white font-semibold rounded-2xl text-lg shadow-2xl hover:shadow-[#2EA043]/25 transition-all duration-300 hover:scale-105 hover:shadow-xl"
          >
            <Download className="h-5 w-5 mr-2 inline" />
            Download GitAlong
            <ArrowRight className="h-5 w-5 ml-2 inline group-hover:translate-x-1 transition-transform duration-300" />
          </button>
          
          <button className="px-8 py-4 border-2 border-[#30363D] text-gray-300 font-semibold rounded-2xl text-lg hover:border-[#2EA043] hover:text-[#2EA043] transition-all duration-300 hover:scale-105">
            Watch Demo
          </button>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.8 }}
          className="flex flex-col sm:flex-row justify-center items-center gap-8 text-gray-400"
        >
          <div className="flex items-center">
            <Users className="h-5 w-5 mr-2 text-[#2EA043]" />
            <span>10,000+ Developers</span>
          </div>
          <div className="flex items-center">
            <Zap className="h-5 w-5 mr-2 text-[#2EA043]" />
            <span>Real-time Matching</span>
          </div>
          <div className="flex items-center">
            <Star className="h-5 w-5 mr-2 text-[#2EA043]" />
            <span>4.9/5 Rating</span>
          </div>
        </motion.div>
      </div>

      {/* Scroll Indicator */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 1, delay: 1.2 }}
        className="absolute bottom-8 left-1/2 transform -translate-x-1/2"
      >
        <motion.div
          animate={{ y: [0, 10, 0] }}
          transition={{ duration: 2, repeat: Infinity }}
          className="w-6 h-10 border-2 border-[#30363D] rounded-full flex justify-center"
        >
          <motion.div
            animate={{ y: [0, 12, 0] }}
            transition={{ duration: 2, repeat: Infinity }}
            className="w-1 h-3 bg-[#2EA043] rounded-full mt-2"
          />
        </motion.div>
      </motion.div>
    </section>
  );
}; 