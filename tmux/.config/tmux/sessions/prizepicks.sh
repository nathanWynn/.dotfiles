# /Users/nathan.wynn/.config/tmux/sessions/prizepicks.sh
#!/usr/bin/env bash
set -euo pipefail

SESSION="prizepicks"

if tmux has-session -t "$SESSION" 2>/dev/null; then
  if [ -n "${TMUX-}" ]; then
    tmux switch-client -t "$SESSION"
  else
    tmux attach -t "$SESSION"
  fi
  exit 0
fi

tmux new-session -d -s "$SESSION" -n polls -c /Users/nathan.wynn/Workspace/polls
tmux new-window  -t "$SESSION":2 -n prizepicks-rails -c /Users/nathan.wynn/Workspace/prizepicks-rails
tmux new-window  -t "$SESSION":3 -n dev-env -c /Users/nathan.wynn/Workspace/prizepicks-devenv

tmux select-window -t "$SESSION":1

if [ -n "${TMUX-}" ]; then
  tmux switch-client -t "$SESSION"
else
  tmux attach -t "$SESSION"
fi