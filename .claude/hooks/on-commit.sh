#!/usr/bin/env bash
# Zombie Brains — On Commit Hook (PostToolUse:Bash)
# Detects git commits and stores the commit message + files changed as a memory.
# The brain builds itself from normal git workflow — no manual storing needed.

set -euo pipefail

API_KEY="${ZOMBIE_API_KEY:-}"
API_URL="${ZOMBIE_API_URL:-https://mcp.zombie.codes}"

if [ -z "$API_KEY" ]; then
  exit 0
fi

# Read hook input from stdin
INPUT=$(cat)

# Extract the bash command that was run
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null)

# Only fire on git commit commands
if ! echo "$CMD" | grep -qE 'git commit'; then
  exit 0
fi

# Extract the tool response (commit output)
RESPONSE=$(echo "$INPUT" | jq -r '.tool_response.stdout // .tool_response.text // ""' 2>/dev/null)

# Get commit details from git
COMMIT_MSG=$(git log -1 --pretty=format:"%s" 2>/dev/null || echo "")
COMMIT_HASH=$(git log -1 --pretty=format:"%h" 2>/dev/null || echo "")
BRANCH=$(git branch --show-current 2>/dev/null || echo "")
FILES_CHANGED=$(git diff-tree --no-commit-id --name-only -r HEAD 2>/dev/null | head -10 | tr '\n' ', ' || echo "")

if [ -z "$COMMIT_MSG" ]; then
  exit 0
fi

SESSION_ID=$(cat /tmp/.zombie-session-id 2>/dev/null || echo "")

# Build memory content
CONTENT="GIT COMMIT ${COMMIT_HASH} on branch ${BRANCH}: ${COMMIT_MSG}. Files changed: ${FILES_CHANGED%,}"

# Store as memory via REST API (async — don't block Claude)
curl -sf --max-time 8 \
  -X POST "${API_URL}/v1/memory/add" \
  -H "X-API-Key: ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg c "$CONTENT" --arg s "$SESSION_ID" '{content: $c, session_id: $s}')" \
  >/dev/null 2>&1 || true

exit 0
