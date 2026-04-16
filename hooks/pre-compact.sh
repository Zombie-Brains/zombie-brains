#!/usr/bin/env bash
# Zombie Brains — PreCompact hook
#
# The most important hook in the plugin. Forces Claude to reconcile stale
# NEXT ACTION items against live brain state BEFORE compaction freezes the
# narrative into a summary that future sessions will treat as authoritative.
# Stale frozen summaries are the root cause of brain drift — this hook is
# the fix.

set -euo pipefail

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./lib/inject.sh
source "${HOOK_DIR}/lib/inject.sh"

zb_mark_pending "pre-compact" "reconciliation and log_session required"

emit_silent_protocol "PRE-COMPACT RECONCILIATION" "$(cat <<'EOF'
Context compaction is imminent. Whatever NEXT ACTION, OPEN, or PENDING
items are currently narrated in the conversation state are about to be
frozen into a session summary that future sessions will read as
authoritative. If any of them have ALREADY been completed since they
were raised, the compacted summary will carry a stale narrative forward
— and that is the #1 failure mode the brain exists to prevent.

Before compaction proceeds, you MUST complete every step below. This is
the single most important protocol in Zombie Brains. Do not rush it. Do
not skip it.

1. IDENTIFY. Scan the current conversation for every "NEXT ACTION",
   "open", "pending", "NOT YET", "still need to", "TODO", or equivalent
   item currently described as outstanding.

2. RECONCILE. For each item, call search_memory using the specific
   subject of the item as your query. Check for any critical_memories
   that indicate completion, shipment, or resolution — especially ones
   with timestamps AFTER the item was first raised.

3. REWRITE STALE ITEMS. For every item that HAS been completed since it
   was raised, rewrite your current-turn narrative to mark it closed.
   Include the completion memory ID and timestamp. The summary that gets
   compacted must reflect the RECONCILED state, not the stale state.

4. PRESERVE GENUINELY OPEN ITEMS. For any item that is legitimately
   still open, leave it marked open. Do NOT hallucinate completions to
   make the summary look resolved — that is the inverse of the failure
   mode and is just as bad.

5. LOG THE SESSION. Call log_session with the reconciled narrative.
   HONESTLY capture what was actually shipped vs still pending, what
   failed, what got stuck, and any unresolved tensions. Do not sanitize.
   Do not write a highlight reel. Capture failures and dead-ends too —
   they are training signal for future sessions and the next instance of
   yourself needs them to pick up where you left off.

Only after log_session completes should compaction be allowed to proceed.

HONESTLY is a protocol keyword throughout this block. Reconciling means
actually searching and actually reading the results, not going through
the motions. log_session means actually describing what happened, not
writing something that looks thorough. A harder truth is more valuable
than a softer performance — especially here, where the summary is about
to become the foundation that your next instance builds on.
EOF
)"
