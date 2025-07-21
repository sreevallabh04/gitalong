#!/bin/bash

# GitAlong Production Deployment Script
# This script ensures production-ready deployment

echo "🚀 GitAlong Production Deployment Starting..."

# 1. Environment Check
echo "📋 Checking environment configuration..."
if [ ! -f ".env.production" ]; then
    echo "❌ Error: .env.production file not found!"
    echo "Please create .env.production with your production configuration"
    exit 1
fi

# 2. Code Quality Check
echo "🔍 Running code quality checks..."
flutter analyze
if [ $? -ne 0 ]; then
    echo "❌ Flutter analyze failed! Please fix all issues before deploying."
    exit 1
fi

# 3. Tests
echo "🧪 Running tests..."
flutter test
if [ $? -ne 0 ]; then
    echo "❌ Tests failed! Please fix failing tests before deploying."
    exit 1
fi

# 4. Security Check
echo "🔒 Checking for security issues..."
if grep -r "localhost" lib/ --include="*.dart"; then
    echo "⚠️  Warning: Found localhost references in code. Please review for production."
fi

if grep -r "TODO\|FIXME\|hack\|temp" lib/ --include="*.dart"; then
    echo "⚠️  Warning: Found TODO/FIXME comments. Please review for production."
fi

# 5. Build for Production
echo "🏗️  Building for production..."

# Android
echo "📱 Building Android..."
flutter build appbundle --release \
    --dart-define-from-file=.env.production \
    --obfuscate \
    --split-debug-info=build/app/outputs/symbols

# iOS (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Building iOS..."
    flutter build ipa --release \
        --dart-define-from-file=.env.production \
        --obfuscate \
        --split-debug-info=build/ios/symbols
fi

# Web
echo "🌐 Building Web..."
flutter build web --release \
    --dart-define-from-file=.env.production \
    --web-renderer canvaskit

# 6. Deploy to Firebase (if configured)
echo "☁️  Deploying to Firebase..."
if command -v firebase &> /dev/null; then
    firebase deploy --only hosting,functions
else
    echo "⚠️  Firebase CLI not found. Skipping Firebase deployment."
fi

echo "✅ Production deployment complete!"
echo ""
echo "📦 Build artifacts:"
echo "   Android: build/app/outputs/bundle/release/app-release.aab"
echo "   iOS: build/ios/ipa/gitalong.ipa (if built)"
echo "   Web: build/web/"
echo ""
echo "🎉 Your GitAlong app is ready for production!"
