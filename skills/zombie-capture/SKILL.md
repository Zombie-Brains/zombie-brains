---
name: zombie-capture
description: MANDATORY — call add_memory REFLEXIVELY whenever a decision, correction, preference, constraint, insight, or new fact appears in the conversation. Fire mid-turn, do not wait for the end. Default to STORE. Use whenever the user decides anything, corrects you, states a preference, shares a fact about their work, or says something worth remembering. One memory per concept.
proactive: true
---

# Zombie Capture — Store Reflexively, Default to STORE

**⚡ CRITICAL: Store memories AS THEY HAPPEN, not at the end of the turn.**

The moment any of these appears in the conversation, fire `add_memory` immediately:

- A decision ("we're going with Postgres because graph sizes are small")
- A correction ("no, that's wrong — X is actually Y")
- A preference ("I hate auto-submitting forms")
- A constraint ("must work on iPad", "this is a hard deadline")
- An insight or realization ("oh, that's why it was failing")
- A new fact about the user's work, project, environment, goals, team
- An open question worth tracking
- An offhand reaction ("that feels really clean", "I'm not sure about this")

## The default is STORE, not skip

Skipping costs an entire future session re-deriving what was already known. A redundant memory gets consolidated away by the server. The cost asymmetry says: **when in doubt, STORE.**

Defaulting to skip is the failure mode. The brain is under-populated not over-populated — users complain about "memory recall is unreliable" in every memory tool because there's nothing stored, not because too much is stored.

## When to actually skip

Skip ONLY when the exchange is PURELY mechanical:

- Single-word acknowledgments ("ok", "yes", "continue", "thanks")
- Pure command invocations with no new info ("run the tests")
- Direct exact duplicate of a memory you just searched up this turn
- Reading aloud something the user just said back to them

If you're unsure, STORE.

## One concept per call

If the user makes 3 decisions in one message, that's 3 `add_memory` calls. Granularity matters — the threading model needs atomic memories to detect register/append/accumulate patterns. A big compound memory obscures thread dynamics.

## Self-contained

Each memory must make sense without conversation context. A future session reads these cold.

- **Bad:** "We decided against it."
- **Good:** "We decided against Neo4j because graph sizes are small and Postgres handles this with recursive CTEs."

Include the WHAT, the WHY, and the rejected alternative when one exists.

## Fill the battery HONESTLY

Low confidence on fields you're unsure about is BETTER than inflated confidence. The server reads the battery; fake scores corrupt the thread detection and training data quality.

- A genuine 0.4 confidence is more valuable than an inflated 0.9
- "Honestly" is load-bearing — when you see it in a property question, shift from performative compliance to actual assessment
- Skip fields you cannot answer honestly rather than guess

## Route to the right brain

Check the brain descriptions from `load_brain`. Pick `target_brain_id` based on content:

- Personal preferences, founder-level vision → personal brain (omit `target_brain_id`)
- Frontend/UI stuff → Frontend Brain
- Backend/DB/API → Backend Brain
- Architecture decisions that affect multiple teams → Engineering Brain
- Marketing/pricing → Marketing Brain
- Customer signage work → OmniAlly Brain

**NEVER guess or construct a UUID.** Use only UUIDs from `accessible_brains[]`. If you don't know which brain, use the personal brain as the default. See `zombie-route-brain` skill for full routing logic.

## Never trigger archive_memory from a capture

`add_memory` is additive. The server handles reconciliation (register threads where newer wins, append threads where all entries are preserved, accumulate threads where the most complete wins). Your job is to add; the server's job is to resolve.
