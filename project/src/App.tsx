import { useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { Navigation } from './components/Navigation';
import { FloatingOctocat } from './components/FloatingOctocat';
import { LandingPage } from './pages/LandingPage';
import { AboutPage } from './pages/AboutPage';
import { ContactPage } from './pages/ContactPage';
import { PrivacyPage } from './pages/PrivacyPage';
import { AuthProvider } from './contexts/AuthContext';
// @ts-ignore
import { analytics } from './lib/firebase';

function App() {
  useEffect(() => {
    // Firebase Analytics is automatically initialized
    // You can add custom analytics events here if needed
    // @ts-ignore
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
