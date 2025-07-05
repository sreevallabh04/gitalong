#!/bin/bash

# GitAlong Web Deployment Script
# Deploys the Flutter web app to Firebase Hosting

set -e

echo "🚀 Starting GitAlong web deployment..."

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

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    print_warning "Firebase CLI is not installed. Installing..."
    npm install -g firebase-tools
fi

# Check if we're in the project directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "Not in the GitAlong project directory. Please run this script from the project root."
    exit 1
fi

print_status "Building Flutter web app..."

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build for web with release configuration
flutter build web --release --web-renderer canvaskit

if [ $? -eq 0 ]; then
    print_success "Web build completed successfully"
else
    print_error "Web build failed"
    exit 1
fi

print_status "Deploying to Firebase Hosting..."

# Check if firebase.json exists
if [ ! -f "firebase.json" ]; then
    print_warning "firebase.json not found. Creating default configuration..."
    cat > firebase.json << EOF
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      },
      {
        "source": "**/*.@(jpg|jpeg|gif|png|svg|webp)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      }
    ]
  }
}
EOF
fi

# Deploy to Firebase
firebase deploy --only hosting

if [ $? -eq 0 ]; then
    print_success "Deployment completed successfully!"
    print_status "Your app is now live at: https://gitalong.web.app"
    print_status "Or at your custom domain if configured"
else
    print_error "Deployment failed"
    exit 1
fi

# Optional: Run tests after deployment
print_status "Running web tests..."
flutter test

print_success "🎉 GitAlong web deployment completed successfully!"
print_status "📊 Check your Firebase console for analytics and performance metrics"
print_status "🔧 To configure custom domains, visit: https://console.firebase.google.com" 