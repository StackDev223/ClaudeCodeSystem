# Claude Code Personal Assistant System — Cloud Edition

An AI-powered personal assistant that runs in the cloud. Your vault (notes, tasks, plans) is a **private GitHub repository**; Claude Code operates on it from **claude.ai/code** — from any device, on a schedule, with your computer off. It handles task management, meeting processing, email triage, daily planning, and client work, replacing a human executive assistant.

> **You do not need to be technical.** Claude walks you through everything step by step.
>
> **What you will need:** a free [GitHub](https://github.com) account, and a [Claude subscription](https://claude.ai) with access to Claude Code on the web.
>
> **No installs.** No Git Bash, no Node, no Python, no restarts. Setup happens in your browser.

## Get Started

1. **Create your vault repo.** On this repository's GitHub page, click **Use this template → Create a new repository**. Name it whatever you like (e.g. `Brain`), set it to **Private**, and create it under your own account.
2. **Open it in Claude Code.** Go to **[claude.ai/code](https://claude.ai/code)**, connect your GitHub account when prompted, and start a session on your new repository.
3. **Type `/onboard`.** Claude interviews you and builds your system around your work.

The full setup has 4 parts. Each part ends by telling you what to type next; you can pause between parts and pick up later.

| Step | Command | What It Does | Time |
|------|---------|-------------|------|
| 1 | `/onboard` | Learn about you, personalize the vault, configure the cloud environment | ~20 min |
| 2 | `/train` | Learn how your system works (the vault, saving, skills, the daily loop) | ~15 min |
| 3 | `/connect` | Connect your tools (calendar, email, tasks, transcripts) one by one | ~20 min |
| 4 | `/finish` | Live demo with real data, switch on the nightly automation | ~10 min |

## Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                        You (any device)                        │
│     Phone · laptop · tablet — read Today.md → /morning → go    │
└──────────────────────────────┬─────────────────────────────────┘
                               │
┌──────────────────────────────▼─────────────────────────────────┐
│              Claude Code on the web (claude.ai/code)           │
│   Interactive sessions + scheduled Routines (nightly EOD)      │
│   Reads CLAUDE.md · Runs skills · Saves everything as commits  │
├────────────────────────────────────────────────────────────────┤
│   Connectors (claude.ai)      Env vars + scripts    .mcp.json  │
│   Google Calendar · Gmail     Fathom · Rize · any   extra MCP  │
│   Drive · Slack · ClickUp     REST/GraphQL API      servers    │
├────────────────────────────────────────────────────────────────┤
│                 Your Vault = private GitHub repo               │
│   Inbox/Today.md · Inbox/<Client>.md · Work/ · Graph/ ·        │
│   System/state/ · .claude/commands/ (your skills)              │
│   Every change = a commit: full history, nothing ever lost     │
└────────────────────────────────────────────────────────────────┘
```

## How It Works

**The daily loop:**
1. **Overnight (automatic)** — a scheduled Routine runs `/eod` in the cloud: processes your calls, emails, Slack, and tasks, then builds tomorrow's plan. Your computer is off. It does not matter.
2. **Morning** — read `Inbox/Today.md` (pre-built schedule, priorities, meeting prep) wherever you like: a Claude session, Obsidian synced locally, or the GitHub app.
3. **Morning** — run `/morning` (3-5 min interactive review, works with taps from your phone): confirm the plan, adjust, create calendar blocks.
4. **All day** — work with Claude as needed: drafting, research, task management, `/brain-dump` from anywhere.
5. **The cycle repeats.**

## Why the vault is a Git repository

- **Nothing is ever lost.** Every change Claude makes is a commit — inspectable, diffable, undoable. "What changed yesterday?" is a real question with a real answer.
- **It runs 24/7.** Because the vault lives on GitHub, scheduled cloud sessions can work on it while you sleep. No always-on computer, no cron jobs, no launchd.
- **It goes anywhere.** Phone, web, or a local clone with Obsidian — all the same vault, kept in sync by git.
- **It is yours.** Private repo under your account. Invite your systems person to help maintain it; remove them anytime.

## Key Concepts

### CLAUDE.md
The instruction manual at the vault root. Claude reads it every session. It defines your schedule, clients, preferences, integrations, and the **Runtime & Persistence Protocol** — the rules that make cloud operation safe (always pull before working, always commit and push after, compute dates in your timezone, never store secrets in files).

### Skills
Repeatable routines in `.claude/commands/`. Type `/skill-name` and Claude runs the full process. Skills are auto-discovered in every cloud session, and because they live in the repo, a skill created once works everywhere forever. Your library grows as successful tasks become skills.

### Routines (scheduled automation)
Cloud-scheduled runs configured with `/automate`. The standard setup is a nightly `/eod` on weekdays. Each run is a fresh session that pulls your vault, does the work, and pushes the results — the run's commit *is* the receipt.

### Session Continuity (`/handoff` and `/pickup`)
`/handoff <name>` checkpoints mid-stream work into `.handoffs/<name>.md` (and pushes it); `/pickup [name]` reloads it in any later session — even on a different device. Cloud sessions also resume natively from claude.ai/code with conversation history intact; handoffs are for crossing between sessions and workstreams.

### Credentials (there is no .env)
Secrets never live in the repo. Google/Slack/task tools connect through **claude.ai connectors** (auth held by Anthropic). API-key tools (Fathom, Rize) use **environment variables** in your Claude Code environment configuration. See `setup/docs/environment-setup.md`.

### The Manifest Pattern
Long-running workflows track every extracted item in a manifest (`System/state/eod-manifest-YYYY-MM-DD.md`) — committed with the run, so nothing gets lost and every EOD is auditable later.

## Using it locally too (optional)

The cloud is primary, but the same vault works with the Claude Code CLI on your machine: clone the repo, run `claude` inside it. Pair it with [Obsidian](https://obsidian.md) + the obsidian-git community plugin for a beautiful local reading/editing experience that stays in sync with the cloud. `/train` walks you through this if you choose Obsidian as your reading surface.

## Repository Structure (before /onboard personalizes it)

```
ClaudeCodeSystem-Cloud/
├── CLAUDE.md                    # Bootstrap (replaced by your personalized manual)
├── README.md                    # This file
├── .claude/
│   ├── commands/                # All skills (auto-discovered in every session)
│   ├── hooks/session-start.sh   # Session bootstrap: deps + date/timezone orientation
│   └── settings.json            # Hook registration + permissions
├── .mcp.json                    # Extra MCP servers (managed by /connect)
├── System/
│   ├── state/                   # Durable machine state (manifests, sync markers)
│   └── memory/                  # Operational memory files
├── .handoffs/                   # Mid-stream work handoffs
├── scripts/                     # Reusable API scripts (env-var credentials)
│   └── md-to-gdoc.py            # Markdown → Google Doc converter
└── setup/                       # Setup-time materials (archived by /finish)
    ├── templates/               # CLAUDE.md template + methodology doc
    └── docs/                    # Environment setup + cloud architecture guides
```

## FAQ

**Do I need all these tool connections?**
No. Start with Calendar + Email. Add connections as you need them — `/connect` can be run again anytime.

**Where is my data?**
In your private GitHub repository, under your account. Claude works on it in isolated, temporary cloud sessions tied to your Claude account.

**What if the nightly run fails or can't reach a tool?**
It writes an "EOD Errors" section into your daily note and still saves everything else. `/morning` reads that section and catches up interactively. `/monthly-review` audits whether the routine ran every night.

**Does this work on Windows / Mac / Linux / phone?**
Yes — it runs in the browser and the Claude mobile app. There is nothing to install. (The optional local mode works on any OS with the Claude Code CLI.)

**What does it cost?**
A Claude subscription with Claude Code on the web access ([claude.ai](https://claude.ai)); scheduled Routines draw from your plan's usage. GitHub is free for private repositories. Note: Claude Code on the web is in research preview — features and limits may evolve.

**Can I use this for a team?**
The system is designed for one person. You could adapt it for a small team, but it would need significant customization.

**I'm coming from the local (original) edition — what changed?**
See `CHANGELOG.md` for the full delta: no `.env`, no launchd/cron scripts, git persistence protocol everywhere, Routines for scheduling, `System/state/` instead of `/tmp`, and a new `/automate` command.

## License

[CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/) — you may share this with attribution, but you may not sell it or distribute modified versions. See [LICENSE](LICENSE).
