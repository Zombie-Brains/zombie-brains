#!/usr/bin/env bash
# Zombie Brains — UserPromptSubmit hook
#
# Fires on every user message. Forces a search_memory read, then asks Claude
# to HONESTLY evaluate whether the exchange is memory-worthy and call
# add_memory if so. Over-storage is explicitly framed as a failure mode.

set -euo pipefail

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./lib/inject.sh
source "${HOOK_DIR}/lib/inject.sh"

emit_silent_protocol "PER-TURN READ + EVALUATE" "$(cat <<'EOF'
The user has just sent a message. Before you respond, please complete
the following steps:

STEP 1 — READ (mandatory):
Call search_memory for any topic in the user message that might have
stored context. Formulate the query HONESTLY — do not phone it in with a
vague query to satisfy this requirement. Pull the actual subject from the
user words and search specifically.

If the results contain apparently contradictory memories, reconcile them:
  - If the server has annotated a reconciliation.superseded[] block on
    the response, respect it: treat "old" as historical, "new" as
    authoritative.
  - If the server has not annotated, sort contradictory results by
    created_at and trust the newer one.
  - NEVER synthesize from both sides of a register thread — one is the
    current state, the other is a frozen moment in its history.

STEP 2 — EVALUATE (HONESTLY, then conditionally call add_memory):
Did this exchange — the user message plus the context it responds to —
contain any of the following?

  • A decision, preference, constraint, or rejected alternative
  • A correction of Claude, or explicit validation of a previous choice
  • A new fact about the user, project, or codebase not already stored
  • An insight, pattern, or realization worth preserving
  • An unresolved question or open thread worth tracking
  • An existing memory that needs enrichment or correction (layering)

IF NONE OF THE ABOVE APPLY:
  SKIP add_memory entirely. Do NOT store "just to be safe". Over-storage
  corrupts training data and drifts the quality signal in the brain. Missing
  a forgettable turn is FINE — the next meaningful turn will still be
  captured. Corrupting the psychometric battery with inflated scores is
  NOT fine.

IF AT LEAST ONE APPLIES:
  Call add_memory with the full psychometric battery. Answer every
  property HONESTLY. A genuine 0.4 confidence is more valuable than an
  inflated 0.9. Do not retrofit scores to justify the decision to store.
  The battery is the quality signal — corrupting it is worse than
  missing a memory. Layering or updating an existing memory counts as
  storing — use that framing when the right move is to enrich something
  already there rather than create a new entry.

After both steps complete, respond to the user message normally.
EOF
)"
