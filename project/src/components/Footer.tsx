import React from 'react';
import { Link } from 'react-router-dom';
import { Github, Twitter, Linkedin, Mail, Download } from 'lucide-react';

export const Footer: React.FC = () => {
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
    <footer className="bg-[#0D1117] border-t border-[#30363D]">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          {/* Brand Section */}
          <div className="col-span-1 md:col-span-2">
            <Link to="/" className="flex items-center space-x-3 text-white hover:text-[#2EA043] transition-all duration-300 mb-4">
              <div className="w-12 h-12 bg-gradient-to-r from-[#2EA043] to-[#3FB950] rounded-xl flex items-center justify-center">
                <span className="text-white font-bold text-lg">G</span>
              </div>
              <span className="text-2xl font-bold">GitAlong</span>
            </Link>
            <p className="text-gray-400 mb-6 max-w-md">
              The future of collaborative coding. Find your perfect GitHub match and build amazing projects together.
            </p>
            <button
              onClick={handleDownloadApp}
              className="inline-flex items-center px-6 py-3 bg-gradient-to-r from-[#2EA043] to-[#3FB950] text-white font-semibold rounded-xl hover:scale-105 transition-all duration-300"
            >
              <Download className="h-4 w-4 mr-2" />
              Download App
            </button>
          </div>

          {/* Quick Links */}
          <div>
            <h3 className="text-white font-semibold mb-4">Quick Links</h3>
            <ul className="space-y-3">
              <li>
                <Link to="/" className="text-gray-400 hover:text-[#2EA043] transition-colors duration-300">
                  Home
                </Link>
              </li>
              <li>
                <Link to="/about" className="text-gray-400 hover:text-[#2EA043] transition-colors duration-300">
                  About
                </Link>
              </li>
              <li>
                <Link to="/contact" className="text-gray-400 hover:text-[#2EA043] transition-colors duration-300">
                  Contact
                </Link>
              </li>
              <li>
                <Link to="/privacy" className="text-gray-400 hover:text-[#2EA043] transition-colors duration-300">
                  Privacy Policy
                </Link>
              </li>
            </ul>
          </div>

          {/* Social Links */}
          <div>
            <h3 className="text-white font-semibold mb-4">Connect</h3>
            <ul className="space-y-3">
              <li>
                <a
                  href="https://github.com/gitalong"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center text-gray-400 hover:text-[#2EA043] transition-colors duration-300"
                >
                  <Github className="h-4 w-4 mr-2" />
                  GitHub
                </a>
              </li>
              <li>
                <a
                  href="https://twitter.com/gitalong"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center text-gray-400 hover:text-[#2EA043] transition-colors duration-300"
                >
                  <Twitter className="h-4 w-4 mr-2" />
                  Twitter
                </a>
              </li>
              <li>
                <a
                  href="https://linkedin.com/company/gitalong"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center text-gray-400 hover:text-[#2EA043] transition-colors duration-300"
                >
                  <Linkedin className="h-4 w-4 mr-2" />
                  LinkedIn
                </a>
              </li>
              <li>
                <a
                  href="mailto:srivallabhkakarala@gmail.com"
                  className="flex items-center text-gray-400 hover:text-[#2EA043] transition-colors duration-300"
                >
                  <Mail className="h-4 w-4 mr-2" />
                  Contact Us
                </a>
              </li>
            </ul>
          </div>
        </div>

        {/* Bottom Section */}
        <div className="border-t border-[#30363D] mt-8 pt-8 flex flex-col md:flex-row justify-between items-center">
          <p className="text-gray-400 text-sm">
            © 2024 GitAlong. All rights reserved.
          </p>
          <div className="flex items-center space-x-6 mt-4 md:mt-0">
            <span className="text-gray-400 text-sm">Available on</span>
            <div className="flex space-x-2">
              <button
                onClick={() => window.open('https://apps.apple.com/app/gitalong', '_blank')}
                className="text-gray-400 hover:text-[#2EA043] transition-colors duration-300 text-sm"
              >
                App Store
              </button>
              <span className="text-gray-600">•</span>
              <button
                onClick={() => window.open('https://play.google.com/store/apps/details?id=com.gitalong.app', '_blank')}
                className="text-gray-400 hover:text-[#2EA043] transition-colors duration-300 text-sm"
              >
                Google Play
              </button>
            </div>
          </div>
        </div>
      </div>
    </footer>
  );
}; 