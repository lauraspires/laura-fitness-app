#!/bin/bash
# Health Hub — push working copy to GitHub
# Tries (in order): gh CLI → HTTPS → SSH. First one that works wins.
# Always pushes to the `main` branch (the GitHub default for this repo).

cd "$(dirname "$0")"
set +e

REPO_OWNER="ellespy"
REPO_NAME="health-hub"
HTTPS_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}.git"
SSH_URL="git@github.com:${REPO_OWNER}/${REPO_NAME}.git"
COMMIT_MSG="Health Hub update - $(date '+%Y-%m-%d %H:%M')"

echo "→ Health Hub: pushing latest changes to GitHub..."

# Source common shell profiles so ssh-agent / gh / brew paths are available
[ -f ~/.zshrc ] && . ~/.zshrc 2>/dev/null
[ -f ~/.bash_profile ] && . ~/.bash_profile 2>/dev/null
[ -f ~/.bashrc ] && . ~/.bashrc 2>/dev/null
export PATH="$PATH:/usr/local/bin:/opt/homebrew/bin"

# Clean up any stale lock from a crashed git process
rm -f .git/index.lock

# 1) Stash uncommitted work so we can replay it on top of remote main
TMP=$(mktemp -d)
for f in index.html Laura_Fitness_App.html MEMORY.md CLAUDE.md PUSH_TO_GITHUB.command laura_app_data.json; do
  [ -f "$f" ] && cp -f "$f" "$TMP/"
done

# 2) Make sure we have a working main branch tracking origin/main
echo "→ Aligning local repo with remote main..."

# Try to fetch through whichever auth works
FETCH_OK=0
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  echo "  using GitHub CLI (gh)"
  git remote set-url origin "$HTTPS_URL"
  gh auth setup-git >/dev/null 2>&1
  git fetch origin main 2>&1 && FETCH_OK=1
fi

if [ $FETCH_OK -eq 0 ]; then
  echo "  trying SSH..."
  git remote set-url origin "$SSH_URL"
  git fetch origin main 2>&1 && FETCH_OK=1
fi

if [ $FETCH_OK -eq 0 ]; then
  echo "  trying HTTPS (will prompt for credentials if needed)..."
  git remote set-url origin "$HTTPS_URL"
  git fetch origin main 2>&1 && FETCH_OK=1
fi

if [ $FETCH_OK -eq 0 ]; then
  echo ""
  echo "✗ Could not reach the GitHub remote with any auth method."
  echo "  Diagnostics:"
  echo "  - SSH test:  $(ssh -T -o BatchMode=yes -o StrictHostKeyChecking=no git@github.com 2>&1 | head -1)"
  echo "  - gh auth:   $(command -v gh >/dev/null && gh auth status 2>&1 | head -1 || echo 'gh CLI not installed')"
  echo "  - Remote:    $(git remote get-url origin)"
  echo ""
  echo "  Quickest fix: install GitHub CLI then run 'gh auth login':"
  echo "    brew install gh && gh auth login"
  echo ""
  echo "  Or upload index.html manually at:"
  echo "    https://github.com/${REPO_OWNER}/${REPO_NAME}/upload/main"
  echo ""
  read -p "Press Enter to close..." _
  exit 1
fi

# 3) Reset our local working area to match remote main, then re-apply our edits.
#    First force-drop any uncommitted modifications so the branch switch can't be blocked.
git reset --hard HEAD 2>&1 | tail -3
git checkout -B main origin/main 2>&1 | tail -3
git branch -D master 2>/dev/null

# Re-apply the edited files we copied off to TMP earlier
for f in index.html Laura_Fitness_App.html MEMORY.md CLAUDE.md PUSH_TO_GITHUB.command laura_app_data.json; do
  [ -f "$TMP/$f" ] && cp -f "$TMP/$f" "./$f"
done
rm -rf "$TMP"

# 4) Commit & push
git add -A
git commit -m "$COMMIT_MSG" 2>/dev/null || echo "  (no new changes to commit)"

echo "→ Pushing to origin/main..."
if git push -u origin main 2>&1; then
  echo ""
  echo "✓ Done! Changes will be live at https://ellespy.github.io/health-hub/"
  echo "  (GitHub Pages takes ~30 seconds to redeploy)"
else
  echo ""
  echo "✗ Push failed. Working tree is preserved — try uploading index.html manually at:"
  echo "    https://github.com/${REPO_OWNER}/${REPO_NAME}/upload/main"
fi

sleep 5
