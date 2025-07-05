import React from 'react';
import { motion } from 'framer-motion';
import { Users, Heart, GitBranch, Zap, ArrowRight, Code, MessageSquare } from 'lucide-react';

export const AboutPage: React.FC = () => {
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
        
        {/* Animated Background Elements */}
        <motion.div
          className="absolute top-20 left-20 w-32 h-32 bg-[#2EA043]/10 rounded-full"
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
        <motion.div
          className="absolute bottom-20 right-20 w-40 h-40 bg-[#3FB950]/10 rounded-full"
          animate={{
            scale: [1, 1.2, 1],
            opacity: [0.1, 0.15, 0.1],
          }}
          transition={{
            duration: 8,
            repeat: Infinity,
            ease: "easeInOut"
          }}
        />
        
        <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            className="text-center mb-16"
          >
            <h1 className="text-5xl md:text-7xl font-bold mb-6 bg-gradient-to-r from-white to-[#2EA043] bg-clip-text text-transparent">
              About GitAlong
            </h1>
            <p className="text-xl md:text-2xl text-gray-300 max-w-3xl mx-auto leading-relaxed">
              A student's solution to the real problem of finding coding partners and collaborators.
            </p>
          </motion.div>
        </div>
      </section>

      {/* Story Section */}
      <section className="py-20 bg-[#161B22]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
            <motion.div
              initial={{ opacity: 0, x: -30 }}
              whileInView={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8 }}
              viewport={{ once: true }}
            >
              <h2 className="text-4xl font-bold text-white mb-6">
                The Problem I Solved
              </h2>
              <p className="text-gray-300 text-lg leading-relaxed mb-6">
                As a computer science student, I was constantly struggling to find people to work on projects with. 
                My classmates were busy, my friends weren't into coding, and cold messaging developers on GitHub felt awkward and rarely worked.
              </p>
              <p className="text-gray-300 text-lg leading-relaxed mb-6">
                I realized this was a universal problem - developers everywhere were coding alone, missing out on 
                collaboration opportunities, and struggling to find partners for their projects. That's when I decided 
                to build GitAlong.
              </p>
              <p className="text-gray-300 text-lg leading-relaxed">
                GitAlong makes it easy to discover developers who share your interests, skills, and goals. 
                No more awkward cold messages or endless searching - just meaningful connections that lead to 
                amazing projects.
              </p>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, x: 30 }}
              whileInView={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8 }}
              viewport={{ once: true }}
              className="relative"
            >
              <div className="bg-gradient-to-br from-[#2EA043] to-[#3FB950] p-8 rounded-2xl">
                <div className="bg-[#0D1117] p-6 rounded-xl">
                  <h3 className="text-2xl font-bold text-white mb-4">My Mission</h3>
                  <p className="text-gray-300 leading-relaxed">
                    To eliminate the loneliness of coding and make collaboration accessible to every developer, 
                    regardless of their experience level or background.
                  </p>
                </div>
              </div>
            </motion.div>
          </div>
        </div>
      </section>

      {/* Values Section */}
      <section className="py-20 bg-[#0D1117]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            viewport={{ once: true }}
            className="text-center mb-16"
          >
            <h2 className="text-4xl font-bold text-white mb-6">
              What I Believe In
            </h2>
            <p className="text-xl text-gray-300 max-w-3xl mx-auto">
              These principles guide everything I do at GitAlong
            </p>
          </motion.div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {[
              {
                icon: Users,
                title: "Community First",
                description: "I believe in the power of community and fostering meaningful connections between developers."
              },
              {
                icon: Heart,
                title: "Authentic Connections",
                description: "I prioritize genuine, verified profiles to ensure quality matches and meaningful collaborations."
              },
              {
                icon: GitBranch,
                title: "Open Source Spirit",
                description: "I'm committed to the open-source ethos of collaboration, transparency, and shared knowledge."
              }
            ].map((value, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.8, delay: index * 0.1 }}
                viewport={{ once: true }}
                className="text-center p-8 rounded-2xl bg-[#161B22] border border-[#30363D] hover:border-[#2EA043] transition-all duration-300"
                whileHover={{ y: -5 }}
              >
                <motion.div 
                  className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-gradient-to-r from-[#2EA043] to-[#3FB950] mb-6"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.6 }}
                >
                  <value.icon className="h-8 w-8 text-white" />
                </motion.div>
                <h3 className="text-xl font-bold text-white mb-4">{value.title}</h3>
                <p className="text-gray-300">{value.description}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* How It Works Section */}
      <section className="py-20 bg-[#161B22]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            viewport={{ once: true }}
            className="text-center mb-16"
          >
            <h2 className="text-4xl font-bold text-white mb-6">
              How GitAlong Works
            </h2>
            <p className="text-xl text-gray-300 max-w-3xl mx-auto">
              Simple, effective, and designed for real developers
            </p>
          </motion.div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {[
              {
                icon: Code,
                title: "Connect Your GitHub",
                description: "Link your GitHub account to showcase your real projects, skills, and contributions."
              },
              {
                icon: MessageSquare,
                title: "Discover Developers",
                description: "Browse through developers who match your interests, skills, and project goals."
              },
              {
                icon: Heart,
                title: "Start Collaborating",
                description: "Connect with developers, start conversations, and build amazing projects together."
              }
            ].map((step, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.8, delay: index * 0.2 }}
                viewport={{ once: true }}
                className="text-center p-8 rounded-2xl bg-[#0D1117] border border-[#30363D] hover:border-[#2EA043] transition-all duration-300"
                whileHover={{ y: -5 }}
              >
                <div className="inline-flex items-center justify-center w-12 h-12 rounded-full bg-[#2EA043] text-white font-bold text-lg mb-4">
                  {index + 1}
                </div>
                <motion.div 
                  className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-gradient-to-r from-[#2EA043] to-[#3FB950] mb-6"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.6 }}
                >
                  <step.icon className="h-8 w-8 text-white" />
                </motion.div>
                <h3 className="text-xl font-bold text-white mb-4">{step.title}</h3>
                <p className="text-gray-300">{step.description}</p>
              </motion.div>
            ))}
          </div>
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
              Ready to Find Your Coding Partner?
            </h2>
            <p className="text-xl text-gray-300 mb-8 max-w-2xl mx-auto">
              Join the community of developers who are tired of coding alone. 
              Connect with like-minded developers and build something amazing together.
            </p>
            <motion.button
              onClick={handleDownloadApp}
              className="group inline-flex items-center px-8 py-4 bg-gradient-to-r from-[#2EA043] to-[#3FB950] text-white font-semibold rounded-2xl text-lg shadow-2xl hover:shadow-[#2EA043]/25 transition-all duration-300 hover:scale-105"
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
            >
              <Zap className="h-5 w-5 mr-2" />
              Download GitAlong
              <ArrowRight className="h-5 w-5 ml-2 group-hover:translate-x-1 transition-transform duration-300" />
            </motion.button>
          </motion.div>
        </div>
      </section>
    </div>
  );
};