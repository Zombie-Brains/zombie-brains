---
name: zombie-create-agent
description: Guide a novice through creating an agent, brain, tool, or permission set using plain-language questions instead of primitive-level configuration. Use when the user says "build me an agent", "create a brain for X", "set up an assistant", "make a bot that does Y", or any variation where they're describing an outcome rather than wiring primitives.
---

# Zombie Create Agent — Novice Wizard Pattern

When a user wants to create something in Zombie Brains, they almost never think in primitives (brain, tool, variable, permission set). They think in outcomes: "I want an agent that answers customer questions about our product."

**Cardinal rule: never ask novice primitive-level questions.** Ask in plain English. Translate internally. Show the result, not the construction.

## The four primitives (internal model, not user-facing)

Everything in Zombie Brains reduces to:

1. **Brain** — the knowledge container (what it knows)
2. **Agent** — a named persona with an MCP URL (what it's called, how it behaves)
3. **Tool** — serverless JS or MCP relay (what it can do)
4. **Variable** — encrypted secret, scoped org → permission_set → brain → agent (what it needs access to)

Everything else is an attribute of a brain (core knowledge, documents, routes, connectors, members).

## The 5-question pattern

Ask these in order, in plain language, and stop at the first "I don't know":

1. **What should it know?** → becomes core_knowledge + seed_memories in a new brain
2. **How should it behave?** → becomes a skill (behavioral instructions) attached to the agent
3. **What should it do?** → becomes tools (serverless JS or MCP relay)
4. **Who uses it?** → becomes a permission_set (brain_scopes + tool_permissions + variables)
5. **What data flows in?** → becomes connectors (Gmail, webhook, etc.) with routes

Do not ask all five at once. Ask them one at a time, each building on the prior answer.

## The bundled create

After collecting the answers, make ONE `manage(action: 'create_agent', ...)` call that bundles everything:

```
manage({
  action: 'create_agent',
  new_brain: { name, description, routing_rules, parent_brain_id? },
  new_skills: [{ title, content, description }],
  new_tools: [{ name, code, description }] // optional
  new_variables: [{ name, value, scope }], // optional
  permission_set_id: ... // or create inline via create_permission_set first
})
```

One API call. The user sees the finished agent, not the construction.

## When to ask vs. when to decide

- **Ask:** name, purpose, who will use it, what data flows in
- **Decide:** routing rules (derive from description), tool shapes (infer from "what it does"), initial skill content (write it, show it for review)

The user should see the result and say "yes that's right" or "change X". They should not see empty form fields.

## Permission sets are user-created entities

Not presets. Not hard-coded roles. A permission set is a CRUD entity with:
- `tool_permissions: { load_brain: true, add_memory: true, ... }` — per-tool boolean
- `brain_scopes: [{ brain_id, access: 'read'|'write'|'admin' }]` — per-brain access
- `connector_ids: [...]` — which connectors
- `variables: [{ name, value }]` — encrypted variables bundled with the set

If the user says "only let it read, not write" → that's a permission_set with `tool_permissions.add_memory: false`.

## Brain parenting — ask or infer?

Ask if there are multiple existing brains in `accessible_brains[]` that could be parents. Infer if:
- There's only one obvious parent (user's company brain)
- The new brain is a standalone domain (create at top level)
- The user explicitly said "standalone"

Default to top-level if unsure. Brain re-parenting is easy; moving memories between brains is harder.

## What NOT to do

- Don't dump the full primitive schema at the user
- Don't ask "what tools should this agent have" before knowing what it does
- Don't create the brain, then the tools, then the variables as separate sequential calls — bundle them
- Don't invent UUIDs — let `manage` return them
- Don't ask about SSO, audit logs, retention policies, or any admin-level setting unless the user raises them

## Worked example

User: "Build me an agent that answers customer questions about ShowCTRL iPad players."

AI (question 1): "Great. What should it know about? For example: technical docs, pricing, known issues, specific product lines?"

User: "The iPad player specifically — setup, activation, troubleshooting."

AI (question 2): "Got it. How should it behave — friendly/informal, technical/precise, short answers or detailed walkthroughs?"

User: "Technical but warm. Short answers first, offer detail on request."

AI (question 3): "Any specific actions beyond answering questions? For example: creating support tickets, looking up activation codes, pinging a human?"

User: "Just answering for now."

AI (question 4): "Who'll talk to it — end customers, internal support team, or both?"

User: "End customers via email."

AI (question 5): "And the data flow — will I need to watch a Gmail inbox, a webhook, both?"

User: "Gmail inbox for support@."

AI: [one bundled `manage(action: 'create_agent', ...)` call with new_brain, new_skills, connector_id, permission_set]

AI: "Done. Agent 'iPad Support' is live. MCP URL: …. Email coming into support@ will be processed, routed to the iPad Support brain, and responses generated with the technical-but-warm style. Want to test it?"

Five questions. One API call. No primitive talk.
