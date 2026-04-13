# Zombie Brains — Deterministic Memory Hooks

**Your AI coding agent forgets everything between sessions. These hooks fix that — deterministically.**

One set of hook scripts. Three platform configs. Every commit, every error, every decision — stored automatically without relying on the AI to remember.

## Supported Platforms

| Platform | Config File | Status |
|----------|------------|--------|
| **Claude Code** | `.claude/settings.json` | ✅ Full support (12+ events) |
| **OpenAI Codex** | `.codex/hooks.json` | ✅ Supported (PostToolUse: Bash only) |
| **Cursor** | `.cursor/hooks.json` | ✅ Supported (15+ events) |

## What the Hooks Do

| Hook | Trigger | What happens |
|------|---------|-------------|
| **Session Start** | Session opens | Auto-loads your brain, injects context — Claude/Codex/Cursor starts briefed |
| **On Commit** | `git commit` | Stores commit message + changed files as a memory |
| **On Edit** | File write/edit | Searches brain for context about the file, injects silently |
| **On Error** | Tool failure | Stores errors as critical "never again" memories |
| **On Stop** | Agent finishes | Logs session summary with git activity (async) |
| **Pre-Compact** | Before compaction | Re-injects critical memories so they survive long sessions |

## Install

### 1. Get your Zombie Brains API key

Sign up at [zombie.codes](https://zombie.codes) and get your API key.

### 2. Set your API key

```bash
# Add to ~/.bashrc, ~/.zshrc, or ~/.config/fish/config.fish
export ZOMBIE_API_KEY="your-api-key-here"
```

### 3. Copy to your project

```bash
git clone https://github.com/Zombie-Brains/zombie-brains.git /tmp/zombie-brains

# Copy the shared hook scripts
cp -r /tmp/zombie-brains/hooks your-project/hooks

# Then copy YOUR platform's config:

# Claude Code
cp -r /tmp/zombie-brains/.claude your-project/.claude

# OpenAI Codex
cp -r /tmp/zombie-brains/.codex your-project/.codex

# Cursor
cp -r /tmp/zombie-brains/.cursor your-project/.cursor
```

### 4. Or install globally

```bash
# Claude Code (all projects)
cp -r /tmp/zombie-brains/hooks ~/.claude/hooks
cp /tmp/zombie-brains/.claude/settings.json ~/.claude/settings.json

# Codex (all projects)
cp -r /tmp/zombie-brains/hooks ~/.codex/hooks
cp /tmp/zombie-brains/.codex/hooks.json ~/.codex/hooks.json

# Cursor (all projects)
cp -r /tmp/zombie-brains/hooks ~/.cursor/hooks
cp /tmp/zombie-brains/.cursor/hooks.json ~/.cursor/hooks.json
```

## Requirements

- `curl` and `jq` (pre-installed on macOS; `apt install jq` on Linux)
- A [Zombie Brains](https://zombie.codes) account with an API key
- Any supported AI coding agent

## How It Works

**The AI doesn't decide to remember — the hooks guarantee it.**

```
Agent event fires (commit, edit, error, session start/end)
  → Hook script reads event JSON from stdin
  → Extracts relevant data (commit msg, file path, error)
  → Calls Zombie REST API via curl
  → Returns additionalContext (injected into agent's context)
```

All three platforms use the same pattern: JSON on stdin → bash script → JSON on stdout. The shared `hooks/` scripts work identically across Claude Code, Codex, and Cursor.

## Also Included

### SKILL.md

The behavioral guide that teaches your AI agent the Zombie Brains core loop:

1. **Load Brain** — always first
2. **Search Memory** — before making decisions
3. **Add Memory** — store decisions reflexively
4. **Log Session** — capture handoff notes

Install as a skill:
```bash
# Claude Code
mkdir -p ~/.claude/skills/zombie-brains
cp SKILL.md ~/.claude/skills/zombie-brains/SKILL.md

# Codex
mkdir -p ~/.codex/skills/zombie-brains
cp SKILL.md ~/.codex/skills/zombie-brains/SKILL.md
```

## Customization

- **Disable a hook:** Remove it from your platform's config file
- **Custom API URL:** `export ZOMBIE_API_URL="https://your-instance.com"`
- **Add test hooks:** Add a PostToolUse matcher for `npm test|pytest|jest`

## Links

- [Zombie Brains](https://zombie.codes) — The Cognitive OS for AI
- [Documentation](https://mcp.zombie.codes/docs)
- [MCP Connector](https://mcp.zombie.codes) — Connect via Claude.ai

---

*Context that won't stay dead.* 🧟
