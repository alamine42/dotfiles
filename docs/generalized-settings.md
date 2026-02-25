# Generalized settings.local.json

## Overview

A permissive-but-safe Claude Code settings file derived from analyzing `settings.local.json` across 14 active projects in `~/Development`.

## Methodology

Analyzed `.claude/settings.local.json` from the 15 most recently edited projects. Commands appearing in 5+ projects were included as "universal". Less common but useful tools (docker, databases, deployment CLIs) were included with wildcard patterns since they're harmless when the tool isn't installed.

### Projects analyzed

ventures, trainscript, theundercut, theriver, schoolr, safetyscore, queuay, qay-web, qay-cli, pushpress_programmer, playdate, personal-site, openclaw_security, lumen (parentbench had no settings file).

## Permission categories

| Category | Commands | Frequency |
|----------|----------|-----------|
| Git operations | add, commit, push, pull, checkout, restore, etc. | 13/14 projects |
| npm/node | install, run, test, audit, npx | 12/14 projects |
| Beads (bd) | All bd subcommands | 10/14 projects |
| Shell utilities | ls, cat, find, grep, tree, echo, curl, jq, etc. | 8+ projects |
| TypeScript | npx tsc | 6/14 projects |
| Docker | docker, docker-compose | 2/14 but safe to allow globally |
| Databases | psql, redis-cli, supabase | 4-6/14 projects |
| Deployment | railway, vercel | 3-4/14 projects |
| GitHub CLI | gh | 3/14 projects |
| Environment vars | export, unset, printenv | Used across projects |
| Web access | WebSearch + common dev domains | 8+ projects |

## Design decisions

- **No MCP tools**: MCP permissions are project-specific (railway, agentation, canva, etc.). Add them per-project.
- **Generic env exports allowed**: `Bash(export:*)` is included. Avoids hardcoding credentials (which was found in qay-cli and flagged as a security risk).
- **No hardcoded URLs/credentials**: Project-specific URLs (staging environments, API endpoints) are excluded.
- **WebFetch limited to dev domains**: Only github.com, stackoverflow, MDN, Next.js, React docs. Add project-specific domains per-project.
- **defaultMode: acceptEdits**: Claude can edit files without asking, but still prompts for other actions.
- **Stop hook**: Plays macOS notification sound when session ends.

## What to add per-project

Things intentionally excluded that you may want in specific projects:
- MCP tool permissions (beads-linear, railway, agentation, etc.)
- Project-specific WebFetch domains
- Specialized CLI tools (eas/expo, pandoc, rsvg-convert, etc.)
- Database connection strings with credentials
- Playwright/testing-specific permissions
- ntfy notification hooks (use the `.claude/settings.local.json` in the dotfiles repo for that)

## File location

The generated file lives at `settings.local.json` in the dotfiles repo root. It is **not** auto-symlinked by `install.sh` — copy or symlink it manually if you want it as your global default:

```bash
ln -sf ~/Development/dotfiles/settings.local.json ~/.claude/settings.local.json
```
