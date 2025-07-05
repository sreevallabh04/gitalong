import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { Mail, MessageSquare, Download, ArrowRight } from 'lucide-react';

export const ContactPage: React.FC = () => {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    message: ''
  });

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Mock form submission - in real app, this would send to backend
    alert('Thank you for your message! We\'ll get back to you soon.');
    setFormData({ name: '', email: '', message: '' });
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
            <h1 className="text-5xl md:text-7xl font-bold mb-6 bg-gradient-to-r from-white to-[#2EA043] bg-clip-text text-transparent">
              Get in Touch
            </h1>
            <p className="text-xl md:text-2xl text-gray-300 max-w-3xl mx-auto leading-relaxed">
              Have questions about GitAlong? We'd love to hear from you. 
              Send us a message and we'll respond as soon as possible.
            </p>
          </motion.div>
        </div>
      </section>

      {/* Contact Form Section */}
      <section className="py-20 bg-[#161B22]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12">
            {/* Contact Form */}
            <motion.div
              initial={{ opacity: 0, x: -30 }}
              whileInView={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8 }}
              viewport={{ once: true }}
            >
              <h2 className="text-3xl font-bold text-white mb-8">Send us a Message</h2>
              <form onSubmit={handleSubmit} className="space-y-6">
                <div>
                  <label htmlFor="name" className="block text-sm font-medium text-gray-300 mb-2">
                    Name
                  </label>
                  <input
                    type="text"
                    id="name"
                    name="name"
                    value={formData.name}
                    onChange={handleInputChange}
                    required
                    className="w-full px-4 py-3 bg-[#0D1117] border border-[#30363D] rounded-xl text-white placeholder-gray-400 focus:border-[#2EA043] focus:outline-none transition-colors duration-300"
                    placeholder="Your name"
                  />
                </div>
                
                <div>
                  <label htmlFor="email" className="block text-sm font-medium text-gray-300 mb-2">
                    Email
                  </label>
                  <input
                    type="email"
                    id="email"
                    name="email"
                    value={formData.email}
                    onChange={handleInputChange}
                    required
                    className="w-full px-4 py-3 bg-[#0D1117] border border-[#30363D] rounded-xl text-white placeholder-gray-400 focus:border-[#2EA043] focus:outline-none transition-colors duration-300"
                    placeholder="your.email@example.com"
                  />
                </div>
                
                <div>
                  <label htmlFor="message" className="block text-sm font-medium text-gray-300 mb-2">
                    Message
                  </label>
                  <textarea
                    id="message"
                    name="message"
                    value={formData.message}
                    onChange={handleInputChange}
                    required
                    rows={5}
                    className="w-full px-4 py-3 bg-[#0D1117] border border-[#30363D] rounded-xl text-white placeholder-gray-400 focus:border-[#2EA043] focus:outline-none transition-colors duration-300 resize-none"
                    placeholder="Tell us about your question or feedback..."
                  />
                </div>
                
                <button
                  type="submit"
                  className="w-full px-8 py-4 bg-gradient-to-r from-[#2EA043] to-[#3FB950] text-white font-semibold rounded-xl hover:scale-105 transition-all duration-300 hover:shadow-xl hover:shadow-[#2EA043]/25"
                >
                  <MessageSquare className="h-5 w-5 mr-2 inline" />
                  Send Message
                </button>
              </form>
            </motion.div>

            {/* Contact Info */}
            <motion.div
              initial={{ opacity: 0, x: 30 }}
              whileInView={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8 }}
              viewport={{ once: true }}
            >
              <h2 className="text-3xl font-bold text-white mb-8">Contact Information</h2>
              
              <div className="space-y-8">
                <div className="flex items-start space-x-4">
                  <div className="w-12 h-12 bg-gradient-to-r from-[#2EA043] to-[#3FB950] rounded-xl flex items-center justify-center flex-shrink-0">
                    <Mail className="h-6 w-6 text-white" />
                  </div>
                  <div>
                    <h3 className="text-lg font-semibold text-white mb-2">Email</h3>
                    <p className="text-gray-300">hello@gitalong.app</p>
                    <p className="text-gray-400 text-sm">We typically respond within 24 hours</p>
                  </div>
                </div>

                <div className="flex items-start space-x-4">
                  <div className="w-12 h-12 bg-gradient-to-r from-[#2EA043] to-[#3FB950] rounded-xl flex items-center justify-center flex-shrink-0">
                    <Download className="h-6 w-6 text-white" />
                  </div>
                  <div>
                    <h3 className="text-lg font-semibold text-white mb-2">Download App</h3>
                    <p className="text-gray-300 mb-4">Get the latest version of GitAlong</p>
                    <button
                      onClick={handleDownloadApp}
                      className="inline-flex items-center px-6 py-3 bg-[#0D1117] border border-[#30363D] text-white font-medium rounded-xl hover:border-[#2EA043] hover:text-[#2EA043] transition-all duration-300"
                    >
                      Download Now
                      <ArrowRight className="h-4 w-4 ml-2" />
                    </button>
                  </div>
                </div>
              </div>

              {/* FAQ Section */}
              <div className="mt-12 p-8 bg-[#0D1117] rounded-2xl border border-[#30363D]">
                <h3 className="text-xl font-bold text-white mb-6">Frequently Asked Questions</h3>
                <div className="space-y-4">
                  <div>
                    <h4 className="text-white font-medium mb-2">How does GitAlong work?</h4>
                    <p className="text-gray-300 text-sm">
                      GitAlong uses a Tinder-style interface to help developers find collaboration partners. 
                      Connect your GitHub account, swipe through profiles, and start building together.
                    </p>
                  </div>
                  <div>
                    <h4 className="text-white font-medium mb-2">Is GitAlong free to use?</h4>
                    <p className="text-gray-300 text-sm">
                      Yes! GitAlong is completely free to download and use. We believe in making 
                      collaboration accessible to all developers.
                    </p>
                  </div>
                  <div>
                    <h4 className="text-white font-medium mb-2">How do I get started?</h4>
                    <p className="text-gray-300 text-sm">
                      Simply download the app, connect your GitHub account, and start swiping through 
                      developer profiles to find your perfect match.
                    </p>
                  </div>
                </div>
              </div>
            </motion.div>
          </div>
        </div>
      </section>
    </div>
  );
};