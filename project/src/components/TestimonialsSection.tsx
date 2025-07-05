import React from 'react';
import { motion } from 'framer-motion';
import { Star, Quote, Heart, Code, GitBranch } from 'lucide-react';

export const TestimonialsSection: React.FC = () => {
  const testimonials = [
    {
      name: "Alex Chen",
      role: "Full Stack Developer",
      company: "Recent CS Graduate",
      avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
      content: "As a recent grad, I was struggling to find collaborators for my side projects. GitAlong helped me connect with experienced developers who mentored me and helped me build my portfolio.",
      rating: 5
    },
    {
      name: "Sarah Rodriguez",
      role: "Open Source Contributor",
      company: "Self-taught Developer",
      avatar: "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face",
      content: "I was intimidated by contributing to open source. GitAlong introduced me to maintainers who were patient and helped me understand the codebase. Now I'm a regular contributor!",
      rating: 5
    },
    {
      name: "Marcus Kim",
      role: "Bootcamp Graduate",
      company: "Career Changer",
      avatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face",
      content: "After my bootcamp, I needed real-world experience. GitAlong connected me with developers who gave me opportunities to work on real projects and build my confidence.",
      rating: 5
    },
    {
      name: "Priya Patel",
      role: "Student Developer",
      company: "Computer Science Major",
      avatar: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&h=150&fit=crop&crop=face",
      content: "Finding study partners for coding projects was impossible. GitAlong helped me find other students who were working on similar projects. We ended up building an amazing app together!",
      rating: 5
    },
    {
      name: "David Thompson",
      role: "Freelance Developer",
      company: "Remote Worker",
      avatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face",
      content: "Working remotely can be lonely. GitAlong helped me find a coding buddy who became my accountability partner. We now meet weekly to code together and share knowledge.",
      rating: 5
    },
    {
      name: "Emily Watson",
      role: "Junior Developer",
      company: "First Job in Tech",
      avatar: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face",
      content: "Starting my first dev job was overwhelming. GitAlong connected me with experienced developers who helped me navigate the industry and improve my skills. It's like having mentors on demand!",
      rating: 5
    }
  ];

  return (
    <section className="py-20 bg-[#0D1117] relative overflow-hidden">
      {/* Background Effects */}
      <div className="absolute inset-0 bg-gradient-to-br from-[#0D1117] via-[#161B22] to-[#0D1117]"></div>
      
      {/* Animated Background Elements */}
      <motion.div
        className="absolute top-20 left-20 w-24 h-24 bg-[#2EA043]/10 rounded-full"
        animate={{
          scale: [1, 1.5, 1],
          opacity: [0.1, 0.2, 0.1],
        }}
        transition={{
          duration: 5,
          repeat: Infinity,
          ease: "easeInOut"
        }}
      />
      <motion.div
        className="absolute bottom-20 right-20 w-32 h-32 bg-[#3FB950]/10 rounded-full"
        animate={{
          scale: [1, 1.3, 1],
          opacity: [0.1, 0.15, 0.1],
        }}
        transition={{
          duration: 7,
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
            Real Stories from Real Developers
          </h2>
          <p className="text-xl text-gray-300 max-w-3xl mx-auto">
            See how GitAlong is helping developers connect, learn, and build together
          </p>
        </motion.div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {testimonials.map((testimonial, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: index * 0.1 }}
              viewport={{ once: true }}
              className="group relative p-8 rounded-2xl bg-[#161B22] border border-[#30363D] hover:border-[#2EA043] transition-all duration-300 hover:scale-105"
              whileHover={{ y: -5 }}
            >
              {/* Quote Icon */}
              <div className="absolute top-6 right-6 text-[#2EA043] opacity-20 group-hover:opacity-40 transition-opacity duration-300">
                <Quote className="h-8 w-8" />
              </div>

              {/* Rating */}
              <div className="flex items-center mb-4">
                {[...Array(testimonial.rating)].map((_, i) => (
                  <Star key={i} className="h-4 w-4 text-yellow-400 fill-current" />
                ))}
              </div>

              {/* Content */}
              <p className="text-gray-300 leading-relaxed mb-6 italic">
                "{testimonial.content}"
              </p>

              {/* Author */}
              <div className="flex items-center">
                <img
                  src={testimonial.avatar}
                  alt={testimonial.name}
                  className="w-12 h-12 rounded-full mr-4 border-2 border-[#30363D]"
                />
                <div>
                  <h4 className="text-white font-semibold">{testimonial.name}</h4>
                  <p className="text-gray-400 text-sm">{testimonial.role} at {testimonial.company}</p>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}; 