# Locked-In — Mobile App

The Flutter client for [Locked-In](../README.md). It talks to the PHP backend in
[`../backend`](../backend) and uses Firebase Authentication.

## Setup

```bash
flutter pub get
```

1. Add your Firebase config:
   - `android/app/google-services.json` (copy `google-services.json.example`)
   - `ios/Runner/GoogleService-Info.plist` (copy `GoogleService-Info.plist.example`)
2. Set the API base URL in `lib/core/constants/app_constants.dart`.

## Run

```bash
flutter run
```

## Test

```bash
flutter test
flutter analyze
```

## Structure

```
lib/
├── core/        # theme, providers, API/auth services, constants
└── features/    # auth, goals, checkins, feed, friends, gamification, profile, settings
```
