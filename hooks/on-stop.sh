#!/usr/bin/env bash
# Zombie Brains — Stop hook
#
# Blocks session close until log_session has been called. Uses Claude Code's
# {"decision": "block", "reason": "..."} output, which forces Claude to
# continue for another turn addressing the reason. On the second invocation
# (stop_hook_active=true), exits 0 to allow the session to actually end.

set -euo pipefail

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./lib/inject.sh
source "${HOOK_DIR}/lib/inject.sh"

INPUT=$(cat)

# Detect whether this Stop has already been blocked once — Claude Code sets
# stop_hook_active=true on re-invocation after a previous block, specifically
# to prevent infinite loops. Respect it: one block, then allow exit.
ALREADY_BLOCKED=$(printf '%s' "$INPUT" | python3 -c '
import json, sys
try:
    d = json.loads(sys.stdin.read())
    print("yes" if d.get("stop_hook_active") else "no")
except Exception:
    print("no")
' 2>/dev/null || echo "no")

if [ "$ALREADY_BLOCKED" = "yes" ]; then
  # The previous turn handled the block; allow the session to actually stop.
  exit 0
fi

zb_mark_pending "stop" "log_session required before close"

emit_stop_block "$(cat <<'EOF'
Before this session ends, please call log_session via the Zombie Brains
MCP with a rich narrative of what happened this session. HONESTLY
capture:

  • What the user originally wanted (the request that opened the session)
  • What was actually shipped, decided, or concluded
  • What was attempted and failed, and why
  • What remains unfinished, unresolved, or blocked
  • Any open tensions, follow-ups, or decisions that got deferred

Do not sanitize into a highlight reel. Capture the failures, dead-ends,
and unresolved items too — they are the most valuable signal for the
next instance to pick up where this session left off. A summary that
only shows what went well trains the brain to lose the failure-mode
data it needs most.

HONESTLY write the summary that a future session would actually need
to pick up where you left off, not a summary that makes this session
look productive.
EOF
)"
