import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Github, Star, GitBranch, Eye, Calendar, User, MessageSquare, ExternalLink, Code, History } from 'lucide-react';
import { githubService, Repository, Commit } from '../services/githubService';

interface RepositoryDetailsProps {
  repository: Repository;
  onClose: () => void;
}

export const RepositoryDetails: React.FC<RepositoryDetailsProps> = ({ repository, onClose }) => {
  const [readme, setReadme] = useState<string>('');
  const [commits, setCommits] = useState<Commit[]>([]);
  const [isLoadingReadme, setIsLoadingReadme] = useState(true);
  const [isLoadingCommits, setIsLoadingCommits] = useState(true);
  const [activeTab, setActiveTab] = useState<'readme' | 'commits'>('readme');

  useEffect(() => {
    loadRepositoryData();
  }, [repository]);

  const loadRepositoryData = async () => {
    const [owner, repo] = repository.full_name.split('/');
    
    // Load README
    setIsLoadingReadme(true);
    try {
      const readmeContent = await githubService.getRepositoryReadme(owner, repo);
      setReadme(readmeContent);
    } catch (error) {
      console.error('Error loading README:', error);
      setReadme('README not available');
    } finally {
      setIsLoadingReadme(false);
    }

    // Load commits
    setIsLoadingCommits(true);
    try {
      const commitsData = await githubService.getRepositoryCommits(owner, repo);
      setCommits(commitsData);
    } catch (error) {
      console.error('Error loading commits:', error);
      setCommits([]);
    } finally {
      setIsLoadingCommits(false);
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const formatCommitMessage = (message: string) => {
    const lines = message.split('\n');
    return lines[0]; // Return first line only
  };

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
      onClick={onClose}
    >
      <motion.div
        initial={{ scale: 0.9, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        exit={{ scale: 0.9, opacity: 0 }}
        className="bg-[#161B22] rounded-2xl max-w-4xl w-full max-h-[90vh] overflow-hidden"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="p-6 border-b border-[#30363D]">
          <div className="flex items-start justify-between">
            <div className="flex-1">
              <div className="flex items-center space-x-3 mb-2">
                <Github className="w-6 h-6 text-[#2EA043]" />
                <h2 className="text-2xl font-bold text-white">{repository.name}</h2>
                <span className="px-2 py-1 bg-[#30363D] text-gray-300 text-xs rounded-full">
                  {repository.visibility}
                </span>
              </div>
              <p className="text-gray-300 mb-4">{repository.description}</p>
              
              <div className="flex items-center space-x-6 text-sm text-gray-400">
                <div className="flex items-center">
                  <Star className="w-4 h-4 mr-1" />
                  {repository.stargazers_count} stars
                </div>
                <div className="flex items-center">
                  <GitBranch className="w-4 h-4 mr-1" />
                  {repository.forks_count} forks
                </div>
                <div className="flex items-center">
                  <Eye className="w-4 h-4 mr-1" />
                  {repository.language || 'Unknown'}
                </div>
                <div className="flex items-center">
                  <Calendar className="w-4 h-4 mr-1" />
                  Updated {formatDate(repository.updated_at)}
                </div>
              </div>
            </div>
            
            <div className="flex space-x-2">
              <a
                href={repository.html_url}
                target="_blank"
                rel="noopener noreferrer"
                className="btn-secondary text-sm"
              >
                <ExternalLink className="w-4 h-4 mr-2" />
                View on GitHub
              </a>
              <button
                onClick={onClose}
                className="p-2 text-gray-400 hover:text-white transition-colors"
              >
                ✕
              </button>
            </div>
          </div>
        </div>

        {/* Tabs */}
        <div className="flex border-b border-[#30363D]">
          <button
            onClick={() => setActiveTab('readme')}
            className={`flex items-center px-6 py-3 text-sm font-medium transition-colors ${
              activeTab === 'readme'
                ? 'text-[#2EA043] border-b-2 border-[#2EA043]'
                : 'text-gray-400 hover:text-white'
            }`}
          >
            <Code className="w-4 h-4 mr-2" />
            README
          </button>
          <button
            onClick={() => setActiveTab('commits')}
            className={`flex items-center px-6 py-3 text-sm font-medium transition-colors ${
              activeTab === 'commits'
                ? 'text-[#2EA043] border-b-2 border-[#2EA043]'
                : 'text-gray-400 hover:text-white'
            }`}
          >
            <History className="w-4 h-4 mr-2" />
            Commits
          </button>
        </div>

        {/* Content */}
        <div className="p-6 overflow-y-auto max-h-[60vh]">
          <AnimatePresence mode="wait">
            {activeTab === 'readme' ? (
              <motion.div
                key="readme"
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                transition={{ duration: 0.2 }}
              >
                {isLoadingReadme ? (
                  <div className="text-center py-12">
                    <div className="inline-flex items-center space-x-2">
                      <div className="w-4 h-4 bg-[#2EA043] rounded-full animate-bounce"></div>
                      <div className="w-4 h-4 bg-[#2EA043] rounded-full animate-bounce" style={{ animationDelay: '0.1s' }}></div>
                      <div className="w-4 h-4 bg-[#2EA043] rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
                    </div>
                    <p className="text-gray-400 mt-4">Loading README...</p>
                  </div>
                ) : (
                  <div className="prose prose-invert max-w-none">
                    <div 
                      className="text-gray-300 leading-relaxed"
                      dangerouslySetInnerHTML={{ __html: readme }}
                    />
                  </div>
                )}
              </motion.div>
            ) : (
              <motion.div
                key="commits"
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                transition={{ duration: 0.2 }}
              >
                {isLoadingCommits ? (
                  <div className="text-center py-12">
                    <div className="inline-flex items-center space-x-2">
                      <div className="w-4 h-4 bg-[#2EA043] rounded-full animate-bounce"></div>
                      <div className="w-4 h-4 bg-[#2EA043] rounded-full animate-bounce" style={{ animationDelay: '0.1s' }}></div>
                      <div className="w-4 h-4 bg-[#2EA043] rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
                    </div>
                    <p className="text-gray-400 mt-4">Loading commits...</p>
                  </div>
                ) : (
                  <div className="space-y-4">
                    {commits.map((commit, index) => (
                      <motion.div
                        key={commit.sha}
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: index * 0.1 }}
                        className="flex items-start space-x-4 p-4 bg-[#21262D] rounded-xl border border-[#30363D] hover:border-[#2EA043] transition-colors"
                      >
                        <img
                          src={commit.author.avatar_url}
                          alt={commit.author.login}
                          className="w-8 h-8 rounded-full"
                        />
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center space-x-2 mb-1">
                            <span className="text-sm font-medium text-white">
                              {commit.author.login}
                            </span>
                            <span className="text-xs text-gray-400">
                              {formatDate(commit.commit.author.date)}
                            </span>
                          </div>
                          <p className="text-gray-300 text-sm">
                            {formatCommitMessage(commit.commit.message)}
                          </p>
                          <div className="flex items-center space-x-4 mt-2 text-xs text-gray-400">
                            <span className="font-mono">{commit.sha.substring(0, 7)}</span>
                            <span>{commit.commit.author.name}</span>
                          </div>
                        </div>
                      </motion.div>
                    ))}
                  </div>
                )}
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </motion.div>
    </motion.div>
  );
}; 