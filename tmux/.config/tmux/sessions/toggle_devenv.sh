#!/usr/bin/env bash
set -euo pipefail

# Stop brew services (avoid port conflicts)
brew services stop postgresql || true
brew services stop redis || true

# Start devenv stack
cd /Users/nathan.wynn/Workspace/prizepicks-devenv
docker compose up -d

tmux display-message "Devenv stack active: docker compose up, brew services stopped"