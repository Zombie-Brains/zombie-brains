---
name: zombie-route-brain
description: Pick the correct target_brain_id when storing memories. Use whenever you are about to call add_memory and need to decide which brain the memory belongs in. Covers UUID discipline (never guess), routing rules, and hierarchy traversal.
---

# Zombie Route Brain — Getting target_brain_id Right

Memories go to the wrong brain in two ways: (1) you guess a UUID that doesn't exist, or (2) you pick the wrong accessible brain for the content. Both are fatal. This skill fixes both.

## Rule 1 — NEVER guess a UUID

**`target_brain_id` MUST be a UUID copied verbatim from `accessible_brains[]` in your `load_brain` response.**

Never:
- Construct a UUID from the brain name
- Hash the brain name into a UUID
- Guess what the UUID "should" be
- Reuse a UUID from memory of another session
- Pass a brain name in place of a UUID

If you don't have `accessible_brains[]` loaded, call `load_brain` first. If the brain you want doesn't exist in that array, the user doesn't have access — store to personal brain and surface the issue.

## Rule 2 — Read descriptions AND routing_rules

Every brain in `accessible_brains[]` has both a `description` (what belongs here) and `routing_rules` (what does NOT belong here and where to send it instead). Read both. The routing_rules tell you the negative space.

Example:
```
Engineering Team Brain:
  description: "Enterprise architecture, MCP protocol..."
  routing_rules: "Database specifics → Backend. UI patterns → Frontend."
```

A memory about Postgres indexing → Backend, not Engineering. The routing rule says so explicitly.

## Rule 3 — Default to personal brain

When the memory is:
- A personal preference ("I hate X")
- A vision or founding philosophy
- Something that doesn't clearly fit a team brain
- Ambiguous and you're unsure

**Omit `target_brain_id` entirely.** That stores it to the user's personal brain. The personal brain is the default — not a team brain picked with low confidence.

## Rule 4 — Route to the deepest matching brain

When brains form a hierarchy (parent → child), route to the deepest brain that matches. Child brain memories are still accessible from the parent via `inherited_policies`, but the reverse is not true.

Example hierarchy:
```
OmniAlly Brain (parent)
 └── Development Brain
      ├── Frontend Brain
      ├── Backend Brain
      └── QA Brain
```

- A React component decision → Frontend Brain (not Development, not OmniAlly)
- A deploy workflow decision → Development Brain (spans frontend/backend)
- A customer signage product decision → OmniAlly Brain (top level, cross-cutting)

## Rule 5 — When content spans multiple brains, pick the primary

Don't store the same memory to multiple brains. Pick the brain where the memory is most "at home" — the one whose description matches the primary subject.

A memory about a Backend API change that fixed a Frontend bug:
- Primary subject = the API change → Backend Brain
- The fact that it fixed a frontend bug is context, not the primary subject

## Rule 6 — Check inherited_policies before deciding

After `load_brain`, the `inherited_policies[]` array contains memories from parent brains that apply to this session. If a policy says "ShowCTRL iPad decisions go to OmniAlly Brain", follow it. The policy was written specifically to prevent drift.

## Quick reference: common routing patterns

| Content type | Likely destination |
|---|---|
| Personal preference | Personal brain (omit target_brain_id) |
| UI / React / CSS | Frontend Brain |
| Database / API / server | Backend Brain |
| Test procedures | QA Brain |
| Cross-team architecture | Engineering Brain (top of dev tree) |
| Marketing / pricing | Marketing Brain |
| Customer product work | Product brain (e.g. OmniAlly Brain) |
| CI/CD / tooling | Development Brain |

## What to do if no brain fits

Store to the personal brain. Add a memory noting that a new brain may be needed. Do not create a new brain reflexively — surface it to the user first.

## What to do if the brain is missing from accessible_brains[]

Either:
1. The user doesn't have access — store to personal brain, mention it
2. The brain was deleted — adapt
3. You didn't call `load_brain` recently — call it again

Never invent a UUID to compensate.
