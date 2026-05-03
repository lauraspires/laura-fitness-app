#!/bin/bash
# Health Hub — copy latest from Drive and push to GitHub

DRIVE_FILE="/Users/LauraSpires/Library/CloudStorage/GoogleDrive-lauraspires5@gmail.com/My Drive/AI Files/Cowork OS/Health Hub/index.html"
LOCAL_REPO="$HOME/Documents/GitHub/health-hub"

if [ ! -d "$LOCAL_REPO/.git" ]; then
  echo "❌ Repo not found at $LOCAL_REPO"
  read -p "Press Enter to close..." _
  exit 1
fi

cd "$LOCAL_REPO"

echo "→ Copying latest file from Drive..."
cp "$DRIVE_FILE" "$LOCAL_REPO/index.html"

echo "→ Staging changes..."
git add -A

echo "→ Committing..."
git diff --cached --quiet && echo "  (no changes to commit)" && read -p "Press Enter to close..." _ && exit 0
git commit -m "Health Hub update - $(date '+%Y-%m-%d %H:%M')"

echo "→ Pulling remote changes..."
git pull origin main --rebase
if [ $? -ne 0 ]; then
  echo "❌ Merge conflict — run 'git rebase --abort' and try again"
  read -p "Press Enter to close..." _
  exit 1
fi

echo "→ Pushing..."
git push origin main

if [ $? -eq 0 ]; then
  echo ""
  echo "✓ Live at https://ellespy.github.io/health-hub/"
else
  echo ""
  echo "❌ Push failed — see error above"
fi

echo ""
read -p "Press Enter to close..." _
