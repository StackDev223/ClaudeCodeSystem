# Onboarding Guide: Setting Up Your Personal Assistant

This guide is a reference for what the setup process covers. **You do not need to follow these steps manually.** Instead, open Claude Code in the repository folder and type:

```
/onboard
```

Claude will interview you using a friendly question-and-answer format with selectable options (no typing required for most questions). It will ask about your name, tools, schedule, and preferences, then build everything for you in about 30 minutes.

The steps below explain what `/onboard` sets up, so you can understand what each piece does or make changes later.

**What you will need:**
- A Mac or PC
- [Obsidian](https://obsidian.md) (free)
- A [Claude Code subscription](https://claude.ai)

**What you are building:** A personal assistant that lives in your notes folder. It reads your calendar, processes your email, tracks your tasks, and builds tomorrow's plan while you sleep. By the end of setup, you will have a working daily system.

---

## Step 1: Give Claude Permission to Help You

Before Claude can do anything, it needs permission to read and write files, run commands, and connect to your tools. There are two permission files: one for global settings (applies everywhere) and one for local settings (applies only inside your notes folder).

### Global Settings

This file lives at `~/.claude/settings.json` (your home folder, inside the `.claude` folder). It controls what Claude can do everywhere on your computer.

Copy and paste this into the file:

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Edit",
      "Write",
      "NotebookEdit",
      "Bash(*)",
      "mcp__clickup__*",
      "mcp__supabase__*",
      "mcp__trigger__*",
      "mcp__context7__*",
      "mcp__unframer__*"
    ],
    "additionalDirectories": [
      "/private/tmp",
      "$HOME/Desktop",
      "$HOME/Downloads",
      "$HOME/Library/LaunchAgents",
      "$HOME/scripts"
    ]
  },
  "alwaysThinkingEnabled": true,
  "effortLevel": "high"
}
```

**What each permission means:**

| Permission | What it allows |
|---|---|
| `Read` | Claude can read files on your computer |
| `Edit` | Claude can make changes to existing files |
| `Write` | Claude can create new files |
| `NotebookEdit` | Claude can work with notebook files |
| `Bash(*)` | Claude can run terminal commands |
| `mcp__clickup__*` | Claude can use ClickUp (task management) |
| `mcp__supabase__*` | Claude can use Supabase (database) |
| `mcp__trigger__*` | Claude can use Trigger.dev (automation) |
| `mcp__context7__*` | Claude can look up documentation |
| `mcp__unframer__*` | Claude can use Unframer (design tool) |

**Adding more tools:** Each tool Claude connects to needs its own permission line. If you connect Claude to Gmail or Google Calendar through Claude.ai, add lines like `"mcp__claude_ai_Gmail__*"` and `"mcp__claude_ai_Google_Calendar__*"` to the allow list. The pattern is always `mcp__` followed by the tool name and `__*`.

**Additional directories** are folders outside your notes folder that Claude can access. The defaults cover your Desktop, Downloads, temporary files, scheduled tasks, and scripts.

### Local Settings

This file lives at `.claude/settings.local.json` inside your notes folder (the vault). It controls what Claude can do when working in that specific folder.

Copy and paste this into the file:

```json
{
  "permissions": {
    "allow": [
      "Bash(*)",
      "Read(/tmp/**)",
      "WebSearch",
      "WebFetch(*)"
    ]
  }
}
```

**What each permission means:**

| Permission | What it allows |
|---|---|
| `Bash(*)` | Claude can run terminal commands |
| `Read(/tmp/**)` | Claude can read temporary files |
| `WebSearch` | Claude can search the web for current information |
| `WebFetch(*)` | Claude can visit web pages to get information |

You do not need to duplicate permissions from the global file here. The global settings already cover file reading, editing, writing, and tool connections.

---

## Step 2: Install Obsidian and Create Your Notes Folder

Obsidian is a notes app where your notes live on your computer as plain text files instead of on someone else's server. Claude can read files on your computer instantly, which makes Obsidian a perfect workspace.

### Download and Install

1. Go to [obsidian.md](https://obsidian.md) and download the app for your computer
2. Install and open it
3. Choose **"Create new vault"**
4. Name it something like **"Brain"** (or whatever you prefer)
5. Choose where to save it (your Documents folder works fine)

### Create Your Starter Folders

Inside your new notes folder, create these three folders:

```
Brain/
├── Inbox/       (where new items go)
├── Work/        (professional projects)
└── Resources/   (reference material)
```

You can create more folders later. These three are enough to start.

For a detailed guide on folder structure and how everything fits together, see the [Vault Design Guide](vault-design-guide.md).

---

## Step 3: Create Claude's Instruction Manual

The instruction manual (called `CLAUDE.md`) is the most important file in the system. Claude reads it every session to know how you want things done.

1. Copy the template from `templates/CLAUDE.md` in this repository
2. Paste it into a new file called `CLAUDE.md` at the root of your notes folder
3. Customize it:
   - Replace `[Your Name]` with your name
   - Replace `[Your Timezone]` with your timezone
   - Replace `[YourCompany]` with your company name (or remove those sections if not applicable)
   - Update the client list and priority tiers to match your situation
   - Adjust the daily schedule skeleton to match your routine

**You do not need to fill in everything right now.** Start with your name, timezone, and daily schedule. Add integrations and workflows as you connect tools.

The template includes sections for:
- **What Claude should do first** every session (startup checklist)
- **Where things go** in your notes folder (quick reference)
- **What tools are connected** (integrations)
- **How Claude should behave** (guidelines and preferences)
- **Common workflows** (step-by-step routines)

---

## Step 4: Connect Your First Tool

Start with one tool. The best first connection depends on what would save you the most time.

**Recommended first connections:**
- **Google Calendar** -- Know what is coming tomorrow, create time blocks
- **ClickUp** (or your task manager) -- Track and update tasks
- **Gmail** -- Surface emails needing responses

### Google Calendar or Gmail Setup

Google tools require a secure login handshake (called "OAuth"). This means you need to set up a Google project that gives Claude permission to access your calendar and email.

#### Check: Do You Have Google Admin Access?

Before starting, check whether your Google account allows you to set up these connections:

1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Try to sign in with your work email

**If you can sign in and see a dashboard:** You have access. Continue to the setup below.

**If you see "This service is not available" or a blocked page:** Your organization's IT team has restricted access. You have three options:
- **Ask IT:** Request access to Google Cloud Console for creating OAuth credentials. Explain you need it for a personal productivity tool.
- **Use a personal Gmail:** Set up the connection with your personal Gmail account instead. You can still add your work calendar later using calendar sharing.
- **Skip Google for now:** Move on to a different tool (like ClickUp) and come back to Google later.

#### Google Workspace Admin (Optional)

If you manage your organization's Google account, there is a separate admin panel at [admin.google.com](https://admin.google.com). This is where you control things like which apps your team can use. You only need this if you want to enable Google connections for other people in your organization. For personal use, the Cloud Console above is all you need.

### Setting Up the Connection

See [Integration Architecture](integration-architecture.md) for detailed step-by-step instructions on connecting each tool, including how to get your login credentials and store them in the password keychain file (.env).

---

## Step 5: Discover Your Personal Workflow

Before building saved routines, think about how you want your day to flow. This section helps you figure out what would be most useful.

### How Do You Want to Start Your Day?

Pick the option that sounds most like you:

- **A) "Show me what is on my plate."** You want a summary of today's tasks, meetings, and priorities. (This is the `/morning` routine.)
- **B) "Just tell me the one thing to focus on."** You want a single top priority, not a full review. (A simplified morning check.)
- **C) "I already know what I am doing. Just prep my meetings."** You want meeting context and prep notes without the full planning flow.

### How Do You Want to End Your Day?

- **A) "Process everything automatically while I sleep."** Full end-of-day pipeline: transcripts, email, Slack, task sync, tomorrow's plan. (The `/eod` pipeline.)
- **B) "Just capture what happened today."** A daily summary note without the full processing. (A simplified daily note.)
- **C) "I will tell Claude what happened."** A manual brain dump where you dictate what to capture.

### What Routines Would Help You Most?

Pick all that apply:

- [ ] **Morning review** -- Confirm today's plan, adjust priorities, create calendar time blocks
- [ ] **Meeting prep** -- Context and talking points before each meeting
- [ ] **Email triage** -- Surface emails that need responses, draft replies
- [ ] **Task sync** -- Keep your notes folder and task manager in sync
- [ ] **Daily summary** -- A record of what happened today
- [ ] **Tomorrow's plan** -- Pre-built schedule and priorities for the next day
- [ ] **Weekly reset** -- Archive completed work, carry forward open items
- [ ] **Monthly review** -- Check what is working, clean up, improve the system

Your answers shape which saved routines you should build first. Start with one or two that would save you the most time.

---

## Step 6: Create Your First Saved Routine

A saved routine (called a "slash command") is a text file that tells Claude how to run a multi-step process. You type `/routine-name` and Claude does the rest.

### Create the Folder

Inside your notes folder, create this path:

```
Brain/.claude/commands/
```

### Write Your First Routine

Based on your workflow answers in Step 5, pick one to start with. Here is a simple morning review example:

Create a file called `morning.md` inside `.claude/commands/`:

```markdown
# Morning Review

## Step 1: Check the Date
Run `date` to verify today's date.

## Step 2: Read Today's Plan
Read `Inbox/Today.md` and summarize:
- How many meetings today and when
- Top 3 priorities
- Any deadlines this week

## Step 3: Ask for Adjustments
Ask: "Any changes to today's plan?"
- If yes, discuss and update
- If no, confirm the plan is locked

## Step 4: Send-Off
Announce the first priority and wish a good morning.
```

Now when you type `/morning` in Claude Code, it will run through these steps automatically.

### Building More Routines

See the [examples/commands/](../examples/commands/) folder for full examples of:
- End-of-day processing (`eod-gather.md`)
- Morning interactive review (`morning.md`)

Start simple. Add complexity as you learn what works for you.

---

## Step 7: Your First Full Day

Here is what a day looks like with the system running:

### The Night Before

If you have the nightly automation set up (see [Daily Workflow](daily-workflow.md)), Claude processes your calls, emails, and messages overnight and builds tomorrow's plan in `Inbox/Today.md`.

If you do not have automation yet, you can run `/eod` manually before bed, or skip this step and start fresh in the morning.

### Morning (5 minutes)

1. Open Obsidian and read `Inbox/Today.md`
2. Open Claude Code in your notes folder
3. Type `/morning`
4. Claude walks you through:
   - Today's schedule and priorities
   - Any conflicts or concerns
   - Calendar time blocks to create
5. Confirm the plan. You are ready to start.

### During the Day

Use Claude whenever you need help:
- "Draft a reply to [Contact]'s email about the timeline"
- "What do I have with [Client] this week?"
- "Add a task to follow up with [Name] by Friday"
- "Summarize the notes from yesterday's call with [Client]"

### End of Day

Run `/eod` (or let it run automatically at 11:30 PM) to:
- Process any remaining items
- Sync tasks with your task manager
- Generate tomorrow's plan

### Over Time

The system improves as you use it:
- When Claude makes a mistake, add a guideline to CLAUDE.md
- When you repeat a process manually, turn it into a saved routine
- When a tool connection would save time, add it
- Run `/monthly-review` once a month to clean up and improve

---

## Glossary

Plain-language definitions for terms you will see in the documentation.

| Term | What It Means |
|---|---|
| **Vault** | Your notes folder. Obsidian calls it a "vault" but it is just a folder of text files on your computer. |
| **CLAUDE.md** | Claude's instruction manual. A text file at the root of your notes folder that Claude reads every session. |
| **Slash command** | A saved routine. A text file that tells Claude how to run a multi-step process. You type `/name` to run it. |
| **MCP server** | A direct connection between Claude and a tool (like ClickUp or Google Calendar). Once set up, Claude can use the tool without going through a browser. |
| **API** | A way for software to talk to other software. When Claude "calls an API," it is asking another service for information or telling it to do something. |
| **OAuth** | A secure login handshake. Instead of giving Claude your password, OAuth lets you approve access once and Claude gets a special key to use going forward. |
| **.env file** | Your password keychain file. A text file that stores all the login information Claude needs for your tools. It never leaves your computer. |
| **Manifest** | A tracking list. During long processes, Claude writes down every item it finds so nothing gets lost. |
| **EOD pipeline** | The end-of-day routine. A multi-step process that collects everything from your day and builds tomorrow's plan. |
| **launchd / cron** | Scheduled task runners. They tell your computer to run something at a specific time (like the nightly end-of-day at 11:30 PM). launchd is for Mac, cron is for Linux. |
| **Context window** | Claude's working memory for a single conversation. Claude can hold a lot of information at once, but very long sessions may compress older details. That is why important things get written to files. |
