import React from 'react';
import { motion } from 'framer-motion';
import { Brain, MessageCircle, Github, Zap, Shield, TrendingUp, Users, Code, ArrowRight } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

export const FeaturesSection: React.FC = () => {
  const navigate = useNavigate();

  const features = [
    {
      icon: Brain,
      title: "AI-Powered Matching",
      description: "Our advanced AI analyzes your GitHub activity, tech stack, and contribution patterns to find perfect project matches with 95% accuracy.",
      gradient: "from-purple-500 to-pink-500",
      delay: 0.1
    },
    {
      icon: MessageCircle,
      title: "Real-time Collaboration",
      description: "Chat directly with maintainers and contributors. Share code snippets, discuss ideas, and coordinate seamlessly.",
      gradient: "from-blue-500 to-cyan-500",
      delay: 0.2
    },
    {
      icon: Github,
      title: "GitHub Integration",
      description: "Seamless integration with your GitHub profile. Import projects, track contributions, and sync activity automatically.",
      gradient: "from-green-500 to-emerald-500",
      delay: 0.3
    },
    {
      icon: Shield,
      title: "Trust & Security",
      description: "Enterprise-grade security with verified profiles, secure messaging, and protected code sharing.",
      gradient: "from-orange-500 to-red-500",
      delay: 0.4
    },
    {
      icon: TrendingUp,
      title: "Analytics Dashboard",
      description: "Track your contribution impact, project health metrics, and collaboration success rates in real-time.",
      gradient: "from-indigo-500 to-purple-500",
      delay: 0.5
    },
    {
      icon: Code,
      title: "Code Review Tools",
      description: "Built-in code review tools with syntax highlighting, diff visualization, and collaborative commenting.",
      gradient: "from-teal-500 to-blue-500",
      delay: 0.6
    }
  ];

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1
      }
    }
  };

  const cardVariants = {
    hidden: { opacity: 0, y: 50 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        duration: 0.6,
        ease: "easeOut"
      }
    }
  };

  const handleStartBuildingClick = () => {
    navigate('/search');
  };

  const handleViewDocumentationClick = () => {
    // Mock documentation link - in real app, this would link to actual docs
    window.open('https://docs.gitalong.app', '_blank');
  };

  return (
    <section className="py-24 relative overflow-hidden">
      {/* Background gradient */}
      <div className="absolute inset-0 bg-gradient-to-b from-[#0D1117] via-[#161B22] to-[#0D1117]"></div>
      
      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section header */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          viewport={{ once: true }}
          className="text-center mb-16"
        >
          <motion.div
            initial={{ opacity: 0, scale: 0.8 }}
            whileInView={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.6, delay: 0.2 }}
            viewport={{ once: true }}
            className="inline-flex items-center px-4 py-2 bg-[#2EA043]/20 border border-[#2EA043] rounded-full text-[#2EA043] text-sm font-medium mb-6"
          >
            <Zap className="w-4 h-4 mr-2" />
            Powerful Features
          </motion.div>
          
          <h2 className="text-4xl md:text-6xl font-bold gradient-text mb-6">
            Everything you need to
            <br />
            <span className="text-[#2EA043]">collaborate effectively</span>
          </h2>
          
          <p className="text-xl text-gray-300 max-w-3xl mx-auto">
            Built for developers, by developers. Experience the future of open-source collaboration.
          </p>
        </motion.div>

        {/* Features grid */}
        <motion.div
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8"
        >
          {features.map((feature, index) => (
            <motion.div
              key={index}
              variants={cardVariants}
              custom={feature.delay}
              whileHover={{ 
                y: -10,
                scale: 1.02,
                transition: { duration: 0.3 }
              }}
              className="group relative"
            >
              {/* Gradient border */}
              <div className="absolute inset-0 bg-gradient-to-r from-[#2EA043] to-[#238636] rounded-2xl p-[1px] opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                <div className="bg-[#161B22] rounded-2xl h-full"></div>
              </div>
              
              <div className="relative bg-[#161B22] border border-[#30363D] rounded-2xl p-8 h-full hover:border-[#2EA043] transition-all duration-300">
                {/* Icon */}
                <div className={`w-16 h-16 bg-gradient-to-r ${feature.gradient} rounded-2xl flex items-center justify-center mb-6 group-hover:scale-110 transition-transform duration-300`}>
                  <feature.icon className="w-8 h-8 text-white" />
                </div>
                
                {/* Content */}
                <h3 className="text-2xl font-bold text-white mb-4 group-hover:text-[#2EA043] transition-colors duration-300">
                  {feature.title}
                </h3>
                
                <p className="text-gray-300 leading-relaxed">
                  {feature.description}
                </p>
                
                {/* Hover effect */}
                <div className="absolute inset-0 bg-gradient-to-r from-[#2EA043]/5 to-transparent rounded-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
              </div>
            </motion.div>
          ))}
        </motion.div>

        {/* Bottom CTA */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.8 }}
          viewport={{ once: true }}
          className="text-center mt-16"
        >
          <div className="inline-flex items-center space-x-4">
            <button 
              onClick={handleStartBuildingClick}
              className="btn-primary group"
            >
              Start Building Today
              <ArrowRight className="w-5 h-5 ml-2 group-hover:translate-x-1 transition-transform" />
            </button>
            <button 
              onClick={handleViewDocumentationClick}
              className="btn-secondary"
            >
              View Documentation
            </button>
          </div>
        </motion.div>
      </div>
    </section>
  );
}; 