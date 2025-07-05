import React from 'react';
import { motion } from 'framer-motion';

export const ContributionGraph: React.FC = () => {
  const generateContributions = () => {
    return Array.from({ length: 365 }, (_, i) => ({
      day: i,
      level: Math.floor(Math.random() * 5),
    }));
  };

  const contributions = generateContributions();

  const getColor = (level: number) => {
    const colors = [
      '#161B22', // No contributions
      '#0E4429', // Low
      '#006D32', // Medium-low
      '#26A641', // Medium
      '#39D353', // High
    ];
    return colors[level];
  };

  return (
    <div className="absolute inset-0 opacity-10 overflow-hidden">
      <div className="grid grid-cols-52 gap-1 p-8 transform rotate-12 scale-150">
        {contributions.map((contrib, index) => (
          <motion.div
            key={index}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: index * 0.001, duration: 0.5 }}
            className="w-3 h-3 rounded-sm"
            style={{ backgroundColor: getColor(contrib.level) }}
          />
        ))}
      </div>
    </div>
  );
};