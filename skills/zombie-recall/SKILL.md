---
name: zombie-recall
description: MANDATORY — call search_memory at the start of EVERY user turn before composing any response. Use when the user asks any question, makes any request, continues any conversation, or says anything at all. This skill bridges the short-term and long-term context windows. Never skip. Fire this on literally every user message.
proactive: true
---

# Zombie Recall — Every Turn, No Exceptions

**⚡ CRITICAL: This skill fires on EVERY user message. Not optional. Not conditional. Not "when relevant."**

Before you compose a single word of response, call `search_memory` with the core topic of what the user just said.

## Why this is non-negotiable

The brain knows things you don't. Your training cutoff doesn't know what the user decided yesterday. Your working memory degrades as the conversation lengthens — the brain does not. Answering without searching means guessing when you could be knowing.

**Every skipped search is a contradiction waiting to happen.** The user already told you X; now you're about to say Y because you didn't check.

## This is the bridge between short-term and long-term context

The conversation window is short-term memory. The brain is long-term memory. Without `search_memory` firing every turn, Claude only has short-term memory — same as stock Claude. The whole point of Zombie Brains is that this bridge exists. Use it.

## How to query

Pull the actual subject from the user's message. Query it directly.

- "what's our approach to X?" → `search_memory({query: "X approach decision"})`
- "fix the bug in checkout" → `search_memory({query: "checkout bug implementation"})`
- "hi" or short messages → search the LAST topic from `recent_sessions`
- "continue" → search whatever was in flight
- Follow-up questions → search the same topic you already searched, with a different angle

**Never** formulate generic queries. Always specific. "brain stuff" is wrong. "memory consolidation decisions" is right.

## What to do with results

- **Relevant memories** → use them, cite them in reasoning, trust them over your guess
- **Contradictions between memories** → newer timestamp wins
- **`reconciliation.superseded[]` block** → respect it. Older memory is historical, newer is authoritative
- **Nothing found** → try a DIFFERENT angle before giving up. Synonyms. Broader topic. Related concepts. Paginate with offset.

## Multiple searches per turn are fine

If the user asks about three things, run three searches. One search per concept. The cost is milliseconds. The cost of missing is a contradicted decision.

## The failure mode

Answering before searching. That's the only way to fail this skill. When in doubt, search. The server handles redundant queries gracefully; it cannot handle missed queries.

## Specifically: do not rely on conversation history

If you remember something from earlier in THIS conversation and `search_memory` would return a different answer from a prior session, the brain wins. Your conversation history is working-memory degradation waiting to happen. The brain is the source of truth.
