import React from 'react';
import { motion } from 'framer-motion';
import { Shield, Download, ArrowRight } from 'lucide-react';

export const PrivacyPage: React.FC = () => {
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
    <div className="min-h-screen bg-[#0D1117]">
      {/* Hero Section */}
      <section className="py-20 relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-[#0D1117] via-[#161B22] to-[#0D1117]"></div>
        
        <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            className="text-center mb-16"
          >
            <div className="inline-flex items-center px-4 py-2 rounded-full bg-[#2EA043]/10 border border-[#2EA043]/20 text-[#2EA043] text-sm font-medium mb-6">
              <Shield className="h-4 w-4 mr-2" />
              Your Privacy Matters
            </div>
            <h1 className="text-5xl md:text-7xl font-bold mb-6 bg-gradient-to-r from-white to-[#2EA043] bg-clip-text text-transparent">
              Privacy Policy
            </h1>
            <p className="text-xl md:text-2xl text-gray-300 max-w-3xl mx-auto leading-relaxed">
              We're committed to protecting your privacy and ensuring a secure experience on GitAlong.
            </p>
          </motion.div>
        </div>
      </section>

      {/* Privacy Content */}
      <section className="py-20 bg-[#161B22]">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            viewport={{ once: true }}
            className="prose prose-invert max-w-none"
          >
            <div className="bg-[#0D1117] rounded-2xl p-8 border border-[#30363D] mb-8">
              <h2 className="text-2xl font-bold text-white mb-4">Information We Collect</h2>
              <p className="text-gray-300 mb-4">
                GitAlong collects only the information necessary to provide you with the best possible experience:
              </p>
              <ul className="text-gray-300 space-y-2">
                <li>• GitHub profile information (public data only)</li>
                <li>• App usage analytics to improve our service</li>
                <li>• Communication preferences and settings</li>
                <li>• Device information for app optimization</li>
              </ul>
            </div>

            <div className="bg-[#0D1117] rounded-2xl p-8 border border-[#30363D] mb-8">
              <h2 className="text-2xl font-bold text-white mb-4">How We Use Your Information</h2>
              <p className="text-gray-300 mb-4">
                Your information helps us provide a personalized and secure experience:
              </p>
              <ul className="text-gray-300 space-y-2">
                <li>• Match you with compatible developers</li>
                <li>• Improve our matching algorithms</li>
                <li>• Provide customer support</li>
                <li>• Send important app updates and notifications</li>
              </ul>
            </div>

            <div className="bg-[#0D1117] rounded-2xl p-8 border border-[#30363D] mb-8">
              <h2 className="text-2xl font-bold text-white mb-4">Data Security</h2>
              <p className="text-gray-300 mb-4">
                We implement industry-standard security measures to protect your data:
              </p>
              <ul className="text-gray-300 space-y-2">
                <li>• End-to-end encryption for all communications</li>
                <li>• Secure cloud storage with regular backups</li>
                <li>• Regular security audits and updates</li>
                <li>• Compliance with data protection regulations</li>
              </ul>
            </div>

            <div className="bg-[#0D1117] rounded-2xl p-8 border border-[#30363D] mb-8">
              <h2 className="text-2xl font-bold text-white mb-4">Your Rights</h2>
              <p className="text-gray-300 mb-4">
                You have complete control over your data:
              </p>
              <ul className="text-gray-300 space-y-2">
                <li>• Access and download your data at any time</li>
                <li>• Request deletion of your account and data</li>
                <li>• Opt out of non-essential communications</li>
                <li>• Control what information is shared with other users</li>
              </ul>
            </div>

            <div className="bg-[#0D1117] rounded-2xl p-8 border border-[#30363D]">
              <h2 className="text-2xl font-bold text-white mb-4">Contact Us</h2>
              <p className="text-gray-300 mb-4">
                If you have any questions about our privacy practices, please contact us:
              </p>
              <p className="text-gray-300">
                Email: privacy@gitalong.app<br />
                We're committed to transparency and will respond to all privacy-related inquiries within 48 hours.
              </p>
            </div>
          </motion.div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-[#0D1117]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            viewport={{ once: true }}
          >
            <h2 className="text-4xl font-bold text-white mb-6">
              Ready to Get Started?
            </h2>
            <p className="text-xl text-gray-300 mb-8 max-w-2xl mx-auto">
              Join thousands of developers who trust GitAlong with their privacy and collaboration needs.
            </p>
            <button
              onClick={handleDownloadApp}
              className="group inline-flex items-center px-8 py-4 bg-gradient-to-r from-[#2EA043] to-[#3FB950] text-white font-semibold rounded-2xl text-lg shadow-2xl hover:shadow-[#2EA043]/25 transition-all duration-300 hover:scale-105"
            >
              <Download className="h-5 w-5 mr-2" />
              Download GitAlong
              <ArrowRight className="h-5 w-5 ml-2 group-hover:translate-x-1 transition-transform duration-300" />
            </button>
          </motion.div>
        </div>
      </section>
    </div>
  );
};