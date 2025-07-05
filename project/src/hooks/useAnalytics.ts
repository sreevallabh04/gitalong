import { analytics } from '../lib/firebase';
import { logEvent } from 'firebase/analytics';

export const useAnalytics = () => {
  const trackEvent = (eventName: string, parameters?: Record<string, any>) => {
    if (analytics) {
      logEvent(analytics, eventName, parameters);
    }
  };

  const trackPageView = (pageName: string) => {
    if (analytics) {
      logEvent(analytics, 'page_view', {
        page_title: pageName,
        page_location: window.location.href,
      });
    }
  };

  const trackWaitlistSignup = (email: string) => {
    if (analytics) {
      logEvent(analytics, 'waitlist_signup', {
        method: 'email',
        email_domain: email.split('@')[1],
      });
    }
  };

  const trackAppStoreClick = (platform: 'ios' | 'android') => {
    if (analytics) {
      logEvent(analytics, 'app_store_click', {
        platform,
        source: 'website',
      });
    }
  };

  const trackMaintainerLoginAttempt = () => {
    if (analytics) {
      logEvent(analytics, 'maintainer_login_attempt', {
        source: 'website',
      });
    }
  };

  const trackAuthEvent = (action: string, method: string, success: boolean) => {
    if (analytics) {
      logEvent(analytics, 'auth_event', {
        action,
        method,
        success,
        source: 'website',
      });
    }
  };

  return {
    trackEvent,
    trackPageView,
    trackWaitlistSignup,
    trackAppStoreClick,
    trackMaintainerLoginAttempt,
    trackAuthEvent,
  };
};