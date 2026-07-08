# Onboard: Set Up Your Personal Assistant (Cloud Edition)

You are setting up the Claude Code Personal Assistant system for a new user. **This repository IS their vault** — it was created from Integral's template ("Use this template" on GitHub) and you personalize it in place. This is Part 1 of a 4-part setup:

1. **`/onboard`** (you are here) — Learn about the user, personalize the vault, configure the cloud environment
2. **`/train`** — Learn how the system works (the vault, git, skills, the daily loop)
3. **`/connect`** — Connect their tools (calendar, email, tasks, transcripts)
4. **`/finish`** — Live demo with real data, set up the nightly Routine, wrap up

**Voice:** Friendly, patient, non-technical. Explain everything in plain language. Use technical terms only in parentheses after the plain version.

**Important:** Use `AskUserQuestion` for EVERY question. Present 2-4 options with descriptions. Allow free-text input only when truly necessary (like entering a name). Never dump a wall of text — keep each step short and focused.

**Persistence rule for this command:** commit and push at the end of every build phase (6A-6G and 7), not just once at the end. If the session dies mid-setup, the next session picks up where this one left off instead of starting over. Check `git log` at the start: if you see "Onboard:" commits already, tell the user setup partially ran and resume from the first missing piece.

---

## Phase 0: Detect Environment

1. **Runtime mode.** Check the `CLAUDE_CODE_REMOTE` environment variable (`printenv CLAUDE_CODE_REMOTE`):
   - `true` → **Cloud mode** (Claude Code on the web). This is the primary path.
   - unset → **Local mode** (Claude Code CLI on the user's machine, working on a clone of this repo). Same personalization flow; skip the cloud-environment phases (1B, 6G) and note local specifics where flagged.
   Record this as `RUNTIME`.

2. **Template state.** Confirm `setup/templates/CLAUDE.md` exists and the root `CLAUDE.md` still says "Not Yet Personalized". If the root CLAUDE.md is already personalized, this vault has been set up before — ask the user whether they want to re-run setup (destructive: overwrites personalization) or just adjust something specific.

3. **Git state.** Run `git status -sb` and `git log --oneline -5`. Confirm you are on `main` (or the repo's default branch). If not, check out `main` before doing anything: setup builds the vault's foundation and it belongs on the default branch.

---

## Phase 1: Welcome

Give a brief welcome:
- What this system does (2-3 sentences, plain language: "I am going to turn this repository into your personal assistant's brain. It connects to your calendar, email, and task manager, runs daily routines to keep you organized, and works from the cloud — so it runs even when your computer is off.")
- Setup has 4 parts and the first part takes about 20 minutes
- They can stop at any point and come back — progress is saved to the repo as we go

**If cloud mode**, add one sentence of orientation: "One thing that makes the cloud version special: I save everything by committing it to this private GitHub repository. You'll see me do that as we go — every save is permanent and undoable."

---

## Phase 1B: Cloud Environment Check (cloud mode only)

**Skip entirely in local mode.**

Before building anything, make sure the session environment is set up. Run silently:

1. `printenv TZ` — is a timezone set?
2. `git push --dry-run` — can we push? (If this fails or warns about branch restrictions, note it for Phase 6G.)

**Do not walk the user through fixing these yet.** Environment configuration happens in Phase 6G after the interview, when you know their timezone and tools. Just record what's missing. If pushing fails entirely, pause and resolve it now (setup cannot save otherwise):

AskUserQuestion: "Quick technical check: I can't save to your repository yet. Did you create this repo from the template under your own GitHub account?"
Options:
- Yes, it is my repo
- Someone else created it for me
- I am not sure

Walk through the fix based on the error (usually: the Claude GitHub app needs access to this repo, granted at github.com/apps/claude → Configure).

---

## Phase 2: Who Are You?

### 2A: Name
Ask: "What should I call you?"
- Free text input

### 2B: Company Name
Ask: "What is the name of your company or business?"
- Free text input

### 2C: Research

**Before asking more questions, research the user and their company.** Use WebSearch to look up:
- The company name (website, what they do, industry, size)
- The person's name + company (LinkedIn, role, bio)
- Relevant context: what the company sells/does, who their clients are, team size

(If WebSearch is blocked by the environment's network policy, skip research gracefully and interview instead.)

**Present findings for verification:**

"Here is what I found about you and [Company Name]:
- [Company] appears to be a [description]
- Your role seems to be [role/title if found]
- [Other relevant details]"

AskUserQuestion: "How accurate is this?"
Options:
- That is spot on
- Mostly right, let me correct a few things
- Pretty far off, let me explain

Use corrections and research to inform the rest of the interview.

### 2D: Timezone
Ask: "What timezone are you in?"
Options:
- US Eastern (New York)
- US Central (Chicago)
- US Mountain (Denver)
- US Pacific (Los Angeles)

Note: "Type your timezone if it is not listed."

Map the answer to an IANA timezone name (e.g., `America/New_York`, `America/Chicago`). Record both the display name and the IANA name — the IANA name gets personalized into commands and set as the `TZ` environment variable in Phase 6G.

### 2E: Work Type
If research already revealed this, confirm instead of asking from scratch.

Otherwise ask: "What best describes your work?"
Options:
- I run my own business or consultancy (solo or small team)
- I work at a company and manage my own workload
- I manage a team and need to track their work too
- Something else (let me describe it)

---

## Phase 3: Your Tools

Collect which tools they use. We are NOT connecting them yet — just finding out what they have. Connections happen in `/connect`.

### 3A: Calendar
Ask: "What calendar do you use?"
Options:
- Google Calendar (Gmail/Google Workspace)
- Outlook / Microsoft 365
- Apple Calendar
- I do not use a digital calendar

### 3B: Email
Ask: "What email do you use for work?"
Options:
- Gmail / Google Workspace
- Outlook / Microsoft 365
- Apple Mail
- Other

### 3C: Task Manager
Ask: "Do you use a task or project management tool?"
Options:
- ClickUp
- Asana
- Trello
- Todoist
- I do not use one (I will use this system instead)
- Something else

### 3D: Meeting Recordings
Ask: "Do you record your meetings or get automatic transcripts?"
Options:
- Yes, I use Fathom
- Yes, I use another tool (Otter, Fireflies, etc.)
- No, but I would like to start
- No, and I do not need this

### 3E: Team Chat
Ask: "Do you use a team chat app?"
Options:
- Slack (ask how many workspaces if selected)
- Microsoft Teams
- Discord
- I do not use team chat

### 3F: Time Tracking
Ask: "Do you track your time?"
Options:
- Yes, I use Rize
- Yes, I use another tool (Toggl, Harvest, etc.)
- No, but I would like to start
- No, and I do not need this

---

## Phase 4: Your Schedule

### 4A: Work Hours
Ask: "When does your workday typically start?"
Options:
- Around 7:00 AM
- Around 8:00 AM
- Around 9:00 AM
- Different time (let me specify)

### 4B: End of Day
Ask: "When do you typically wrap up?"
Options:
- Around 4:00 PM
- Around 5:00 PM
- Around 5:30 PM
- Around 6:00 PM
- Different time

### 4C: Meeting Preferences
Ask: "When do you prefer to have meetings?"
Options:
- Mornings (before lunch)
- Afternoons (after lunch)
- A specific window (e.g., 1:00-3:00 PM)
- Spread throughout the day

### 4D: Protected Time
Ask: "Do you want to protect any time for focused work (no meetings)?"
Options:
- Yes, mornings are for deep work
- Yes, I want a specific block protected (let me specify)
- No, I am flexible
- Fridays should be meeting-free

### 4E: Lunch
Ask: "When do you usually take lunch?"
Options:
- Around 12:00 PM
- Around 12:30 PM
- Around 1:00 PM
- It varies / I eat at my desk

---

## Phase 5: Your Workflow Preferences

### 5A: Morning Routine
Ask: "How do you want to start your workday with Claude?"
Options:
- Full morning review: summary of tasks, meetings, and priorities with options to adjust (recommended)
- Quick check: just tell me the one most important thing
- Meeting prep only: just prepare me for today's meetings
- No morning routine

### 5B: End-of-Day Routine
Ask: "How do you want to end your workday?"
Options:
- Automatic: a scheduled Routine runs every night, processes calls, emails, and messages, and builds tomorrow's plan while you sleep (recommended — this is the cloud edition's superpower)
- Manual: I run one command before wrapping up and walk away while it works
- Simple daily note: Claude writes a summary of what happened today
- No end-of-day routine

If they chose Automatic, note it — `/finish` will set up the Routine via `/automate`.

### 5C: Where You'll Read Your Plan
The nightly routine writes `Inbox/Today.md`. Ask where they want to read it each morning:

AskUserQuestion: "Every morning there will be a fresh plan waiting in your vault. Where would you like to read it?"
Options:
- In a Claude session: open Claude Code (web or phone), type /morning, and I present it (simplest — nothing to install)
- In Obsidian on my computer: your vault syncs to your machine and opens as a beautiful notes app (I will help set up syncing in /train)
- On GitHub: read it in the GitHub app or website (works, but plainest)

Record as `READING_SURFACE`. This changes what `/train` teaches.

### 5D: Client Structure
If your research revealed clients, pre-populate: "It looks like you work with clients like [Client A] and [Client B]. Are these your current active clients?"

Otherwise: "Do you work with multiple clients or projects that should be tracked separately?"
Options:
- Yes, I have multiple clients (ask for names)
- Yes, I have multiple projects but they are all internal
- No, I mainly do one type of work

If they have clients, confirm the list (free text, comma-separated).

### 5E: Client Tiers (if applicable)
If they listed clients: "Are some clients higher priority than others?"
Options:
- Yes, let me rank them (then ask Tier 1 vs Tier 2)
- They are all roughly equal
- It changes week to week

---

## Phase 6: Build Everything

Tell the user what you are about to create before creating it. **Commit and push after each lettered step** with messages like `Onboard: folder structure`, `Onboard: personalized CLAUDE.md`.

### 6A: Vault Folder Structure

The vault root is this repository's root. Create the structure:

```
├── Inbox/
├── [CompanyName]/  (if provided)
│   ├── Hiring/
│   ├── SOPs/
│   └── Transcripts/
├── Work/
│   ├── Clients/    (with subfolders per client)
│   │   └── <ClientName>/
│   │       ├── Transcripts/
│   │       └── Archive/
│   ├── Transcripts/
│   ├── Sales Leads/
│   └── Daily/
├── Projects/
│   └── Personal/
├── Resources/
│   ├── API Keys/
│   ├── Concepts/
│   ├── People/
│   ├── Reference/
│   └── Health/
├── Graph/
├── Templates/
└── Archive/
```

Skip folders that do not apply based on their answers. Since git does not track empty folders, drop a short `README.md` in each folder explaining what belongs there (one or two sentences — these double as documentation for the user). Do NOT create an `Attachments/` folder — explain: "Files like images and PDFs stay in your Google Drive; we link to them from notes. That keeps your vault fast."

### 6B: CLAUDE.md

Read `setup/templates/CLAUDE.md` as the base. Customize with everything from the interview and research:

- Replace all placeholders: `[Your Name]`, `[Your Timezone]` (display name), `[IANA-Timezone]` (e.g. `America/Chicago`), `[YourCompany]`, `[Your Task Manager]`
- Fill in company context from research
- Update the daily schedule skeleton with their hours, lunch, meeting window
- Update the integrations sections: uncomment the connectors and API-key rows for tools they use, remove the rest
- Use actual client names (not `[Client A]`) in priority tiers and examples
- Adjust meeting window and protected time based on preferences

Write to the repo root `CLAUDE.md`, replacing the bootstrap version.

### 6C: Personalize the Commands

Customize the tool-specific commands in `.claude/commands/` in place. Customization never deletes a command — every command ships to every user:

- Replace `[IANA-Timezone]` / `[Your Timezone]` placeholders in `morning.md`, `eod.md`, all `eod-*.md`, `daily-note.md` with their real timezone
- Replace `[Client A]`-style placeholders with their real client names in `eod-gather.md`, `eod-today.md`, `morning.md`, `brain-dump.md`
- Wire their actual tools: if they do not use a time tracker, leave `eod-time.md` in place but note in `eod.md` that the time phase is skipped
- Replace `[YourCompany]` everywhere with the real company name

### 6D: Knowledge Graph Setup

Create starter files at `Graph/`:

1. **entity-registry.md** — Pre-populate with entries for each client and the user's company:

```markdown
# Entity Registry

Master lookup table for the knowledge graph. Maps searchable terms to wiki-link targets.

## How This Works
When the graph sync runs, it searches vault files for these terms and automatically creates wiki-links on first mention. Aliases are alternative terms that resolve to the same target.

## Clients

| Term | Page | Aliases |
|------|------|---------|
| [ClientName] | Work/Clients/[ClientName]/Company Profile | [abbreviations, alternate names] |

## People

| Term | Page | Aliases |
|------|------|---------|

## Concepts

| Term | Page | Aliases |
|------|------|---------|

## SOPs & Guides

| Term | Page | Aliases |
|------|------|---------|
```

2. **index.md** — Empty starter: "*Run `/graph-sync` to populate this index.*"

Do not create MOC files yet — `/graph-sync` generates those from actual content.

### 6E: Methodology Document

Copy `setup/templates/integral-methodology.md` to `Resources/Reference/How We Think About AI Agents.md`. Do not customize it — it is the same for every user.

### 6F: Inbox Starter Files

- One starter task file per client: `Inbox/<ClientName>.md` with the standard structure: Open Tasks, Pending from Others, Key Dates, Notes, Reference, Completed
- `Inbox/[YourCompany].md` (actual name) for cross-client/agency/internal tasks — same structure plus a `## Brain Dump` section near the top
- `Inbox/Personal.md` with the same structure
- `Inbox/Today.md` with a simple first-day message (it gets regenerated nightly once the EOD routine runs)

### 6G: Configure the Cloud Environment (cloud mode only)

**In local mode:** skip; just remind them to set `TZ` in their shell profile if their system timezone differs from their work timezone (rare), and move on.

This is the one part you cannot do for them — environment settings live in the claude.ai interface. Walk through each item with AskUserQuestion confirmations. Reference `setup/docs/environment-setup.md` for the details.

1. **Open environment settings:** "Go to **claude.ai/code**, find this repository's environment (usually named after the repo), and open its **settings**. Look for **Environment variables** and **Network access**."

2. **Timezone:** "Add an environment variable: name `TZ`, value `[their IANA timezone]`. This makes every session compute dates in your timezone instead of UTC — without it, anything I do late in the evening would think it is tomorrow."

AskUserQuestion: "Is the TZ variable saved?"
Options:
- Yes, saved
- I cannot find where to add variables
- I will do it later

(If "later": add a task to `Inbox/[YourCompany].md` — this one bites silently, so flag it as important.)

3. **Network access:** Based on their tools from Phase 3, tell them exactly which setting to choose:
   - If everything they use has a claude.ai connector (Google, Slack, ClickUp, etc.): "The default **Trusted** network setting is fine — connectors do not need special network access."
   - If they use API-key tools (Fathom, Rize, or similar): "Choose **Custom** network access and add these domains: [list from setup/docs/environment-setup.md, e.g. api.fathom.ai]. This lets me call those services directly."

4. **Branch pushes:** "Find the setting called **Allow unrestricted branch pushes** (in the repository/routine options) and enable it for this repo. Your vault is personal — I save directly to the main branch, and this setting allows that. Without it, my scheduled nightly runs would strand your daily plans on side branches you would have to merge by hand."

AskUserQuestion: "Were you able to enable unrestricted branch pushes?"
Options:
- Yes, enabled
- I cannot find that setting
- I will do it later

(If they cannot find it: it may be surfaced when creating a Routine — note it for `/automate`, which needs it anyway.)

5. **Setup script:** "You can leave the environment's Setup script empty. This vault ships with a session-start hook (in the repo itself) that handles the small installs automatically." (Only if this vault later gains heavyweight dependencies would a setup script be worth adding — see setup/docs/environment-setup.md.)

### 6H: Final Commit

Commit anything not yet committed and push:
```bash
git add -A && git commit -m "Onboard: vault personalized for [Name]" && git push
```
Confirm the push succeeded. If it fails, resolve before continuing — nothing is saved until this works.

---

## Phase 7: Wrap Up and Hand Off

Tell the user what was created (list every folder and key file).

Then explain what happens next:

"Your vault is built and your instruction manual is customized — and it is all saved to your private GitHub repository. Next, start a **fresh session** so I load your new instruction manual from the start."

Walk them through it, adapted to `RUNTIME`:

**Cloud mode:**
- "Step 1: End this session (you can just close this tab, everything is saved)."
- "Step 2: Go to **claude.ai/code** and start a **new session** on this same repository."
- "Step 3: In the new session, type exactly this: `/train`"
- "That is it. `/train` walks you through how your new system works."

**Local mode:**
- "Step 1: Close this session (`/exit` or Ctrl+C)."
- "Step 2: In your terminal: `cd [repo path] && claude`"
- "Step 3: Type `/train`"

AskUserQuestion: "Do you know what to do next?"
Options:
- Yes: new session on this repo, then type /train
- Can you repeat that?
- I am confused

If confused: re-explain in simpler language. Offer to stay in this conversation until they confirm.

**Important final note:** "When the new session starts, I will automatically read your CLAUDE.md — the instruction manual we just built. It knows your name, your clients, your schedule, and how you like things done. You will not need to explain anything again."

---

## Error Handling

- If the user seems confused, back up and explain in simpler terms
- If they want to skip a section, let them and note what was skipped in `Inbox/[YourCompany].md`
- If a push fails mid-setup: `git pull --rebase && git push`. If it still fails, stop and fix access before building more — unpushed setup is unsaved setup
- If the session dies mid-setup, the next `/onboard` run detects existing "Onboard:" commits and resumes rather than starting over
- Never hardcode a vault path — the vault root is always this repository's root
