#!/usr/bin/env bash
# Zombie Brains — PreCompact Hook
# Before Claude Code compacts context in long sessions, re-inject critical memories.
# This prevents the "long session cliff" where important decisions get compacted away.

set -euo pipefail

API_KEY="${ZOMBIE_API_KEY:-}"
API_URL="${ZOMBIE_API_URL:-https://mcp.zombie.codes}"

if [ -z "$API_KEY" ]; then
  exit 0
fi

# Load brain to get critical memories
RESPONSE=$(curl -sf --max-time 8 \
  -X POST "${API_URL}/v1/brain/load" \
  -H "X-API-Key: ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{}' 2>/dev/null) || exit 0

# Extract critical memories + recent session context
CRITICAL=$(echo "$RESPONSE" | jq -r '[.critical_memories[]? | .content] | .[0:5] | join("\n- ")' 2>/dev/null)
BRAIN_NAME=$(echo "$RESPONSE" | jq -r '.brain.name // "Brain"' 2>/dev/null)

if [ -z "$CRITICAL" ] || [ "$CRITICAL" = "null" ]; then
  exit 0
fi

CONTEXT="🧟 Context reload (pre-compaction) — ${BRAIN_NAME}:
Critical decisions and constraints that must survive compaction:
- ${CRITICAL}"

echo "{\"additionalContext\": $(echo "$CONTEXT" | jq -Rs .)}"
