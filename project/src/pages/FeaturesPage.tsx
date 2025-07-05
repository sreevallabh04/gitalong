import React from 'react';
import { motion } from 'framer-motion';
import { Brain, GitBranch, MessageCircle, TrendingUp, Shield, Zap } from 'lucide-react';

export const FeaturesPage: React.FC = () => {
  const features = [
    {
      icon: Brain,
      title: "AI-Powered Matching",
      description: "Our advanced AI analyzes your tech stack, GitHub activity, and contribution patterns to find perfect project matches.",
      details: [
        "Tech stack similarity analysis",
        "GitHub activity pattern recognition",
        "Contribution history evaluation",
        "Skill gap identification"
      ]
    },
    {
      icon: GitBranch,
      title: "Smart Project Discovery",
      description: "Discover projects that align with your interests, skills, and availability through intelligent recommendations.",
      details: [
        "Project difficulty matching",
        "Language preference filtering",
        "Contribution opportunity mapping",
        "Maintainer response rate analysis"
      ]
    },
    {
      icon: MessageCircle,
      title: "Seamless Communication",
      description: "Built-in messaging system designed specifically for technical discussions and collaboration planning.",
      details: [
        "Code snippet sharing",
        "Technical discussion threads",
        "Project milestone tracking",
        "Collaboration scheduling"
      ]
    },
    {
      icon: TrendingUp,
      title: "Contribution Analytics",
      description: "Track your open source journey with detailed analytics and contribution insights.",
      details: [
        "Contribution graph visualization",
        "Impact measurement metrics",
        "Skill development tracking",
        "Community reputation scoring"
      ]
    },
    {
      icon: Shield,
      title: "Trust & Safety",
      description: "Comprehensive verification system ensures authentic connections and quality collaborations.",
      details: [
        "GitHub account verification",
        "Contribution history validation",
        "Community feedback system",
        "Spam and abuse protection"
      ]
    },
    {
      icon: Zap,
      title: "Instant Matching",
      description: "Real-time matching algorithm that adapts to your preferences and learning patterns.",
      details: [
        "Swipe feedback integration",
        "Preference learning system",
        "Match quality optimization",
        "Instant notification system"
      ]
    }
  ];

  return (
    <div className="min-h-screen py-20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          className="text-center mb-20"
        >
          <h1 className="text-5xl md:text-6xl font-bold text-white mb-6">
            Powerful Features for
            <span className="text-[#2EA043]"> Modern Collaboration</span>
          </h1>
          <p className="text-xl text-gray-300 max-w-3xl mx-auto">
            Discover how Gitalong revolutionizes open source collaboration with cutting-edge AI 
            and intuitive design built for developers, by developers.
          </p>
        </motion.div>

        {/* Features Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mb-20">
          {features.map((feature, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: index * 0.1 }}
              className="bg-[#161B22] rounded-lg p-8 border border-[#30363D] hover:border-[#2EA043] transition-all hover:shadow-xl"
            >
              <div className="flex items-center mb-4">
                <div className="w-12 h-12 bg-[#2EA043] rounded-lg flex items-center justify-center mr-4">
                  <feature.icon className="h-6 w-6 text-white" />
                </div>
                <h3 className="text-xl font-bold text-white">{feature.title}</h3>
              </div>
              <p className="text-gray-300 mb-6">{feature.description}</p>
              <ul className="space-y-2">
                {feature.details.map((detail, detailIndex) => (
                  <li key={detailIndex} className="flex items-center text-sm text-gray-400">
                    <div className="w-2 h-2 bg-[#2EA043] rounded-full mr-3" />
                    {detail}
                  </li>
                ))}
              </ul>
            </motion.div>
          ))}
        </div>

        {/* Contribution Graph Visualization */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.6 }}
          className="bg-[#161B22] rounded-lg p-8 border border-[#30363D] mb-20"
        >
          <h2 className="text-2xl font-bold text-white mb-6 text-center">
            Track Your Open Source Journey
          </h2>
          <div className="grid grid-cols-12 gap-1 max-w-4xl mx-auto">
            {Array.from({ length: 365 }, (_, i) => (
              <div
                key={i}
                className={`w-3 h-3 rounded-sm ${
                  Math.random() > 0.7
                    ? 'bg-[#2EA043]'
                    : Math.random() > 0.5
                    ? 'bg-[#2EA043]/60'
                    : Math.random() > 0.3
                    ? 'bg-[#2EA043]/30'
                    : 'bg-[#30363D]'
                }`}
              />
            ))}
          </div>
          <div className="flex justify-between items-center mt-4 text-sm text-gray-400">
            <span>Less</span>
            <div className="flex items-center space-x-1">
              <div className="w-3 h-3 bg-[#30363D] rounded-sm" />
              <div className="w-3 h-3 bg-[#2EA043]/30 rounded-sm" />
              <div className="w-3 h-3 bg-[#2EA043]/60 rounded-sm" />
              <div className="w-3 h-3 bg-[#2EA043] rounded-sm" />
            </div>
            <span>More</span>
          </div>
        </motion.div>

        {/* App Screenshots Section */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.8 }}
          className="text-center"
        >
          <h2 className="text-3xl font-bold text-white mb-12">
            Experience the Mobile App
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {/* Mock Screenshots */}
            <div className="bg-[#161B22] rounded-2xl p-6 border border-[#30363D] max-w-xs mx-auto">
              <div className="bg-[#21262D] rounded-xl p-4 mb-4">
                <div className="w-full h-32 bg-gradient-to-br from-[#2EA043] to-[#2EA043]/60 rounded-lg flex items-center justify-center">
                  <span className="text-white font-bold">Swipe Interface</span>
                </div>
              </div>
              <h3 className="text-white font-semibold mb-2">Discover Projects</h3>
              <p className="text-gray-400 text-sm">Swipe through curated project matches</p>
            </div>
            
            <div className="bg-[#161B22] rounded-2xl p-6 border border-[#30363D] max-w-xs mx-auto">
              <div className="bg-[#21262D] rounded-xl p-4 mb-4">
                <div className="w-full h-32 bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg flex items-center justify-center">
                  <span className="text-white font-bold">Chat Interface</span>
                </div>
              </div>
              <h3 className="text-white font-semibold mb-2">Connect & Chat</h3>
              <p className="text-gray-400 text-sm">Discuss projects with maintainers</p>
            </div>
            
            <div className="bg-[#161B22] rounded-2xl p-6 border border-[#30363D] max-w-xs mx-auto">
              <div className="bg-[#21262D] rounded-xl p-4 mb-4">
                <div className="w-full h-32 bg-gradient-to-br from-purple-500 to-purple-600 rounded-lg flex items-center justify-center">
                  <span className="text-white font-bold">Analytics</span>
                </div>
              </div>
              <h3 className="text-white font-semibold mb-2">Track Progress</h3>
              <p className="text-gray-400 text-sm">Monitor your contribution journey</p>
            </div>
          </div>
        </motion.div>
      </div>
    </div>
  );
};