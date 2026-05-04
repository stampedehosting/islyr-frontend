#!/usr/bin/env python3
"""
ISLYR Direct Deployment Script
Run on GPU France 1 (151.241.228.235) as root:
  python3 deploy_direct.py
"""
import os
import sys
import shutil
import subprocess
from pathlib import Path
from datetime import datetime

BACKEND_DIR = Path("/opt/islyr/api")
GITHUB_RAW = "https://raw.githubusercontent.com/stampedehosting/islyr-frontend/main"

def find_static_dir():
    """Find the static files directory for the FastAPI backend."""
    candidates = [
        BACKEND_DIR / "static",
        BACKEND_DIR / "dist", 
        BACKEND_DIR / "frontend",
        BACKEND_DIR / "web",
    ]
    for c in candidates:
        if c.exists():
            return c
    
    # Search for index.html
    result = subprocess.run(
        ["find", "/opt/islyr", "-name", "index.html", "-not", "-path", "*/node_modules/*"],
        capture_output=True, text=True
    )
    if result.stdout.strip():
        return Path(result.stdout.strip().split('\n')[0]).parent
    
    # Create default
    static = BACKEND_DIR / "static"
    static.mkdir(parents=True, exist_ok=True)
    return static

def download_file(url, dest):
    """Download a file using curl or urllib."""
    try:
        subprocess.run(["curl", "-fsSL", url, "-o", str(dest)], check=True)
        return True
    except:
        import urllib.request
        urllib.request.urlretrieve(url, str(dest))
        return True

def main():
    print("🏝️  ISLYR Frontend Deployment")
    print("=" * 40)
    
    static_dir = find_static_dir()
    print(f"📁 Static directory: {static_dir}")
    
    # Backup
    index_file = static_dir / "index.html"
    if index_file.exists():
        backup = static_dir / f"index.html.backup.{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        shutil.copy(index_file, backup)
        print(f"💾 Backup: {backup.name}")
    
    # Download files
    files = ["index.html", "sw.js", "manifest.json"]
    for f in files:
        url = f"{GITHUB_RAW}/{f}"
        dest = static_dir / f
        print(f"📥 Downloading {f}...")
        download_file(url, dest)
        os.chmod(dest, 0o644)
        print(f"   ✓ {f} deployed")
    
    print("\n✅ Deployment complete!")
    print(f"   Frontend: http://151.241.228.235:4000")
    print(f"   Production: https://app.islyr.com")
    print("\n🔄 Restart if needed:")
    print("   systemctl restart islyr-api")

if __name__ == "__main__":
    main()
