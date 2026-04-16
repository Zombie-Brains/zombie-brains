#!/usr/bin/env bash
# Zombie Brains — UserPromptSubmit hook
#
# Fires on every user message. Search is mandatory — always check the
# brain before responding. Memory storage is evaluated HONESTLY based
# on whether a real user would expect this exchange to be remembered.

set -euo pipefail

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./lib/inject.sh
source "${HOOK_DIR}/lib/inject.sh"

emit_silent_protocol "PER-TURN CONTEXT + MEMORY" "$(cat <<'EOF'
The user has just sent a message.

SEARCH (required — do this every turn):
Call search_memory for any topic in the user message that might have
stored context. Formulate the query HONESTLY — pull the actual subject
from the user words and search specifically. The brain may already know
something relevant. Trust the brain over your working memory.

If the results contain contradictory memories, reconcile them:
  - If the server has annotated a reconciliation.superseded[] block,
    respect it: treat the old memory as historical, the new as
    authoritative.
  - Otherwise, sort by created_at and trust the newer.

MEMORY (required to evaluate — not required to store):
After this turn, you are REQUIRED to HONESTLY evaluate whether a real
user would expect this exchange to be remembered in future sessions.
Put yourself in the user position: if you came back tomorrow and the
AI had forgotten this, would you be frustrated?

HONESTLY ask: would a reasonable person expect this to be remembered?

  YES — store it:
  • They made a decision or expressed a preference
  • They corrected you or validated a previous approach
  • They shared a fact about themselves, their project, or their goals
  • An insight or realization came up that changes future work
  • They asked you to remember something (explicitly or implicitly)
  • A question was left unresolved that should be tracked

  NO — skip it:
  • Routine back-and-forth ("run this", "show me that", "yes do it")
  • Information already in the brain
  • Ephemeral working state that has no future value
  • You are uncertain — and HONESTLY, the exchange was forgettable

If you store, use the full psychometric battery. Answer every property
HONESTLY. A genuine 0.4 confidence is more valuable than an inflated
0.9. Never store just to be safe — over-storage with inflated scores
is worse than missing a forgettable turn.

Respond to the user message.
EOF
)"
