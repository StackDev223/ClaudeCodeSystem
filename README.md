# Claude Code Personal Assistant System

An AI-powered personal assistant built on [Obsidian](https://obsidian.md) + [Claude Code](https://docs.anthropic.com/en/docs/claude-code). The vault is the operating system; Claude Code is the brain. Together they handle task management, meeting processing, email triage, time tracking, client work, and daily planning -- replacing a human executive assistant.

It can be used from either the Claude Desktop app or the Claude Code CLI. The setup now asks which one the user is using and changes the integration setup path accordingly.

> **You do not need to be technical.** Claude will walk you through everything step by step.
>
> **What you will need:** A Mac or PC, [Obsidian](https://obsidian.md) (free), and a [Claude Max subscription](https://claude.ai) ($100/month -- includes Claude Code).
>
> **Windows users:** Complete the Windows setup steps below before opening Claude for the first time.

## Windows Setup (do this first)

Skip this section if you are on Mac or Linux.

These steps must be done **before** opening Claude Code. They require one restart, so we batch them together.

**Step 1: Create your notes folder**
- Open File Explorer, go to your **Documents** folder, and create a new folder called **Brain**

**Step 2: Enable Developer Mode**
- Open **Settings** > **System** > **For developers** (or search "Developer Mode" in Settings)
- Turn on **Developer Mode** and confirm if prompted

**Step 3: Install Git Bash**
- Go to [git-scm.com](https://git-scm.com) and click **Download for Windows**
- Run the installer -- accept all the default options (just click Next until it finishes)

**Step 4: Install Claude**
- Go to [claude.ai/download](https://claude.ai/download) and install the desktop app
- Open Claude once -- it will install **Virtual Machine Platform** (a Windows component it needs). Let it finish.

**Step 5: Restart your computer**
- This one restart covers Git Bash, Developer Mode, and Virtual Machine Platform all at once

**Step 6: Open Claude and start setup**
- After restarting, open Claude and navigate to this folder
- Type `/onboard` to begin

---

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
| 1 | `/onboard` | Detect Desktop vs CLI, learn about you, build your notes folder and files | ~20 min |
| 2 | `/train` | Walk through Obsidian, your vault, skills, and the daily loop | ~15 min |
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
│              Reads CLAUDE.md · Executes skills                    │
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
- **Skills** for morning review, end-of-day processing, and other workflows
- **Understanding** of how the system works and how to improve it over time

## Repository Structure

```
ClaudeCodeSystem/
├── CLAUDE.md                           # Bootstrap file (tells Claude how to start setup)
├── README.md                           # This file
├── .claude/commands/                   # ALL Claude Code CLI slash commands (auto-discovered; every one installs during /onboard)
│   ├── onboard.md                      # Part 1: Permissions, interview, build vault
│   ├── train.md                        # Part 2: Learn the system
│   ├── connect.md                      # Part 3: Connect all your tools
│   ├── finish.md                       # Part 4: Live demo, improvement tips
│   ├── handoff.md                      # Save current work state to a named briefing file
│   ├── pickup.md                       # Resume from a named handoff in a fresh session
│   ├── strategy.md / optimize.md       # Decision-making + tool/process improvement
│   ├── build-skill.md / learn.md       # Turn tasks into skills · capture knowledge
│   ├── graph-sync.md / graph-daily.md  # Knowledge graph maintenance
│   ├── morning.md                      # Interactive morning review command
│   ├── eod.md                          # End of day: monolithic (all phases in one)
│   ├── eod-gather.md                   # EOD Phase 1: data gathering
│   ├── eod-sync.md                     # EOD Phase 2: dedup, sync, hygiene
│   ├── eod-time.md                     # EOD Phase 3: time tracking (if configured)
│   ├── eod-note.md                     # EOD Phase 4: daily note generation
│   ├── eod-today.md                    # EOD Phase 5: tomorrow's plan generation
│   ├── monthly-review.md               # Monthly system review
│   ├── brain-dump.md                   # Manual brain dump capture
│   └── daily-note.md                   # Simplified daily note (lightweight EOD)
├── cowork-commands/                    # CoWork versions (YAML frontmatter, manual upload)
│   └── *.md                            # Mirror of all commands with YAML frontmatter
├── docs/
│   ├── onboarding-guide.md             # Reference for what /onboard sets up
│   ├── vault-design-guide.md           # How to build the vault (folder structure, inbox, templates)
│   ├── integration-architecture.md     # How Claude connects to your tools
│   └── daily-workflow.md               # Today.md + /morning + EOD pipeline
├── templates/
│   ├── CLAUDE.md                       # Starting CLAUDE.md template (customized by /onboard)
│   └── .env.example                    # All env var names with descriptions
├── examples/                           # Optional CLI settings + advanced automation (NOT commands)
│   ├── settings.json                   # CLI example: global Claude Code settings
│   ├── settings.local.json             # CLI example: project-level permissions
│   └── scripts/
│       ├── md-to-gdoc.py               # Markdown to Google Doc converter
│       ├── eod-runner.sh               # (Advanced) EOD phase orchestrator for cron
│       ├── eod-cron.sh                 # (Advanced) Cron wrapper with version pinning
│       └── com.brain.eod-runner.plist  # (Advanced) launchd config for nightly schedule
├── .gitignore
└── LICENSE                             # CC BY-NC-ND 4.0
```

## Documentation

| Document | What It Covers |
|----------|---------------|
| [Onboarding Guide](docs/onboarding-guide.md) | Step-by-step setup for new users: permissions, Obsidian, CLAUDE.md, first tool connection, workflow discovery |
| [Vault Design Guide](docs/vault-design-guide.md) | Folder structure, inbox system, CLAUDE.md design, skills, integrations, monthly reviews, step-by-step build guide |
| [Integration Architecture](docs/integration-architecture.md) | How Claude connects to your tools: direct connections, tool credentials, custom scripts, scheduled automation |
| [Daily Workflow](docs/daily-workflow.md) | Today.md structure, /morning interactive review, EOD 5-phase pipeline, scheduled automation, tracking list pattern, carry-forward system |

## Key Concepts

### CLAUDE.md
The instruction file at your vault root. Claude reads it automatically every session. It defines your folder structure, integrations, preferences, workflows, and routing rules. Think of it as Claude's operating manual. Keep it under 30K characters; move detailed content to reference files.

### Skills
Successful tasks turned into repeatable routines. Each skill is a text file that defines a multi-step workflow. Type `/skill-name` and Claude runs the full process. Examples: `/eod-gather` (collect all daily data), `/morning` (interactive morning review), `/audit-deliver` (populate a client portal). Your skills library grows over time as you turn successful one-off tasks into reusable routines.

**Two formats exist for different runtimes:**
- **Claude Code (CLI):** Skills live in `.claude/commands/` and are auto-discovered. No special formatting needed.
- **Claude CoWork:** Skills require YAML frontmatter (`name:` and `description:` fields in a `---` block) and must be manually uploaded through the **Customize** section in the app settings. The `cowork-commands/` directory contains pre-formatted versions of all skills ready for upload.

### Session Continuity (`/handoff` and `/pickup`)
Every user gets these two commands. They solve the single biggest limitation of working with an AI agent: a session's memory is finite. When the context window fills up, or you run `/clear`, close the window, or the conversation gets compacted, everything that was only "in the chat" is gone.

- **`/handoff <name>`** writes a self-contained briefing to `.handoffs/<name>.md`: the goal, what's been done, what was tried and rejected, the exact next steps, and which files and commands the next session should reload. Run it before `/clear`, before closing a window mid-task, or whenever a long conversation is getting unwieldy. The handoff is written *to the next Claude*, not to you, so it reads like a briefing for a colleague who just walked in.
- **`/pickup [name]`** (in the next session) reads that file, reloads the listed context in parallel, sanity-checks it against the current state of the repo, and reports back where you left off, all without you re-explaining anything. With no argument it lists the available handoffs and asks which to resume.

Because each handoff is a named, persistent file inside the vault, they accumulate into a **track record of in-flight workstreams**: you can keep several open across different projects, and old ones stay put until you delete them. This is better task and context management than holding everything in one long chat. Use it for mid-stream work; `/eod` still handles end-of-day wrap-up and routing items to your task inboxes.

> Named `/pickup` (not `/resume`) so it doesn't shadow Claude Code's built-in `/resume` session picker.

### Tracking Lists (The Manifest Pattern)
Long-running workflows track every extracted item in a tracking list (`/tmp/eod-manifest-TODAY.md`). Each item gets: description, client, type, source, destination, status. This makes sure nothing gets lost during long processes.

### Safe File Writes (Atomic Writes)
If your notes folder syncs via iCloud or Dropbox, use Python read-modify-write scripts instead of Claude's built-in editor. The editor's separate read and write operations can lose data when cloud sync modifies the file in between. This is a safety measure for cloud-synced notes.

### Route-As-You-Go
Every extracted item is routed to its destination file immediately, not batched for later. This prevents data loss if a step fails partway through or the process runs long.

### Vault Hygiene and Canonical Detection
`/vault-audit` runs every night (standalone, or as an EOD phase) and keeps the vault matching its own design contract. Each run: **(1) structure** -- walks the tree, refiles misfiled notes, backfills frontmatter, stages removals into `_generated/vault-hygiene/audit-trash/` (never deletes); **(2) index** -- hashes every file and keeps a one-line concept/entities row per note; **(3) embeddings** -- embeds changed notes locally and generates same-subject candidate pairs; **(4) canonical proposals** -- a comparator classifies each pair as a version-fork, a duplicate, or legitimately distinct, a deterministic rule picks the winner, and the proposal lands in `_generated/vault-hygiene/pending-supersession-review.md`; **(5) file-mode review** -- you edit the `decision:` line in each block (`confirm` folds and retires the loser, `confirm-keep` labels only, `reject`, or `swap`), and the next run applies your decisions; **(6) invariant** -- a fail-loud check that no canonical/superseded marker is dangling, chained, or self-contradictory. Nothing is merged or hidden without a human decision; a wrong merge is high-consequence and near-invisible, so the human gate is mandatory.

Run the embedding step directly when you want to inspect candidates:

```
# locally (installs the embedder into a throwaway env):
uv run --python 3.12 --with fastembed,numpy scripts/vault-embed.py report --vault <path>

# in the cloud / a scheduled run (self-installs its one dependency at run start):
python3 scripts/vault-embed.py report --vault <path> --install
```

**Privacy:** the **embedding** step runs in-process with a small local model (`bge-small`) and sends no note content off the machine; its only outbound call is a one-time download of the model weights. (The separate **judging** step hands the candidate pair's text to Claude, the same as any other Claude session that reads your vault.) After a file or folder rename, run `python3 scripts/vault-embed.py migrate --vault <path> --rename "<old>" "<new>"` to re-key the saved state so nothing re-embeds or re-judges. Thresholds, the owner/company exclusion list, and the staleness window are config in the schema's `embedding:` block.

### EOD Command
The default `/eod` flow should run as one command in one Claude session. Claude Code now supports long-context sessions, so the simplest setup is a single `/eod` that gathers, routes, syncs, writes the daily note, and builds tomorrow's plan. If a user's workflow is unusually heavy, or if they want unattended scheduled automation, you can still split EOD into separate phases as an advanced fallback.

## Install the System Journal (optional)

The System Journal turns every Claude Code session into a durable, checkable record so a later
review can spot what keeps coming back. It ships in `templates/scripts/system-journal/` (full
reference: that folder's `README.md`). This template ships **capture** only: there is no weekly
reflection command and no Themes writer yet.

1. **Install the scripts and record your vault path** (macOS can block execution of scripts in a
   cloud-synced folder, so they are copied to a plain local dir):
   ```bash
   bash scripts/system-journal/install.sh --vault "$VAULT" --write-hooks
   ```
   `--vault` writes your vault path to `~/.system-journal/config.json`; `--write-hooks` merges
   three hooks into your user-level `~/.claude/settings.json` (it only adds hooks that are not
   already present and preserves everything else). Re-run `install.sh` (no flags) after editing
   any script.
2. **What the hooks do.** `Stop` extracts the live session every ~15 minutes (no model call);
   `SessionEnd` extracts the finished session and distills one journal line; `SessionStart`
   injects directory-matched Themes (inert until a reflection step writes `_generated/Themes.md`,
   which this template does not).
3. **Per-session cost.** The journal line is produced by your own `claude -p` call with the
   default Sonnet distiller: about **nine cents per finished session**. Set `SYSTEM_JOURNAL_MODEL`
   to change the model. The Stop-hook extract and the SessionStart inject are free.
4. **What is kept.** Your words verbatim, the agent's visible words capped, the tool calls it
   made and the errors that came back. **No tool outputs**, no thinking, no attachments. Full
   transcripts are never stored (Claude Code keeps its own for ~30 days locally).
5. **Where the files land.** `_generated/system-journal/` in your vault: `evidence/<YYYY-MM>/`
   (deterministic, kept forever) and `<YYYY-MM>.<host>.jsonl` (one journal line per session).
6. **Cost guard.** Before any bulk re-run, read the pending count first:
   ```bash
   python3 ~/scripts/system-journal/distill.py --dry-run | tail -1
   ```
   `--force` keeps existing journal lines unless you also pass `--redistill`.
7. **Privacy.** Everything stays in your own vault repo. The audit tier (a work-only projection
   with personal lines dropped) is **generated locally only and shipped nowhere**.

**Cloud capture (optional).** If you also run your vault in Claude Code on the web, add the
repo-level hook block in `examples/cloud-hooks.settings.json` to your vault's own committed
`.claude/settings.json`. Those hooks (`scripts/cloud-land.sh` and
`scripts/system-journal/cloud-journal.sh`) ship to every cloud container that clones your vault,
land the session's file edits and journal on `main` without the agent running git, and bypass the
permission classifier so an unattended run never stalls. The cloud environment needs push access
to your vault's `origin` (main).

**Knowledge graph.** `scripts/graph-render.py` renders `Graph/index.md` and the MOCs from
frontmatter and the concept index; `/graph-daily` and `/graph-sync` drive it. Graph files are
generated, not hand-edited, and links are structural edges only (no inline wiki-link pass).

## FAQ

**Do I need all these tool connections?**
No. Start with Calendar + Email + your meeting transcript service. Add connections as you need them.

**Does this work on Windows and Linux?**
Yes. Everything works on Mac, Linux, and Windows. Windows users need Git Bash, Developer Mode, and Virtual Machine Platform -- the setup process handles all of this automatically.

**How much does this cost?**
Claude Code requires a [Claude Max subscription](https://claude.ai) ($100/month). Connections to Google, Slack, and similar services are within their free tiers for personal use. Some tools (like meeting transcript services or time trackers) have their own pricing.

**Can I use this for a team?**
The system is designed for one person. You could adapt it for a small team, but it would need significant customization.

**What if the EOD routine fails partway through?**
If you are using the default one-command `/eod`, just run it again after fixing the issue. If you later adopt the advanced phased version, you can re-run only the failed phase.

**Can I automate the EOD to run on a schedule?**
Yes, for power users. The `examples/scripts/` folder includes a shell orchestrator, cron wrapper, and launchd plist for running `/eod` automatically at a set time (e.g., 11:30 PM weekdays). This requires some terminal setup. Most users just run `/eod` manually before wrapping up for the day.

## License

[CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/) — you may share this with attribution, but you may not sell it or distribute modified versions. See [LICENSE](LICENSE) for details.
