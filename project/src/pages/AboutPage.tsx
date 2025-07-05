import React from 'react';
import { motion } from 'framer-motion';
import { Users, Heart, GitBranch, Zap, ArrowRight } from 'lucide-react';

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
              We're on a mission to revolutionize how developers find collaboration partners and build amazing projects together.
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
                Our Story
              </h2>
              <p className="text-gray-300 text-lg leading-relaxed mb-6">
                GitAlong was born from a simple observation: finding the right collaboration partner 
                in the open-source world was incredibly difficult. Traditional methods like posting 
                on forums or cold messaging on GitHub were inefficient and often led to mismatched partnerships.
              </p>
              <p className="text-gray-300 text-lg leading-relaxed mb-6">
                We realized that developers needed a more intuitive way to discover and connect with 
                like-minded collaborators. Inspired by successful dating apps, we created a platform 
                that makes finding your perfect coding partner as easy as swiping right.
              </p>
              <p className="text-gray-300 text-lg leading-relaxed">
                Today, GitAlong has helped thousands of developers find their ideal collaboration 
                partners, leading to hundreds of successful open-source projects and meaningful 
                professional relationships.
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
                  <h3 className="text-2xl font-bold text-white mb-4">Our Mission</h3>
                  <p className="text-gray-300 leading-relaxed">
                    To democratize collaboration in the developer community by making it easier 
                    than ever to find the perfect partner for your next big project.
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
              Our Values
            </h2>
            <p className="text-xl text-gray-300 max-w-3xl mx-auto">
              These core principles guide everything we do at GitAlong
            </p>
          </motion.div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {[
              {
                icon: Users,
                title: "Community First",
                description: "We believe in the power of community and fostering meaningful connections between developers."
              },
              {
                icon: Heart,
                title: "Authentic Connections",
                description: "We prioritize genuine, verified profiles to ensure quality matches and meaningful collaborations."
              },
              {
                icon: GitBranch,
                title: "Open Source Spirit",
                description: "We're committed to the open-source ethos of collaboration, transparency, and shared knowledge."
              }
            ].map((value, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.8, delay: index * 0.1 }}
                viewport={{ once: true }}
                className="text-center p-8 rounded-2xl bg-[#161B22] border border-[#30363D] hover:border-[#2EA043] transition-all duration-300"
              >
                <div className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-gradient-to-r from-[#2EA043] to-[#3FB950] mb-6">
                  <value.icon className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-xl font-bold text-white mb-4">{value.title}</h3>
                <p className="text-gray-300">{value.description}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-[#161B22]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            viewport={{ once: true }}
          >
            <h2 className="text-4xl font-bold text-white mb-6">
              Join Our Community
            </h2>
            <p className="text-xl text-gray-300 mb-8 max-w-2xl mx-auto">
              Ready to find your perfect collaboration partner? Download GitAlong today and 
              start building amazing projects with developers who share your passion.
            </p>
            <button
              onClick={handleDownloadApp}
              className="group inline-flex items-center px-8 py-4 bg-gradient-to-r from-[#2EA043] to-[#3FB950] text-white font-semibold rounded-2xl text-lg shadow-2xl hover:shadow-[#2EA043]/25 transition-all duration-300 hover:scale-105"
            >
              <Zap className="h-5 w-5 mr-2" />
              Download GitAlong
              <ArrowRight className="h-5 w-5 ml-2 group-hover:translate-x-1 transition-transform duration-300" />
            </button>
          </motion.div>
        </div>
      </section>
    </div>
  );
};