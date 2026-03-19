# Claude Code Personal Assistant System

An AI-powered personal assistant built on [Obsidian](https://obsidian.md) + [Claude Code](https://docs.anthropic.com/en/docs/claude-code). The vault is the operating system; Claude Code is the brain. Together they handle task management, meeting processing, email triage, time tracking, client work, and daily planning -- replacing a human executive assistant.

## Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                         You (Morning Review)                      │
│                    Read Today.md → /morning → Day starts          │
└──────────────────────────────┬───────────────────────────────────┘
                               │
┌──────────────────────────────▼───────────────────────────────────┐
│                     Claude Code (AI Agent)                        │
│              Reads CLAUDE.md · Executes slash commands            │
│              Reads .env · Calls APIs · Writes vault files        │
├──────────────────────────────────────────────────────────────────┤
│                                                                    │
│   MCP Servers          REST/GraphQL APIs       Custom Scripts     │
│   ClickUp              Gmail                   fathom-fetch.py    │
│   Supabase             Slack (N workspaces)    classify-transcript│
│   Google Calendar      Fathom                  rize_classify.py   │
│   Context7             Rize                    eod-runner.sh      │
│                        n8n                     eod-cron.sh        │
│                        Google Drive/Docs                          │
│                                                                    │
├──────────────────────────────────────────────────────────────────┤
│                       Obsidian Vault                              │
│   Inbox/Today.md · Inbox/<Client>.md · Work/Clients/<Client>/    │
│   [YourCompany]/ · Work/Daily/ · Templates/ · Resources/         │
└──────────────────────────────────────────────────────────────────┘
                               │
                    ┌──────────▼──────────┐
                    │   launchd / cron     │
                    │   11:30 PM weekdays  │
                    │   EOD Pipeline       │
                    └─────────────────────┘
```

## How It Works

**The daily loop:**
1. **11:30 PM** -- EOD pipeline runs automatically (5 phases: gather data, sync, time tracking, daily note, tomorrow's plan)
2. **8:00 AM** -- Read `Inbox/Today.md` (pre-built schedule, priorities, meeting prep)
3. **8:00 AM** -- Run `/morning` (3-5 min interactive review: confirm plan, adjust, create calendar blocks)
4. **All day** -- Work with Claude Code as needed (drafting, research, task management, document creation)
5. **11:30 PM** -- Cycle repeats

## Quick Start

### 1. Set up the vault

Create the folder structure and copy `templates/CLAUDE.md` to your vault root. Customize it with your clients, integrations, and preferences. See [docs/vault-design-guide.md](docs/vault-design-guide.md) for details.

### 2. Connect your APIs

Copy `templates/.env.example` to your vault root as `.env` and fill in credentials. Start with Google (Calendar + Gmail) and Fathom. See [docs/integration-architecture.md](docs/integration-architecture.md) for setup instructions.

### 3. Build your first slash command

Create `.claude/commands/eod.md` in your vault with a simple end-of-day routine. See [examples/commands/](examples/commands/) for full examples.

### 4. Add the daily workflow

Add `/morning` and `/eod-today` commands. Set up the nightly automation with `eod-runner.sh` and `launchd`. See [docs/daily-workflow.md](docs/daily-workflow.md) for the full system.

### 5. Iterate

The system improves every day. Add guidelines to CLAUDE.md when the AI makes mistakes. Add slash commands for new workflows. Save API quirks to memory files. Split your EOD into phases when context overflows.

## Repository Structure

```
ClaudeCodeSystem/
├── README.md                           # This file
├── docs/
│   ├── vault-design-guide.md           # How to build the vault (folder structure, inbox, templates)
│   ├── integration-architecture.md     # Technical layers (MCP, REST, scripts, cron)
│   └── daily-workflow.md               # Today.md + /morning + EOD pipeline
├── templates/
│   ├── CLAUDE.md                       # Starting CLAUDE.md with all sections
│   └── .env.example                    # All env var names with descriptions
├── examples/
│   ├── settings.json                   # Global Claude Code settings (permissions, additional dirs)
│   ├── settings.local.json             # Project-level permissions
│   ├── scripts/
│   │   ├── eod-runner.sh               # EOD phase orchestrator
│   │   ├── eod-cron.sh                 # Cron wrapper with version pinning
│   │   └── com.brain.eod-runner.plist  # launchd config for nightly schedule
│   └── commands/
│       ├── eod-gather.md               # Phase 1: data gathering slash command
│       └── morning.md                  # Interactive morning review command
├── .gitignore
└── LICENSE                             # MIT
```

## Documentation

| Document | What It Covers |
|----------|---------------|
| [Vault Design Guide](docs/vault-design-guide.md) | Folder structure, inbox system, CLAUDE.md design, slash commands, integrations, monthly reviews, step-by-step build guide |
| [Integration Architecture](docs/integration-architecture.md) | Four integration layers (MCP, REST, scripts, cron), credential management, transcript routing, Rize classification, data flow diagrams, setup from scratch |
| [Daily Workflow](docs/daily-workflow.md) | Today.md structure, /morning interactive review, EOD 5-phase pipeline, cron automation, manifest pattern, carry-forward system |

## Key Concepts

### CLAUDE.md
The instruction file at your vault root. Claude Code reads it automatically every session. It defines your folder structure, integrations, preferences, workflows, and routing rules. Think of it as the AI's operating manual. Keep it under 30K characters; move verbose content to reference files.

### Slash Commands
Custom markdown files in `.claude/commands/` that define multi-step workflows. Type `/command-name` and the AI executes the full routine. Examples: `/eod-gather` (pull all daily data), `/morning` (interactive review), `/audit-deliver` (populate a client portal).

### The Manifest Pattern
Long-running workflows track every extracted item in a manifest file (`/tmp/eod-manifest-TODAY.md`). Each item gets: description, client, type, source, destination, status. Prevents items from being lost during context compression in long sessions.

### Atomic Writes
If your vault syncs via iCloud/Dropbox, use Python read-modify-write scripts instead of the AI's built-in editor. The editor's separate read and write operations can lose data when cloud sync modifies the file in between.

### Route-As-You-Go
Every extracted item is routed to its destination file immediately, not batched for later. This prevents data loss if a phase fails partway through or the AI's context fills up.

### Phased EOD Pipeline
Split the monolithic end-of-day into multiple phases, each in a fresh Claude context. The manifest file on disk is the handoff. Phases can fail independently without blocking later phases. Start monolithic; split when context overflows.

## FAQ

**Do I need all these integrations?**
No. Start with Calendar + Email + Fathom (or whatever meeting transcript service you use). Add integrations as you need them.

**Does this work on Linux?**
Yes. Replace `launchd` with `cron` for scheduling. The vault, CLAUDE.md, slash commands, and API integrations are platform-independent.

**How much does this cost?**
Claude Code requires a [Claude subscription](https://claude.ai). API calls to Google, Slack, etc. are within their free tiers for personal use. Fathom and Rize have their own pricing.

**Can I use this for a team?**
The system is designed for a single user. The `[YourCompany]/` folder at root level is private; `Work/` is shareable. You could adapt the routing for a small team, but it would need significant customization.

**What if the EOD fails?**
The runner sends macOS notifications and optional Slack DMs on failure. Use `--phase N` to re-run a single failed phase. Each phase is independent; later phases work with partial data.

**How do I update Claude Code without breaking the EOD?**
Pin your Claude version: `echo "2.1.14" > ~/scripts/eod-claude-version`. When Claude updates, grant the new version file permissions, then update the pin file.

## License

MIT
