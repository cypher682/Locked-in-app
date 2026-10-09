# iOS Deployment Guide

This guide covers how to build and test your app on iOS devices.

## Prerequisites

### Required
- Flutter SDK installed
- Firebase project configured
- iOS `GoogleService-Info.plist` from Firebase Console

### Choose Your Path

**Option A: Have a Mac?** → Use Local Build (faster, free)  
**Option B: No Mac?** → Use Codemagic Cloud Build (easier, free tier available)

---

## Option A: Local Mac Build

### Requirements
- macOS computer (or macOS VM)
- Xcode 14+ installed from App Store
- Apple Developer account (free or paid)

### Steps

#### 1. Setup Firebase for iOS
```bash
# Download GoogleService-Info.plist from Firebase Console:
# Firebase Console → Project Settings → iOS app → Download config file

# Place it in:
cp ~/Downloads/GoogleService-Info.plist mobile/ios/Runner/
```

#### 2. Open Project in Xcode
```bash
cd mobile
open ios/Runner.xcworkspace
```

#### 3. Configure Signing
- In Xcode, select **Runner** (top left)
- Go to **Signing & Capabilities** tab
- Check **Automatically manage signing**
- Select your **Team** (Apple Developer account)
- Change **Bundle Identifier** to something unique like `com.yourname.lockedin`

#### 4. Build for Testing
```bash
# Connect your iPhone via USB
# Trust the computer on your iPhone

# Build and install
flutter build ios --release
# OR run directly
flutter run --release
```

#### 5. Trust Developer Certificate
On your iPhone:
- Settings → General → VPN & Device Management
- Tap your developer account → Trust

---

## Option B: Codemagic Cloud Build (No Mac Required)

### Requirements
- GitHub account
- Apple Developer account (free tier works for testing)

### Steps

#### 1. Setup Apple Certificates

**Create App ID:**
1. Go to [developer.apple.com/account](https://developer.apple.com/account)
2. **Identifiers** → **+** → **App IDs**
3. Bundle ID: `com.yourname.lockedin`
4. Enable capabilities: Push Notifications, Sign in with Apple

**Create Certificates:**
1. **Certificates** → **+** → **iOS Development**
2. Follow steps to create CSR (Certificate Signing Request)
3. Download certificate, double-click to install in Keychain

**Create Provisioning Profile:**
1. **Profiles** → **+** → **iOS App Development**
2. Select your App ID and Certificate
3. Select your test device(s)
4. Download profile

#### 2. Setup Codemagic

1. Go to [codemagic.io](https://codemagic.io)
2. **Sign in with GitHub**
3. **Add application** → Select your repository
4. **Flutter** → **Start your first build**

#### 3. Configure Build Settings

In Codemagic dashboard:
1. **App settings** → **Build**
2. **Flutter version**: Select stable
3. **iOS settings**:
   - Upload your certificates and provisioning profiles
   - Or use Automatic code signing (requires Apple Developer paid account)

#### 4. Add Firebase Config
1. **Environment variables**
2. Upload `GoogleService-Info.plist` as a file variable
3. Add post-clone script:
```bash
#!/bin/bash
cp $CM_BUILD_DIR/GoogleService-Info.plist ios/Runner/
```

#### 5. Trigger Build
- **Start new build**
- Wait ~15-20 minutes
- Download `.ipa` file from build artifacts

#### 6. Install on Device

**Option 1: Via Xcode (Mac required)**
```bash
# Connect iPhone
# Drag .ipa file into Xcode → Window → Devices and Simulators
```

**Option 2: Via TestFlight (Recommended)**
1. Upload `.ipa` to App Store Connect
2. Invite testers via email
3. They install via TestFlight app

---

## Common Issues

### "Untrusted Developer"
- Settings → General → VPN & Device Management → Trust

### "Code Signing Error"
- Ensure Bundle ID matches everywhere (Xcode, Firebase, Apple Developer)
- Use unique Bundle ID (not `com.example.app`)

### "GoogleService-Info.plist not found"
- Ensure file is in `mobile/ios/Runner/`
- Rebuild: `flutter clean && flutter build ios`

### "Network Security Error" (HTTP not HTTPS)
Already handled! Your `Info.plist` allows HTTP for development.

---

## Next Steps

### For Testing
- Use free Apple Developer account
- Install directly on your device

### For Distribution
- Upgrade to Apple Developer Program ($99/year)
- Submit to App Store via App Store Connect
- Or use TestFlight for beta testing

---

## Useful Commands

```bash
# Clean build
flutter clean

# Build iOS (Mac only)
flutter build ios --release

# Build IPA for distribution (Mac only)
flutter build ipa --release

# Run on connected device
flutter run --release

# List connected devices
flutter devices
```

---

## Resources

- [Apple Developer Portal](https://developer.apple.com/account)
- [Codemagic Flutter Guide](https://docs.codemagic.io/flutter-code-signing/ios-code-signing/)
- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)
- [TestFlight Beta Testing](https://developer.apple.com/testflight/)
