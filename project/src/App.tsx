import React, { useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { Navigation } from './components/Navigation';
import { FloatingOctocat } from './components/FloatingOctocat';
import { LandingPage } from './pages/LandingPage';
import { AboutPage } from './pages/AboutPage';
import { ContactPage } from './pages/ContactPage';
import { PrivacyPage } from './pages/PrivacyPage';
import { AuthProvider } from './contexts/AuthContext';
import type { Analytics } from 'firebase/analytics';
import { getAnalytics } from 'firebase/analytics';
import app from './lib/firebase';

// If you need to initialize analytics here, use a different variable name to avoid conflicts
// const appAnalytics: Analytics | undefined = typeof window !== 'undefined' ? getAnalytics(app) : undefined;

export const analytics: Analytics | undefined = typeof window !== 'undefined' && app !== null ? getAnalytics(app) : undefined;

function App() {
  useEffect(() => {
    // Firebase Analytics is automatically initialized
    // You can add custom analytics events here if needed
    if (analytics && typeof analytics !== 'undefined') {
      console.log('Firebase Analytics initialized');
    } else {
      console.log('Firebase Analytics not available');
    }
  }, []);

  return (
    <AuthProvider>
      <Router>
        <div className="min-h-screen bg-[#0D1117] text-white font-mono">
          <Navigation />
          <Routes>
            <Route path="/" element={<LandingPage />} />
            <Route path="/about" element={<AboutPage />} />
            <Route path="/contact" element={<ContactPage />} />
            <Route path="/privacy" element={<PrivacyPage />} />
          </Routes>
          <FloatingOctocat />
        </div>
      </Router>
    </AuthProvider>
  );
}

export default App;
