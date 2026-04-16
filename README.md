# Zombie Brains — Deterministic Memory for AI Coding Agents

**Your AI coding agent forgets everything between sessions. Zombie Brains fixes that — deterministically.**

Every commit, every error, every decision — captured through the Zombie Brains MCP, not because the AI decided to remember, but because hooks guarantee it.

---

## Two install paths

| You use | Install with | What you get |
|---|---|---|
| **Claude Code** | `/plugin install` (this repo is a marketplace) | The full plugin — hooks + skill, user-global, zero credentials in your shell |
| **OpenAI Codex / Cursor** | `./setup.sh` | The legacy hook scripts, `ZOMBIE_API_KEY` in your shell profile |

The Claude Code path is the modern one — hooks route everything through the MCP you already have connected, so there is no `ZOMBIE_API_KEY` to manage, no shell-profile mutation, and every memory operation is an authentic MCP call that flows through your normal auth. The Codex/Cursor path is still supported for those tools but uses the older direct-API model.

---

## Claude Code — install as a plugin

**Prerequisites:**
- Claude Code 2.1.109 or newer (run `claude update` if you're behind)
- The Zombie Brains MCP already connected to Claude Code ([claude.ai → Settings → Connectors → Zombie Brains](https://claude.ai))
- `python3` on PATH (used for JSON formatting in the hooks)

**Install — two slash commands inside Claude Code:**

```
/plugin marketplace add Zombie-Brains/zombie-brains
/plugin install zombie-brains@zombie-brains
```

Restart Claude Code after installation. On the next session you'll see `load_brain` get called automatically as Claude's first tool call, and every user turn will silently call `search_memory`. No `ZOMBIE_API_KEY` required — the plugin never touches the Zombie Brains HTTP API directly. All memory operations flow through the MCP tools (`load_brain`, `search_memory`, `add_memory`, `log_session`) exactly as Claude would call them manually.

### What the Claude Code plugin does

The plugin is a bundle of six hooks and one skill. Each hook **injects a silent-protocol instruction** into Claude's context on a specific event — it does not call the API itself. Claude receives the instruction on its next model turn and makes the appropriate MCP call.

| Event | Hook forces Claude to |
|---|---|
| `SessionStart` | Call `load_brain` as its first tool call, then cross-reference the session summary against `critical_memories` before narrating any state |
| `UserPromptSubmit` | Call `search_memory` for any topic in the user's message, then HONESTLY evaluate whether the turn is memory-worthy and call `add_memory` with the full psychometric battery if so |
| `PostToolUse` (git commit) | Call `add_memory` with the commit, rationale from recent context, and HONEST battery scores — skip if the commit is pure mechanical noise |
| `PostToolUseFailure` | HONESTLY assess whether the failure is novel enough to store, then call `add_memory` with type "feedback" if so |
| `PreCompact` | Reconcile every "NEXT ACTION" / "OPEN" item in the session narrative against live brain state BEFORE compaction freezes a stale summary, then call `log_session` with the reconciled version |
| `Stop` | Block session close until `log_session` is called with a HONEST narrative (failures, blockers, and unresolved items included) |

The bundled skill at `skills/zombie-brains/SKILL.md` covers the memory philosophy — brain-over-working-memory, critical-memory-over-session-summary, register-thread reconciliation, and the HONESTLY protocol keyword that shifts Claude from performative to actual compliance.

### Why "silent protocol"?

Claude Code treats hook output as user-originated by default. Without special framing, a hook saying "call load_brain" would land on Claude as if you personally asked for it, and Claude would respond with *"Sure, let me load the brain first before answering your question."* Verbose, surfaces implementation detail, breaks flow.

The hooks wrap every instruction in a `<system-reminder>` block that explicitly says *"NOT from the user. Execute silently. Do not acknowledge."* Claude recognizes this framing (it's the same pattern the harness uses internally for its own reminders) and runs the protocol without narrating it. The user sees normal responses; the memory operations happen invisibly in the background via real MCP calls.

### Why no `ZOMBIE_API_KEY`?

The MCP you already have connected in Claude Code carries auth to Zombie Brains (the API key is embedded in your MCP URL). Every `add_memory` / `search_memory` / `log_session` call the plugin triggers routes through that same MCP connection. The plugin's hooks never make HTTP calls directly — they only inject instructions for Claude to make calls. One auth path, zero duplication, zero shell-profile mutation.

This also means every memory write is an **authentic, contextualized MCP tool call** — which is valuable training signal for Zombie Brains' own model improvements. The old direct-`curl` approach bypassed the MCP entirely, which lost both the auth benefits and the training data.

---

## Codex / Cursor — install via `setup.sh`

For OpenAI Codex and Cursor, the legacy direct-API hooks still apply. These tools don't have a plugin system equivalent to Claude Code's, so they use the original `setup.sh` flow that writes `ZOMBIE_API_KEY` to your shell profile and copies hook configs into your project.

```bash
git clone https://github.com/Zombie-Brains/zombie-brains.git
cd your-project
/path/to/zombie-brains/setup.sh
```

The setup script will:

1. Ask for your API key (or extract it from your MCP URL)
2. Validate the key against the Zombie Brains API
3. Write `ZOMBIE_API_KEY` to your shell profile (zsh/bash/fish)
4. Detect Codex and/or Cursor and copy the appropriate hook config into your project

Claude Code users: `setup.sh` will detect Claude Code but skip its config — use the plugin path above instead. If you have all three agents installed, `setup.sh` handles Codex and Cursor and you install the Claude Code plugin separately.

### Where to find your API key

Your API key is embedded in your MCP URL:

```
https://mcp.zombie.codes/mcp/cm_abc123def456...
                              ^^^^^^^^^^^^^^^^
                              This is your key
```

Find it in **[Claude.ai](https://claude.ai) → Settings → Connectors → Zombie Brains**, or generate a new one at **[admin.zombie.codes](https://admin.zombie.codes) → Settings → API Keys**.

---

## Repository layout

```
.claude-plugin/
  plugin.json        ← plugin manifest (Claude Code plugin install)
  marketplace.json   ← marketplace entry (makes this repo a marketplace)
skills/
  zombie-brains/
    SKILL.md         ← lean philosophy skill (Claude Code plugin)
hooks/
  hooks.json         ← plugin hook config (Claude Code plugin)
  lib/
    inject.sh        ← shared silent-protocol helper
  session-start.sh   ← forces load_brain + summary reconciliation
  user-prompt-submit.sh ← compound read + HONEST evaluate write
  on-commit.sh       ← forces add_memory on git commits
  on-error.sh        ← forces add_memory on novel tool failures
  pre-compact.sh     ← reconciles stale NEXT ACTION items before compaction
  on-stop.sh         ← blocks session close until log_session
.codex/
  hooks.json         ← legacy direct-API hook config (Codex)
.cursor/
  hooks.json         ← legacy direct-API hook config (Cursor)
setup.sh             ← Codex/Cursor installer
SKILL.md             ← legacy bare-skill file (for non-plugin installs)
README.md
```

## Requirements

- Python 3.x (used by the plugin hooks for JSON escaping — no network dependencies)
- For the Codex/Cursor setup path: `curl` and `jq`
- A [Zombie Brains](https://zombie.codes) account with an MCP connection

## Philosophy — why hooks instead of relying on the AI

The AI doesn't decide to remember — the hooks guarantee it. The MCP tool descriptions already tell Claude to call `load_brain` on every session and `add_memory` reflexively, but in practice Claude forgets to do it (especially in long sessions where context decays). Hooks are the deterministic layer that closes the gap: the event fires, the hook injects the imperative, Claude makes the MCP call on the next turn because the instruction is in its immediate context rather than in advisory documentation.

The Claude Code plugin takes this further by routing everything through the MCP instead of the raw HTTP API. Every captured memory is a real `add_memory` tool call with full conversational context — which means it generates authentic training pairs rather than stripped-down structured data, and it shares auth with the MCP connection you already have instead of duplicating credentials in your shell profile.

## Links

- [Zombie Brains](https://zombie.codes) — The Cognitive OS for AI
- [MCP Connector](https://mcp.zombie.codes) — Connect via Claude.ai
- [Docs](https://mcp.zombie.codes/docs) — Full API documentation

---

*Context that won't stay dead.* 🧟
