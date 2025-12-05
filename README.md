# Claude Code Setup

Personal configuration for [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) - skills, global instructions, and permission settings.

## What's Included

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Global instructions applied to all projects |
| `skills/` | Personal skills (workflows, expertise patterns) |
| `settings.local.json` | Permission rules for tool approval |

## What's NOT Included

- `settings.json` - Contains MCP server API keys (configure per-machine)
- `.credentials.json` - Auth tokens (machine-specific)
- History, todos, debug logs - Ephemeral data

## Installation

Clone and run the install script:

```bash
git clone git@github.com:WayneKennedy/claude-code-setup.git
cd claude-code-setup
./install.sh
```

This creates symlinks from `~/.claude/` to this repo, so:
- Changes are tracked in git
- Updates are visible across machines after `git pull`
- You'll notice if Claude modifies config without asking

## Skills

| Skill | Purpose |
|-------|---------|
| `deployment-sme` | 16 battle-tested patterns for GitHub Actions, Docker, SSH deployments |
| `implement-feature` | Full workflow for implementing RaaS requirements with quality gates |
| `implement-highest-priority` | Deprecated - use implement-feature instead |
| `infrastructure-agent` | VPS bootstrap and hardening workflow |

## MCP Server Setup

MCP servers contain API keys and must be configured per-machine:

```bash
# Add RaaS MCP server
claude mcp add raas --type http --url https://raas.originate.group/mcp --header "X-API-Key: YOUR_KEY"
```

## License

Apache 2.0 - See [LICENSE](LICENSE)
