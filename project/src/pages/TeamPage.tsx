import React from 'react';
import { motion } from 'framer-motion';
import { Github, Linkedin, Twitter, Mail } from 'lucide-react';

export const TeamPage: React.FC = () => {
  const team = [
    {
      name: "Alex Chen",
      role: "Co-founder & CEO",
      bio: "Former GitHub engineer with 10+ years in open source. Passionate about connecting developers worldwide.",
      github: "alexchen",
      avatar: "https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=300&h=300&dpr=1"
    },
    {
      name: "Sarah Kim",
      role: "Co-founder & CTO",
      bio: "AI/ML expert from Google. Building the future of developer matching with cutting-edge algorithms.",
      github: "sarahkim",
      avatar: "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=300&h=300&dpr=1"
    },
    {
      name: "Marcus Johnson",
      role: "Head of Engineering",
      bio: "Full-stack developer with extensive experience in mobile and web applications. Flutter enthusiast.",
      github: "marcusj",
      avatar: "https://images.pexels.com/photos/2182970/pexels-photo-2182970.jpeg?auto=compress&cs=tinysrgb&w=300&h=300&dpr=1"
    },
    {
      name: "Emma Rodriguez",
      role: "Head of Design",
      bio: "UX/UI designer focused on creating intuitive developer experiences. Former Figma design lead.",
      github: "emmarodriguez",
      avatar: "https://images.pexels.com/photos/3783471/pexels-photo-3783471.jpeg?auto=compress&cs=tinysrgb&w=300&h=300&dpr=1"
    },
    {
      name: "David Park",
      role: "DevRel Manager",
      bio: "Community builder and developer advocate. Connecting open source maintainers with contributors.",
      github: "davidpark",
      avatar: "https://images.pexels.com/photos/2613260/pexels-photo-2613260.jpeg?auto=compress&cs=tinysrgb&w=300&h=300&dpr=1"
    },
    {
      name: "Lisa Thompson",
      role: "Data Scientist",
      bio: "PhD in Machine Learning. Optimizing my matching algorithms for better developer connections.",
      github: "lisathompson",
      avatar: "https://images.pexels.com/photos/3756679/pexels-photo-3756679.jpeg?auto=compress&cs=tinysrgb&w=300&h=300&dpr=1"
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
            Meet the Team
          </h1>
          <p className="text-xl text-gray-300 max-w-3xl mx-auto">
            I'm a passionate team of developers, designers, and open source enthusiasts 
            building the future of collaborative software development.
          </p>
        </motion.div>

        {/* Team Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mb-20">
          {team.map((member, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: index * 0.1 }}
              className="bg-[#161B22] rounded-lg border border-[#30363D] p-6 hover:border-[#2EA043] transition-all hover:shadow-xl"
            >
              <div className="text-center mb-4">
                <img
                  src={member.avatar}
                  alt={member.name}
                  className="w-24 h-24 rounded-full mx-auto mb-4 object-cover"
                />
                <h3 className="text-xl font-bold text-white mb-1">{member.name}</h3>
                <p className="text-[#2EA043] font-semibold mb-2">{member.role}</p>
                <p className="text-gray-300 text-sm leading-relaxed">{member.bio}</p>
              </div>
              
              <div className="flex justify-center space-x-4">
                <a
                  href={`https://github.com/${member.github}`}
                  className="text-gray-400 hover:text-[#2EA043] transition-colors"
                >
                  <Github className="h-5 w-5" />
                </a>
                <a
                  href="#"
                  className="text-gray-400 hover:text-[#2EA043] transition-colors"
                >
                  <Linkedin className="h-5 w-5" />
                </a>
                <a
                  href="#"
                  className="text-gray-400 hover:text-[#2EA043] transition-colors"
                >
                  <Twitter className="h-5 w-5" />
                </a>
                <a
                  href="#"
                  className="text-gray-400 hover:text-[#2EA043] transition-colors"
                >
                  <Mail className="h-5 w-5" />
                </a>
              </div>
            </motion.div>
          ))}
        </div>

        {/* Company Values */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.6 }}
          className="bg-[#161B22] rounded-lg border border-[#30363D] p-8 mb-20"
        >
          <h2 className="text-3xl font-bold text-white mb-8 text-center">Our Values</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="text-center">
              <div className="w-16 h-16 bg-[#2EA043] rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-white font-bold text-xl">🤝</span>
              </div>
              <h3 className="text-xl font-bold text-white mb-2">Collaboration</h3>
              <p className="text-gray-300">
                I believe in the power of working together to create something greater than the sum of its parts.
              </p>
            </div>
            <div className="text-center">
              <div className="w-16 h-16 bg-[#2EA043] rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-white font-bold text-xl">🚀</span>
              </div>
              <h3 className="text-xl font-bold text-white mb-2">Innovation</h3>
              <p className="text-gray-300">
                I'm constantly pushing the boundaries of what's possible in developer tooling and collaboration.
              </p>
            </div>
            <div className="text-center">
              <div className="w-16 h-16 bg-[#2EA043] rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-white font-bold text-xl">🌍</span>
              </div>
              <h3 className="text-xl font-bold text-white mb-2">Open Source</h3>
              <p className="text-gray-300">
                I'm committed to supporting and growing the open source community that made my career possible.
              </p>
            </div>
          </div>
        </motion.div>

        {/* Join Us Section */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.8 }}
          className="text-center bg-gradient-to-r from-[#21262D] to-[#161B22] rounded-lg p-12"
        >
          <h2 className="text-3xl font-bold text-white mb-4">Join Our Team</h2>
          <p className="text-xl text-gray-300 mb-8 max-w-2xl mx-auto">
            I'm always looking for talented individuals who share my passion for open source 
            and developer collaboration. Let's build the future together.
          </p>
          <a
            href="/contact"
            className="inline-flex items-center px-8 py-4 bg-[#2EA043] text-white rounded-lg font-semibold hover:bg-[#2EA043]/90 transition-colors"
          >
            View Open Positions
          </a>
        </motion.div>
      </div>
      <div className="text-center mt-20">
        <p className="text-gray-300">Built entirely by Sreevallabh Kakarala.</p>
      </div>
    </div>
  );
};