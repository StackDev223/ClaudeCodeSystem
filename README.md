# Claude Code Personal Assistant System

An AI-powered personal assistant built on [Obsidian](https://obsidian.md) + [Claude Code](https://docs.anthropic.com/en/docs/claude-code). The vault is the operating system; Claude Code is the brain. Together they handle task management, meeting processing, email triage, time tracking, client work, and daily planning -- replacing a human executive assistant.

> **You do not need to be technical.** Claude will walk you through everything step by step.
>
> **What you will need:** A Mac or PC, [Obsidian](https://obsidian.md) (free), and a [Claude Code subscription](https://claude.ai).

## Get Started

The fastest way to set up is to let Claude interview you. Open Claude Code in this folder and type:

```
/onboard
```

Claude will ask you about your name, timezone, tools, schedule, and preferences -- then build everything for you. The whole process takes about 30 minutes. No manual file editing required.

> For a detailed reference of what gets set up, see the [Onboarding Guide](docs/onboarding-guide.md).

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

## What `/onboard` Does

The interactive setup walks you through these steps (you can also do them manually using the [Onboarding Guide](docs/onboarding-guide.md)):

1. **Permissions** -- Configures what Claude is allowed to do on your computer
2. **Notes folder** -- Creates your Obsidian vault with the right folder structure
3. **Instruction manual** -- Generates a customized CLAUDE.md based on your answers
4. **Tool connections** -- Walks you through connecting your calendar, email, task manager
5. **Saved routines** -- Creates your first automated workflows based on your preferences
6. **Daily system** -- Sets up your morning review and end-of-day processing

## Repository Structure

```
ClaudeCodeSystem/
├── README.md                           # This file
├── .claude/commands/
│   └── onboard.md                      # Interactive setup interview (run /onboard)
├── docs/
│   ├── onboarding-guide.md             # Reference for what /onboard sets up
│   ├── vault-design-guide.md           # How to build the vault (folder structure, inbox, templates)
│   ├── integration-architecture.md     # How Claude connects to your tools
│   └── daily-workflow.md               # Today.md + /morning + EOD pipeline
├── templates/
│   ├── CLAUDE.md                       # Starting CLAUDE.md template (customized by /onboard)
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
| [Onboarding Guide](docs/onboarding-guide.md) | Step-by-step setup for new users: permissions, Obsidian, CLAUDE.md, first tool connection, workflow discovery |
| [Vault Design Guide](docs/vault-design-guide.md) | Folder structure, inbox system, CLAUDE.md design, slash commands, integrations, monthly reviews, step-by-step build guide |
| [Integration Architecture](docs/integration-architecture.md) | How Claude connects to your tools: direct connections, tool credentials, custom scripts, scheduled automation |
| [Daily Workflow](docs/daily-workflow.md) | Today.md structure, /morning interactive review, EOD 5-phase pipeline, scheduled automation, tracking list pattern, carry-forward system |

## Key Concepts

### CLAUDE.md
The instruction file at your vault root. Claude reads it automatically every session. It defines your folder structure, integrations, preferences, workflows, and routing rules. Think of it as Claude's operating manual. Keep it under 30K characters; move detailed content to reference files.

### Saved Routines (Slash Commands)
Text files stored in `.claude/commands/` that define multi-step workflows. Type `/routine-name` and Claude runs the full process. Examples: `/eod-gather` (collect all daily data), `/morning` (interactive morning review), `/audit-deliver` (populate a client portal).

### Tracking Lists (The Manifest Pattern)
Long-running workflows track every extracted item in a tracking list (`/tmp/eod-manifest-TODAY.md`). Each item gets: description, client, type, source, destination, status. This makes sure nothing gets lost during long processes.

### Safe File Writes (Atomic Writes)
If your notes folder syncs via iCloud or Dropbox, use Python read-modify-write scripts instead of Claude's built-in editor. The editor's separate read and write operations can lose data when cloud sync modifies the file in between. This is a safety measure for cloud-synced notes.

### Route-As-You-Go
Every extracted item is routed to its destination file immediately, not batched for later. This prevents data loss if a step fails partway through or the process runs long.

### Phased EOD Pipeline
The end-of-day routine can be split into multiple phases, each in a fresh Claude session. A tracking list file on disk is the handoff between phases. Phases can fail independently without blocking later phases. Start with a single routine; split into phases when it gets too long.

## FAQ

**Do I need all these tool connections?**
No. Start with Calendar + Email + your meeting transcript service. Add connections as you need them.

**Does this work on Linux?**
Yes. Replace the Mac scheduler (`launchd`) with `cron` for scheduling. Everything else is the same.

**How much does this cost?**
Claude Code requires a [Claude subscription](https://claude.ai). Connections to Google, Slack, and similar services are within their free tiers for personal use. Some tools (like Fathom for meeting transcripts and Rize for time tracking) have their own pricing.

**Can I use this for a team?**
The system is designed for one person. You could adapt it for a small team, but it would need significant customization.

**What if the nightly routine fails?**
The runner sends notifications on failure. Use `--phase N` to re-run a single failed step. Each step is independent, so later steps work with partial data.

**How do I update Claude without breaking the nightly routine?**
Pin your Claude version: `echo "2.1.14" > ~/scripts/eod-claude-version`. When Claude updates, grant the new version file permissions, then update the pin file.

## License

MIT
