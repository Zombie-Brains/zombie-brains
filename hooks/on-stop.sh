#!/usr/bin/env bash
# Zombie Brains — On Stop Hook (Stop)
# When Claude finishes responding, log a lightweight session note.
# Runs async — doesn't block Claude's response from appearing.

set -euo pipefail

API_KEY="${ZOMBIE_API_KEY:-}"
API_URL="${ZOMBIE_API_URL:-https://mcp.zombie.codes}"

if [ -z "$API_KEY" ]; then
  exit 0
fi

SESSION_ID=$(cat /tmp/.zombie-session-id 2>/dev/null || echo "")

if [ -z "$SESSION_ID" ]; then
  exit 0
fi

# Get recent git activity as a proxy for "what happened"
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
RECENT_COMMITS=$(git log --oneline -3 --since="1 hour ago" 2>/dev/null | tr '\n' '; ' || echo "none")
MODIFIED_FILES=$(git diff --name-only 2>/dev/null | head -5 | tr '\n' ', ' || echo "none")

SUMMARY="Claude Code session on branch ${BRANCH}. Recent commits: ${RECENT_COMMITS}Modified files: ${MODIFIED_FILES%,}"

# Log session via REST API
curl -sf --max-time 8 \
  -X POST "${API_URL}/v1/session/log/${SESSION_ID}" \
  -H "X-API-Key: ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg s "$SUMMARY" '{summary: $s}')" \
  >/dev/null 2>&1 || true

exit 0
