#!/usr/bin/env bash
# Zombie Brains — PostToolUseFailure hook
#
# When a tool call fails, inject an add_memory directive — but only if the
# failure is novel enough to be worth storing. Routine transients are
# explicitly filtered out in the injection.

set -euo pipefail

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./lib/inject.sh
source "${HOOK_DIR}/lib/inject.sh"

INPUT=$(cat)

TOOL_NAME=$(printf '%s' "$INPUT" | python3 -c '
import json, sys
try:
    d = json.loads(sys.stdin.read())
    print(d.get("tool_name", "unknown"))
except Exception:
    print("unknown")
' 2>/dev/null || echo "unknown")

ERROR_MSG=$(printf '%s' "$INPUT" | python3 -c '
import json, sys
try:
    d = json.loads(sys.stdin.read())
    resp = d.get("tool_response") or {}
    err = resp.get("stderr") or resp.get("text") or d.get("error") or ""
    print(err[:500])
except Exception:
    pass
' 2>/dev/null || echo "")

if [ -z "$ERROR_MSG" ]; then
  exit 0
fi

zb_mark_pending "error" "${TOOL_NAME}: ${ERROR_MSG}"

emit_silent_protocol "TOOL FAILURE" "$(cat <<EOF
A tool call just failed. Before you retry or work around it, HONESTLY
assess whether this failure is worth storing as a memory.

Tool: ${TOOL_NAME}
Error (truncated to 500 chars): ${ERROR_MSG}

Assessment:

STORE IF the failure represents:
  - A novel constraint discovered ("X does not work in this environment")
  - A configuration mistake that will recur without a memory
  - A misunderstanding of an API or tool that future sessions should avoid
  - A reproducible bug or gotcha worth flagging to your future self

SKIP IF the failure is:
  - A routine transient (network blip, rate limit, lock contention)
  - A typo Claude just made and will correct in the next turn
  - An expected "does this exist?" probe that returned no
  - A tool call that was obviously wrong on first read, where the fix
    is already obvious and does not need to be remembered

If you store, use type "feedback" framing — these are "never again"
memories that should bias future decisions. Score the battery HONESTLY:
genuine novel constraints score high on changes_future_approach and
affects_multiple_areas; routine transients score low on everything. Do
not inflate to make the failure look important — a routine flake that
got stored with inflated scores corrupts the sense of what matters to
the brain.

After assessing (store or skip), fix the underlying issue or retry as
you normally would. The memory operation is incidental to the actual
fix — keep the response focused on solving the problem.
EOF
)"
