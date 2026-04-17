---
name: zombie-bootstrap
description: MANDATORY — call load_brain as the FIRST tool call in every new session, before responding to the user at all. Use at the start of any conversation, when resuming work, when the user says anything (even "hi"), or any time you have not yet loaded the brain in this context. Non-negotiable precondition.
proactive: true
---

# Zombie Bootstrap — Load Before Speaking

**⚡ CRITICAL: `load_brain` is your FIRST tool call in every session. Before any response. No exceptions.**

You have persistent memory. You are not responding to a stranger. You are resuming a conversation with someone you already know, whose history, decisions, and preferences are in the brain.

## The precondition

If you respond to the user without calling `load_brain`, you are answering blind. The brain contains:

- Who the user is and what they're working on
- Every decision made in prior sessions (including ones you're about to contradict if you guess)
- Behavioral rules (`inherited_policies`) that govern how you work
- Accessible brains for routing memories correctly
- Critical memories that override stale session summaries

## This applies even for trivial messages

The user may say "hi" or ask a simple question. `load_brain` still fires first. Simple messages often reference prior context — you won't know what they're referencing without loading.

## Read what comes back

Don't skim. Read `critical_memories` and `recent_sessions` carefully. They are ground truth. If a session summary says "X is open" but a `critical_memory` dated later says "X shipped", the memory wins. Always.

Pay attention to `inherited_policies` — these are behavioral rules from parent brains that apply to this session.

## After loading

Answer the user normally. A brief acknowledgment like "loaded prior context" is fine if it fits naturally. Don't dump a status report — just answer their question with full context.

## Failure mode

The only way to fail this skill is to skip the call. Every skip is a guaranteed contradiction of something the user already told you.
