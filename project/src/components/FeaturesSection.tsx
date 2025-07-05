import React from 'react';
import { motion } from 'framer-motion';
import { Heart, MessageSquare, GitBranch, Shield, Zap, Users, Star, ArrowRight } from 'lucide-react';

export const FeaturesSection: React.FC = () => {
  const features = [
    {
      icon: Heart,
      title: "Tinder-Style Matching",
      description: "Swipe right on developers you'd love to collaborate with, left on those who aren't your match. Simple, intuitive, and fun.",
      color: "from-pink-500 to-red-500"
    },
    {
      icon: GitBranch,
      title: "GitHub Integration",
      description: "Connect your GitHub account to showcase your projects, skills, and contributions. Let your code speak for itself.",
      color: "from-[#2EA043] to-[#3FB950]"
    },
    {
      icon: MessageSquare,
      title: "Smart Messaging",
      description: "Start conversations with matched developers through our intelligent chat system. Share ideas, discuss projects, and plan collaborations.",
      color: "from-blue-500 to-purple-500"
    },
    {
      icon: Shield,
      title: "Verified Profiles",
      description: "All developers are verified through GitHub authentication. No fake profiles, just real developers ready to collaborate.",
      color: "from-green-500 to-emerald-500"
    },
    {
      icon: Zap,
      title: "Real-time Notifications",
      description: "Get instant notifications when someone likes your profile, sends you a message, or wants to collaborate on a project.",
      color: "from-yellow-500 to-orange-500"
    },
    {
      icon: Users,
      title: "Community Building",
      description: "Join developer communities, participate in discussions, and find like-minded developers for your next big project.",
      color: "from-indigo-500 to-purple-500"
    }
  ];

  return (
    <section className="py-20 bg-[#161B22] relative overflow-hidden">
      {/* Background Effects */}
      <div className="absolute inset-0 bg-gradient-to-br from-[#161B22] via-[#0D1117] to-[#161B22]"></div>
      
      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          viewport={{ once: true }}
          className="text-center mb-16"
        >
          <h2 className="text-4xl md:text-5xl font-bold mb-6 bg-gradient-to-r from-white to-[#2EA043] bg-clip-text text-transparent">
            Why Choose GitAlong?
          </h2>
          <p className="text-xl text-gray-300 max-w-3xl mx-auto">
            We've built the perfect platform for developers to find their ideal collaboration partners. 
            Join thousands of developers who've already found their perfect match.
          </p>
        </motion.div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {features.map((feature, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: index * 0.1 }}
              viewport={{ once: true }}
              className="group relative p-8 rounded-2xl bg-[#0D1117] border border-[#30363D] hover:border-[#2EA043] transition-all duration-300 hover:scale-105 hover:shadow-2xl hover:shadow-[#2EA043]/10"
            >
              <div className={`inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-gradient-to-r ${feature.color} mb-6 group-hover:scale-110 transition-transform duration-300`}>
                <feature.icon className="h-8 w-8 text-white" />
              </div>
              
              <h3 className="text-xl font-bold text-white mb-4 group-hover:text-[#2EA043] transition-colors duration-300">
                {feature.title}
              </h3>
              
              <p className="text-gray-300 leading-relaxed">
                {feature.description}
              </p>
            </motion.div>
          ))}
        </div>

        {/* CTA Section */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.6 }}
          viewport={{ once: true }}
          className="text-center mt-16"
        >
          <div className="inline-flex items-center px-6 py-3 rounded-full bg-[#2EA043]/10 border border-[#2EA043]/20 text-[#2EA043] text-sm font-medium mb-6">
            <Star className="h-4 w-4 mr-2" />
            Trusted by 10,000+ developers worldwide
          </div>
          
          <h3 className="text-3xl font-bold text-white mb-4">
            Ready to Find Your Perfect Match?
          </h3>
          
          <p className="text-gray-300 mb-8 max-w-2xl mx-auto">
            Join the community of developers who are already building amazing projects together. 
            Download GitAlong today and start your journey.
          </p>
          
          <button className="group inline-flex items-center px-8 py-4 bg-gradient-to-r from-[#2EA043] to-[#3FB950] text-white font-semibold rounded-2xl text-lg shadow-2xl hover:shadow-[#2EA043]/25 transition-all duration-300 hover:scale-105">
            Download Now
            <ArrowRight className="h-5 w-5 ml-2 group-hover:translate-x-1 transition-transform duration-300" />
          </button>
        </motion.div>
      </div>
    </section>
  );
}; 