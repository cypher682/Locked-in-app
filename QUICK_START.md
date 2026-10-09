# Quick Start

Get Locked-In running locally in a few minutes.

## Prerequisites

- **PHP 8.2+** and **Composer**
- **Flutter SDK**
- A **Supabase** project and a **Firebase** project

## 1. Backend

```bash
cd backend
composer install
cp .env.example .env          # fill in SUPABASE_URL, SUPABASE_SERVICE_KEY, JWT_SECRET, …
```

Add your Firebase service-account key: copy
`config/firebase/credentials.json.example` to `config/firebase/credentials.json`
and replace the placeholders.

Create the database objects by running the SQL files in `docs/database/` **in
numeric order** (`01_users_table.sql`, `02_goals_table.sql`, … `12_achievements.sql`)
in the Supabase SQL editor.

Run the API:

```bash
php -S localhost:8000 -t src/
```

## 2. Mobile

```bash
cd mobile
flutter pub get
```

- Copy `android/app/google-services.json.example` → `android/app/google-services.json`
- Copy `ios/Runner/GoogleService-Info.plist.example` → `ios/Runner/GoogleService-Info.plist`
- Set the API URL in `lib/core/constants/app_constants.dart`
  (`http://10.0.2.2:8000/api/v1` for the Android emulator)

```bash
flutter run
```

## Troubleshooting

- **API error** — make sure the backend is running on port 8000.
- **Auth error** — verify the Firebase config matches your package name (`com.lockedin.app`).
- **Database error** — re-run the SQL scripts in order.
