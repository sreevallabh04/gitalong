# Firebase GitHub Authentication Setup Script for Windows
# This script helps you configure Firebase for GitHub authentication

Write-Host "🚀 Setting up Firebase GitHub Authentication for GitAlong" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

# Function to print colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Check if Firebase CLI is installed
function Test-FirebaseCLI {
    Write-Status "Checking Firebase CLI installation..."
    try {
        $firebaseVersion = firebase --version 2>$null
        if ($firebaseVersion) {
            Write-Success "Firebase CLI is installed"
            Write-Host $firebaseVersion
        } else {
            throw "Firebase CLI not found"
        }
    } catch {
        Write-Error "Firebase CLI is not installed"
        Write-Status "Installing Firebase CLI..."
        npm install -g firebase-tools
    }
}

# Check if FlutterFire CLI is installed
function Test-FlutterFireCLI {
    Write-Status "Checking FlutterFire CLI installation..."
    try {
        $dartfireVersion = dartfire --version 2>$null
        if ($dartfireVersion) {
            Write-Success "FlutterFire CLI is installed"
            Write-Host $dartfireVersion
        } else {
            throw "FlutterFire CLI not found"
        }
    } catch {
        Write-Error "FlutterFire CLI is not installed"
        Write-Status "Installing FlutterFire CLI..."
        dart pub global activate flutterfire_cli
    }
}

# Get Android SHA fingerprints
function Get-AndroidFingerprints {
    Write-Status "Getting Android SHA fingerprints..."
    
    $debugKeystore = "android\app\debug.keystore"
    if (Test-Path $debugKeystore) {
        Write-Status "Found debug keystore, getting SHA-1 and SHA-256..."
        try {
            $result = & keytool -list -v -keystore $debugKeystore -alias androiddebugkey -storepass android -keypass android 2>$null
            $result | Select-String -Pattern "(SHA1|SHA256)"
        } catch {
            Write-Warning "Could not get SHA fingerprints from debug keystore"
        }
    } else {
        Write-Warning "Debug keystore not found. You'll need to add SHA fingerprints manually."
        Write-Status "To get SHA fingerprints, run:"
        Write-Host "keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android"
    }
}

# Main setup function
function Start-FirebaseSetup {
    Write-Status "Starting Firebase GitHub authentication setup..."
    
    # Check CLI tools
    Test-FirebaseCLI
    Test-FlutterFireCLI
    
    Write-Host ""
    Write-Status "Manual steps required:"
    Write-Host ""
    Write-Host "1. 🔥 Firebase Console Configuration:" -ForegroundColor Cyan
    Write-Host "   - Go to: https://console.firebase.google.com/project/gitalong-c8075"
    Write-Host "   - Navigate to: Authentication → Sign-in method"
    Write-Host "   - Enable GitHub provider"
    Write-Host "   - Add Client ID: Ov23liqdqoZ88pfzPSnY"
    Write-Host "   - Add Client Secret: c9aee11b9fa27492e73d7a1433e94b9cb7299efe"
    Write-Host ""
    Write-Host "2. 🌐 Add Authorized Domains:" -ForegroundColor Cyan
    Write-Host "   - Go to: Authentication → Settings → Authorized domains"
    Write-Host "   - Add: gitalong.app"
    Write-Host "   - Add: www.gitalong.app"
    Write-Host "   - Add: gitalong.vercel.app"
    Write-Host "   - Add: localhost"
    Write-Host ""
    Write-Host "3. 📱 Android Configuration:" -ForegroundColor Cyan
    Write-Host "   - Go to: Project Settings → Your apps → Android app"
    Write-Host "   - Add SHA-1 and SHA-256 fingerprints:"
    Get-AndroidFingerprints
    Write-Host "   - Download new google-services.json"
    Write-Host "   - Replace android\app\google-services.json"
    Write-Host ""
    Write-Host "4. 🍎 iOS Configuration:" -ForegroundColor Cyan
    Write-Host "   - Go to: Project Settings → Your apps → iOS app"
    Write-Host "   - Verify bundle ID: com.gitalong.app"
    Write-Host "   - Download GoogleService-Info.plist"
    Write-Host "   - Add to ios\Runner\"
    Write-Host "   - Update ios\Runner\Info.plist with URL schemes"
    Write-Host ""
    Write-Host "5. 🔧 GitHub OAuth App Configuration:" -ForegroundColor Cyan
    Write-Host "   - Go to: https://github.com/settings/developers"
    Write-Host "   - Update OAuth App settings:"
    Write-Host "     * Homepage URL: https://gitalong.app"
    Write-Host "     * Authorization callback URL: https://gitalong-c8075.firebaseapp.com/__/auth/handler"
    Write-Host ""
    Write-Host "6. 🧪 Test the Implementation:" -ForegroundColor Cyan
    Write-Host "   - Run: flutter run"
    Write-Host "   - Click 'Continue with GitHub' button"
    Write-Host "   - Verify authentication works"
    Write-Host ""
    
    Write-Success "Setup instructions completed!"
    Write-Status "Follow the manual steps above to complete the configuration."
}

# Run the setup
Start-FirebaseSetup
