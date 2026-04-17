---
name: zombie-threads
description: Understand the three thread types (register, append, accumulate) that the server uses to compile training data and reconcile contradictions. Use when a memory might contradict, supersede, or refine an earlier memory — the thread type affects how to frame the new memory and how to fill the psychometric battery.
---

# Zombie Threads — How the Server Reconciles Evolving Memories

Memories about the same micro-subject form "threads" that evolve over time. The server detects thread type automatically via citation dynamics — you do not classify threads manually. But understanding the model helps you write better memories and fill the battery correctly.

## The three thread types

### 1. Register thread (correction — latest wins)

**Signature:** Memory A cited for weeks → Memory B arrives with high similarity but different content → B starts getting cited → A's citation rate drops to zero.

**Example:** "We use Railway" → "We use Google Cloud."

**Training data treatment:** Compiler uses only the most recent memory. A becomes historical.

**How to write the new memory:**
- State the new value clearly
- Reference the rejected alternative if relevant ("We moved off Railway because…")
- `type_properties.establishes_choice_between_alternatives` → 1.0
- `memory_properties.replaces_or_layers` → 1.0 (replaces a value)

### 2. Append thread (arc/evolution — all entries preserved)

**Signature:** Memory A cited → Memory B about same entity arrives → BOTH continue being cited in their respective contexts. Neither kills the other.

**Example:** "Kael alive" → "Kael wounded at the ice fortress" → "Kael dies."

**Training data treatment:** Compiler uses ALL memories preserving chronological order. The full arc matters.

**How to write the new memory:**
- State the new state of the entity
- Don't try to "update" the old one — the old state was valid at its time
- `type_properties.establishes_choice_between_alternatives` → 0.0 (no choice, evolution)
- `memory_properties.replaces_or_layers` → 0.0 (layers context)

### 3. Accumulate thread (refinement — most complete wins)

**Signature:** Memory A cited → Memory B arrives with very high similarity (>0.90) AND longer/more detailed → B subsumes A → A's citations get absorbed by B.

**Example:** "We use Auth0" → "We use Auth0 with MFA and 24hr token rotation."

**Training data treatment:** Compiler uses the most complete version only.

**How to write the new memory:**
- Include ALL prior detail, not just the new part
- Write as if you're writing the ONE memory that captures everything currently known
- `memory_properties.full_nuance_or_simplified` → 1.0 (full nuance)
- `memory_properties.replaces_or_layers` → 1.0 (replaces, but with superset)

## You don't classify threads — the server does

Thread type is detected automatically from citation patterns over time. You just write good memories and fill the battery honestly. The server analyzes:
- Embedding similarity between memories
- Citation recency and frequency
- Whether one memory absorbs another's citations
- Length trajectory within a cluster

Over weeks of usage, each cluster reveals its thread type without any AI judgment.

## Why this matters for the psychometric battery

The battery fields you fill on `add_memory` feed the server's thread-type detection:

- `settled_or_open` — settled register memories get prioritized
- `replaces_or_layers` — replaces = register/accumulate, layers = append
- `changes_future_approach` — high = likely register correction
- `full_nuance_or_simplified` — full nuance = likely accumulate subsumer
- `alternatives_open` — open = not yet settled as register

**Honest scores help the server detect the right thread type. Inflated scores corrupt detection.**

## Reconciliation at recall time

When `search_memory` returns multiple memories from the same thread, the response includes a `reconciliation.superseded[]` block:

- Memories in `superseded[]` are historical
- Memories not in `superseded[]` are current
- Trust the newer timestamps

Never cite a superseded memory as current truth. Reference it only when explaining history.

## Practical implications

- When correcting a prior decision, write a new memory — don't ask to "update" the old one
- When a character/entity evolves, write the new state — don't try to overwrite
- When refining a known thing, include everything you know (the full picture subsumes the partial)
- The brain heals itself through citation dynamics — your job is to add, not to reconcile

## You never delete

There is no "update memory" or "delete memory" in the normal flow. Only `add_memory`. The server decides what's current via thread dynamics. This preserves training data integrity (you cannot erase training history) and matches how human memory actually works (new memories displace old ones through use, not deletion).
