import React from 'react';
import { motion } from 'framer-motion';
import { Github, Heart, Users, Zap } from 'lucide-react';

export const AboutPage: React.FC = () => {
  return (
    <div className="min-h-screen py-20">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          className="text-center mb-16"
        >
          <h1 className="text-5xl font-bold text-white mb-6">
            About Gitalong
          </h1>
          <p className="text-xl text-gray-300 max-w-3xl mx-auto">
            We're building the future of open source collaboration, one match at a time.
          </p>
        </motion.div>

        <div className="space-y-12">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.2 }}
            className="bg-[#161B22] rounded-lg border border-[#30363D] p-8"
          >
            <h2 className="text-2xl font-bold text-white mb-4">Our Mission</h2>
            <p className="text-gray-300 leading-relaxed">
              Open source software powers the world, but finding the right projects to contribute to 
              has always been a challenge. Gitalong uses AI to match developers with projects that 
              align with their skills, interests, and availability, making open source contribution 
              more accessible and meaningful for everyone.
            </p>
          </motion.div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: 0.4 }}
              className="bg-[#161B22] rounded-lg border border-[#30363D] p-6 text-center"
            >
              <div className="w-12 h-12 bg-[#2EA043] rounded-lg flex items-center justify-center mx-auto mb-4">
                <Heart className="h-6 w-6 text-white" />
              </div>
              <h3 className="text-lg font-bold text-white mb-2">For Contributors</h3>
              <p className="text-gray-300 text-sm">
                Discover projects that match your skills and interests. No more endless searching.
              </p>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: 0.5 }}
              className="bg-[#161B22] rounded-lg border border-[#30363D] p-6 text-center"
            >
              <div className="w-12 h-12 bg-[#2EA043] rounded-lg flex items-center justify-center mx-auto mb-4">
                <Users className="h-6 w-6 text-white" />
              </div>
              <h3 className="text-lg font-bold text-white mb-2">For Maintainers</h3>
              <p className="text-gray-300 text-sm">
                Connect with qualified contributors who are genuinely interested in your project.
              </p>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: 0.6 }}
              className="bg-[#161B22] rounded-lg border border-[#30363D] p-6 text-center"
            >
              <div className="w-12 h-12 bg-[#2EA043] rounded-lg flex items-center justify-center mx-auto mb-4">
                <Zap className="h-6 w-6 text-white" />
              </div>
              <h3 className="text-lg font-bold text-white mb-2">AI-Powered</h3>
              <p className="text-gray-300 text-sm">
                Smart matching algorithms that learn from your preferences and improve over time.
              </p>
            </motion.div>
          </div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.8 }}
            className="bg-[#161B22] rounded-lg border border-[#30363D] p-8"
          >
            <h2 className="text-2xl font-bold text-white mb-4">Why Mobile-First?</h2>
            <p className="text-gray-300 leading-relaxed mb-4">
              We believe that the best connections happen when you can engage with the community 
              anywhere, anytime. Our mobile-first approach means you can discover new projects 
              during your commute, chat with maintainers on the go, and stay connected with your 
              open source community wherever you are.
            </p>
            <p className="text-gray-300 leading-relaxed">
              The swipe interface makes discovering projects fun and intuitive, while our AI 
              learns from your preferences to show you increasingly relevant matches.
            </p>
          </motion.div>
        </div>
      </div>
    </div>
  );
};