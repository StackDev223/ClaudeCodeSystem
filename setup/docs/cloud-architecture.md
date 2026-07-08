# Cloud Architecture: How the System Connects Everything

> **You do not need to understand every detail in this document.** Claude can walk you through any connection. This is a reference for when you want to know how things work under the hood — and the design rationale for maintainers.

This document explains the cloud edition's architecture: how a private GitHub repository, claude.ai connectors, environment variables, custom scripts, skills, and Routines work together to turn a folder of markdown files into an automated operations hub.

---

## The Five Layers

```
┌──────────────────────────────────────────────────┐
│            Claude Code (cloud sessions)           │
│      Reads CLAUDE.md · Executes skills            │
│      Saves everything as git commits              │
├──────────────────────────────────────────────────┤
│  Layer 1: Connectors (claude.ai)                  │
│  Google Calendar · Gmail · Drive · Slack · tasks  │
│  → OAuth held by Anthropic; tools just appear     │
│                                                    │
│  Layer 2: Environment (env vars + network)        │
│  TZ · FATHOM_API_KEY · RIZE_API_KEY · domains     │
│  → Credentials and permissions, zero files        │
│                                                    │
│  Layer 3: REST/GraphQL APIs (via scripts/curl)    │
│  Any tool with an API, using Layer 2 credentials  │
│                                                    │
│  Layer 4: Custom Scripts (scripts/*.py)           │
│  Multi-step recipes: md-to-gdoc, fetchers, etc.   │
│                                                    │
│  Layer 5: Routines (scheduled cloud sessions)     │
│  Nightly /eod · optional morning brief            │
│  → Fresh session per run; the commit is the receipt│
├──────────────────────────────────────────────────┤
│           Your Vault = private GitHub repo        │
│     Source of truth for all state; full history   │
└──────────────────────────────────────────────────┘
```

The local edition's `.env` file and launchd/cron layers are gone. Their jobs moved up into the platform: credentials → connectors + environment config; scheduling → Routines.

---

## Layer 0 (the foundation): Git as the storage layer

Cloud sessions run in temporary containers with a fresh clone of the repo. Two consequences drive the whole design:

1. **Persistence is explicit.** A file written but not pushed is destroyed with the container. So every mutating workflow ends with `git add -A && git commit && git push`, and every workflow that reads state starts with `git pull --ff-only`. This is the Runtime & Persistence Protocol in CLAUDE.md — the single most important convention in the system.
2. **State that must cross sessions lives in the repo.** `System/state/` holds EOD manifests, calendar caches, and the graph sync marker; `System/memory/` holds operational memory; `.handoffs/` holds mid-stream checkpoints. `/tmp` is used only for true scratch within one session.

What this buys you: a complete audit trail (every EOD run is a commit), a real undo button (`git revert`, or just read any historical version), and multi-device consistency for free.

**Change detection is git-native.** A fresh clone stamps every file with clone-time modification dates, so mtime-based "changed today" logic is meaningless in the cloud. The incremental graph sync instead records the last-synced commit in `System/state/graph-last-sync` and diffs against it.

**Concurrency:** the race condition is no longer iCloud rewriting files mid-edit (the container filesystem is private); it is two sessions pushing divergent commits. The protocol handles it: pull before working, push promptly, `git pull --rebase` on rejection. The per-client file layout keeps genuine conflicts rare.

---

## Layer 1: Connectors

Connectors are managed at **claude.ai → Settings → Connectors** and attach to cloud sessions automatically as ready-to-use tools. Auth is OAuth held by Anthropic — no tokens anywhere in the system.

- **The user adds connectors; Claude cannot.** When a new one is needed, Claude names it and points at the settings page.
- New connectors attach at the next fresh session.
- Preferred for: Google Calendar, Gmail, Google Drive, Slack, and task managers that offer one.

**Scheduled-run caveat:** connectors are included in Routine configurations, but an OAuth login can expire or require interactive re-authentication that an unattended session cannot perform. The system treats connector access in Routines as *expected but not guaranteed*: the nightly `/eod` skips unreachable sources, logs them to the daily note's `EOD Errors` section, and `/morning` catches up interactively. `/automate`'s test run checks this on day one.

## Layer 2: Environment (variables + network policy)

Per-repository configuration at claude.ai/code. Three things live here: `TZ` (the owner's IANA timezone — the container clock is UTC), API keys for key-based tools, and the network allowlist for any domains scripts call directly. Full details and the domain table: `environment-setup.md`.

`.mcp.json` at the vault root extends this layer for tools that ship an MCP server but no connector. Claude may edit it (secrets referenced as `${ENV_VAR}`, never inline); it loads at the next session.

## Layer 3: REST/GraphQL APIs

For services without connectors, sessions call APIs directly with Layer 2 credentials:

```bash
curl -s -H "X-Api-Key: ${FATHOM_API_KEY}" \
  "https://api.fathom.ai/external/v1/meetings?include_transcript=true"
```

Gotchas that carried over from the local edition (still true):
- **Shell isolation**: env vars set in one Bash call don't persist to the next — chain with `&&` or re-read from the environment (which, in the cloud, always has them).
- **OAuth token freshness** (full-control Google path): the refresh endpoint issues a new access token per call; get one and use it immediately.
- **Rate limits and pagination**: Slack rate-limits aggressively; Fathom paginates with `next_cursor`. Handle both.
- **UTC timestamps**: convert to [Your Timezone] before reporting — doubly important now that the local clock is also UTC.

New gotcha: a network error from exactly one tool almost always means its domain is missing from the environment allowlist.

## Layer 4: Custom Scripts

Same philosophy as always — when an operation is too complex for one curl or needs reuse, it becomes a Python script in `scripts/`:

- Credentials from `os.environ`, never from files
- `--json` output so skills can parse results; `--help`; clear error messages that name the missing env var and where to set it
- Dependencies covered by the SessionStart hook (fast installs) or a per-environment setup script (heavy installs) — see `environment-setup.md`

Shipped: `md-to-gdoc.py` (markdown → styled HTML → Google Drive import as a Google Doc; requires the full-control Google OAuth env vars, since the Drive connector cannot create Docs).

## Layer 5: Routines (scheduled automation)

A Routine is a saved prompt + repository + connectors + schedule. At the scheduled time, the platform starts a **fresh session on a fresh clone of the default branch**, runs the prompt, and shuts down.

Design constraints the system honors:
- **Self-contained runs**: the nightly prompt is one line ("Run /eod in unattended mode...") because the session has no memory of anything not in the repo. All context comes from CLAUDE.md and vault files — which is exactly why the persistence protocol matters: a Routine can only see what was pushed.
- **Unattended mode**: `/eod` never asks questions when scheduled, logs failures into the daily note, and always pushes — partial data saved beats complete data lost.
- **Hourly minimum, daily run caps**: nightly EOD + optional morning brief fits comfortably; don't design chatty sub-hourly automations.
- **The commit is the receipt**: monitoring a Routine = reading `git log`. `/morning` checks for last night's commit; `/monthly-review` counts the week's EOD commits and flags gaps.

This layer replaces the local edition's entire launchd/cron apparatus (runner scripts, lockfiles, version pinning, macOS TCC/Gatekeeper workarounds) with configuration.

---

## How It All Connects: the nightly data flow

```
Fathom API ────► transcripts → per-client Transcripts/ → action items ─┐
Gmail (connector) ──► emails needing response ─────────────────────────┤
Slack (connector) ──► unread DMs & mentions ───────────────────────────┼─► Inbox/<Client>.md
Calendar (connector) ► tomorrow's events → System/state/ cache ────────┤   (route-as-you-go)
Brain Dump (Today.md) ► classified & routed ───────────────────────────┘
                                   │
                        Manifest (System/state/) — audit trail
                                   │
                          Task manager sync (connector)
                                   │
                     Daily note (Work/Daily/YYYY-MM-DD.md)
                                   │
                      Tomorrow's plan (Inbox/Today.md)
                                   │
                        Incremental graph sync (git-diff)
                                   │
                    git commit "EOD YYYY-MM-DD" + push  ◄── the receipt
```

## Alternatives: Zapier and Manual Connections

Not every tool has a connector or an API. Options:
- **Zapier** — "when X happens in App A, do Y in App B." Useful for bridging tools Claude cannot reach directly.
- **WebFetch/WebSearch** — for occasional lookups, Claude can read public web pages (subject to the environment's network policy). Slower and less reliable than a real connection.
- Never browser automation. If a service has no connector and no API, it is not connected — say so and decide with the user.

## Design Rules Carried Forward

- **Route-as-you-go**: every extracted item is written to its destination immediately, never batched in conversation memory.
- **The manifest pattern**: long workflows track every item in a manifest on disk; it survives context compression and, in this edition, gets committed — so it also survives the container.
- **Deduplication everywhere**: fuzzy-match before creating; merge source notes instead of duplicating.
- **Script-first for repeated API calls**; inline curl only for one-off exploration.
- **Self-updating documentation**: an integration isn't done until CLAUDE.md, the API guide, and the pointer files reflect it — and it's pushed.
