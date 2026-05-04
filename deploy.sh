#!/bin/bash
# ISLYR Frontend Deployment Script
# Run this on GPU France 1 (151.241.228.235) as root or with sudo
# Usage: bash deploy.sh

set -e

BACKEND_DIR="/opt/islyr/api"
STATIC_DIR="$BACKEND_DIR/static"
FRONTEND_REPO="https://github.com/stampedehosting/islyr-frontend.git"
TEMP_DIR="/tmp/islyr-frontend-deploy"

echo "🏝️  ISLYR Frontend Deployment"
echo "================================"

# Step 1: Find the static directory
echo "📁 Locating static directory..."
if [ -d "$STATIC_DIR" ]; then
    echo "   Found: $STATIC_DIR"
elif [ -d "$BACKEND_DIR/dist" ]; then
    STATIC_DIR="$BACKEND_DIR/dist"
    echo "   Found: $STATIC_DIR"
elif [ -d "$BACKEND_DIR/frontend" ]; then
    STATIC_DIR="$BACKEND_DIR/frontend"
    echo "   Found: $STATIC_DIR"
else
    # Search for the directory containing the current index.html
    FOUND=$(find /opt/islyr -name "index.html" 2>/dev/null | head -1)
    if [ -n "$FOUND" ]; then
        STATIC_DIR=$(dirname "$FOUND")
        echo "   Found via search: $STATIC_DIR"
    else
        echo "   Creating new static directory: $STATIC_DIR"
        mkdir -p "$STATIC_DIR"
    fi
fi

# Step 2: Backup existing frontend
echo "💾 Backing up existing frontend..."
if [ -f "$STATIC_DIR/index.html" ]; then
    cp "$STATIC_DIR/index.html" "$STATIC_DIR/index.html.backup.$(date +%Y%m%d_%H%M%S)"
    echo "   Backup created"
fi

# Step 3: Clone/pull latest frontend
echo "📥 Pulling latest frontend..."
rm -rf "$TEMP_DIR"
git clone --depth=1 "$FRONTEND_REPO" "$TEMP_DIR"

# Step 4: Deploy files
echo "🚀 Deploying files..."
cp "$TEMP_DIR/index.html" "$STATIC_DIR/index.html"
cp "$TEMP_DIR/sw.js" "$STATIC_DIR/sw.js"
cp "$TEMP_DIR/manifest.json" "$STATIC_DIR/manifest.json"

echo "   ✓ index.html deployed"
echo "   ✓ sw.js deployed"
echo "   ✓ manifest.json deployed"

# Step 5: Set permissions
chmod 644 "$STATIC_DIR/index.html"
chmod 644 "$STATIC_DIR/sw.js"
chmod 644 "$STATIC_DIR/manifest.json"

# Step 6: Clean up
rm -rf "$TEMP_DIR"

echo ""
echo "✅ Deployment complete!"
echo "   Frontend is now live at: http://151.241.228.235:4000"
echo "   Production URL: https://app.islyr.com"
echo ""
echo "🔄 If the backend needs a restart:"
echo "   systemctl restart islyr-api"
echo "   # OR"
echo "   pm2 restart islyr-api"
echo "   # OR"
echo "   supervisorctl restart islyr-api"
