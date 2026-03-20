# Onboard: Interactive Setup Interview

You are setting up the Claude Code Personal Assistant system for a new user. Walk them through the entire process using `AskUserQuestion` at every decision point. The user should never need to type long answers -- give them selectable options wherever possible.

**Voice:** Friendly, patient, non-technical. Explain everything in plain language. Use technical terms only in parentheses after the plain version.

**Important:** Use `AskUserQuestion` for EVERY question. Present 2-4 options with descriptions. Allow free-text input only when truly necessary (like entering a name). Never dump a wall of text -- keep each step short and focused.

---

## Phase 1: Welcome and Context

Start with a brief welcome. Tell the user:
- What this system does (in 2-3 sentences, plain language)
- That you will walk them through everything step by step
- That the whole process takes about 30 minutes
- They can stop at any point and pick up later by running `/onboard` again

Then begin the interview.

---

## Phase 2: About You

Collect the following using AskUserQuestion, one question at a time:

### 2A: Name
Ask: "What should I call you?"
- Free text input (no options needed for a name)

### 2B: Timezone
Ask: "What timezone are you in?"
Options:
- US Eastern (New York)
- US Central (Chicago)
- US Mountain (Denver)
- US Pacific (Los Angeles)

Include a note: "Type your timezone if it is not listed here."

### 2C: Work Type
Ask: "What best describes your work?"
Options:
- I run my own business or consultancy (solo or small team)
- I work at a company and manage my own workload
- I manage a team and need to track their work too
- Something else (let me describe it)

### 2D: Company Name (if applicable)
If they chose option 1 or 3 above, ask: "What is your company or business name?"
- Free text input
- This will become the `[YourCompany]/` folder name

If they chose option 2, ask: "What is your company name? (This is just for organizing your notes -- Claude will create a folder for company-specific documents.)"

---

## Phase 3: Your Tools

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

### 3G: Google Admin Check
If they selected Google Calendar or Gmail, ask:
"Have you ever used Google Cloud Console? (This is needed to connect Claude to your Google tools.)"
Options:
- Yes, I have access to console.cloud.google.com
- I am not sure
- No, and my company might block it
- I would rather skip Google setup for now

If they say "not sure" or "company might block it":
- Walk them through checking: go to console.cloud.google.com, try to sign in
- If blocked, explain the three options: ask IT, use personal Gmail, skip for now
- Use AskUserQuestion to let them choose which path

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
- Full morning review: summary of today's tasks, meetings, and priorities, with options to adjust (recommended)
- Quick check: just tell me the one most important thing to do first
- Meeting prep only: just prepare me for today's meetings
- No morning routine

### 5B: End-of-Day Routine
Ask: "How do you want to end your workday?"
Options:
- Full automated processing: Claude collects calls, emails, messages, and builds tomorrow's plan overnight (recommended)
- Simple daily note: Claude writes a summary of what happened today
- Manual brain dump: I will tell Claude what to capture
- No end-of-day routine

### 5C: Client Structure
Ask: "Do you work with multiple clients or projects that should be tracked separately?"
Options:
- Yes, I have multiple clients (ask for client names)
- Yes, I have multiple projects but they are all internal
- No, I mainly do one type of work

If they have clients, ask: "List your active clients or projects (you can always add more later)."
- Free text input, comma-separated

### 5D: Client Tiers (if applicable)
If they listed clients, ask: "Are some clients higher priority than others?"
Options:
- Yes, let me rank them (then ask which are Tier 1 vs Tier 2)
- They are all roughly equal priority
- It changes week to week

---

## Phase 6: Build Everything

Now generate all the files based on the interview answers. Tell the user what you are about to create before creating it.

### 6A: Create the Vault Folder Structure

Using Bash, create the folder structure inside the current directory (or ask where they want it if this does not seem like the right location):

```
Brain/
├── Inbox/
├── [CompanyName]/  (if provided)
│   ├── Hiring/
│   ├── SOPs/
│   └── Transcripts/
├── Work/
│   ├── Clients/    (with subfolders for each client if provided)
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
│   ├── Reference/
│   └── Health/
├── Templates/
├── Archive/
└── Attachments/
```

Skip folders that do not apply based on their answers (e.g., skip Sales Leads/ if they do not do sales).

### 6B: Generate CLAUDE.md

Read `templates/CLAUDE.md` from this repository as the base template. Then customize it with the interview answers:

- Replace `[Your Name]` with their name
- Replace `[Your Timezone]` with their timezone
- Replace `[YourCompany]` with their company name
- Update the daily schedule skeleton with their work hours, lunch, meeting window
- Update the integrations section based on their tools:
  - Remove integrations they do not use
  - Add notes about tools they mentioned that are not in the template
- Update client priority tiers if they provided clients
- Update the Friday rule if they did not mention wanting meeting-free Fridays
- Adjust the meeting window based on their preference

Write the customized CLAUDE.md to the vault root (Brain/CLAUDE.md or wherever they created it).

### 6C: Generate .env Template

Create a `.env` file at the vault root with only the services they selected, commented with instructions:

```bash
# Password keychain file for Claude
# Fill in credentials as you connect each tool.
# See docs/integration-architecture.md for setup instructions.

# Google (Calendar + Gmail) -- requires OAuth setup
# GOOGLE_CLIENT_ID=
# GOOGLE_CLIENT_SECRET=
# GOOGLE_REFRESH_TOKEN=

# (etc., only for tools they selected)
```

### 6D: Generate Settings Files

Ask: "Where should I save your Claude Code permission settings?"
Options:
- Global settings (applies everywhere on your computer) -- recommended for most people
- Just for this project (local settings only)
- Both (global + local overrides)

Then write the appropriate settings files:
- Global: `~/.claude/settings.json` (read the existing file first if it exists, merge permissions)
- Local: `Brain/.claude/settings.local.json`

Use the contents from `examples/settings.json` and `examples/settings.local.json` in this repo as the base. Customize the MCP permissions list to only include tools they are actually using.

### 6E: Create First Slash Command

Based on their workflow preferences (Phase 5), create their first saved routine:

- If they chose "full morning review" -> create `.claude/commands/morning.md` in their vault based on `examples/commands/morning.md`
- If they chose "full automated processing" for EOD -> create `.claude/commands/eod.md` based on `examples/commands/eod-gather.md`
- If they chose "simple daily note" -> create a simplified `.claude/commands/daily-note.md`
- If they chose "manual brain dump" -> create `.claude/commands/brain-dump.md`

Customize the command content based on their specific tools, clients, and schedule.

### 6F: Create Inbox Starter Files

Create `Brain/Inbox/Incoming.md` with a starter structure:

```markdown
# Incoming -- Overview

## Client Boards
| Client | Open Tasks | Next Deadline | Status |
|--------|-----------|---------------|--------|
| [ClientA] | 0 | -- | New |
(repeat for each client)

## Cross-Client Tasks
- (none yet)

## Completed
- (none yet)
```

Create a starter file for each client: `Brain/Inbox/ClientName.md`

Create `Brain/Inbox/Today.md` with a simple first-day plan.

---

## Phase 7: First Tool Connection

Ask: "Would you like to connect your first tool right now?"
Options:
- Yes, let us set up [their most impactful tool based on answers]
- Yes, but a different one (show list)
- No, I will do this later

If yes, walk them through the connection step by step:
- For Google: OAuth setup in Cloud Console (check admin access first)
- For ClickUp: MCP server setup in Claude Code settings
- For Fathom: API key from their Fathom settings page
- For Slack: OAuth app creation or API token

Use AskUserQuestion at each step to confirm they completed it before moving on.

---

## Phase 8: Summary and Next Steps

Present a clear summary of everything that was created:

```
Here is what I set up for you:

Folders created:
- Brain/Inbox/ (with starter files for [N] clients)
- Brain/Work/Clients/ (with folders for [Client A], [Client B])
- Brain/[Company]/ (company docs)
- (etc.)

Files created:
- Brain/CLAUDE.md (your instruction manual, customized)
- Brain/.env (password keychain template)
- Brain/.claude/commands/morning.md (your morning review routine)
- (etc.)

Settings updated:
- ~/.claude/settings.json (permissions configured)
```

Then give them three concrete next steps:

1. **Right now:** Open Obsidian and point it at the Brain/ folder you just created
2. **Today:** Fill in your first `.env` credential (walk them through whichever tool they chose)
3. **Tomorrow morning:** Try running `/morning` to see your first daily review

Ask: "Any questions about what we set up, or would you like to adjust anything?"

---

## Error Handling

- If the user seems confused at any point, back up and explain in simpler terms
- If they want to skip a section, let them. Mark it as "skipped" and mention they can come back
- If a file already exists (e.g., they ran `/onboard` before), ask before overwriting
- If they are running this from the repo directory (not a vault), create the vault structure in a sibling directory or ask where they want it
