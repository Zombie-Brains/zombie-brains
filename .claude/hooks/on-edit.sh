#!/usr/bin/env bash
# Zombie Brains — On Edit Hook (PostToolUse:Write|Edit)
# When Claude writes or edits a file, search the brain for context about that file/module.
# Returns additionalContext so Claude silently knows WHY past decisions were made.

set -euo pipefail

API_KEY="${ZOMBIE_API_KEY:-}"
API_URL="${ZOMBIE_API_URL:-https://mcp.zombie.codes}"

if [ -z "$API_KEY" ]; then
  exit 0
fi

# Read hook input from stdin
INPUT=$(cat)

# Extract the file path being edited
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // ""' 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Extract meaningful search terms from the file path
# e.g., "src/auth/oauth.ts" → "auth oauth"
FILENAME=$(basename "$FILE_PATH" 2>/dev/null | sed 's/\.[^.]*$//')
DIRNAME=$(dirname "$FILE_PATH" 2>/dev/null | tr '/' ' ' | sed 's/src //; s/\. //')
QUERY="${DIRNAME} ${FILENAME}"

# Trim and clean
QUERY=$(echo "$QUERY" | xargs | head -c 100)

if [ ${#QUERY} -lt 3 ]; then
  exit 0
fi

# Search brain for relevant context
RESPONSE=$(curl -sf --max-time 6 \
  -G "${API_URL}/v1/memory/search" \
  --data-urlencode "q=${QUERY}" \
  --data-urlencode "limit=5" \
  -H "X-API-Key: ${API_KEY}" \
  2>/dev/null) || exit 0

# Extract memories
MEMORIES=$(echo "$RESPONSE" | jq -r '[.memories[]? | .content] | .[0:3] | join("\n- ")' 2>/dev/null)

if [ -z "$MEMORIES" ] || [ "$MEMORIES" = "null" ] || [ "$MEMORIES" = "" ]; then
  exit 0
fi

# Inject context about this file/module
CONTEXT="🧟 Brain context for ${FILE_PATH}:
- ${MEMORIES}"

echo "{\"additionalContext\": $(echo "$CONTEXT" | jq -Rs .)}"
