import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { Mail, MessageCircle, Github, Send } from 'lucide-react';

export const ContactPage: React.FC = () => {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    subject: '',
    message: ''
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    console.log('Form submitted:', formData);
    setFormData({ name: '', email: '', subject: '', message: '' });
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

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
            Get in Touch
          </h1>
          <p className="text-xl text-gray-300 max-w-2xl mx-auto">
            Have questions about Gitalong? Want to join our beta? We'd love to hear from you.
          </p>
        </motion.div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12">
          <motion.div
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8, delay: 0.2 }}
            className="bg-[#161B22] rounded-lg border border-[#30363D] p-8"
          >
            <h2 className="text-2xl font-bold text-white mb-6">Send us a message</h2>
            <form onSubmit={handleSubmit} className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label htmlFor="name" className="block text-sm font-medium text-gray-300 mb-2">
                    Name
                  </label>
                  <input
                    type="text"
                    id="name"
                    name="name"
                    value={formData.name}
                    onChange={handleChange}
                    className="w-full px-3 py-2 bg-[#0D1117] border border-[#30363D] rounded-lg text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#2EA043] focus:border-transparent"
                    placeholder="Your name"
                    required
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
                    onChange={handleChange}
                    className="w-full px-3 py-2 bg-[#0D1117] border border-[#30363D] rounded-lg text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#2EA043] focus:border-transparent"
                    placeholder="your@email.com"
                    required
                  />
                </div>
              </div>
              
              <div>
                <label htmlFor="subject" className="block text-sm font-medium text-gray-300 mb-2">
                  Subject
                </label>
                <select
                  id="subject"
                  name="subject"
                  value={formData.subject}
                  onChange={handleChange}
                  className="w-full px-3 py-2 bg-[#0D1117] border border-[#30363D] rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-[#2EA043] focus:border-transparent"
                  required
                >
                  <option value="">Select a subject</option>
                  <option value="beta">Join Beta Program</option>
                  <option value="support">General Support</option>
                  <option value="partnership">Partnership</option>
                  <option value="feedback">Feedback</option>
                  <option value="other">Other</option>
                </select>
              </div>
              
              <div>
                <label htmlFor="message" className="block text-sm font-medium text-gray-300 mb-2">
                  Message
                </label>
                <textarea
                  id="message"
                  name="message"
                  value={formData.message}
                  onChange={handleChange}
                  rows={6}
                  className="w-full px-3 py-2 bg-[#0D1117] border border-[#30363D] rounded-lg text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#2EA043] focus:border-transparent"
                  placeholder="Tell us how we can help you..."
                  required
                />
              </div>
              
              <button
                type="submit"
                className="w-full flex items-center justify-center px-6 py-3 bg-[#2EA043] text-white rounded-lg font-semibold hover:bg-[#2EA043]/90 transition-colors"
              >
                Send Message
                <Send className="ml-2 h-4 w-4" />
              </button>
            </form>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8, delay: 0.4 }}
            className="space-y-8"
          >
            <div className="bg-[#161B22] rounded-lg border border-[#30363D] p-8">
              <h2 className="text-2xl font-bold text-white mb-6">Quick Contact</h2>
              <div className="space-y-4">
                <div className="flex items-center">
                  <div className="w-10 h-10 bg-[#2EA043] rounded-lg flex items-center justify-center mr-4">
                    <Mail className="h-5 w-5 text-white" />
                  </div>
                  <div>
                    <p className="text-gray-300 text-sm">Email</p>
                    <p className="text-white font-semibold">hello@gitalong.dev</p>
                  </div>
                </div>
                <div className="flex items-center">
                  <div className="w-10 h-10 bg-[#2EA043] rounded-lg flex items-center justify-center mr-4">
                    <MessageCircle className="h-5 w-5 text-white" />
                  </div>
                  <div>
                    <p className="text-gray-300 text-sm">Discord</p>
                    <p className="text-white font-semibold">Join our community</p>
                  </div>
                </div>
                <div className="flex items-center">
                  <div className="w-10 h-10 bg-[#2EA043] rounded-lg flex items-center justify-center mr-4">
                    <Github className="h-5 w-5 text-white" />
                  </div>
                  <div>
                    <p className="text-gray-300 text-sm">GitHub</p>
                    <p className="text-white font-semibold">@gitalong</p>
                  </div>
                </div>
              </div>
            </div>

            <div className="bg-gradient-to-r from-[#2EA043] to-[#2EA043]/80 rounded-lg p-8 text-center">
              <h3 className="text-2xl font-bold text-white mb-4">Join the Beta</h3>
              <p className="text-white/90 mb-6">
                Be among the first to experience the future of open source collaboration. 
                Get early access to Gitalong when we launch.
              </p>
              <button className="bg-white text-[#2EA043] px-6 py-3 rounded-lg font-semibold hover:bg-gray-100 transition-colors">
                Request Beta Access
              </button>
            </div>
          </motion.div>
        </div>
      </div>
    </div>
  );
};