#!/bin/bash
# ISLYR Frontend Deployment Script
# Run this on GPU France 1 (151.241.228.235) as root or with sudo
# Usage: bash deploy.sh [GITHUB_TOKEN]
# 
# The GITHUB_TOKEN is optional if the repo is public.
# If the repo is private, provide your GitHub token:
#   bash deploy.sh ghp_xxxxxxxxxxxx

set -e

BACKEND_DIR="/opt/islyr/api"
GITHUB_TOKEN="${1:-}"
GITHUB_API="https://api.github.com/repos/stampedehosting/islyr-frontend/contents"
TEMP_DIR="/tmp/islyr-frontend-deploy"

echo "🏝️  ISLYR Frontend Deployment"
echo "================================"

# Step 1: Find the static directory
echo "📁 Locating static directory..."
STATIC_DIR=""

# Check common locations
for dir in "$BACKEND_DIR/static" "$BACKEND_DIR/dist" "$BACKEND_DIR/frontend" "$BACKEND_DIR/web"; do
    if [ -d "$dir" ]; then
        STATIC_DIR="$dir"
        break
    fi
done

# Search for existing index.html
if [ -z "$STATIC_DIR" ]; then
    FOUND=$(find /opt/islyr -name "index.html" 2>/dev/null | grep -v ".git" | head -1)
    if [ -n "$FOUND" ]; then
        STATIC_DIR=$(dirname "$FOUND")
    fi
fi

# Create default if not found
if [ -z "$STATIC_DIR" ]; then
    STATIC_DIR="$BACKEND_DIR/static"
    mkdir -p "$STATIC_DIR"
fi

echo "   Found: $STATIC_DIR"

# Step 2: Backup existing frontend
echo "💾 Backing up existing frontend..."
if [ -f "$STATIC_DIR/index.html" ]; then
    cp "$STATIC_DIR/index.html" "$STATIC_DIR/index.html.backup.$(date +%Y%m%d_%H%M%S)"
    echo "   Backup created"
fi

# Step 3: Download files
echo "📥 Downloading frontend files..."
mkdir -p "$TEMP_DIR"

download_file() {
    local filename="$1"
    local dest="$2"
    local url="https://raw.githubusercontent.com/stampedehosting/islyr-frontend/main/$filename"
    
    if [ -n "$GITHUB_TOKEN" ]; then
        curl -fsSL -H "Authorization: token $GITHUB_TOKEN" "$url" -o "$dest"
    else
        curl -fsSL "$url" -o "$dest"
    fi
}

download_file "index.html" "$TEMP_DIR/index.html"
download_file "sw.js" "$TEMP_DIR/sw.js"
download_file "manifest.json" "$TEMP_DIR/manifest.json"

# Step 4: Deploy files
echo "🚀 Deploying files..."
cp "$TEMP_DIR/index.html" "$STATIC_DIR/index.html"
cp "$TEMP_DIR/sw.js" "$STATIC_DIR/sw.js"
cp "$TEMP_DIR/manifest.json" "$STATIC_DIR/manifest.json"

chmod 644 "$STATIC_DIR/index.html" "$STATIC_DIR/sw.js" "$STATIC_DIR/manifest.json"

echo "   ✓ index.html deployed"
echo "   ✓ sw.js deployed"
echo "   ✓ manifest.json deployed"

# Step 5: Clean up
rm -rf "$TEMP_DIR"

echo ""
echo "✅ Deployment complete!"
echo "   Frontend: http://151.241.228.235:4000"
echo "   Production: https://app.islyr.com"
echo ""
echo "🔄 Restart backend if needed:"
echo "   systemctl restart islyr-api  # or pm2 restart islyr-api"
