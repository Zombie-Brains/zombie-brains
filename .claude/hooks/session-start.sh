#!/usr/bin/env bash
# Zombie Brains — SessionStart Hook
# Loads the brain and injects project context at the start of every Claude Code session.
# This is the hook that makes "session 2 already knows session 1" work deterministically.

set -euo pipefail

API_KEY="${ZOMBIE_API_KEY:-}"
API_URL="${ZOMBIE_API_URL:-https://mcp.zombie.codes}"

if [ -z "$API_KEY" ]; then
  exit 0  # No key configured, skip silently
fi

# Load brain via REST API
RESPONSE=$(curl -sf --max-time 8 \
  -X POST "${API_URL}/v1/brain/load" \
  -H "X-API-Key: ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{}' 2>/dev/null) || exit 0

# Extract key context for injection
BRAIN_NAME=$(echo "$RESPONSE" | jq -r '.brain.name // "Unknown"' 2>/dev/null)
SESSION_ID=$(echo "$RESPONSE" | jq -r '.current_session_id // ""' 2>/dev/null)
RECENT=$(echo "$RESPONSE" | jq -r '[.recent_sessions[]? | select(.summary != null and .summary != "(no summary recorded)") | .summary] | .[0:3] | join("\n---\n")' 2>/dev/null)
CRITICAL=$(echo "$RESPONSE" | jq -r '[.critical_memories[]? | .content] | .[0:5] | join("\n- ")' 2>/dev/null)
BRAINS=$(echo "$RESPONSE" | jq -r '[.accessible_brains[]? | "\(.name) (\(.memory_count) memories)"] | join(", ")' 2>/dev/null)

# Build context injection
CONTEXT="🧟 Zombie Brain loaded: ${BRAIN_NAME}
Session: ${SESSION_ID}
Brains: ${BRAINS}"

if [ -n "$RECENT" ] && [ "$RECENT" != "null" ]; then
  CONTEXT="${CONTEXT}

Recent sessions:
${RECENT}"
fi

if [ -n "$CRITICAL" ] && [ "$CRITICAL" != "null" ]; then
  CONTEXT="${CONTEXT}

Critical context:
- ${CRITICAL}"
fi

# Store session ID for other hooks
echo "$SESSION_ID" > /tmp/.zombie-session-id 2>/dev/null || true

# Return additionalContext to inject into Claude's context
echo "{\"additionalContext\": $(echo "$CONTEXT" | jq -Rs .)}"
