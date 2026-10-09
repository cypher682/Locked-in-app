# Deployment Guide

## Backend Deployment

### Option 1: Railway (Recommended - Free Tier)

1. **Create account** at [railway.app](https://railway.app)

2. **Connect GitHub repo**
   - Click "New Project" → "Deploy from GitHub"
   - Select `Locked-in-app` repo
   - Set root directory: `backend`

3. **Set Environment Variables**
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_SERVICE_KEY=your_service_key
   FIREBASE_PROJECT_ID=your_firebase_project
   ```

4. **Deploy**
   - Railway auto-detects PHP and deploys
   - Get URL like: `https://your-app.railway.app`

5. **Update Mobile App**
   - Edit `mobile/lib/core/constants/app_constants.dart`:
   ```dart
   static const String apiBaseUrl = 'https://locked-in-app-production.up.railway.app/api/v1';
   ```

---

### Option 2: Render (Free Tier)

1. Go to [render.com](https://render.com) → New Web Service
2. Connect GitHub, select `backend` directory
3. Set environment: PHP
4. Add environment variables (same as above)
5. Deploy!

---

## Mobile App Distribution

### Android APK (Quickest)

1. **Build release APK:**
   ```bash
   cd mobile
   flutter build apk --release
   ```

2. **Find APK at:**
   ```
   mobile/build/app/outputs/flutter-apk/app-release.apk
   ```

3. **Share via:**
   - Google Drive / Dropbox
   - Email
   - WhatsApp / Telegram

### Firebase App Distribution (Better)

1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login: `firebase login`
3. Distribute:
   ```bash
   firebase appdistribution:distribute app-release.apk \
     --app YOUR_APP_ID \
     --groups "testers"
   ```

---

## Pre-Deployment Checklist

- [ ] Run SQL schemas in Supabase (Phase 5)
- [ ] Update `app_constants.dart` with production URL
- [ ] Set Firebase configuration
- [ ] Test on real device before sharing

---

## Environment Variables Required

| Variable | Description |
|:---|:---|
| `SUPABASE_URL` | Your Supabase project URL |
| `SUPABASE_SERVICE_KEY` | Service role key (not anon) |
| `FIREBASE_PROJECT_ID` | Firebase project ID |
