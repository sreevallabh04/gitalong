import React from 'react';
import { motion } from 'framer-motion';
import { Heart, MessageSquare, GitBranch, Shield, Zap, Users, Code, ArrowRight } from 'lucide-react';

export const FeaturesSection: React.FC = () => {
  const features = [
    {
      icon: Heart,
      title: "Smart Matching",
      description: "Our algorithm analyzes your GitHub activity, tech stack, and coding style to find developers who complement your skills and share your interests.",
      color: "from-pink-500 to-red-500"
    },
    {
      icon: GitBranch,
      title: "GitHub Integration",
      description: "Connect your GitHub account to showcase your real projects, contributions, and coding expertise. Let your code speak for itself.",
      color: "from-[#2EA043] to-[#3FB950]"
    },
    {
      icon: MessageSquare,
      title: "Collaborative Chat",
      description: "Start meaningful conversations with potential collaborators. Share ideas, discuss project requirements, and plan your next big build.",
      color: "from-blue-500 to-purple-500"
    },
    {
      icon: Shield,
      title: "Verified Profiles",
      description: "All developers are verified through GitHub authentication. No fake profiles, just real developers with real projects and skills.",
      color: "from-green-500 to-emerald-500"
    },
    {
      icon: Zap,
      title: "Real-time Updates",
      description: "Get instant notifications when someone wants to collaborate, sends you a message, or shows interest in your projects.",
      color: "from-yellow-500 to-orange-500"
    },
    {
      icon: Users,
      title: "Build Together",
      description: "Join forces with developers who share your vision. Create open-source projects, build startups, or just code for fun together.",
      color: "from-indigo-500 to-purple-500"
    }
  ];

  return (
    <section className="py-20 bg-[#161B22] relative overflow-hidden">
      {/* Background Effects */}
      <div className="absolute inset-0 bg-gradient-to-br from-[#161B22] via-[#0D1117] to-[#161B22]"></div>
      
      {/* Animated Background Elements */}
      <motion.div
        className="absolute top-10 left-10 w-20 h-20 bg-[#2EA043]/10 rounded-full"
        animate={{
          scale: [1, 1.2, 1],
          opacity: [0.1, 0.3, 0.1],
        }}
        transition={{
          duration: 4,
          repeat: Infinity,
          ease: "easeInOut"
        }}
      />
      <motion.div
        className="absolute bottom-10 right-10 w-32 h-32 bg-[#3FB950]/10 rounded-full"
        animate={{
          scale: [1, 1.3, 1],
          opacity: [0.1, 0.2, 0.1],
        }}
        transition={{
          duration: 6,
          repeat: Infinity,
          ease: "easeInOut"
        }}
      />
      
      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          viewport={{ once: true }}
          className="text-center mb-16"
        >
          <h2 className="text-4xl md:text-5xl font-bold mb-6 bg-gradient-to-r from-white to-[#2EA043] bg-clip-text text-transparent">
            Why GitAlong Works
          </h2>
          <p className="text-xl text-gray-300 max-w-3xl mx-auto">
            We've solved the real problem of finding the right coding partner. 
            No more endless searching or awkward cold messages on GitHub.
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
              whileHover={{ y: -5 }}
            >
              <motion.div 
                className={`inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-gradient-to-r ${feature.color} mb-6 group-hover:scale-110 transition-transform duration-300`}
                whileHover={{ rotate: 360 }}
                transition={{ duration: 0.6 }}
              >
                <feature.icon className="h-8 w-8 text-white" />
              </motion.div>
              
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
            <Code className="h-4 w-4 mr-2" />
            Built with ❤️ by developers
          </div>
          
          <h3 className="text-3xl font-bold text-white mb-4">
            Ready to Find Your Coding Partner?
          </h3>
          
          <p className="text-gray-300 mb-8 max-w-2xl mx-auto">
            Join the community of developers who are tired of coding alone. 
            Connect with like-minded developers and build something amazing together.
          </p>
          
          <motion.button 
            className="group inline-flex items-center px-8 py-4 bg-gradient-to-r from-[#2EA043] to-[#3FB950] text-white font-semibold rounded-2xl text-lg shadow-2xl hover:shadow-[#2EA043]/25 transition-all duration-300 hover:scale-105"
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            Start Connecting
            <ArrowRight className="h-5 w-5 ml-2 group-hover:translate-x-1 transition-transform duration-300" />
          </motion.button>
        </motion.div>
      </div>
    </section>
  );
}; 