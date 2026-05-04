# ISLYR Frontend — Single-File PWA

A complete mobile-first PWA for the ISLYR platform, built as a single HTML/JS/CSS file.

## Features

- **Phone + OTP Authentication** — Real SMS via Twilio, connects to shared `users` table
- **Island Explore** — Browse, search, and filter all islands by biome
- **Island Creation** — Create islands with biome picker, visibility settings, and tags
- **Social Feed** — Activity feed from followed islands
- **User Profile** — View and edit profile, see your islands
- **Island Detail Modal** — Full island info with like/visit actions
- **PWA Ready** — Service worker, manifest, installable on mobile
- **Mobile Responsive** — Optimized for iOS and Android

## API Endpoints Used

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/send-otp` | Send OTP to phone |
| POST | `/api/v1/auth/verify-otp` | Verify OTP, get token |
| GET | `/api/v1/auth/me` | Get current user |
| POST | `/api/v1/profiles/` | Create profile (new users) |
| PUT | `/api/v1/profiles/me` | Update profile |
| GET | `/api/v1/profiles/{user_id}` | Get profile |
| GET | `/api/v1/islands/` | List all islands |
| GET | `/api/v1/islands/featured` | Featured islands |
| POST | `/api/v1/islands/` | Create island |
| POST | `/api/v1/islands/{id}/visit` | Visit island |
| POST | `/api/v1/social/like/{id}` | Like island |
| DELETE | `/api/v1/social/like/{id}` | Unlike island |
| GET | `/api/v1/social/feed` | Social feed |

## Deployment

### Option 1: One-liner on the server (recommended)
```bash
curl -fsSL https://raw.githubusercontent.com/stampedehosting/islyr-frontend/main/deploy.sh | bash
```

### Option 2: Python script
```bash
curl -fsSL https://raw.githubusercontent.com/stampedehosting/islyr-frontend/main/deploy_direct.py | python3
```

### Option 3: Manual
```bash
# Find the static directory
STATIC_DIR=$(find /opt/islyr -name "index.html" 2>/dev/null | head -1 | xargs dirname)

# Download and deploy
curl -fsSL https://raw.githubusercontent.com/stampedehosting/islyr-frontend/main/index.html -o "$STATIC_DIR/index.html"
curl -fsSL https://raw.githubusercontent.com/stampedehosting/islyr-frontend/main/sw.js -o "$STATIC_DIR/sw.js"
curl -fsSL https://raw.githubusercontent.com/stampedehosting/islyr-frontend/main/manifest.json -o "$STATIC_DIR/manifest.json"
```

## Architecture

- **Backend**: FastAPI at `/opt/islyr/api/` on port 4000
- **Database**: MySQL `p2pdojo_mall` on 72.60.70.159 (13 `islyr_*` tables)
- **Auth**: Phone + OTP via Twilio, shared `users` table
- **Vectors**: Qdrant on port 6333
- **Server**: GPU France 1 (151.241.228.235)

## File Structure

```
index.html    — Complete SPA (HTML + CSS + JS, ~2100 lines)
sw.js         — Service Worker for PWA/offline support
manifest.json — PWA manifest for installability
deploy.sh     — Bash deployment script
deploy_direct.py — Python deployment script
```
