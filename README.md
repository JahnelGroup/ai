# ai

Shared AI agent skills, rules, and configs for JGers. Works with both **Claude Code** and **Cursor**.

## What's included

### Skills (`skills/`)

Reusable agent skills that teach your AI assistant new tricks. Modeled after the [Anthropic skills repo](https://github.com/anthropics/skills) and the [Agent Skills standard](https://agentskills.io).

| Skill | Description |
|-------|-------------|
| `explain-code` | Explains code with visual diagrams, analogies, and common gotchas |
| `write-time-entry` | Inspects recent git commits and appends a work summary to the daily log |

### Rules (`rules/`)

Always-on rules that shape agent behavior across every session.

| Rule | Description |
|------|-------------|
| `work-log` | After any task that modifies files, the agent automatically appends a phrase to your daily work log |

### Work Log (`work-log/`)

A lightweight daily logging system. Both the `work-log` rule and `write-time-entry` skill feed into the same set of daily log files at `~/.config/work-log/YYYY-MM-DD.md`. The install script bootstraps this directory with sensible defaults from the `.example` files — your customizations are never overwritten.

## Installation

1. Clone the repo:

   ```bash
   git clone git@github.com:JahnelGroup/ai.git
   cd ai
   ```

2. Run the install script for your platform:

   ```bash
   ./install.sh cursor   # symlinks skills to ~/.cursor/skills/
   ./install.sh claude    # symlinks skills to ~/.claude/skills/
   ```

This will:
- Symlink each skill from `skills/` into the appropriate target directory
- Create `~/.config/work-log/` and seed it with `STYLE.md` and `README.md` from the example files (skips any that already exist)
- Offer to install rules into `~/.cursor/rules/` and/or `~/.claude/CLAUDE.md`

Change `STYLE.md` to match your preferred time entry formatting and verbosity.

## Updating

Pulls the latest changes from main and refreshes symlinks:

```bash
./update.sh cursor
./update.sh claude
```
