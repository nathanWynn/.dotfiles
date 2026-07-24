#!/usr/bin/env bash
# Claude Code status line — reads stdin JSON, fetches rate limits, outputs formatted line
# Only contacts api.anthropic.com. Only reads Claude credentials. No dependencies beyond jq+curl.
set -euo pipefail

# ── Colors ──
RESET='\033[0m'
CYAN='\033[38;5;117m'
YELLOW='\033[38;5;222m'
GREEN='\033[38;5;151m'
RED='\033[38;5;210m'
PINK='\033[38;5;177m'
GRAY='\033[90m'

SEP="${GRAY} │ ${RESET}"

# ── Helpers ──

# Join args with separator into a string. Usage: join_parts "${arr[@]}"
join_parts() {
  local out="" first=1
  for part in "$@"; do
    [ "$first" -eq 0 ] && out+="$SEP"
    out+="$part"
    first=0
  done
  printf "%s" "$out"
}

# Color for a percentage: green < 60, yellow 60-79, red 80+
color_for_pct() {
  local pct="$1"
  if [ "$pct" -ge 80 ]; then printf "$RED"
  elif [ "$pct" -ge 60 ]; then printf "$YELLOW"
  else printf "$GREEN"; fi
}

# Pace color based on usage% vs elapsed% of the window
# Green = under pace, yellow = slightly over, red = way over
pace_color() {
  local usage_pct="$1" reset_at="$2" window_secs="$3"
  [ -z "$reset_at" ] || [ "$reset_at" = "null" ] && return

  local reset_epoch now remaining elapsed elapsed_pct delta
  reset_epoch=$(date -d "$reset_at" +%s 2>/dev/null) || return
  now=$(date +%s)
  remaining=$(( reset_epoch - now ))
  [ "$remaining" -lt 0 ] && remaining=0
  elapsed=$(( window_secs - remaining ))
  [ "$elapsed" -lt 0 ] && elapsed=0
  elapsed_pct=$(( elapsed * 100 / window_secs ))
  delta=$(( usage_pct - elapsed_pct ))

  if [ "$delta" -ge 10 ]; then printf "$RED"
  elif [ "$delta" -ge 0 ]; then printf "$YELLOW"
  else printf "$GREEN"; fi
}

# Format seconds-until-reset as human-readable. Usage: format_reset "ISO8601"
format_reset() {
  local reset_at="$1"
  [ -z "$reset_at" ] || [ "$reset_at" = "null" ] && return

  local reset_epoch now diff hours mins
  reset_epoch=$(date -d "$reset_at" +%s 2>/dev/null) || return
  now=$(date +%s)
  diff=$(( reset_epoch - now ))
  if [ "$diff" -le 0 ]; then printf "now"; return; fi

  hours=$(( diff / 3600 ))
  mins=$(( (diff % 3600) / 60 ))
  if [ "$hours" -gt 0 ]; then printf "%dh%dm" "$hours" "$mins"
  else printf "%dm" "$mins"; fi
}

# Format a single rate limit widget. Usage: format_rl "label" "utilization" "resets_at" window_secs
format_rl() {
  local label="$1" util="$2" reset_at="$3" window="$4"
  [ -z "$util" ] && return

  local pct pcolor rcolor reset_str out
  pct=$(printf "%.0f" "$util")
  pcolor=$(color_for_pct "$pct")
  rcolor=$(pace_color "$pct" "$reset_at" "$window")
  reset_str=$(format_reset "$reset_at")

  out="${GRAY}${label}:${RESET} ${pcolor}${pct}%${RESET}"
  [ -n "$reset_str" ] && out+=" ${rcolor}${reset_str}${RESET}"
  printf "%s" "$out"
}

# ── Read stdin JSON ──
STDIN=$(cat)
if [ -z "$STDIN" ]; then
  printf "${YELLOW}⚠️${RESET}"
  exit 0
fi

# ── Parse stdin (single jq call, NUL-delimited for safety) ──
{
  IFS= read -r -d '' MODEL
  IFS= read -r -d '' CTX_SIZE
  IFS= read -r -d '' CTX_INPUT
  IFS= read -r -d '' CTX_CACHE_CREATE
  IFS= read -r -d '' CTX_CACHE_READ
  IFS= read -r -d '' COST
  IFS= read -r -d '' CWD
} < <(echo "$STDIN" | jq -j '
  (.model.display_name // ""),        "\u0000",
  (.context_window.context_window_size // 0),  "\u0000",
  (.context_window.current_usage.input_tokens // 0), "\u0000",
  (.context_window.current_usage.cache_creation_input_tokens // 0), "\u0000",
  (.context_window.current_usage.cache_read_input_tokens // 0), "\u0000",
  (.cost.total_cost_usd // 0),        "\u0000",
  (.workspace.current_dir // ""),      "\u0000"
' 2>/dev/null)

# ── Model ──
model_out=""
[ -n "$MODEL" ] && model_out="${CYAN}${MODEL}${RESET}"

# ── Context ──
ctx_out=""
if [ "$CTX_SIZE" -gt 0 ] 2>/dev/null; then
  CTX_USED=$((CTX_INPUT + CTX_CACHE_CREATE + CTX_CACHE_READ))
  PCT=$((CTX_USED * 100 / CTX_SIZE))
  [ "$PCT" -gt 100 ] && PCT=100
  PCT_COLOR=$(color_for_pct "$PCT")

  # Braille progress bar: ⣿=full ⣦=3/4 ⣤=1/2 ⣀=1/4 ⠀=empty
  UNITS=$((PCT * 40 / 100))
  BAR="${GRAY}[${PCT_COLOR}"
  for ((i=0; i<10; i++)); do
    FILL=$((UNITS - i * 4))
    if   [ "$FILL" -ge 4 ]; then BAR+="⣿"
    elif [ "$FILL" -eq 3 ]; then BAR+="⣦"
    elif [ "$FILL" -eq 2 ]; then BAR+="⣤"
    elif [ "$FILL" -eq 1 ]; then BAR+="${GRAY}⣀"
    else                         BAR+="${GRAY}⠀"
    fi
  done
  BAR+="${GRAY}]${RESET}"

  ctx_out="${BAR} ${PCT_COLOR}${PCT}%${RESET} ${GRAY}($((CTX_USED/1000))K/$((CTX_SIZE/1000))K)${RESET}"
fi

# ── Cost ──
cost_out=""
if [ "$COST" != "0" ] && [ -n "$COST" ]; then
  cost_out="${YELLOW}\$$(printf "%.2f" "$COST")${RESET}"
fi

# ── Rate limits (cached API call) ──
CACHE_DIR="$HOME/.cache/claude-statusline"
CACHE_FILE="$CACHE_DIR/usage.json"
CACHE_TTL=60
WINDOW_5H=18000
WINDOW_7D=604800

fetch_rate_limits() {
  local cred_file="$HOME/.claude/.credentials.json"
  [ ! -f "$cred_file" ] && return 1

  local token
  token=$(jq -r '.claudeAiOauth.accessToken // empty' "$cred_file" 2>/dev/null)
  [ -z "$token" ] && return 1

  # Serve from cache if fresh
  if [ -f "$CACHE_FILE" ]; then
    local age=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0) ))
    if [ "$age" -lt "$CACHE_TTL" ]; then cat "$CACHE_FILE"; return 0; fi
  fi

  # Fetch from API
  mkdir -p "$CACHE_DIR"
  local resp
  resp=$(curl -s --max-time 5 \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token" \
    -H "anthropic-beta: oauth-2025-04-20" \
    "https://api.anthropic.com/api/oauth/usage" 2>/dev/null) || return 1

  if echo "$resp" | jq -e '.five_hour' >/dev/null 2>&1; then
    echo "$resp" > "$CACHE_FILE"
    chmod 600 "$CACHE_FILE"
    echo "$resp"
    return 0
  fi

  # Stale cache fallback
  [ -f "$CACHE_FILE" ] && { cat "$CACHE_FILE"; return 0; }
  return 1
}

rl_5h="" rl_7d="" rl_7ds=""

USAGE=$(fetch_rate_limits 2>/dev/null) || USAGE=""
if [ -n "$USAGE" ]; then
  U5=$(echo "$USAGE" | jq -r '.five_hour.utilization // empty' 2>/dev/null)
  R5=$(echo "$USAGE" | jq -r '.five_hour.resets_at // empty' 2>/dev/null)
  rl_5h=$(format_rl "5h" "$U5" "$R5" "$WINDOW_5H")

  U7=$(echo "$USAGE" | jq -r '.seven_day.utilization // empty' 2>/dev/null)
  R7=$(echo "$USAGE" | jq -r '.seven_day.resets_at // empty' 2>/dev/null)
  rl_7d=$(format_rl "7d" "$U7" "$R7" "$WINDOW_7D")

  US=$(echo "$USAGE" | jq -r '.seven_day_sonnet.utilization // empty' 2>/dev/null)
  RS=$(echo "$USAGE" | jq -r '.seven_day_sonnet.resets_at // empty' 2>/dev/null)
  rl_7ds=$(format_rl "7dS" "$US" "$RS" "$WINDOW_7D")
fi

# ── Folder + Git branch ──
folder_out="" branch_out=""
if [ -n "$CWD" ] && [ -d "$CWD" ]; then
  folder_out="${YELLOW}📁 $(basename "$CWD")${RESET}"
  BRANCH=$(git -C "$CWD" rev-parse --abbrev-ref HEAD 2>/dev/null) || BRANCH=""
  [ -n "$BRANCH" ] && branch_out="${PINK}🌿 ${BRANCH}${RESET}"
fi

# ── Assemble output ──
line1_parts=()
[ -n "$model_out" ] && line1_parts+=("$model_out")
[ -n "$ctx_out" ]   && line1_parts+=("$ctx_out")
[ -n "$cost_out" ]  && line1_parts+=("$cost_out")
[ -n "$rl_5h" ]     && line1_parts+=("$rl_5h")
[ -n "$rl_7d" ]     && line1_parts+=("$rl_7d")
[ -n "$rl_7ds" ]    && line1_parts+=("$rl_7ds")

line2_parts=()
[ -n "$folder_out" ] && line2_parts+=("$folder_out")
[ -n "$branch_out" ] && line2_parts+=("$branch_out")

output=$(join_parts "${line1_parts[@]}")
line2=$(join_parts "${line2_parts[@]}")
[ -n "$line2" ] && output+="\n${line2}"

printf "%b" "$output"
