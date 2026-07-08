# ClaudeCodeSystem Cloud Vault (Not Yet Personalized)

This repository is a **fresh Claude Code System vault** — the cloud edition. It was created from Integral's template and has not been set up yet. Once setup runs, this file is replaced by the owner's personalized instruction manual.

## If you are reading this, setup has not run

Guide the user to type `/onboard` to begin. The setup interview takes about 20 minutes and personalizes everything in place: folder structure, this CLAUDE.md, the commands, and the knowledge graph starters.

If the user says anything like "set me up", "help me get started", or "what is this?", explain in one or two friendly sentences ("This repo becomes your personal assistant's brain — I'll interview you and build it around your work") and start `/onboard` for them.

## Runtime facts (apply even during setup)

1. **This vault is a git repository and git is the storage layer.** In Claude Code on the web, the container is temporary — anything not committed and pushed is lost when the session's environment is reclaimed. Commit and push after every phase that creates or changes files. Work directly on `main` unless the user has told you otherwise.
2. **Detect where you are running.** If the environment variable `CLAUDE_CODE_REMOTE` is `true` (or your system prompt says you are in a managed remote/cloud environment), you are in Claude Code on the web. Otherwise you are in a local CLI session. `/onboard` branches on this.
3. **The container clock is UTC.** Never trust bare `date` for the user's calendar day. Until the user's timezone is configured (a `TZ` environment variable plus a rule in the personalized CLAUDE.md), ask the user what day it is for them if it matters.
4. **Never write secrets into this repository.** No API keys, tokens, or passwords in any file, ever — this repo lives on GitHub. Credentials belong in claude.ai connectors or in the Claude Code environment configuration (environment variables). There is deliberately no `.env` file in this system.

## What ships in this template

- `.claude/commands/` — every skill, ready to use (`/onboard`, `/train`, `/connect`, `/automate`, `/finish`, `/morning`, `/eod` and its phases, `/handoff`, `/pickup`, and more)
- `.claude/settings.json` + `.claude/hooks/session-start.sh` — session bootstrap (dependency install, date/timezone orientation)
- `setup/` — the CLAUDE.md template, methodology doc, and cloud setup guides used by `/onboard` (archived by `/finish` when setup completes)
- `System/state/` and `System/memory/` — durable machine state and memory (committed, unlike `/tmp`)
- `scripts/` — reusable API helpers (credentials come from environment variables)

## For maintainers of the template itself

If this repo is the template (Integral's master copy, not a client vault): commands live only in `.claude/commands/`, there is no CoWork mirror in this edition, and every command must follow the Runtime & Persistence Protocol defined in `setup/templates/CLAUDE.md`. Test changes by instantiating a scratch vault from the template and running `/onboard` in a web session.
