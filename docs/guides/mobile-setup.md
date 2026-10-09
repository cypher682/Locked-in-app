# Mobile Setup Guide

## Requirements
- Flutter SDK (Latest Stable)
- Android Studio / VS Code
- Android Emulator / iOS Simulator

## Installation

1. **Navigate to mobile directory**
   ```bash
   cd mobile
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`

## Configuration

Edit `lib/core/constants/app_constants.dart`:

```dart
class AppConstants {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS
  static const String apiBaseUrl = 'http://10.0.2.2:8000/api/v1'; 
  
  // For Production/Device:
  // static const String apiBaseUrl = 'https://your-api.railway.app/api/v1';
}
```

## Running the App

```bash
flutter run
```

## Common Issues

- **Connection Refused:** Ensure backend is running and `apiBaseUrl` is correct.
- **Firebase Error:** Verify `google-services.json` package name matches `android/app/build.gradle`.
- ** Gradle Errors:** Run `flutter clean` then `flutter pub get`.
