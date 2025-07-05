import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { ArrowRight, ArrowLeft, Github, Smartphone, MessageCircle, Heart } from 'lucide-react';

export const ContributorOnboarding: React.FC = () => {
  const [currentStep, setCurrentStep] = useState(0);

  const steps = [
    {
      title: "Welcome to Gitalong",
      description: "Join thousands of developers building the future of open source",
      icon: Heart,
      content: (
        <div className="text-center space-y-6">
          <div className="w-24 h-24 bg-[#2EA043] rounded-full flex items-center justify-center mx-auto">
            <Heart className="h-12 w-12 text-white" />
          </div>
          <div>
            <h3 className="text-2xl font-bold text-white mb-4">Ready to contribute?</h3>
            <p className="text-gray-300">
              Discover meaningful projects that match your skills and interests. 
              Let's get you started on your open source journey.
            </p>
          </div>
        </div>
      )
    },
    {
      title: "Connect Your GitHub",
      description: "We'll analyze your profile to find perfect project matches",
      icon: Github,
      content: (
        <div className="text-center space-y-6">
          <div className="w-24 h-24 bg-[#2EA043] rounded-full flex items-center justify-center mx-auto">
            <Github className="h-12 w-12 text-white" />
          </div>
          <div>
            <h3 className="text-2xl font-bold text-white mb-4">Connect GitHub Account</h3>
            <p className="text-gray-300 mb-6">
              Our AI will analyze your repositories, languages, and contribution patterns 
              to find projects that match your expertise.
            </p>
            <button className="bg-[#2EA043] text-white px-6 py-3 rounded-lg hover:bg-[#2EA043]/90 transition-colors">
              Connect GitHub
            </button>
          </div>
        </div>
      )
    },
    {
      title: "Swipe & Match",
      description: "Discover projects by swiping through curated matches",
      icon: Smartphone,
      content: (
        <div className="text-center space-y-6">
          <div className="w-24 h-24 bg-[#2EA043] rounded-full flex items-center justify-center mx-auto">
            <Smartphone className="h-12 w-12 text-white" />
          </div>
          <div>
            <h3 className="text-2xl font-bold text-white mb-4">Swipe to Discover</h3>
            <p className="text-gray-300 mb-6">
              Swipe right on projects you're interested in. Our AI learns from your 
              preferences to show better matches over time.
            </p>
            <div className="bg-[#21262D] rounded-lg p-4 max-w-sm mx-auto">
              <div className="flex items-center mb-3">
                <div className="w-8 h-8 bg-[#2EA043] rounded-full flex items-center justify-center mr-3">
                  <Github className="h-4 w-4 text-white" />
                </div>
                <div>
                  <h4 className="text-white font-semibold">React Native</h4>
                  <p className="text-gray-400 text-sm">Mobile Framework</p>
                </div>
              </div>
              <div className="flex gap-2">
                <button className="flex-1 py-2 bg-red-600 text-white rounded text-sm">
                  Pass
                </button>
                <button className="flex-1 py-2 bg-[#2EA043] text-white rounded text-sm">
                  Match
                </button>
              </div>
            </div>
          </div>
        </div>
      )
    },
    {
      title: "Connect & Collaborate",
      description: "Message maintainers and start contributing",
      icon: MessageCircle,
      content: (
        <div className="text-center space-y-6">
          <div className="w-24 h-24 bg-[#2EA043] rounded-full flex items-center justify-center mx-auto">
            <MessageCircle className="h-12 w-12 text-white" />
          </div>
          <div>
            <h3 className="text-2xl font-bold text-white mb-4">Start Collaborating</h3>
            <p className="text-gray-300 mb-6">
              When you match with a project, you can chat directly with maintainers 
              to discuss how you can contribute.
            </p>
            <div className="bg-[#21262D] rounded-lg p-4 max-w-sm mx-auto text-left">
              <div className="space-y-2">
                <div className="bg-[#2EA043] text-white p-2 rounded-lg rounded-tl-none text-sm">
                  Hi! I'm interested in contributing to the authentication module.
                </div>
                <div className="bg-[#30363D] text-white p-2 rounded-lg rounded-tr-none text-sm">
                  Great! We have some good first issues. Let me share the details.
                </div>
              </div>
            </div>
          </div>
        </div>
      )
    }
  ];

  const handleNext = () => {
    if (currentStep < steps.length - 1) {
      setCurrentStep(currentStep + 1);
    }
  };

  const handlePrevious = () => {
    if (currentStep > 0) {
      setCurrentStep(currentStep - 1);
    }
  };

  return (
    <div className="min-h-screen py-20">
      <div className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Progress Bar */}
        <div className="mb-12">
          <div className="flex justify-between items-center mb-2">
            <span className="text-sm text-gray-400">
              Step {currentStep + 1} of {steps.length}
            </span>
            <span className="text-sm text-gray-400">
              {Math.round(((currentStep + 1) / steps.length) * 100)}%
            </span>
          </div>
          <div className="w-full bg-[#30363D] rounded-full h-2">
            <div
              className="bg-[#2EA043] h-2 rounded-full transition-all duration-300"
              style={{ width: `${((currentStep + 1) / steps.length) * 100}%` }}
            />
          </div>
        </div>

        {/* Content */}
        <motion.div
          key={currentStep}
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          exit={{ opacity: 0, x: -20 }}
          transition={{ duration: 0.3 }}
          className="bg-[#161B22] rounded-lg border border-[#30363D] p-8"
        >
          <div className="mb-8">
            <h1 className="text-3xl font-bold text-white mb-2">
              {steps[currentStep].title}
            </h1>
            <p className="text-gray-400">
              {steps[currentStep].description}
            </p>
          </div>

          {steps[currentStep].content}

          {/* Navigation */}
          <div className="flex justify-between items-center mt-12">
            <button
              onClick={handlePrevious}
              disabled={currentStep === 0}
              className={`flex items-center px-4 py-2 rounded-lg transition-colors ${
                currentStep === 0
                  ? 'text-gray-500 cursor-not-allowed'
                  : 'text-white hover:bg-[#30363D]'
              }`}
            >
              <ArrowLeft className="h-4 w-4 mr-2" />
              Previous
            </button>

            <div className="flex space-x-2">
              {steps.map((_, index) => (
                <button
                  key={index}
                  onClick={() => setCurrentStep(index)}
                  className={`w-3 h-3 rounded-full transition-colors ${
                    index === currentStep ? 'bg-[#2EA043]' : 'bg-[#30363D]'
                  }`}
                />
              ))}
            </div>

            <button
              onClick={handleNext}
              disabled={currentStep === steps.length - 1}
              className={`flex items-center px-4 py-2 rounded-lg transition-colors ${
                currentStep === steps.length - 1
                  ? 'bg-[#2EA043] text-white'
                  : 'bg-[#2EA043] text-white hover:bg-[#2EA043]/90'
              }`}
            >
              {currentStep === steps.length - 1 ? 'Get Started' : 'Next'}
              <ArrowRight className="h-4 w-4 ml-2" />
            </button>
          </div>
        </motion.div>

        {/* Download App CTA */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.4 }}
          className="mt-8 bg-[#161B22] rounded-lg border border-[#30363D] p-6 text-center"
        >
          <h2 className="text-xl font-bold text-white mb-2">Ready to start swiping?</h2>
          <p className="text-gray-400 mb-4">
            Download the Gitalong mobile app to begin your open source journey
          </p>
          <div className="flex justify-center space-x-4">
            <button className="bg-[#2EA043] text-white px-6 py-3 rounded-lg hover:bg-[#2EA043]/90 transition-colors">
              Download for iOS
            </button>
            <button className="bg-[#2EA043] text-white px-6 py-3 rounded-lg hover:bg-[#2EA043]/90 transition-colors">
              Download for Android
            </button>
          </div>
        </motion.div>
      </div>
    </div>
  );
};