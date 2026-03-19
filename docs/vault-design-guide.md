# How to Build an AI-Powered Obsidian Vault (Personal Assistant System)

This is a breakdown of how an Obsidian vault works as an AI-powered personal assistant system. The vault is the central hub; Claude Code (Anthropic's CLI agent) is the brain that operates on it. Together they replace a human executive assistant for task management, meeting processing, email triage, time tracking, and client work.

If you want to replicate something like this, here's everything you need to know.

---

## The Core Idea

An Obsidian vault is just a folder of markdown files. Claude Code is an AI agent that can read, write, and edit files, run shell commands, and call APIs. By pointing Claude Code at your vault and giving it a detailed instruction file (`CLAUDE.md`), you get an AI that:

- Knows your entire system (folder structure, workflows, preferences)
- Can read and update any note in your vault
- Can call external APIs (Google Calendar, Gmail, Slack, Fathom, etc.)
- Can run automated routines (end-of-day closeout, morning review, meeting processing)
- Remembers lessons across sessions (via persistent memory files)
- Gets better over time as you refine the instructions

The vault is the single source of truth. Everything flows through it.

---

## Folder Structure

Keep it simple. Five top-level folders cover everything:

```
Vault/
├── Inbox/              # Active task tracking + daily plan (the "hot" zone)
│   ├── Incoming.md     # Overview dashboard (Client Boards table, cross-client tasks)
│   ├── Today.md        # Today's plan (generated nightly by EOD, read each morning)
│   ├── ClientA.md      # Per-client task files
│   ├── ClientB.md
│   └── ...
├── [YourCompany]/      # Your own company docs (at root level, private)
│   ├── Hiring/         # Candidate pipeline, interview prep
│   ├── SOPs/           # Standard operating procedures
│   └── Transcripts/    # Private/internal calls
├── Work/               # Professional projects, clients (shareable)
│   ├── Clients/        # One subfolder per client
│   │   └── <Client>/
│   │       ├── Company Profile.md
│   │       ├── Transcripts/    # Client-specific call transcripts
│   │       └── Archive/
│   ├── Transcripts/    # Admin/multi-client calls
│   ├── Sales Leads/    # Pipeline and discovery notes
│   └── Daily/          # Auto-generated daily summaries
├── Projects/           # Personal projects, goals, life stuff
├── Resources/          # Reference material, contacts, recipes, health, learning
│   └── Reference/      # System docs, API guides, improvement backlog
├── Templates/          # Note templates (meeting, client, transcript, etc.)
└── Archive/            # Completed weekly task snapshots
```

### Design Principles

1. **Inbox is for action, not storage.** It holds active tasks organized by client/area. Once tasks are done, they get archived weekly.
2. **One subfolder per client.** Each client gets a `Company Profile.md` (overview, contacts, engagement details, active/completed projects), a `Transcripts/` folder for call recordings, and an `Archive/` folder for old call recaps, weekly snapshots, and completed work.
3. **Separate reference from action.** Resources are things you look up. Inbox items are things you do. Don't mix them.
4. **Archive aggressively.** Completed tasks get moved to dated archive files weekly. This keeps active files clean and scannable.
5. **Transcripts route per-client.** A classifier script determines which client a call belongs to and routes it to the right `Transcripts/` folder automatically. Admin/team calls go to `Work/Transcripts/`, private calls to `[YourCompany]/Transcripts/`.
6. **Company docs at root level.** Your own company (hiring, SOPs, strategy) lives at the vault root, separate from `Work/` which is shareable with staff.

---

## The Inbox System (Task Management)

This is the heart of the daily workflow. The Inbox folder has:

- **`Incoming.md`** -- The overview dashboard. Contains a Client Boards table (open task counts, status summaries per client), cross-client tasks, and any items that don't belong to a specific client.
- **`Today.md`** -- Today's plan, generated nightly by the EOD pipeline. Contains the schedule, prioritized tasks, meeting prep, deadline radar, and strategic goals. Read each morning, then reviewed interactively via `/morning`.
- **One file per client** (e.g., `ClientA.md`, `ClientB.md`) -- Each follows a standard structure:

```markdown
# Client Name -- Week of MMM DD, YYYY

### New from Calls MM/DD
- [ ] **Task description** -- *from [Contact Name] call MM/DD*
- [ ] Follow up: [Person] to deliver X by Friday -- *from [Contact Name] call MM/DD*

### Open Tasks
- [ ] **Existing task** -- *from source*

### Pending from Others
- Items you're waiting on from other people

### Key Dates
- Upcoming deadlines

### Notes
- Non-actionable observations from calls, Slack, email

### Completed
- [x] Done items get moved here, then archived weekly
```

### Key Patterns

- **Source notes on every item.** Every task includes where it came from (e.g., "from [Contact Name] call 2/3", "from Slack DM", "from email: subject"). This makes it easy to trace context later.
- **Task ownership matters.** If someone else owns the action, frame it as a follow-up for you: "Follow up: [Team Member] to deliver X by Friday." You mark it complete when they deliver, not when the action happens.
- **Deduplication.** Before adding a task, check if it already exists from a previous day. If it does, update the source note instead of creating a duplicate.
- **Weekly reset.** Every Monday, archive all completed items to `Archive/Completed Week of YYYY-MM-DD.md`, clear the Completed sections, and carry forward everything still open.

---

## The Daily Workflow System

The system operates on a daily loop: EOD generates tomorrow's plan, morning confirms it, the day happens, and EOD processes everything again.

### Today.md (Generated Nightly)

`Inbox/Today.md` is an ephemeral file overwritten every night by EOD Phase 5. It contains:

- **Schedule table**: Time blocks with the day's skeleton (deep work, meetings, breaks)
- **Morning exceptions**: Any calls before 1 PM, with fragmentation cost notes
- **Tasks section**: Prioritized tasks assigned to time blocks, with source tags linking back to client inbox files
- **Meeting prep**: Context for each meeting (recent transcript summary, open tasks, strategic goals)
- **Deadline radar**: Upcoming deadlines in the next 7 days
- **North Star goals**: This week's strategic focus per client
- **Team priorities**: Copy/paste-ready message for team delegation

#### Source Tags and Carry-Forward

Tasks in Today.md include invisible HTML comments:
- `<!-- src:Inbox/ClientA.md|fingerprint text here -->` -- Links back to the source task in the client file
- `<!-- type:meeting -->` -- Calendar meetings (don't carry forward)
- `<!-- carried:N -->` -- Items carried forward from previous days (N = number of days)

When generating tomorrow's Today.md, the system checks today's unchecked tasks. If a task is re-selected for tomorrow, its carry count increments. Tasks carried for multiple days surface as a concern during the morning review.

### /morning (Interactive Review)

The `/morning` command is a 3-5 minute interactive review:

1. **Summary**: Date, meeting count, top priority, deadline alerts, weekly goals
2. **Client review**: All clients presented at once with flags for conflicts, missing estimates, overcommitment. User selects which need adjustments via `AskUserQuestion`.
3. **Goal check**: Detects stale strategic goals (>7 days) and prompts for refresh
4. **Calendar time blocks**: Proposes deep work blocks on Google Calendar based on the confirmed plan
5. **Send-off**: Confirms plan is locked, announces first priority

The entire review can complete with just 3 taps if the plan looks good: "All good" -> "Skip goals" -> "Create all blocks."

### The Daily Loop

```
 11:30 PM  EOD Pipeline runs (automated via launchd)
           Phase 1: Gather (Fathom, email, Slack, calendar)
           Phase 2: Sync (dedup, ClickUp, hygiene)
           Phase 3: Rize (time tracking)
           Phase 4: Daily note
           Phase 5: Generate Tomorrow's Today.md
    |
    v
  8:00 AM  Read Today.md
  8:00 AM  Run /morning (interactive review, 3-5 min)
  8:05 AM  Deep Work 1 begins
    |
   ...     Day happens (meetings, tasks, Slack, email)
    |
    v
 11:30 PM  EOD Pipeline runs again
```

---

## The CLAUDE.md File (AI Instructions)

This is the most important file in the system. It's a markdown file at the vault root that Claude Code reads automatically every session. It contains:

### What Goes in CLAUDE.md

1. **Startup checklist** -- What the AI should do first every session (verify date, check for monthly reviews, check inbox for pending items).
2. **Quick reference table** -- Where to find key things (inbox, credentials, client profiles, Today.md, transcripts).
3. **Folder structure** -- So the AI knows where everything lives.
4. **Available integrations** -- What APIs and tools are connected, with brief descriptions. Including local tools like the transcript classifier and Fathom fetcher.
5. **Assistant guidelines** -- Your preferences and rules. Examples:
   - "All times in [Your Timezone]"
   - "Route tasks to client files, not a central list"
   - "Be direct and challenge my decisions constructively"
   - "Only plan 2 days ahead; priorities shift too fast for a full week"
   - "Fridays are for deep work, no calls"
6. **Common workflows** -- Step-by-step instructions for recurring processes (morning routine, processing incoming items, weekly resets, EOD pipeline, document creation).
7. **Self-improvement protocol** -- Instructions for the AI to update its own instructions when it learns something new.
8. **Change log** -- Recent significant system changes (keeps the AI oriented on what's new).

### Key Design Principles for CLAUDE.md

- **Be explicit about routing rules.** The AI needs to know exactly where different types of information go. "Client tasks go to `Inbox/<Client>.md` under Open Tasks" is better than "put tasks somewhere appropriate."
- **Define what is NOT a task.** Half the battle is preventing the AI from creating checkbox items for everything. Define clearly: meeting recaps without action items are notes, not tasks. Calendar confirmations are not tasks. FYI emails are not tasks.
- **Include your scheduling philosophy.** How you think about time blocking, meeting windows, deep work, and planning horizons.
- **Keep it under 30K characters.** Move verbose content (API docs, detailed SOPs) to separate reference files and link to them. CLAUDE.md should be a concise operating manual, not an encyclopedia.
- **Update it as you go.** When you discover a new preference or the AI makes a recurring mistake, add a guideline. The file is a living document.

---

## Slash Commands (Automated Routines)

Claude Code supports custom slash commands defined as markdown files in `.claude/commands/`. Each file is a detailed prompt that runs a multi-step workflow. You type `/command-name` and the AI executes the full routine.

### End-of-Day Pipeline (Phased)

The EOD runs as a multi-phase pipeline, with each phase in a fresh Claude context. This avoids context overflow on busy days with many calls and messages.

| Phase | Command | What It Does | Timeout |
|-------|---------|--------------|---------|
| 1 | `/eod-gather` | Brain dump triage, Fathom transcripts (via `fathom-fetch.py`), calendar, email, Slack. Routes all items to client files. Creates manifest. | 25 min |
| 2 | `/eod-sync` | Deduplication, completed task cleanup, Client Boards update, ClickUp sync, vault hygiene. | 15 min |
| 3 | `/eod-rize` | Rize time tracking: classify sessions by client + work type (delivery/sales/audit/meeting/admin/internal), generate relabeling checklist. | 15 min |
| 4 | `/eod-note` | Generate daily note at `Work/Daily/YYYY-MM-DD.md` with session summary. | 5 min |
| 5 | `/eod-today` | Generate tomorrow's `Inbox/Today.md`: schedule, priorities, meeting prep, deadline radar, team priorities. | 10 min |

An `eod-runner.sh` script orchestrates all phases sequentially. Each phase writes its output to disk (manifest files, inbox files, temp files in `/tmp/`). Later phases read from disk, not from conversation context.

The runner supports `--phase N` to re-run a single phase and `--dry-run` to preview without executing. It logs per-phase timing and sends macOS notifications (and optionally Slack DMs) on failure.

A cron wrapper (`eod-cron.sh`) handles version pinning, lockfiles, and Gatekeeper issues for running Claude Code from `launchd`.

#### The Manifest Pattern

The EOD uses a **manifest file** (`/tmp/eod-manifest-TODAY.md`) as a tracking ledger. Every extracted item gets a row with: item description, client, type, source, where it was routed, and status. This prevents items from getting lost during a long multi-step process and serves as an audit trail.

#### Atomic Writes

If your vault syncs via iCloud (or Dropbox, or any cloud sync), files can change between when the AI reads them and when it writes. The solution: use Python scripts that read-modify-write in a single operation, rather than the AI's built-in file editor which can fail on sync conflicts.

#### The Monolithic Alternative

Instead of the phased pipeline, you can run a single `/eod` command that does everything in one context. This is simpler to set up but risks context overflow on busy days (5+ calls, 100+ Slack messages). Start with the monolithic version and split into phases when context becomes a bottleneck.

### Morning Review (`/morning`)

Interactive 3-5 minute review (see "Daily Workflow System" above for details). Key features:
- Batch client review with `AskUserQuestion` for efficient decision-making
- Stale goal detection with non-blocking refresh prompts
- Calendar time block creation on Google Calendar
- Overcommitment guard (forces prioritization if work exceeds capacity)

### Monthly Review (`/monthly-review`)

Triggered by a non-blocking nudge at the start of a new month (not auto-triggered). Covers:
- System feedback (what's working, what's clunky)
- Vault cleanup (stuck inbox items, notes to archive, misplaced files)
- Testimonial scan (searches Slack and transcripts for positive client feedback)

### Other Slash Commands

- **`/debrief`** -- Processes a specific meeting transcript into structured notes with action items.
- **`/audit-research`**, **`/audit-roadmap`**, **`/audit-review`**, **`/audit-deliver`** -- A multi-stage pipeline for client technology audits.
- **`/browse`** -- Browser automation for when APIs aren't enough.

You can build a slash command for any repeatable multi-step process. The pattern is always: define the steps in markdown, specify the data sources and routing rules, and let the AI execute.

---

## Integrations

The system connects to external services in two ways:

### MCP Servers (Native Tool Access)

MCP (Model Context Protocol) servers give Claude Code direct tool access to services. These show up as callable functions the AI can use without writing API calls. Examples:

- **ClickUp** -- Create/update/search tasks, manage lists and folders
- **Supabase** -- Run SQL queries, manage database migrations
- **Google Calendar** -- List/create/update events, find free time

### REST/GraphQL APIs (Via Shell Commands)

For services without MCP servers, Claude Code calls APIs directly using `curl` in the shell. Credentials are stored in a `.env` file at the vault root (gitignored, never committed). Examples:

- **Fathom** -- Pull meeting transcripts and summaries
- **Gmail** -- Read/search/send email via Google's API
- **Slack** -- Read channels, DMs, post messages (one token per workspace)
- **Rize** -- Time tracking data via GraphQL
- **n8n** -- Manage automation workflows across multiple instances
- **Google Drive/Docs** -- Create and manage documents

### Credential Management

- All secrets live in `.env` at the vault root
- The vault itself never contains raw API keys
- A `Resources/API Keys/` folder holds reference pointers only (e.g., "Stored in .env as FATHOM_API_KEY")
- An `API Integration Guide.md` in Resources documents every endpoint, auth method, and usage example

---

## Persistent Memory

Claude Code has a memory directory (`.claude/projects/<path>/memory/`) that persists across sessions. This is where the AI stores:

- **Tool setup notes** -- How local tools work, CLI paths, gotchas
- **API quirks** -- Things that break in non-obvious ways (e.g., "Google Docs insertText inherits styles from adjacent text")
- **Operational patterns** -- Lessons learned from past sessions
- **Workflow gotchas** -- Edge cases discovered during automation work

A `MEMORY.md` file is loaded into every conversation automatically. It links to topic-specific files (e.g., `bash-gotchas.md`, `google-docs-api.md`) for detailed notes.

### What to Store vs. What Not To

**Store:** Stable patterns confirmed across multiple sessions, key file paths, user preferences, solutions to recurring problems, architectural decisions.

**Don't store:** Session-specific context, in-progress work, speculative conclusions from reading a single file, anything that duplicates CLAUDE.md.

---

## Templates

Keep a `Templates/` folder with standard note structures. The AI uses these when creating new notes to maintain consistency. Examples:

- **Meeting Note** -- Date, client, attendees, summary, discussion notes, decisions, action items, transcript
- **Client Note** -- Overview, key contacts table, notes, action items
- **Video Transcript** -- Date, speaker, duration, source, transcript body

Templates use Obsidian's `{{date}}` and `{{title}}` placeholders.

---

## Monthly Reviews

CLAUDE.md includes a "Last Monthly Review" date. Every session, the AI checks if a new month has started. If so, it gives you a **one-line nudge** ("the monthly review is due, run `/monthly-review` whenever you're ready") and proceeds with whatever you asked for. It does not block work or auto-trigger the review.

When you do run `/monthly-review`, it covers:

- **System feedback** -- What's working, what's clunky, what's missing
- **Vault cleanup** -- Stuck inbox items, notes to archive, outdated info, misplaced files
- **Testimonial scan** -- Searches Slack and call transcripts for positive client feedback (appreciation, praise, results) and adds approved quotes to a testimonials file

After the review, improvement ideas go to a dedicated `System Improvements.md` file, workflow changes update CLAUDE.md, and the review date gets bumped.

---

## Putting It Together: How a Typical Day Works

1. **Night before (automated)**: At 11:30 PM, the EOD pipeline runs automatically. It pulls all your calls, emails, Slack messages, and time tracking data. It extracts action items, routes them to the right client files, syncs with ClickUp, generates a daily summary, and creates tomorrow's `Today.md` with schedule, priorities, and meeting prep.

2. **Morning**: Read `Inbox/Today.md` for the day's plan. Run `/morning` for a 3-5 minute interactive review: confirm priorities, flag conflicts, refresh stale goals, and create calendar time blocks.

3. **During the day**: Ask the AI to help with anything: draft emails, research a topic, create a document, update client notes, prepare for a meeting, review code, manage tasks in ClickUp.

4. **End of day**: The automated pipeline handles everything. Or run `/eod` manually for an immediate closeout.

5. **Monday morning**: The AI archives last week's completed tasks and resets the client files for the new week.

---

## How to Build Your Own

### Step 1: Set Up the Vault Structure

Create the folder structure above. Start with just `Inbox/`, `Work/`, `Resources/`, and `Templates/`. Add `[YourCompany]/` and per-client `Transcripts/` folders as complexity grows.

### Step 2: Write Your CLAUDE.md

Start small. Include:
- Your folder structure
- Where new items go (your inbox system)
- Your timezone and scheduling preferences
- Any integrations you have
- Your daily schedule skeleton

See `templates/CLAUDE.md` in this repo for a complete starting point.

### Step 3: Connect Your APIs

Pick 2-3 integrations that would save you the most time. For most people:
- **Calendar** (know what's coming tomorrow)
- **Email** (surface what needs responses)
- **Meeting transcripts** (auto-extract action items)

Store credentials in `.env`. Document endpoints in a reference file.

### Step 4: Build Your First Slash Command

Start with an end-of-day routine. Even a simple version that just checks your calendar and email is valuable. Add sections as you connect more services.

### Step 5: Add the Daily Workflow

Once your EOD is stable:
1. Add a `/eod-today` phase that generates `Inbox/Today.md`
2. Add a `/morning` command for interactive review
3. Schedule EOD via `launchd` (macOS) or `cron` (Linux)
4. Split into phases when context becomes a bottleneck

### Step 6: Iterate

The system gets better every time you use it. When the AI makes a mistake, add a guideline to CLAUDE.md. When you discover a new workflow, add a slash command. When you learn an API quirk, save it to memory.

The goal isn't to build the perfect system on day one. It's to build a system that improves itself every day.

---

## What Makes This Different from a Normal Obsidian Vault

A normal Obsidian vault is a passive knowledge base. You write notes, you read notes. This system is **active**:

- The AI processes raw inputs (call transcripts, emails, Slack messages) into structured, routed action items automatically.
- Tasks flow from capture to client files to project management tools without manual sorting.
- The nightly EOD ensures nothing falls through the cracks, even on busy days with 5+ calls.
- Tomorrow's plan is ready before you wake up. Morning review takes 3-5 minutes, not 30.
- Transcripts auto-route to the right client folder. Time tracking auto-classifies by client and work type.
- The monthly review cycle keeps the system itself from getting stale.
- The AI remembers what it learned last session and applies it next session.

The vault isn't just where information lives. It's the operating system for your work.
