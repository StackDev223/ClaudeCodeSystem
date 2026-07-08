# Changelog

All notable changes to the ClaudeCodeSystem Cloud template.

## 1.0.0 — 2026-07-08

Initial cloud edition, rebuilt from ClaudeCodeSystem (local edition) for Claude Code on the web.

### Architecture changes from the local edition

- **The repo is the vault.** Distributed as a GitHub template repository; `/onboard` personalizes in place. The "drop this folder into your vault" bootstrap is gone.
- **Git is the storage layer.** Every mutating command begins with `git pull` and ends with commit + push (the Runtime & Persistence Protocol). Sessions run in ephemeral containers; unpushed work does not survive.
- **Credentials moved out of files.** The `.env` layer is removed entirely: claude.ai connectors for Google Calendar / Gmail / Drive / Slack, environment variables (Claude Code environment config) for API-key tools, repo-committed `.mcp.json` for MCP servers.
- **Scheduling moved to Routines.** The launchd/cron scripts (`eod-runner.sh`, `eod-cron.sh`, plist, version pinning, TCC/Gatekeeper handling) are replaced by `/automate`, which sets up cloud Routines. `/eod` gained an unattended mode for scheduled runs.
- **Durable state moved into the vault.** EOD manifests, calendar caches, and sync markers live in `System/state/` (committed) instead of `/tmp` (per-session scratch).
- **Change detection is git-native.** `/graph-daily` diffs against the last-synced commit instead of file modification times (which a fresh clone resets).
- **Timezone is explicit.** Containers run UTC; all date math uses the owner's IANA timezone, personalized into commands by `/onboard` and set as a `TZ` environment variable.
- **iCloud atomic-write rules removed.** Replaced by git concurrency discipline (pull before write, push promptly, rebase on rejection).
- **New commands:** `/automate` (Routine setup). **Removed:** the CoWork command mirror (web sessions auto-discover `.claude/commands/`).
- **Session bootstrap ships in the repo:** `.claude/settings.json` + a SessionStart hook that installs Python dependencies and orients each session (date in the owner's timezone, git sync state).
