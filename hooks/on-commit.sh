#!/usr/bin/env bash
# Zombie Brains — PostToolUse(Bash) → on-commit
#
# Filters Bash tool calls to git commit commands. When one is detected,
# injects an add_memory directive enriched with commit metadata pulled
# from local git (no network). Claude does the actual MCP write on its
# next model turn.

set -euo pipefail

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./lib/inject.sh
source "${HOOK_DIR}/lib/inject.sh"

# Read hook input (JSON with tool_name, tool_input, tool_response)
INPUT=$(cat)

CMD=$(printf '%s' "$INPUT" | python3 -c '
import json, sys
try:
    d = json.loads(sys.stdin.read())
    print((d.get("tool_input") or {}).get("command", ""))
except Exception:
    pass
' 2>/dev/null || echo "")

# Only fire on git commit commands (ignore git log, git diff, git status, etc.)
case "$CMD" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac

# Gather commit metadata from local git — purely local, no network
COMMIT_HASH=$(git log -1 --pretty=format:"%h" 2>/dev/null || echo "")
COMMIT_MSG=$(git log -1 --pretty=format:"%s" 2>/dev/null || echo "")
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
FILES=$(git diff-tree --no-commit-id --name-only -r HEAD 2>/dev/null | head -10 | tr '\n' ',' | sed 's/,$//' || echo "")

if [ -z "$COMMIT_HASH" ]; then
  # Not a real commit (maybe --amend failed, or commit was aborted).
  exit 0
fi

# Mark pending for crash recovery — if Claude doesn't execute the injection
# this turn (e.g. session is killed), the next SessionStart will pick this up.
zb_mark_pending "commit" "${COMMIT_HASH} ${COMMIT_MSG}"

emit_silent_protocol "COMMIT CAPTURE" "$(cat <<EOF
A git commit was just made. You MUST call add_memory to capture it —
but only with a HONESTLY enriched rationale, not a raw echo of the
commit message.

Commit metadata (verified from local git):
  hash:   ${COMMIT_HASH}
  branch: ${BRANCH}
  msg:    ${COMMIT_MSG}
  files:  ${FILES}

Memory authoring rules:

1. RATIONALE > METADATA. The commit hash and message are metadata; the
   memory is the RATIONALE. Pull a one-to-two-sentence "why" from recent
   conversation context — the decision, bug, or constraint that led to
   this commit. Do not echo the commit message as the memory content.
   A memory that just repeats the commit subject is worthless; the git
   log already has that.

2. HONEST BATTERY SCORES. Most commits are routine — typo fixes, mechanical
   refactors, dependency bumps. These should score LOW on
   changes_future_approach, affects_multiple_areas, and
   rederivable_or_original. Only landmark commits (architecture pivots,
   critical fixes, new systems, first shipment of a feature) score high.
   If this commit is routine, score it routine. Do NOT inflate scores to
   make the memory look important.

3. CONSIDER SKIPPING. If this commit is a pure mechanical change (typo,
   lint fix, version bump, whitespace) with no rationale worth capturing,
   consider skipping add_memory entirely. The git history already records
   the mechanical change. Store only when there is a decision, a
   rationale, or a non-obvious connection to preserve. Missing a routine
   commit is fine; polluting the brain with mechanical noise is not.

Call add_memory now (or skip honestly), then respond to the user normally.
EOF
)"
