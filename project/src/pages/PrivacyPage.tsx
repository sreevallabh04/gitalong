import React from 'react';
import { motion } from 'framer-motion';
import { Shield, Eye, Lock, Users } from 'lucide-react';

export const PrivacyPage: React.FC = () => {
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
            Privacy Policy
          </h1>
          <p className="text-xl text-gray-300 max-w-2xl mx-auto">
            Your privacy is important to us. Here's how we protect and use your data.
          </p>
        </motion.div>

        <div className="space-y-8">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.2 }}
            className="bg-[#161B22] rounded-lg border border-[#30363D] p-8"
          >
            <div className="flex items-center mb-4">
              <Shield className="h-6 w-6 text-[#2EA043] mr-3" />
              <h2 className="text-2xl font-bold text-white">Data Protection</h2>
            </div>
            <p className="text-gray-300 leading-relaxed">
              We use industry-standard encryption and security measures to protect your personal information. 
              Your GitHub data is accessed only with your explicit permission and is used solely to improve 
              your matching experience on Gitalong.
            </p>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.3 }}
            className="bg-[#161B22] rounded-lg border border-[#30363D] p-8"
          >
            <div className="flex items-center mb-4">
              <Eye className="h-6 w-6 text-[#2EA043] mr-3" />
              <h2 className="text-2xl font-bold text-white">What We Collect</h2>
            </div>
            <ul className="text-gray-300 space-y-2">
              <li>• GitHub profile information (public repositories, languages, contribution activity)</li>
              <li>• Email address for account creation and communication</li>
              <li>• App usage data to improve matching algorithms</li>
              <li>• Messages sent through our platform (encrypted)</li>
            </ul>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.4 }}
            className="bg-[#161B22] rounded-lg border border-[#30363D] p-8"
          >
            <div className="flex items-center mb-4">
              <Lock className="h-6 w-6 text-[#2EA043] mr-3" />
              <h2 className="text-2xl font-bold text-white">How We Use Your Data</h2>
            </div>
            <ul className="text-gray-300 space-y-2">
              <li>• To match you with relevant open source projects</li>
              <li>• To facilitate communication between contributors and maintainers</li>
              <li>• To improve our AI matching algorithms</li>
              <li>• To send you important updates about the platform</li>
            </ul>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.5 }}
            className="bg-[#161B22] rounded-lg border border-[#30363D] p-8"
          >
            <div className="flex items-center mb-4">
              <Users className="h-6 w-6 text-[#2EA043] mr-3" />
              <h2 className="text-2xl font-bold text-white">Data Sharing</h2>
            </div>
            <p className="text-gray-300 leading-relaxed">
              We never sell your personal data. We may share anonymized, aggregated data for research 
              purposes to benefit the open source community. Any data sharing is done with your explicit 
              consent and in compliance with applicable privacy laws.
            </p>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.6 }}
            className="bg-[#161B22] rounded-lg border border-[#30363D] p-8"
          >
            <h2 className="text-2xl font-bold text-white mb-4">Your Rights</h2>
            <div className="text-gray-300 space-y-3">
              <p><strong>Access:</strong> You can request a copy of all data we have about you.</p>
              <p><strong>Correction:</strong> You can update or correct your personal information at any time.</p>
              <p><strong>Deletion:</strong> You can request deletion of your account and all associated data.</p>
              <p><strong>Portability:</strong> You can export your data in a machine-readable format.</p>
            </div>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.7 }}
            className="bg-[#161B22] rounded-lg border border-[#30363D] p-8"
          >
            <h2 className="text-2xl font-bold text-white mb-4">Contact Us</h2>
            <p className="text-gray-300 leading-relaxed">
              If you have any questions about this Privacy Policy or how we handle your data, 
              please contact us at{' '}
              <a href="mailto:privacy@gitalong.dev" className="text-[#2EA043] hover:underline">
                privacy@gitalong.dev
              </a>
            </p>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.8 }}
            className="text-center text-gray-400 text-sm"
          >
            <p>Last updated: January 2025</p>
          </motion.div>
        </div>
      </div>
    </div>
  );
};