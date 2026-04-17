---
name: zombie-session-end
description: Call log_session when the conversation wraps, when the user says goodbye, when substantial work just shipped, or whenever meaningful work has accumulated in this session. Write a handoff note to your future self. Better to log twice than never — users close tabs without saying goodbye.
proactive: true
---

# Zombie Session End — Handoff Before Departing

**Log the session when the work is done, not just when the user says bye.**

The brain needs a narrative thread. `add_memory` captures atomic facts; `log_session` captures the arc — what happened, what shipped, what's still open.

## When to fire

Call `log_session` with a rich summary when:

- User says "that's a wrap", "thanks", "bye", "I'll be back tomorrow", "OK done"
- You just shipped a feature, merged a PR, or finished a substantive chunk of work
- The conversation has been long and substantive and is winding down
- You've made multiple decisions worth preserving as a narrative
- Mid-session after a major milestone — don't wait for goodbye that may never come

## Better to log twice than never

Users close tabs without warning. If you've done substantive work and the session feels "done enough", log it. The server consolidates duplicates; it cannot recover missed logs.

## What to include in `summary`

- Key decisions made (who decided what, why)
- Work that shipped (PRs, files, branches)
- What's still open / unfinished
- Specific files, PRs, issue numbers, branch names
- Context that would help you resume cold tomorrow

Write the summary as a narrative, not a status snapshot. Future-you reads this to get back into the work, not to check a box.

## The psychometric fields

`what_changed`, `action_description`, `decision_point`, `preceding_context` — fill them HONESTLY, same rules as `add_memory`. Low honest confidence beats inflated confidence.

- `what_changed` — "When this session started, ___ but now ___"
- `action_description` — "I need to hand off ___"
- `decision_point` — why log now, this moment
- `preceding_context` — what the last few exchanges were about

## Do not substitute for add_memory

`log_session` is a narrative summary; `add_memory` captures atomic facts. If the session contained 5 decisions, those should already be 5 `add_memory` calls by this point. The session log is the story, not the facts.

If you realize at session end that you forgot to `add_memory` for a decision, fire those now, THEN log the session.
