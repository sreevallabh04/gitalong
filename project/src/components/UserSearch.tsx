import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Search, User, MapPin, Calendar, Building, Globe, Twitter, Github, Star, GitBranch, Eye } from 'lucide-react';
import { githubService, GitHubUser } from '../services/githubService';

export const UserSearch: React.FC = () => {
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState<GitHubUser[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [selectedUser, setSelectedUser] = useState<GitHubUser | null>(null);
  const [showUserModal, setShowUserModal] = useState(false);

  // Debounced search
  useEffect(() => {
    const timeoutId = setTimeout(() => {
      if (searchQuery.trim()) {
        performSearch(searchQuery);
      } else {
        setSearchResults([]);
      }
    }, 300);

    return () => clearTimeout(timeoutId);
  }, [searchQuery]);

  const performSearch = async (query: string) => {
    setIsLoading(true);
    try {
      const result = await githubService.searchUsers(query);
      setSearchResults(result.items);
    } catch (error) {
      console.error('Search error:', error);
      setSearchResults([]);
    } finally {
      setIsLoading(false);
    }
  };

  const handleUserClick = (user: GitHubUser) => {
    setSelectedUser(user);
    setShowUserModal(true);
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  };

  return (
    <div className="min-h-screen bg-[#0D1117] py-12">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center mb-12"
        >
          <h1 className="text-4xl md:text-6xl font-bold gradient-text mb-6">
            Find Developers
          </h1>
          <p className="text-xl text-gray-300 max-w-3xl mx-auto">
            Search for developers by username, skills, or location. Connect with contributors and maintainers.
          </p>
        </motion.div>

        {/* Search Input */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="max-w-2xl mx-auto mb-12"
        >
          <div className="relative">
            <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search developers by username, skills, or location..."
              className="input-modern w-full pl-12 pr-4 py-4 text-lg"
            />
          </div>
        </motion.div>

        {/* Search Results */}
        <AnimatePresence>
          {isLoading ? (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="text-center py-12"
            >
              <div className="inline-flex items-center space-x-2">
                <div className="w-4 h-4 bg-[#2EA043] rounded-full animate-bounce"></div>
                <div className="w-4 h-4 bg-[#2EA043] rounded-full animate-bounce" style={{ animationDelay: '0.1s' }}></div>
                <div className="w-4 h-4 bg-[#2EA043] rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
              </div>
              <p className="text-gray-400 mt-4">Searching for developers...</p>
            </motion.div>
          ) : searchResults.length > 0 ? (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
            >
              {searchResults.map((user, index) => (
                <motion.div
                  key={user.id}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.1 }}
                  whileHover={{ y: -5, scale: 1.02 }}
                  className="card-modern cursor-pointer group"
                  onClick={() => handleUserClick(user)}
                >
                  <div className="flex items-start space-x-4">
                    <img
                      src={user.avatar_url}
                      alt={user.name || user.login}
                      className="w-16 h-16 rounded-full border-2 border-[#30363D] group-hover:border-[#2EA043] transition-colors"
                    />
                    <div className="flex-1 min-w-0">
                      <h3 className="text-lg font-bold text-white group-hover:text-[#2EA043] transition-colors">
                        {user.name || user.login}
                      </h3>
                      <p className="text-sm text-gray-400 mb-2">@{user.login}</p>
                      {user.bio && (
                        <p className="text-gray-300 text-sm mb-3 line-clamp-2">
                          {user.bio}
                        </p>
                      )}
                      
                      <div className="flex items-center space-x-4 text-xs text-gray-400">
                        {user.location && (
                          <div className="flex items-center">
                            <MapPin className="w-3 h-3 mr-1" />
                            {user.location}
                          </div>
                        )}
                        <div className="flex items-center">
                          <User className="w-3 h-3 mr-1" />
                          {user.public_repos} repos
                        </div>
                        <div className="flex items-center">
                          <Star className="w-3 h-3 mr-1" />
                          {user.followers} followers
                        </div>
                      </div>
                    </div>
                  </div>
                </motion.div>
              ))}
            </motion.div>
          ) : searchQuery && !isLoading ? (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className="text-center py-12"
            >
              <User className="w-16 h-16 text-gray-400 mx-auto mb-4" />
              <p className="text-gray-400">No developers found for "{searchQuery}"</p>
            </motion.div>
          ) : null}
        </AnimatePresence>

        {/* User Modal */}
        {showUserModal && selectedUser && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
            onClick={() => setShowUserModal(false)}
          >
            <motion.div
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.9, opacity: 0 }}
              className="bg-[#161B22] rounded-2xl p-8 max-w-2xl w-full max-h-[90vh] overflow-y-auto"
              onClick={(e) => e.stopPropagation()}
            >
              <div className="flex items-start space-x-6">
                <img
                  src={selectedUser.avatar_url}
                  alt={selectedUser.name || selectedUser.login}
                  className="w-24 h-24 rounded-full border-4 border-[#30363D]"
                />
                <div className="flex-1">
                  <h2 className="text-2xl font-bold text-white mb-2">
                    {selectedUser.name || selectedUser.login}
                  </h2>
                  <p className="text-gray-400 mb-4">@{selectedUser.login}</p>
                  
                  {selectedUser.bio && (
                    <p className="text-gray-300 mb-6">{selectedUser.bio}</p>
                  )}

                  <div className="grid grid-cols-2 gap-4 mb-6">
                    <div className="flex items-center text-gray-400">
                      <MapPin className="w-4 h-4 mr-2" />
                      {selectedUser.location || 'Location not specified'}
                    </div>
                    <div className="flex items-center text-gray-400">
                      <Building className="w-4 h-4 mr-2" />
                      {selectedUser.company || 'Company not specified'}
                    </div>
                    <div className="flex items-center text-gray-400">
                      <Calendar className="w-4 h-4 mr-2" />
                      Joined {formatDate(selectedUser.created_at)}
                    </div>
                    <div className="flex items-center text-gray-400">
                      <GitBranch className="w-4 h-4 mr-2" />
                      {selectedUser.public_repos} repositories
                    </div>
                  </div>

                  <div className="flex items-center space-x-4 mb-6">
                    <div className="text-center">
                      <div className="text-2xl font-bold text-[#2EA043]">{selectedUser.public_repos}</div>
                      <div className="text-xs text-gray-400">Repositories</div>
                    </div>
                    <div className="text-center">
                      <div className="text-2xl font-bold text-[#2EA043]">{selectedUser.followers}</div>
                      <div className="text-xs text-gray-400">Followers</div>
                    </div>
                    <div className="text-center">
                      <div className="text-2xl font-bold text-[#2EA043]">{selectedUser.following}</div>
                      <div className="text-xs text-gray-400">Following</div>
                    </div>
                  </div>

                  <div className="flex space-x-3">
                    {selectedUser.blog && (
                      <a
                        href={selectedUser.blog}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="btn-secondary text-sm"
                      >
                        <Globe className="w-4 h-4 mr-2" />
                        Website
                      </a>
                    )}
                    {selectedUser.twitter_username && (
                      <a
                        href={`https://twitter.com/${selectedUser.twitter_username}`}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="btn-secondary text-sm"
                      >
                        <Twitter className="w-4 h-4 mr-2" />
                        Twitter
                      </a>
                    )}
                    <a
                      href={`https://github.com/${selectedUser.login}`}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="btn-primary text-sm"
                    >
                      <Github className="w-4 h-4 mr-2" />
                      View Profile
                    </a>
                  </div>
                </div>
              </div>
            </motion.div>
          </motion.div>
        )}
      </div>
    </div>
  );
}; 