# Integration Architecture: How the Brain System Connects Everything

> **You do not need to understand every detail in this document.** Claude can walk you through setting up any connection. This is a reference for when you want to know how things work under the hood.

This document explains the technical architecture behind the Brain personal assistant system. It covers how a `.env` file, MCP servers, REST/GraphQL API calls, custom scripts, and slash commands work together to turn an Obsidian vault into an automated operations hub.

---

## The Four Integration Layers

The system connects to external platforms through four layers, each serving a different purpose:

```
┌─────────────────────────────────────────────────┐
│                  Claude Code (AI Agent)          │
│          Reads CLAUDE.md for instructions        │
│          Reads .env for credentials              │
│          Executes slash commands                  │
├─────────────────────────────────────────────────┤
│                                                   │
│  Layer 1: .env File                              │
│  Where your login information is stored          │
│  → Passwords, keys, and tokens in one place     │
│                                                   │
│  Layer 2: Direct Connections (MCP Servers)       │
│  Tools Claude can use directly, like built-in    │
│  apps                                            │
│  ClickUp, Supabase, Google Calendar, etc.        │
│  → No extra steps needed, they just work         │
│                                                   │
│  Layer 3: Tool Connections (REST/GraphQL APIs)   │
│  Tools Claude accesses using your saved          │
│  passwords                                       │
│  Gmail, Slack, Fathom, Rize, n8n, Google Drive   │
│  → Claude runs commands using credentials        │
│    from .env                                     │
│                                                   │
│  Layer 4: Custom Scripts (Python/Bash helpers)   │
│  Multi-step recipes for complicated operations   │
│  fathom-fetch.py, classify-transcript.py, etc.   │
│  → Reusable scripts that handle complex tasks    │
│                                                   │
│  Layer 5: Scheduled Automation (launchd / cron)  │
│  Runs things automatically on a schedule         │
│  eod-cron.sh, version pinning, lockfiles         │
│  → Unattended nightly routines                   │
│                                                   │
├─────────────────────────────────────────────────┤
│                  Obsidian Vault                   │
│           (markdown files on disk)               │
│        Source of truth for all task state         │
└─────────────────────────────────────────────────┘
```

---

## Layer 1: The .env File (Credential Management)

Every API key, OAuth token, and secret lives in a single `.env` file at the vault root. This file is:

- **Gitignored** (never committed to version control)
- **Local-only** (excluded from iCloud sync if applicable)
- **The single source of truth** for credentials

### What's in the .env

```bash
# Google OAuth (used for Gmail, Calendar, Drive, Docs)
GOOGLE_CLIENT_ID=...
GOOGLE_CLIENT_SECRET=...
GOOGLE_REFRESH_TOKEN=...

# Fathom (meeting transcripts)
FATHOM_API_KEY=...

# Slack (one token per workspace)
SLACK_TOKEN_WORKSPACE_A=xoxp-...
SLACK_TOKEN_WORKSPACE_B=xoxp-...
SLACK_TOKEN_WORKSPACE_C=xoxp-...

# Rize (time tracking)
RIZE_API_KEY=...

# n8n (one URL + key per instance)
N8N_INSTANCE_A_URL=https://...
N8N_INSTANCE_A_API_KEY=...
N8N_INSTANCE_B_URL=https://...
N8N_INSTANCE_B_API_KEY=...
```

See `templates/.env.example` for a full list of supported variables with descriptions.

### How the AI Uses It

At the start of any workflow that needs API access, the AI runs:

```bash
source "/path/to/vault/.env"
```

This loads all credentials as environment variables. Then API calls reference them:

```bash
curl -s -H "X-Api-Key: ${FATHOM_API_KEY}" \
  "https://api.fathom.ai/external/v1/meetings?include_transcript=true"
```

### Why Not Use a Secrets Manager?

Simplicity. The vault runs on one machine. The AI agent reads from the local filesystem. A `.env` file is the simplest thing that works. No network calls to a vault service, no token rotation complexity, no extra dependencies. The security model is: if someone has access to this machine, they have access to everything anyway.

### Reference Pointers in the Vault

The vault has a `Resources/API Keys/` folder with markdown files that document which credentials exist and where they're stored, but contain zero actual secrets. Example content:

```markdown
# Fathom API Key
- **Stored in**: `.env` as `FATHOM_API_KEY`
- **Type**: API key (X-Api-Key header)
- **Scopes**: Read meetings, transcripts, summaries
- **Rate limit**: 60 calls/min
```

This lets you browse your integrations in Obsidian without exposing secrets.

---

## Layer 2: Direct Connections (MCP Servers)

Some tools have a direct connection built for Claude. Think of them as built-in apps -- Claude can use them directly without going through a browser or typing passwords. Technically these are called "MCP servers" (Model Context Protocol), but all you need to know is that once they are set up, they just work. Instead of writing commands, Claude calls tools like `clickup_create_task` or `supabase_execute_sql` as native functions.

### How MCP Servers Work

MCP servers are configured in Claude Code's settings (not in the vault). Each server:
1. Connects to an external service (ClickUp, Supabase, Google Calendar, etc.)
2. Exposes a set of tools (functions) the AI can call directly
3. Handles authentication internally (credentials configured once during setup)

### When to Use MCP vs. REST API

| Use MCP When | Use REST API When |
|---|---|
| A server exists for the service | No MCP server available |
| You need structured tool calls (create task, run SQL) | You need raw API flexibility |
| The operation is common and well-supported | The operation is niche or custom |
| You want the AI to have typed parameters and validation | You need full control over headers, pagination, etc. |

### Example: ClickUp (MCP)

The AI can call ClickUp tools directly:

```
clickup_create_task(
  list_id: "901323564130",
  name: "Fix login page timeout",
  description: "Users report 504 errors after 30 seconds",
  status: "to do",
  priority: 2
)
```

No curl, no auth headers, no JSON parsing. The MCP server handles all of that.

### Example: Supabase (MCP)

Direct SQL execution against your database:

```
supabase_execute_sql(
  project_id: "your_project_id",
  query: "SELECT * FROM projects WHERE customer_id = 'abc123'"
)
```

This is used heavily in audit delivery workflows to populate client portals, insert assessment scores, and create project structures.

---

## Layer 3: REST/GraphQL APIs (Via Shell Commands)

For services without MCP servers, the AI makes direct API calls using curl in the shell. This is more manual but gives full flexibility.

### OAuth2 Refresh Token Flow (Google Services)

Google services (Gmail, Calendar, Drive, Docs) use OAuth2. The `.env` stores a long-lived refresh token. The AI exchanges it for a short-lived access token at runtime:

```bash
source ".env"

# Get a fresh access token
ACCESS_TOKEN=$(curl -s -X POST "https://oauth2.googleapis.com/token" \
  --data "grant_type=refresh_token&client_id=${GOOGLE_CLIENT_ID}&client_secret=${GOOGLE_CLIENT_SECRET}&refresh_token=${GOOGLE_REFRESH_TOKEN}" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")

# Use it immediately
curl -s "https://gmail.googleapis.com/gmail/v1/users/me/messages?q=newer_than:1d" \
  -H "Authorization: Bearer $ACCESS_TOKEN"
```

**Key gotcha**: Each shell command runs in an isolated session. Environment variables don't persist between commands. Either chain commands with `&&` or extract the token value and pass it explicitly.

### API Key Auth (Fathom, n8n)

Simpler services use static API keys passed in headers:

```bash
source ".env"

# Fathom: list today's meetings
curl -s -H "X-Api-Key: ${FATHOM_API_KEY}" \
  "https://api.fathom.ai/external/v1/meetings?created_after=2026-03-06T00:00:00Z&include_transcript=true"

# n8n: list workflows on an instance
curl -s -H "X-N8N-API-KEY: ${N8N_INSTANCE_A_API_KEY}" \
  "${N8N_INSTANCE_A_URL}/api/v1/workflows"
```

### Per-Workspace Tokens (Slack)

Slack requires a separate OAuth token for each workspace. The `.env` stores one per workspace:

```bash
# Check DMs in Workspace A
curl -s "https://slack.com/api/conversations.list?types=im" \
  -H "Authorization: Bearer ${SLACK_TOKEN_WORKSPACE_A}"

# Post to a channel in Workspace B
curl -s -X POST "https://slack.com/api/chat.postMessage" \
  -H "Authorization: Bearer ${SLACK_TOKEN_WORKSPACE_B}" \
  -H "Content-Type: application/json" \
  -d '{"channel":"C0AGY6548HH","text":"Hello from the AI"}'
```

### GraphQL (Rize Time Tracking)

```bash
curl -s -X POST "https://api.rize.io/api/v1/graphql" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${RIZE_API_KEY}" \
  -d '{"query": "{ sessions(startTime: \"2026-03-06T05:00:00Z\", endTime: \"2026-03-07T05:00:00Z\") { id title startTime endTime type } }"}'
```

---

## Layer 4: Custom Scripts (Complex Operations)

When an operation is too complex for a single curl command, or needs to be reusable, it lives in a `scripts/` folder as a Python or Bash script.

### Why Scripts?

- **State management**: Some operations need to track what's already been processed (e.g., which Slack messages have been ingested)
- **Multi-step logic**: Pagination, deduplication, conditional branching
- **Reusability**: The AI calls the same script from different slash commands
- **Testability**: Scripts can be tested independently

### Script Catalog

| Script | Language | Purpose |
|--------|----------|---------|
| `fathom-fetch.py` | Python | Deterministic Fathom transcript download. Downloads today's calls, classifies per-client routing, returns JSON report. |
| `classify-transcript.py` | Python | Routes transcript files to the correct client folder based on participant names and call title. |
| `rize-daily-triage.sh` | Bash | Fetches Rize time tracking sessions, detects gaps, generates classification input. |
| `rize_classify.py` | Python | Two-axis classification: client (who) + work_type (delivery/sales/audit/meeting/admin/internal). |
| `eod-runner.sh` | Bash | Orchestrates EOD phases sequentially with timeouts, logging, and notifications. |
| `eod-cron.sh` | Bash | Cron wrapper with version pinning, lockfiles, and Gatekeeper handling. |
| `n8n-test.py` | Python | Tests n8n workflows across multiple instances. Trigger, activate, inspect node data. |
| `chrome-debug.sh` | Bash | Launches Chrome with remote debugging port for agent-browser CDP mode. |

### Transcript Routing Architecture

Call transcripts are auto-routed to the correct folder by `classify-transcript.py`:

```
Fathom API
    |
    v
fathom-fetch.py (downloads transcript)
    |
    v
classify-transcript.py (determines client from participants + title)
    |
    ├── Client contact detected ──> Work/Clients/<Client>/Transcripts/
    ├── Dev team only ────────────> Work/Transcripts/
    └── Partner/private ──────────> [YourCompany]/Transcripts/
```

The classifier uses a contact-to-client mapping (configured in the script) and falls back to title-based heuristics for edge cases. The AI can override classifications when the script gets it wrong.

### Rize Time Tracking Architecture

Time tracking uses a two-axis classification system:

- **Axis 1: Client** -- Who is the time for? (Client A, Client B, internal, etc.)
- **Axis 2: Work Type** -- What kind of work? (delivery, sales, audit, meeting, admin, internal)

```
Rize API (sessions)
    |
    v
rize-daily-triage.sh (fetch + gap detection)
    |
    v
rize_classify.py (two-axis classification)
    |
    v
EOD Phase 3: review + relabel via Rize API
```

The classifier uses app patterns (which apps map to which clients), calendar cross-referencing, and transcript matching to determine both axes. Sessions during detected gaps are reconstructed from per-hour app usage data.

### Example: Cron Automation

`eod-cron.sh` runs on a schedule via macOS `launchd` (the macOS equivalent of cron). It manages:

1. **Version pinning**: Uses a specific Claude CLI version (stored in a pin file) to avoid TCC permission dialogs from auto-updates. Notifies when a newer version is available.
2. **Lockfile**: Prevents overlapping runs if a previous EOD is still executing.
3. **Gatekeeper bypass**: Strips `com.apple.provenance` xattr from the pinned binary.
4. **Path setup**: Ensures Claude CLI and Homebrew tools are on PATH for launchd context.

```bash
#!/bin/bash
# Simplified cron wrapper pattern
BRAIN_DIR="/path/to/vault"
RUNNER="$HOME/scripts/eod-runner.sh"

# Lockfile to prevent overlapping runs
LOCKFILE="/tmp/eod-runner.lock"
if [ -f "$LOCKFILE" ]; then
  LOCK_PID=$(cat "$LOCKFILE" 2>/dev/null)
  if kill -0 "$LOCK_PID" 2>/dev/null; then
    echo "SKIPPED: Previous run still active" >&2
    exit 0
  fi
  rm -f "$LOCKFILE"
fi
echo $$ > "$LOCKFILE"
trap 'rm -f "$LOCKFILE"' EXIT

cd "$BRAIN_DIR"
source "$RUNNER"
```

The `launchd` plist schedules this at 11:30 PM weekdays. See `examples/scripts/` for full sanitized versions.

---

## Slash Commands: Orchestrating Everything

Slash commands are the glue. They're markdown files in `.claude/commands/` that define multi-step workflows. When you type `/command-name`, the AI reads the markdown file and executes each step.

### Anatomy of a Slash Command

Each command file is essentially a detailed prompt with:

1. **Setup**: Load credentials, verify date, check preconditions
2. **Data gathering**: Pull from APIs, read vault files, query databases
3. **Processing**: Classify, extract, transform, score
4. **Routing**: Write results to the right vault files
5. **Sync**: Push state to external systems (ClickUp, Supabase, Slack)
6. **Summary**: Report what was done

### Command Catalog

#### EOD Phase 1: `/eod-gather` (Data Gathering)

The daily workhorse. Touches nearly every integration:

| Section | Integration | What It Does |
|---|---|---|
| 0. Brain Dump Triage | Vault files | Classify and route brain dump items to client files |
| 1. Call Transcripts | Fathom API + classify-transcript.py | Pull today's meetings, save transcripts, classify per-client, extract action items |
| 2. Tomorrow's Calendar | Google Calendar API | Fetch tomorrow's schedule, flag early meetings |
| 3. Email Check | Gmail API | Surface emails needing responses, cross-reference with tasks |
| 4. Slack Check | Slack API (all workspaces) | Surface unread DMs and mentions across all workspaces |

**Key pattern: Route-as-you-go.** Every section routes its extracted items to client files immediately, rather than batching them for later. This prevents items from being lost if the session runs long and context gets compressed.

**Key pattern: Manifest tracking.** A manifest file (`/tmp/eod-manifest-TODAY.md`) tracks every extracted item with its source, type, destination, and status. This serves as an audit trail and prevents items from falling through the cracks.

#### EOD Phase 2: `/eod-sync` (Verify + Sync)

| Step | Integration | What It Does |
|---|---|---|
| Deduplication | Vault files | Remove duplicate tasks across client files |
| Completed cleanup | Vault files | Move checked items to Completed sections |
| Client Boards | Vault files | Update overview table in Incoming.md |
| ClickUp sync | ClickUp MCP | Create new tasks, update statuses |
| Vault hygiene | Vault files | Flag stale items, Monday weekly archiving |

#### EOD Phase 3: `/eod-rize` (Time Tracking)

| Step | Integration | What It Does |
|---|---|---|
| Fetch sessions | Rize GraphQL API | Pull today's time tracking data |
| Gap detection | Rize API + calendar | Find untracked periods, reconstruct from app data |
| Classification | rize_classify.py | Two-axis: client + work type |
| Relabeling | Rize API mutations | Apply correct labels via API |

#### EOD Phase 4: `/eod-note` (Daily Note)

| Step | Integration | What It Does |
|---|---|---|
| Generate summary | Vault files + manifest | Create `Work/Daily/YYYY-MM-DD.md` with full day summary |

#### EOD Phase 5: `/eod-today` (Tomorrow's Plan)

| Step | Integration | What It Does |
|---|---|---|
| Calendar fetch | Google Calendar API (or cached from Phase 1) | Tomorrow's schedule |
| Priority ranking | Vault files (inbox + manifest) | Select top 5-7 tasks by tier and deadline |
| Meeting prep | Vault files (transcripts + profiles) | Context for each meeting |
| Carry forward | Today's Today.md | Detect unchecked tasks, increment carry count |
| Team priorities | Vault files + ClickUp | Generate delegation message |
| Write Today.md | Vault write | Overwrite `Inbox/Today.md` |

#### `/morning` (Morning Review)

Interactive command with `AskUserQuestion` at every decision point:

| Step | Integration | What It Does |
|---|---|---|
| Load + stale check | Vault read | Read Today.md, verify date matches |
| Summary | Vault read | Present 8-10 line overview |
| Client review | AskUserQuestion | Batch review with adjustment options |
| Goal check | Vault read + AskUserQuestion | Detect stale goals, prompt for refresh |
| Time blocks | Google Calendar MCP | Create deep work blocks |
| Send-off | Text output | Confirm plan, announce first priority |

#### `/monthly-review` (Monthly Review)

| Step | Integration | What It Does |
|---|---|---|
| System feedback | AskUserQuestion | Collect improvement ideas |
| Vault cleanup | Vault scan | Surface stuck, stale, or misplaced items |
| Testimonial scan | Slack API + vault search | Find positive client feedback |
| Apply updates | Vault writes | Route improvements to appropriate files |

#### Other Commands

| Command | What It Does |
|---|---|
| `/debrief [Name]` | Post-interview candidate assessment against criteria |
| `/audit-research [Client]` | Pull assessment data, generate research doc |
| `/audit-roadmap [Client]` | Transform research into client-facing roadmap |
| `/audit-review [Client]` | 11-point QC gate with auto-fix offer |
| `/audit-deliver [Client]` | Populate portal, create projects/milestones, draft email |
| `/browse [URL]` | Browser automation via agent-browser |

---

## How It All Connects: Data Flow

Here's how data flows through a typical end-of-day:

```
Fathom API ─────► fathom-fetch.py ──► classify-transcript.py ──► Client Transcripts/
                                                                        │
                  Transcript text ──► Action item extraction ──────────┐
                                                                       │
Gmail API ──────► Important emails ──► Email tasks ───────────────────┤
                                                                       │
Slack API ──────► Unread messages ───► Slack tasks ───────────────────┤
(N workspaces)                                                         │
                                                                       ├──► Client files in Inbox/
Rize GraphQL ───► Time sessions ─────► rize_classify.py ──────────────┤    (routed by client)
                                       (client + work type)            │
                                                                       │
Google Calendar ► Tomorrow's events ─► Schedule ──────────────────────┤
                                                                       │
Brain Dump ─────► Classify + route ──► Client tasks ──────────────────┘
                                          │
                                     Manifest (audit trail)
                                          │
                                          ▼
                                    ClickUp Sync
                                    (new tasks → ClickUp)
                                    (done tasks → update status)
                                          │
                                          ▼
                                    Daily Summary Note
                                    (Work/Daily/YYYY-MM-DD.md)
                                          │
                                          ▼
                                    Today.md
                                    (Inbox/Today.md -- tomorrow's plan)
```

---

## Setting This Up From Scratch

### Step 1: Create the .env File

Start with whichever integrations matter most to you:

```bash
# Minimum viable setup: calendar + email + meeting transcripts
GOOGLE_CLIENT_ID=your_client_id
GOOGLE_CLIENT_SECRET=your_client_secret
GOOGLE_REFRESH_TOKEN=your_refresh_token
FATHOM_API_KEY=your_fathom_key
```

Getting Google OAuth credentials requires creating a project in Google Cloud Console, enabling the relevant APIs (Gmail, Calendar, Drive), creating OAuth credentials, and completing the consent flow once to get a refresh token. This is the most involved setup step.

### Check: Do You Have Google Admin Access?

If you are connecting Google tools (Calendar, Gmail, Drive), you need access to Google Cloud Console. This is where you create the login credentials Claude uses.

**Step 1: Check Cloud Console access**
1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Sign in with your work email
3. If you see a dashboard with project options, you have access. Skip to Step 2 below.
4. If you see "This service is not available" or get blocked, your organization's IT team has restricted access.

**If you are blocked, you have three options:**
- **Ask IT:** Request access to Google Cloud Console for creating OAuth credentials. Explain that you need it for a personal productivity tool that connects to your calendar and email.
- **Use a personal Gmail:** Set up the connection with your personal Gmail account instead. You can still access your work calendar if it is shared with your personal account.
- **Skip Google for now:** Use other tools first (ClickUp, Fathom, etc.) and come back to Google later.

**Step 2: Check Google Workspace Admin (optional)**
If you manage your organization's Google account:
1. Go to [admin.google.com](https://admin.google.com)
2. If you can sign in, you are a Google Workspace administrator
3. This means you can enable APIs and create OAuth credentials without asking anyone
4. This is a separate thing from Cloud Console -- you can have admin access without Cloud Console access, or vice versa

Most people are NOT Google Workspace admins. If you just use Gmail and Calendar for your own work, you only need Cloud Console access (Step 1 above).

### Step 2: Configure MCP Servers

In Claude Code's configuration, add MCP servers for services you use. ClickUp and Supabase are the most useful for task and data management. Each MCP server has its own setup process (usually an API key or OAuth flow).

### Step 3: Document Your Integrations

Create an API Integration Guide in your vault that documents every connected service: auth method, base URL, key endpoints, gotchas learned the hard way. This is critical because the AI references this guide when making API calls. Without it, the AI has to guess at endpoint structures.

### Step 4: Build Your First Slash Command

Start with something simple. An end-of-day that just checks your calendar and email:

```markdown
# End of Day

## Step 1: Tomorrow's Calendar
1. Source .env and get a Google access token
2. Fetch tomorrow's events from the Calendar API
3. Format as a readable schedule

## Step 2: Email Check
1. Fetch today's important emails from Gmail API
2. Surface anything needing a response

## Step 3: Summary
Present a brief end-of-day report.
```

Then add sections as you connect more integrations: meeting transcripts, Slack, time tracking, task sync.

### Step 5: Add Scripts for Complex Operations

When a slash command step gets too complex for inline curl commands (pagination, state tracking, multi-step logic), extract it into a Python script in `scripts/`. Give the script a `--json` output flag so the AI can parse results programmatically.

### Step 6: Automate with Cron

Once a slash command works reliably in autonomous mode, schedule it with `launchd` (macOS) or `cron` (Linux). The pattern:

```bash
#!/bin/bash
cd "/path/to/vault"
claude --command "/your-command" --dangerously-skip-permissions --no-input
```

Key considerations for unattended execution:
- **Version pinning**: Pin a specific Claude CLI version to avoid TCC dialogs on macOS when new versions auto-update
- **Lockfiles**: Prevent overlapping runs
- **Notifications**: macOS `osascript` for local, Slack DM for remote failure alerts
- **Timeouts**: Use `perl -e 'alarm shift; exec @ARGV'` on macOS (no GNU `timeout`)

---

## Alternatives: Zapier, n8n, and Manual Connections

Not every tool has a direct connection (MCP server) built for Claude. When a direct connection is not available, there are other ways to connect:

### Zapier

Zapier connects apps together without coding, like a middleman. You set up a "Zap" that says "when X happens in App A, do Y in App B." This is useful for:
- Connecting tools that Claude cannot reach directly
- Simple automations like "when I get an email from [sender], create a task in ClickUp"
- Bridging tools without building custom scripts

Zapier has a free tier for basic use. Visit [zapier.com](https://zapier.com) to explore.

### n8n (Self-Hosted Automation)

n8n is similar to Zapier but more powerful and customizable. This system uses n8n internally for some automation workflows. It requires more setup but gives you full control. Best for users who want to build complex multi-step automations.

### Manual Connections (WebFetch/WebSearch)

For occasional use, Claude can access many tools through the web. Using WebFetch and WebSearch, Claude can visit websites, read pages, and extract information without any special connection. This is slower and less reliable than a direct connection, but works for tools you only use occasionally.

---

## Lessons Learned

### Shell Isolation

Each shell command runs in a fresh session. Environment variables from `source .env` don't persist to the next command. Always source credentials and use them in the same command chain (`&&`), or extract values and pass them explicitly.

### Atomic Writes for Synced Vaults

If your vault syncs via iCloud/Dropbox/etc., files can change between read and write operations. Use Python atomic writes (read-modify-write in a single script execution) instead of the AI's built-in file editor for files that change frequently:

```python
python3 << 'EOF'
with open("path/to/file.md", "r") as f:
    content = f.read()
# ... modify content ...
with open("path/to/file.md", "w") as f:
    f.write(content)
EOF
```

### MCP Tool Payload Limits

MCP tools can struggle with very large text payloads (e.g., inserting a full 30-page roadmap into a database field). For large content, use the REST API directly via curl with jq for JSON construction, bypassing the MCP tool.

### Rate Limits and Pagination

Slack's API in particular has aggressive rate limits. When scanning multiple workspaces, space out requests. Fathom's API paginates with `next_cursor`. Always handle pagination rather than assuming all results fit in one response.

### OAuth Token Freshness

Google's OAuth refresh endpoint issues a new token on every call. If you call it twice, only the most recent token is valid. Get one token and use it immediately across all requests in that session.

### Deduplication Everywhere

Every system that syncs data between two sources needs deduplication. The AI checks for existing items before creating new ones: fuzzy-matching task names against vault items, checking Slack message timestamps against a processed-messages state file, comparing new call action items against existing tasks in client files. Without this, you get duplicates within a week.

### The Manifest Pattern

For long-running workflows (like EOD with multiple sections), use a manifest file to track every item extracted. This prevents items from being lost to context compression (when the AI's conversation gets too long, older context gets summarized). The manifest serves as a persistent ledger the AI can read back at any point.

### macOS Gatekeeper and TCC

When running Claude Code from `launchd` (unattended), two macOS security systems can block execution:
- **Gatekeeper**: Blocks binaries with `com.apple.provenance` xattr (downloaded files). Strip with `xattr -d`.
- **TCC (Transparency, Consent, Control)**: File access permissions are granted per-binary. When Claude auto-updates, the new binary needs fresh TCC grants. Solution: pin a specific version that already has permissions.
