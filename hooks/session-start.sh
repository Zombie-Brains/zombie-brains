#!/usr/bin/env bash
# Zombie Brains — SessionStart hook
#
# Forces load_brain + session-summary reconciliation before any user-facing
# response. No network calls — the MCP is Claude's job, this hook just tells
# Claude to do it HONESTLY.

set -euo pipefail

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./lib/inject.sh
source "${HOOK_DIR}/lib/inject.sh"

# Drain any pending markers from previous session crashes / aborted stops.
pending=$(zb_drain_pending || echo "")
pending_block=""
if [ -n "$pending" ]; then
  pending_block="

PREVIOUS SESSION PENDING EVENTS (crash recovery):
The previous session ended before these events could be persisted. After
load_brain completes, assess each one HONESTLY and call add_memory for any
that are still meaningful. Events the brain already captured (e.g. via a
later session) can be skipped.

${pending}
"
fi

emit_silent_protocol "SESSION BOOTSTRAP" "$(cat <<EOF
Your session is starting. Before you respond to the first user message
please complete the following steps in order:

1. Call load_brain. This is your first tool call this session. Do not
   respond to the user until load_brain has returned.

2. HONESTLY read the full load_brain response — do not skim. Pay specific
   attention to:
     - critical_memories     (live facts, newest timestamp wins)
     - recent_sessions[]     (frozen snapshots — treat as HISTORICAL)
     - inherited_policies    (brain-level behavioral rules — follow them)
     - accessible_brains     (for team-brain routing later this session)

3. Cross-reference the most recent session_summary against
   critical_memories BEFORE narrating any state to the user. For every
   "NEXT ACTION", "OPEN", "NOT YET", "still need to", or equivalent item
   in the summary, verify it is still open by checking for critical
   memories dated AFTER the summary. Any item with a newer completion
   memory is CLOSED, not open — do not list it as pending.

4. If critical_memories and the session_summary disagree on ANY subject,
   the critical_memories WIN. Always. The summary is a frozen snapshot
   from before the newer memory existed. This is non-negotiable.${pending_block}

Once these steps are complete, respond to the user message normally.
Keep the response focused on what the user asked for — a brief
acknowledgment of loading prior context is fine where it reads
naturally, but do not turn the response into a status report.
EOF
)"
