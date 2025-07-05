import React from 'react';
import { motion } from 'framer-motion';
import { Download, ArrowRight, Star, Users, Zap } from 'lucide-react';

interface CTASectionProps {
  onDownload: () => void;
}

export const CTASection: React.FC<CTASectionProps> = ({ onDownload }) => {
  return (
    <section className="py-20 bg-gradient-to-br from-[#0D1117] via-[#161B22] to-[#0D1117] relative overflow-hidden">
      {/* Background Effects */}
      <div className="absolute inset-0 bg-gradient-to-br from-[#2EA043]/5 via-transparent to-[#3FB950]/5"></div>
      
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
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          viewport={{ once: true }}
          className="mb-8"
        >
          <div className="inline-flex items-center px-4 py-2 rounded-full bg-[#2EA043]/10 border border-[#2EA043]/20 text-[#2EA043] text-sm font-medium mb-6">
            <Zap className="h-4 w-4 mr-2" />
            Limited Time: Join 10,000+ developers
          </div>
        </motion.div>

        <motion.h2
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.2 }}
          viewport={{ once: true }}
          className="text-4xl md:text-6xl font-bold mb-6 bg-gradient-to-r from-white via-gray-100 to-[#2EA043] bg-clip-text text-transparent"
        >
          Ready to Find Your
          <br />
          <span className="text-[#2EA043]">Perfect Match?</span>
        </motion.h2>

        <motion.p
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.4 }}
          viewport={{ once: true }}
          className="text-xl md:text-2xl text-gray-300 mb-8 max-w-3xl mx-auto leading-relaxed"
        >
          Download GitAlong today and join thousands of developers who are already building 
          amazing projects together. Your next collaboration partner is just a swipe away.
        </motion.p>

        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.6 }}
          viewport={{ once: true }}
          className="flex flex-col sm:flex-row gap-4 justify-center items-center mb-12"
        >
          <button
            onClick={onDownload}
            className="group relative px-8 py-4 bg-gradient-to-r from-[#2EA043] to-[#3FB950] text-white font-semibold rounded-2xl text-lg shadow-2xl hover:shadow-[#2EA043]/25 transition-all duration-300 hover:scale-105 hover:shadow-xl"
          >
            <Download className="h-5 w-5 mr-2 inline" />
            Download GitAlong
            <ArrowRight className="h-5 w-5 ml-2 inline group-hover:translate-x-1 transition-transform duration-300" />
          </button>
          
          <button className="px-8 py-4 border-2 border-[#30363D] text-gray-300 font-semibold rounded-2xl text-lg hover:border-[#2EA043] hover:text-[#2EA043] transition-all duration-300 hover:scale-105">
            Learn More
          </button>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.8 }}
          viewport={{ once: true }}
          className="flex flex-col sm:flex-row justify-center items-center gap-8 text-gray-400"
        >
          <div className="flex items-center">
            <Users className="h-5 w-5 mr-2 text-[#2EA043]" />
            <span>10,000+ Active Users</span>
          </div>
          <div className="flex items-center">
            <Star className="h-5 w-5 mr-2 text-[#2EA043]" />
            <span>4.9/5 App Store Rating</span>
          </div>
          <div className="flex items-center">
            <Zap className="h-5 w-5 mr-2 text-[#2EA043]" />
            <span>Free to Download</span>
          </div>
        </motion.div>

        {/* Trust Indicators */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 1.0 }}
          viewport={{ once: true }}
          className="mt-12 pt-8 border-t border-[#30363D]"
        >
          <p className="text-gray-400 text-sm mb-4">Trusted by developers at</p>
          <div className="flex flex-wrap justify-center items-center gap-8 opacity-60">
            <div className="text-gray-500 font-semibold">GitHub</div>
            <div className="text-gray-500 font-semibold">Microsoft</div>
            <div className="text-gray-500 font-semibold">Google</div>
            <div className="text-gray-500 font-semibold">Meta</div>
            <div className="text-gray-500 font-semibold">Netflix</div>
            <div className="text-gray-500 font-semibold">Spotify</div>
          </div>
        </motion.div>
      </div>
    </section>
  );
}; 