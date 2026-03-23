# Claude Code Personal Assistant System

An AI-powered personal assistant built on [Obsidian](https://obsidian.md) + [Claude Code](https://docs.anthropic.com/en/docs/claude-code). The vault is the operating system; Claude Code is the brain. Together they handle task management, meeting processing, email triage, time tracking, client work, and daily planning -- replacing a human executive assistant.

> **You do not need to be technical.** Claude will walk you through everything step by step.
>
> **What you will need:** A Mac or PC, [Obsidian](https://obsidian.md) (free), and a [Claude Max subscription](https://claude.ai) ($100/month -- includes Claude Code).

## Get Started

**Option A -- Open Claude Code in this folder:**

```
cd path/to/ClaudeCodeSystem
claude
```

Then type `/onboard`.

**Option B -- Already have an Obsidian vault?** Drop this entire folder into your vault, open Claude Code in your vault, and say:

> Set me up

Claude will find the setup files, copy the commands into place, and start the process automatically.

Either way, Claude interviews you in a friendly question-and-answer format (no manual file editing). The full setup has 4 parts:

| Step | Command | What It Does | Time |
|------|---------|-------------|------|
| 1 | `/onboard` | Permissions, learn about you, build your notes folder and files | ~20 min |
| 2 | `/train` | Walk through Obsidian, your vault, slash commands, and the daily loop | ~15 min |
| 3 | `/connect` | Connect each of your tools (calendar, email, tasks, etc.) one by one | ~20 min |
| 4 | `/finish` | Live demo with real data, improvement tips, how to maximize the system | ~10 min |

Each part ends by telling you what to type next. You can pause between parts and pick up later.

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
│   (your tools)         Gmail                   md-to-gdoc.py      │
│   Google Calendar      Slack (N workspaces)    (your scripts)     │
│   Task Manager         Google Drive/Docs                          │
│   Context7             Transcript Service                         │
│                                                                    │
├──────────────────────────────────────────────────────────────────┤
│                       Obsidian Vault                              │
│   Inbox/Today.md · Inbox/<Client>.md · Work/Clients/<Client>/    │
│   [YourCompany]/ · Work/Daily/ · Templates/ · Resources/         │
└──────────────────────────────────────────────────────────────────┘
```

## How It Works

**The daily loop:**
1. **End of day** -- Run `/eod` before wrapping up. Claude processes your calls, emails, Slack, and tasks, then builds tomorrow's plan. You can walk away while it runs.
2. **Morning** -- Read `Inbox/Today.md` (pre-built schedule, priorities, meeting prep)
3. **Morning** -- Run `/morning` (3-5 min interactive review: confirm plan, adjust, create calendar blocks)
4. **All day** -- Work with Claude Code as needed (drafting, research, task management, document creation)
5. **End of day** -- Cycle repeats

## What the Setup Creates

By the end of all 4 steps, you will have (see the [Onboarding Guide](docs/onboarding-guide.md) for details):

- **Permissions** configured so Claude can work without interrupting you
- **Notes folder** (Obsidian vault) with organized folders for clients, projects, and tasks
- **Instruction manual** (CLAUDE.md) customized with your name, schedule, clients, and preferences
- **Tool connections** to your calendar, email, task manager, and other services
- **Saved routines** for morning review, end-of-day processing, and other workflows
- **Understanding** of how the system works and how to improve it over time

## Repository Structure

```
ClaudeCodeSystem/
├── CLAUDE.md                           # Bootstrap file (tells Claude how to start setup)
├── README.md                           # This file
├── .claude/commands/
│   ├── onboard.md                      # Part 1: Permissions, interview, build vault
│   ├── train.md                        # Part 2: Learn the system
│   ├── connect.md                      # Part 3: Connect all your tools
│   └── finish.md                       # Part 4: Live demo, improvement tips
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
│   │   ├── md-to-gdoc.py              # Markdown to Google Doc converter
│   │   ├── eod-runner.sh               # (Advanced) EOD phase orchestrator for cron
│   │   ├── eod-cron.sh                 # (Advanced) Cron wrapper with version pinning
│   │   └── com.brain.eod-runner.plist  # (Advanced) launchd config for nightly schedule
│   └── commands/
│       ├── eod-gather.md               # Phase 1: data gathering slash command
│       ├── eod-sync.md                 # Phase 2: dedup, sync, hygiene
│       ├── eod-time.md                 # Phase 3: time tracking (if configured)
│       ├── eod-note.md                 # Phase 4: daily note generation
│       ├── eod-today.md                # Phase 5: tomorrow's plan generation
│       ├── eod.md                      # Monolithic alternative (all phases in one)
│       ├── morning.md                  # Interactive morning review command
│       ├── monthly-review.md           # Monthly system review
│       ├── brain-dump.md               # Manual brain dump capture
│       └── daily-note.md              # Simplified daily note (lightweight EOD)
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

### EOD Command
The default `/eod` flow should run as one command in one Claude session. Claude Code now supports long-context sessions, so the simplest setup is a single `/eod` that gathers, routes, syncs, writes the daily note, and builds tomorrow's plan. If a user's workflow is unusually heavy, or if they want unattended scheduled automation, you can still split EOD into separate phases as an advanced fallback.

## FAQ

**Do I need all these tool connections?**
No. Start with Calendar + Email + your meeting transcript service. Add connections as you need them.

**Does this work on Linux?**
Yes. Everything works on Mac, Linux, and Windows (with WSL).

**How much does this cost?**
Claude Code requires a [Claude Max subscription](https://claude.ai) ($100/month). Connections to Google, Slack, and similar services are within their free tiers for personal use. Some tools (like meeting transcript services or time trackers) have their own pricing.

**Can I use this for a team?**
The system is designed for one person. You could adapt it for a small team, but it would need significant customization.

**What if the EOD routine fails partway through?**
If you are using the default one-command `/eod`, just run it again after fixing the issue. If you later adopt the advanced phased version, you can re-run only the failed phase.

**Can I automate the EOD to run on a schedule?**
Yes, for power users. The `examples/scripts/` folder includes a shell orchestrator, cron wrapper, and launchd plist for running `/eod` automatically at a set time (e.g., 11:30 PM weekdays). This requires some terminal setup. Most users just run `/eod` manually before wrapping up for the day.

## License

MIT
