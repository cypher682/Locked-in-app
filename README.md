# Locked-In

**A social accountability app that helps you stick to your goals — through public commitment, daily check-ins, friends, and a bit of healthy competition.**

Locked-In is a full-stack mobile application: a **Flutter** client backed by a lightweight **PHP REST API**, with **Firebase** for authentication and **Supabase (PostgreSQL)** for data and storage.

---

## The idea

Most goal trackers are private, so it's easy to quietly give up. Locked-In makes progress *social*: you commit to a goal, check in daily with photo proof, and stay accountable to friends who can see your streaks. Consistency earns points, badges, and a spot on the leaderboard.

## Features

- **Goals** — create goals with categories, visibility settings, and target dates; track progress against streaks and statistics.
- **Daily check-ins** — photo-verified updates with notes, feeding a public progress timeline.
- **Social layer** — profiles, friend connections, an activity feed, likes, and comments.
- **Gamification** — points for consistency, global and friends-only leaderboards, and achievement badges.
- **Modern UI** — light and dark themes, a clean feature-first design that works across Android, iOS, web, and desktop.

## Tech stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter 3, Dart, Riverpod, Dio |
| Auth | Firebase Authentication (email/password + Google Sign-In), JWT |
| Backend | PHP 8.2, custom router, PSR-4 autoloading, Composer |
| Database | Supabase (PostgreSQL), SQL views for feeds and leaderboards |
| Storage | Supabase Storage |
| CI | GitHub Actions (Flutter analyze/test + PHP lint/test) |

## Architecture

```
mobile (Flutter)                 backend (PHP)
──────────────                   ─────────────
features/  (UI + providers)  →   Routes       → API endpoints
core/services (HTTP clients) →   Controllers  → validation & response
core/theme, constants            Services     → business logic
                                 Middleware   → auth (JWT / Firebase)
                                 Database     → Supabase REST
```

Requests flow from a Riverpod provider → service → HTTP call. The backend router matches the route, auth middleware verifies the token, the controller validates input, and the service layer talks to Supabase.

## Project structure

```
Locked-in-app/
├── backend/                 # PHP REST API
│   ├── config/firebase/     # credentials.json.example (add your own)
│   ├── public/              # web entry point
│   ├── src/
│   │   ├── Controllers/     # endpoint handlers
│   │   ├── Services/        # business logic
│   │   ├── Middleware/      # auth, CORS
│   │   └── Routes/          # route definitions
│   ├── tests/
│   └── .env.example
├── mobile/                  # Flutter app
│   └── lib/
│       ├── core/            # theme, services, constants
│       └── features/        # auth, goals, checkins, feed, gamification…
├── docs/                    # setup, API, architecture, database docs
└── .github/workflows/       # CI
```

## Getting started

### Prerequisites

- **Flutter SDK** 3.x and Dart
- **PHP** 8.2+ and **Composer**
- A **Firebase** project (Authentication enabled)
- A **Supabase** project

### 1. Clone

```bash
git clone https://github.com/cypher682/Locked-in-app.git
cd Locked-in-app
```

### 2. Backend

```bash
cd backend
composer install
cp .env.example .env        # then fill in your values
```

Place your Firebase service-account key at `backend/config/firebase/credentials.json`
(copy `credentials.json.example` and replace the placeholders).

Then create the database objects by running the SQL files in `docs/database/`
in numeric order (`01_users_table.sql` … `12_achievements.sql`) in the Supabase SQL editor.

Start the API:

```bash
php -S localhost:8000 -t src/
```

### 3. Mobile

```bash
cd mobile
flutter pub get
```

Add your Firebase config:
- `mobile/android/app/google-services.json` (from `google-services.json.example`)
- `mobile/ios/Runner/GoogleService-Info.plist` (from `GoogleService-Info.plist.example`)

Point the app at your backend in `lib/core/constants/app_constants.dart`
(`http://10.0.2.2:8000/api/v1` for the Android emulator, `http://localhost:8000/api/v1` for iOS).

```bash
flutter run
```

## Configuration & secrets

This repository ships **templates only** — never real credentials:

| File (real) | Template to copy |
|-------------|------------------|
| `backend/.env` | `backend/.env.example` |
| `backend/config/firebase/credentials.json` | `backend/config/firebase/credentials.json.example` |
| `mobile/android/app/google-services.json` | `mobile/android/app/google-services.json.example` |
| `mobile/ios/Runner/GoogleService-Info.plist` | `mobile/ios/Runner/GoogleService-Info.plist.example` |

The real files are git-ignored. Do not commit them.

## Documentation

- [Backend setup](docs/guides/backend-setup.md)
- [Mobile setup](docs/guides/mobile-setup.md)
- [API reference](docs/api/endpoints.md)
- [Architecture](docs/architecture/README.md)
- [Database schema](docs/database/schema.md)
- [Deployment](docs/DEPLOYMENT.md)
- [Quick start](QUICK_START.md)

## Testing

```bash
# Mobile
cd mobile && flutter test && flutter analyze

# Backend
cd backend && vendor/bin/phpunit
```

## Contributing

Contributions are welcome. Fork the repo, create a feature branch, and open a pull request.

## License

Released under the MIT License — see [LICENSE](LICENSE).

---

*Built with Flutter, PHP, Firebase, and Supabase.*
