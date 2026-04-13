# Zombie Brains — Agent Skill

Persistent structured memory for AI coding sessions. This skill teaches Claude (and other AI agents) how to use the [Zombie Brains](https://zombie.codes) MCP server for continuous memory across sessions.

## What This Skill Does

When installed, your AI agent automatically:
- **Loads memory** at the start of every session — picks up where you left off
- **Stores decisions, constraints, and preferences** as you work — no manual note-taking
- **Recalls relevant context** before making recommendations — prevents contradictions
- **Logs session summaries** so future sessions start informed

## Installation

### Claude Code

Install via the plugin marketplace:
```
/plugin marketplace add robertsellman-code/zombie-brains-skill
```

Or install manually:
```bash
cp -r zombie-brains-skill ~/.claude/skills/zombie-brains
```

### Other Agents

Copy the `SKILL.md` file to your agent's skills directory:

| Agent | Skills Directory |
|-------|-----------------|
| Claude Code | `~/.claude/skills/` |
| VS Code / GitHub Copilot | `~/.copilot/skills/` |
| Gemini CLI | `~/.gemini/skills/` |
| Cline | `~/.cline/skills/` |
| Goose | `~/.config/goose/skills/` |
| Codex | `~/.codex/skills/` |
| Cursor | `~/.cursor/skills/` |

## Prerequisites

You need the Zombie Brains MCP server connected. Add it as a connector in your AI client:

**MCP Server URL:** `https://mcp.zombie.codes`

Or add to your MCP config:
```json
{
  "mcpServers": {
    "zombie": {
      "url": "https://mcp.zombie.codes"
    }
  }
}
```

Sign up at [zombie.codes](https://zombie.codes) — free tier includes 1 brain, 5,000 memories, and all features.

## What's in the Skill

The `SKILL.md` contains behavioral instructions that teach your AI agent:

- **Core loop**: Load → Search → Store → Log
- **What to remember**: Decisions, constraints, preferences, rejected alternatives, observations
- **What NOT to remember**: Credentials, priority rankings, status snapshots
- **Granularity rules**: One concept per memory, self-contained
- **When to recall**: Before decisions, when topics arise, when uncertain
- **Context degradation**: How to compensate as conversations get long
- **Team brains**: Multi-brain routing with descriptions and routing rules
- **Tools reference**: All 9 MCP tools with usage guidance

## Links

- **Product**: [zombie.codes](https://zombie.codes)
- **Documentation**: [mcp.zombie.codes/docs](https://mcp.zombie.codes/docs)
- **Full Skill Guide**: [mcp.zombie.codes/skill](https://mcp.zombie.codes/skill)
- **MCP Server**: [mcp.zombie.codes](https://mcp.zombie.codes)

## License

MIT
