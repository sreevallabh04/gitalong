import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

export const FloatingOctocat: React.FC = () => {
  const [showEasterEgg, setShowEasterEgg] = useState(false);

  const handleClick = () => {
    setShowEasterEgg(true);
    setTimeout(() => setShowEasterEgg(false), 3000);
  };

  return (
    <>
      <motion.div
        className="fixed bottom-6 right-6 z-50"
        initial={{ scale: 0, rotate: -180 }}
        animate={{ scale: 1, rotate: 0 }}
        transition={{ delay: 1, duration: 0.5, type: "spring", stiffness: 200 }}
      >
        <motion.div
          animate={{
            y: [0, -10, 0],
            rotate: [0, 5, -5, 0],
          }}
          transition={{
            duration: 3,
            repeat: Infinity,
            repeatType: "loop",
          }}
          className="w-16 h-16 bg-[#2EA043] rounded-full flex items-center justify-center shadow-lg hover:shadow-xl transition-all cursor-pointer"
          onClick={handleClick}
        >
          <svg
            className="w-8 h-8 text-white"
            fill="currentColor"
            viewBox="0 0 24 24"
          >
            <path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0024 12c0-6.63-5.37-12-12-12z"/>
          </svg>
        </motion.div>
      </motion.div>

      {/* Easter Egg Popup */}
      <AnimatePresence>
        {showEasterEgg && (
          <motion.div
            initial={{ opacity: 0, scale: 0.8, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.8, y: 20 }}
            className="fixed bottom-24 right-6 z-50 bg-[#161B22] border border-[#30363D] rounded-lg p-4 shadow-xl max-w-xs"
          >
            <div className="flex items-center">
              <div className="w-8 h-8 bg-[#2EA043] rounded-full flex items-center justify-center mr-3">
                <span className="text-white text-sm">💡</span>
              </div>
              <p className="text-white text-sm font-medium">
                You're 1 commit away from a perfect match.
              </p>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
};