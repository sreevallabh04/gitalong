import React from 'react';
import { motion } from 'framer-motion';
import { Star, Quote } from 'lucide-react';

export const TestimonialsSection: React.FC = () => {
  const testimonials = [
    {
      name: "Sarah Chen",
      role: "Full Stack Developer",
      company: "TechCorp",
      avatar: "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face",
      content: "GitAlong completely changed how I find collaborators. I met my current co-founder through the app, and we've built 3 successful projects together. The matching algorithm is incredibly accurate!",
      rating: 5
    },
    {
      name: "Marcus Rodriguez",
      role: "Open Source Maintainer",
      company: "React Community",
      avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
      content: "As a maintainer, finding quality contributors was always a challenge. GitAlong helped me discover amazing developers who are passionate about my projects. Game changer!",
      rating: 5
    },
    {
      name: "Emily Watson",
      role: "Frontend Developer",
      company: "StartupXYZ",
      avatar: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face",
      content: "The Tinder-style interface is so intuitive! I love how I can quickly see someone's GitHub activity and decide if we'd work well together. Found my dream team through GitAlong.",
      rating: 5
    },
    {
      name: "Alex Thompson",
      role: "Backend Engineer",
      company: "ScaleUp Inc",
      avatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face",
      content: "Finally, a platform that understands developers! The GitHub integration is seamless, and the real-time notifications keep me connected with potential collaborators.",
      rating: 5
    },
    {
      name: "Priya Patel",
      role: "DevOps Engineer",
      company: "CloudTech",
      avatar: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&h=150&fit=crop&crop=face",
      content: "I was skeptical at first, but GitAlong's verified profiles and smart matching helped me find developers who share my passion for clean code and best practices.",
      rating: 5
    },
    {
      name: "David Kim",
      role: "Mobile Developer",
      company: "AppStudio",
      avatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face",
      content: "The community features are incredible. I've joined several developer groups and learned so much from other members. GitAlong is more than just matching - it's a community.",
      rating: 5
    }
  ];

  return (
    <section className="py-20 bg-[#0D1117] relative overflow-hidden">
      {/* Background Effects */}
      <div className="absolute inset-0 bg-gradient-to-br from-[#0D1117] via-[#161B22] to-[#0D1117]"></div>
      
      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          viewport={{ once: true }}
          className="text-center mb-16"
        >
          <h2 className="text-4xl md:text-5xl font-bold mb-6 bg-gradient-to-r from-white to-[#2EA043] bg-clip-text text-transparent">
            What Developers Say
          </h2>
          <p className="text-xl text-gray-300 max-w-3xl mx-auto">
            Join thousands of satisfied developers who've found their perfect collaboration partners through GitAlong
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

        {/* Stats Section */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.6 }}
          viewport={{ once: true }}
          className="mt-16 grid grid-cols-1 md:grid-cols-4 gap-8 text-center"
        >
          <div className="p-6 rounded-2xl bg-[#161B22] border border-[#30363D]">
            <div className="text-3xl font-bold text-[#2EA043] mb-2">10,000+</div>
            <div className="text-gray-400">Active Developers</div>
          </div>
          <div className="p-6 rounded-2xl bg-[#161B22] border border-[#30363D]">
            <div className="text-3xl font-bold text-[#2EA043] mb-2">5,000+</div>
            <div className="text-gray-400">Successful Matches</div>
          </div>
          <div className="p-6 rounded-2xl bg-[#161B22] border border-[#30363D]">
            <div className="text-3xl font-bold text-[#2EA043] mb-2">4.9/5</div>
            <div className="text-gray-400">App Store Rating</div>
          </div>
          <div className="p-6 rounded-2xl bg-[#161B22] border border-[#30363D]">
            <div className="text-3xl font-bold text-[#2EA043] mb-2">500+</div>
            <div className="text-gray-400">Projects Created</div>
          </div>
        </motion.div>
      </div>
    </section>
  );
}; 