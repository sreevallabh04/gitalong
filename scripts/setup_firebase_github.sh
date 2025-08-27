#!/bin/bash

# Firebase GitHub Authentication Setup Script
# This script helps you configure Firebase for GitHub authentication

echo "🚀 Setting up Firebase GitHub Authentication for GitAlong"
echo "========================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Firebase CLI is installed
check_firebase_cli() {
    print_status "Checking Firebase CLI installation..."
    if command -v firebase &> /dev/null; then
        print_success "Firebase CLI is installed"
        firebase --version
    else
        print_error "Firebase CLI is not installed"
        print_status "Installing Firebase CLI..."
        npm install -g firebase-tools
    fi
}

# Check if FlutterFire CLI is installed
check_flutterfire_cli() {
    print_status "Checking FlutterFire CLI installation..."
    if command -v dartfire &> /dev/null; then
        print_success "FlutterFire CLI is installed"
        dartfire --version
    else
        print_error "FlutterFire CLI is not installed"
        print_status "Installing FlutterFire CLI..."
        dart pub global activate flutterfire_cli
    fi
}

# Get Android SHA fingerprints
get_android_fingerprints() {
    print_status "Getting Android SHA fingerprints..."
    
    if [ -f "android/app/debug.keystore" ]; then
        print_status "Found debug keystore, getting SHA-1 and SHA-256..."
        keytool -list -v -keystore android/app/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep -E "(SHA1|SHA256)"
    else
        print_warning "Debug keystore not found. You'll need to add SHA fingerprints manually."
        print_status "To get SHA fingerprints, run:"
        echo "keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android"
    fi
}

# Main setup function
main() {
    print_status "Starting Firebase GitHub authentication setup..."
    
    # Check CLI tools
    check_firebase_cli
    check_flutterfire_cli
    
    echo ""
    print_status "Manual steps required:"
    echo ""
    echo "1. 🔥 Firebase Console Configuration:"
    echo "   - Go to: https://console.firebase.google.com/project/gitalong-c8075"
    echo "   - Navigate to: Authentication → Sign-in method"
    echo "   - Enable GitHub provider"
    echo "   - Add Client ID: Ov23liqdqoZ88pfzPSnY"
    echo "   - Add Client Secret: c9aee11b9fa27492e73d7a1433e94b9cb7299efe"
    echo ""
    echo "2. 🌐 Add Authorized Domains:"
    echo "   - Go to: Authentication → Settings → Authorized domains"
    echo "   - Add: gitalong.app"
    echo "   - Add: www.gitalong.app"
    echo "   - Add: gitalong.vercel.app"
    echo "   - Add: localhost"
    echo ""
    echo "3. 📱 Android Configuration:"
    echo "   - Go to: Project Settings → Your apps → Android app"
    echo "   - Add SHA-1 and SHA-256 fingerprints:"
    get_android_fingerprints
    echo "   - Download new google-services.json"
    echo "   - Replace android/app/google-services.json"
    echo ""
    echo "4. 🍎 iOS Configuration:"
    echo "   - Go to: Project Settings → Your apps → iOS app"
    echo "   - Verify bundle ID: com.gitalong.app"
    echo "   - Download GoogleService-Info.plist"
    echo "   - Add to ios/Runner/"
    echo "   - Update ios/Runner/Info.plist with URL schemes"
    echo ""
    echo "5. 🔧 GitHub OAuth App Configuration:"
    echo "   - Go to: https://github.com/settings/developers"
    echo "   - Update OAuth App settings:"
    echo "     * Homepage URL: https://gitalong.app"
    echo "     * Authorization callback URL: https://gitalong-c8075.firebaseapp.com/__/auth/handler"
    echo ""
    echo "6. 🧪 Test the Implementation:"
    echo "   - Run: flutter run"
    echo "   - Click 'Continue with GitHub' button"
    echo "   - Verify authentication works"
    echo ""
    
    print_success "Setup instructions completed!"
    print_status "Follow the manual steps above to complete the configuration."
}

# Run the setup
main
