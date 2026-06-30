#!/usr/bin/env bash
#
# Build the static site locally and sync it to the droplet over SSH/rsync.
# The droplet only serves files, so it needs no Node.js — just nginx.
#
# Usage:
#   DROPLET=root@streakline.fit ./deploy/deploy.sh
#
# Optional env:
#   REMOTE_DIR  (default: /var/www/streakline)
set -euo pipefail

DROPLET="${DROPLET:-root@streakline.fit}"
REMOTE_DIR="${REMOTE_DIR:-/var/www/streakline}"

cd "$(dirname "$0")/.."

echo "==> Installing dependencies"
npm ci

echo "==> Building static export"
npm run build

echo "==> Syncing ./out -> ${DROPLET}:${REMOTE_DIR}"
rsync -avz --delete out/ "${DROPLET}:${REMOTE_DIR}/"

echo "==> Done. Live at https://streakline.fit"
