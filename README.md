# Zombie Brains — Claude Code Hooks

**Deterministic memory for Claude Code.** These hooks automatically store decisions, recall context, and build your brain — without relying on the AI to remember.

## What it does

| Hook | When | What happens |
|------|------|-------------|
| **Session Start** | Every session | Auto-loads your brain, injects project context |
| **On Commit** | `git commit` | Stores commit message + files changed as a memory |
| **On Edit** | File write/edit | Recalls brain context about the file being changed |
| **On Error** | Tool failure | Stores errors as critical "never again" memories |
| **On Stop** | Claude finishes | Logs session summary with recent git activity |
| **Pre-Compact** | Before compaction | Re-injects critical memories to survive long sessions |

## Install

### 1. Get your API key

Sign up at [zombie.codes](https://zombie.codes) and get your API key from the MCP connector setup.

### 2. Set your API key

```bash
# Add to your shell profile (~/.bashrc, ~/.zshrc, etc.)
export ZOMBIE_API_KEY="your-api-key-here"
```

### 3. Copy hooks to your project

```bash
# Clone this repo
git clone https://github.com/Zombie-Brains/zombie-brains-skill.git /tmp/zombie-hooks

# Copy hooks into your project
cp -r /tmp/zombie-hooks/.claude/hooks your-project/.claude/hooks

# Merge settings into your existing .claude/settings.json
# (or copy if you don't have one)
cp /tmp/zombie-hooks/.claude/settings.json your-project/.claude/settings.json
```

### 4. Install globally (all projects)

```bash
# Copy hooks to global Claude Code config
cp -r /tmp/zombie-hooks/.claude/hooks ~/.claude/hooks

# Merge settings into ~/.claude/settings.json
```

## Requirements

- `curl` and `jq` (pre-installed on macOS, `apt install jq` on Linux)
- A Zombie Brains account with an API key
- Claude Code

## How it works

**The AI doesn't decide to remember — the hooks guarantee it.**

When you `git commit`, the on-commit hook fires deterministically and stores the commit as a memory. When Claude edits a file, the on-edit hook searches your brain for relevant context about that file and injects it silently. When a tool fails, the error is stored as a critical-salience memory that surfaces every time anyone works on that module.

This solves the core UX problem: tool descriptions can *suggest* the AI should store things, but hooks *guarantee* it happens.

### Hook → API Flow

```
Claude Code event fires
  → Hook script reads event JSON from stdin
  → Script extracts relevant data (commit msg, file path, error)
  → Script calls Zombie REST API (POST /v1/memory/add or GET /v1/memory/search)
  → API stores memory or returns relevant context
  → Script returns additionalContext (injected into Claude's context)
```

## Customization

Edit `.claude/settings.json` to:

- **Disable a hook**: Remove it from the settings
- **Change API URL**: Set `ZOMBIE_API_URL` env var (default: `https://mcp.zombie.codes`)
- **Add test hooks**: Add a PostToolUse matcher for Bash that filters `npm test|pytest|jest`

## Also included

### SKILL.md

The behavioral guide that teaches Claude Code the Zombie Brains core loop:
1. Load Brain → always first
2. Search Memory → before making decisions
3. Add Memory → store decisions reflexively
4. Log Session → capture handoff notes

Install as a Claude Code skill:
```bash
cp SKILL.md ~/.claude/skills/zombie-brains/SKILL.md
```

## Links

- [Zombie Brains](https://zombie.codes) — Sign up
- [Documentation](https://mcp.zombie.codes/docs) — Full API docs
- [MCP Connector](https://mcp.zombie.codes) — Connect via Claude.ai

---

*Context that won't stay dead.* 🧟
