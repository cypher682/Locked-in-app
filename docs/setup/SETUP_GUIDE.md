
-# Environment Setup Guide

## Prerequisites Checklist

### 1. Development Tools
- [ ] **PHP 8.1+** installed (tested with 8.4.14)
- [ ] **Composer** installed (latest version)
- [ ] **Flutter SDK 3.0+** installed
- [ ] **Dart SDK 3.0+** installed
- [ ] **Android Studio** (for Android development)
- [ ] **Android Emulator** configured
- [ ] **Git** installed

### 2. External Services Accounts
- [ ] **Firebase Project** created
- [ ] **Supabase Project** created
- [ ] **Google Cloud Console** project (for Google Sign-In)

---

## Firebase Setup

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Name it "CommitStack" (or your preferred name)
4. Enable Google Analytics (optional)

### Step 2: Enable Authentication
1. In Firebase Console → **Authentication**
2. Click "Get started"
3. Enable **Email/Password** provider
4. Enable **Google** provider
   - Add your support email
   - Download OAuth client configuration

### Step 3: Get Service Account Credentials
1. Go to **Project Settings** → **Service accounts**
2. Click "Generate new private key"
3. Save the JSON file as `backend/config/firebase/credentials.json`

### Step 4: Get Mobile Configuration Files

**For Android:**
1. In Firebase Console → **Project Settings**
2. Add Android app
3. Package name: `com.commitstack.app` (or your package)
4. Download `google-services.json`
5. Place in `mobile/android/app/google-services.json`

**For iOS:**
1. Add iOS app in Firebase Console
2. Bundle ID: `com.commitstack.app` (or your bundle)
3. Download `GoogleService-Info.plist`
4. Place in `mobile/ios/Runner/GoogleService-Info.plist`

---

## Supabase Setup

### Step 1: Create Supabase Project
1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Click "New project"
3. Choose organization
4. Set project name: "commitstack"
5. Generate strong database password (save it!)
6. Choose region closest to you
7. Wait for project to be ready (~2 minutes)

### Step 2: Get API Credentials
1. Go to **Project Settings** → **API**
2. Copy **Project URL** (e.g., `https://xxxxx.supabase.co`)
3. Copy **service_role key** (under "Project API keys")

### Step 3: Execute Database Schemas
1. Go to **SQL Editor** in Supabase Dashboard
2. Execute in order:
   ```sql
   -- Execute file: docs/database/01_users_table.sql
   -- Execute file: docs/database/02_goals_table.sql
   -- Execute file: docs/database/03_checkins_table.sql
   -- Execute file: docs/database/04_streaks_view.sql
   ```

### Step 4: Create Storage Bucket
1. Go to **Storage** in Supabase Dashboard
2. Click "New bucket"
3. Name: `checkins`
4. **Public bucket:** YES (for reading images)
5. **File size limit:** 5MB
6. **Allowed MIME types:** `image/jpeg, image/jpg, image/png, image/webp`

### Step 5: Configure Storage Policies
1. In the `checkins` bucket, go to **Policies**
2. Add policy for **INSERT**:
   - Name: "Authenticated users can upload"
   - Policy: `(auth.role() = 'authenticated')`
3. Add policy for **SELECT**:
   - Name: "Public read access"
   - Policy: `true`
4. Add policy for **DELETE**:
   - Name: "Users can delete own files"
   - Policy: `(auth.uid() = (storage.foldername(name))[1])`

---

## Backend Configuration

### Step 1: Install Dependencies
```bash
cd backend
composer install
```

### Step 2: Configure Environment
```bash
cp .env.example .env
```

### Step 3: Edit `.env` File
```env
# Supabase Configuration
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_SERVICE_KEY=your_service_role_key_here

# Firebase Configuration
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CREDENTIALS_PATH=config/firebase/credentials.json

# JWT Configuration
JWT_SECRET=your_strong_random_32_character_secret_here
JWT_EXPIRY=86400

# App Configuration
APP_URL=http://localhost:8000
```

### Step 4: Generate JWT Secret
```bash
# Generate a secure random string (32+ characters)
php -r "echo bin2hex(random_bytes(32));"
```

### Step 5: Verify Setup
```bash
php test-setup.php
```

Expected output:
```
✓ PHP version OK
✓ Extensions loaded
✓ Firebase credentials found
✓ Environment variables set
```

### Step 6: Start Development Server
```bash
php -S localhost:8000 -t public
```

---

## Mobile Configuration

### Step 1: Install Dependencies
```bash
cd mobile
flutter pub get
```

### Step 2: Configure API Base URL
Edit `mobile/lib/core/constants/app_constants.dart`:

```dart
class AppConstants {
  // For Android Emulator
  static const String apiBaseUrl = 'http://10.0.2.2:8000/api/v1';
  
  // For iOS Simulator
  // static const String apiBaseUrl = 'http://localhost:8000/api/v1';
  
  // For Physical Device (replace with your computer's IP)
  // static const String apiBaseUrl = 'http://192.168.1.XXX:8000/api/v1';
  
  static const String appName = 'CommitStack';
}
```

### Step 3: Configure Android
1. Ensure `google-services.json` is in `mobile/android/app/`
2. Check `android/app/build.gradle` has:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

### Step 4: Configure iOS (macOS only)
1. Ensure `GoogleService-Info.plist` is in `mobile/ios/Runner/`
2. Open `ios/Runner.xcworkspace` in Xcode
3. Add `GoogleService-Info.plist` to project if not already added

### Step 5: Run the App
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Or just run (will prompt for device)
flutter run
```

---

## Testing Checklist

### Backend Tests
```bash
# Health check
curl http://localhost:8000/api/v1/health

# Should return: {"status":"ok","timestamp":1234567890}
```

### Authentication Test
1. Run mobile app
2. Sign up with email/password
3. Verify user created in Supabase **Authentication** tab
4. Verify user record in **users** table

### Goals Test
1. Create a goal from mobile app
2. Verify goal in Supabase **goals** table
3. Update goal status
4. Delete goal (soft delete - check `deleted_at`)

### Check-ins Test
1. Create check-in without photo
2. Create check-in with photo
3. Verify check-in in **checkins** table
4. Verify photo in **Storage** → **checkins** bucket
5. Check streak calculation in **user_streaks** view

---

## Common Issues & Solutions

### Backend Issues

**Issue:** "Class not found"
```bash
cd backend
composer dump-autoload
```

**Issue:** "Firebase credentials not found"
- Check file exists: `backend/config/firebase/credentials.json`
- Check `.env` has correct path

**Issue:** "Supabase connection failed"
- Verify `SUPABASE_URL` and `SUPABASE_SERVICE_KEY` in `.env`
- Test connection in Supabase dashboard

### Mobile Issues

**Issue:** "Cannot connect to backend"
- Verify backend server is running: `php -S localhost:8000 -t public`
- Check correct API URL in `app_constants.dart`
- For emulator: use `10.0.2.2` not `localhost`

**Issue:** "Firebase not initialized"
```bash
flutter clean
flutter pub get
flutter run
```

**Issue:** "Google Sign-In not working (Android)"
- Add SHA-1 fingerprint to Firebase Console
```bash
cd android
./gradlew signingReport
```
- Copy SHA-1 from output
- Add to Firebase Console → Project Settings → Your apps → Android app

**Issue:** "Photo upload fails"
- Check Supabase Storage bucket exists
- Verify storage policies are configured
- Check file size < 5MB

---

## Environment Variables Summary

### Backend `.env`
```env
SUPABASE_URL=
SUPABASE_SERVICE_KEY=
FIREBASE_PROJECT_ID=
FIREBASE_CREDENTIALS_PATH=config/firebase/credentials.json
JWT_SECRET=
JWT_EXPIRY=86400
APP_URL=http://localhost:8000
```

### Mobile `app_constants.dart`
```dart
static const String apiBaseUrl = 'http://10.0.2.2:8000/api/v1';
```

---

## Quick Start Commands

```bash
# Backend
cd backend
composer install
cp .env.example .env
# Edit .env with your credentials
php test-setup.php
php -S localhost:8000 -t public

# Mobile (new terminal)
cd mobile
flutter pub get
flutter run
```

---

## Next Steps After Setup

1. ✅ Test authentication (email + Google Sign-In)
2. ✅ Create a goal
3. ✅ Add check-in with photo
4. ✅ View streak counter
5. ✅ Test all CRUD operations

**You're ready to develop!** 🚀
