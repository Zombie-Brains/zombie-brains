#!/usr/bin/env bash
# Zombie Brains — On Error Hook (PostToolUseFailure)
# When any tool fails, store the error + what was attempted as a critical memory.
# This turns every mistake into institutional knowledge — "never again" memories.

set -euo pipefail

API_KEY="${ZOMBIE_API_KEY:-}"
API_URL="${ZOMBIE_API_URL:-https://mcp.zombie.codes}"

if [ -z "$API_KEY" ]; then
  exit 0
fi

# Read hook input from stdin
INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null)
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input | tostring' 2>/dev/null | head -c 500)
ERROR=$(echo "$INPUT" | jq -r '.tool_response.text // .tool_response.stderr // .error // "unknown error"' 2>/dev/null | head -c 500)

if [ "$ERROR" = "null" ] || [ -z "$ERROR" ]; then
  exit 0
fi

SESSION_ID=$(cat /tmp/.zombie-session-id 2>/dev/null || echo "")

# Build error memory
CONTENT="TOOL FAILURE — ${TOOL_NAME} failed. Attempted: ${TOOL_INPUT}. Error: ${ERROR}"

# Store as critical-salience memory
curl -sf --max-time 8 \
  -X POST "${API_URL}/v1/memory/add" \
  -H "X-API-Key: ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg c "$CONTENT" --arg s "$SESSION_ID" '{content: $c, salience: "critical", session_id: $s}')" \
  >/dev/null 2>&1 || true

exit 0
