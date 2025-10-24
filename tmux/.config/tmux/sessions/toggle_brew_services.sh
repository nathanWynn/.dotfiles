#!/usr/bin/env bash
set -euo pipefail

# Stop devenv stack (avoid port conflicts)
( cd /Users/nathan.wynn/Workspace/prizepicks-devenv && docker compose down --remove-orphans >/dev/null 2>&1 || true )

# Start brew services needed for polls
brew services start postgresql || true
brew services start redis || true

tmux display-message "Polls stack active: brew services up, devenv down"