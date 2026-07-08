# Handoff -- ClaudeCodeSystem Cloud Edition rollout -- 2026-07-08 15:32 UTC

> **For the next Claude reading this:** You are continuing work mid-stream. Read this entire file before taking any action. Then pull the context listed in "Load This Context" before responding. Do not ask the user to re-explain what is already documented here. (Timestamp is UTC — the owner's timezone is not configured in this template repo; that is expected, see Gotchas.)

**Working directory:** `/home/user/ClaudeCodeSystem` (branch `claude/code-system-cloud-assessment-665w4x`, clean, synced with origin at `fb44aab`)
**Project context:** Integral's client-delivery system ("Claude Code System") — cloud edition rollout. You may instead be reading this from a session on `IntegralOrg/ClaudeCodeSystem-Cloud` after fetching the branch; Next Steps covers that case first.

## The Goal

Ship Integral's personal-assistant system as a **cloud-native GitHub template repo** (`IntegralOrg/ClaudeCodeSystem-Cloud`) for Claude Code on the web, so clients get 24/7 assistants — vault = private GitHub repo, nightly EOD via Routines, no local installs. The owner (Stephen, Integral) delivers this to paying clients; the template must be complete, licensed, and pilot-tested.

## Where We Are Right Now

- **The cloud edition is fully built and pushed**: commit `fb44aab` on branch `claude/code-system-cloud-assessment-665w4x` of `StackDev223/ClaudeCodeSystem` (that repo is PUBLIC). 39 tracked files: 23 commands in `.claude/commands/` (including the new `/automate`), root `CLAUDE.md` bootstrap, `setup/templates/CLAUDE.md` (the vault manual defining the Runtime & Persistence Protocol), `setup/docs/environment-setup.md` + `cloud-architecture.md`, `.claude/settings.json` + `.claude/hooks/session-start.sh` (validated live — it runs on session resume in this very repo), `.mcp.json`, `System/state/` + `System/memory/`, `.handoffs/`, `scripts/md-to-gdoc.py` (env-var credentials), README, CHANGELOG, LICENSE.
- **The destination repo exists but is empty**: `IntegralOrg/ClaudeCodeSystem-Cloud`, public, just an auto-init commit (pushed 2026-07-08T15:27Z). The Claude GitHub credential has push access (verified via `list_repos`: `can_push: true`).
- **The import is the one unfinished step.** The previous session could not push to the org repo (see Tried and Rejected). The agreed path: a session on the org repo fetches the public branch and pushes it as `main`. This handoff file is ON that branch, so an org-repo session that fetches it can read this briefing from `FETCH_HEAD`.
- The full architecture assessment that motivated everything: artifact at `https://claude.ai/code/artifact/ab507364-2da4-4cd1-84d1-8b6f402fe74d`.
- Licensing is settled: `LICENSE` in the tree is byte-for-byte the original repo's CC BY-NC-ND 4.0; README's license section matches. User confirmed this is what "proper licensing" means.

## What Has Been Tried (and Rejected)

- `mcp__github__create_repository` → **403 "Resource not accessible by integration"**. The GitHub App cannot create repos. User created the repo manually — under the **IntegralOrg** org (deliberate; better home for client-facing template than the personal account).
- `add_repo(StackDev223, ClaudeCodeSystem-Cloud)` → not found. The repo is under IntegralOrg, not the personal account.
- `add_repo(IntegralOrg, ClaudeCodeSystem-Cloud)` → **"cross-tier adds are not supported in v1: session already has repos from owner(s) [stackdev223]"**. A session cannot mix repo owners. Do NOT retry from a StackDev223-sourced session; it is a platform limit, not a permissions issue.
- Pushing to the org repo via GitHub MCP API tools from the old session — rejected: the repo was never in that session's scope, and working around scope is not acceptable.
- "Path 2" (create `StackDev223/ClaudeCodeSystem-Cloud`, push there, transfer to org) was offered; user chose the new-session import path instead.

## Decisions Made This Session (do NOT re-litigate)

- **One codebase, cloud-first; no fork.** The `cowork-commands/` mirror is intentionally dropped from the cloud edition (web sessions auto-discover `.claude/commands/`). The original local edition lives untouched on the old repo's `main`.
- **The repo IS the vault** (template model). `/onboard` personalizes in place with per-phase commits so interrupted setups resume.
- **Vault work commits directly to `main`** — requires "Allow unrestricted branch pushes" per environment; no PR flow for single-owner vaults.
- **No `.env`, ever.** Credential priority: claude.ai connectors → environment variables → repo `.mcp.json` (secrets referenced as `${ENV_VAR}`).
- **No environment setup script for the base system.** The SessionStart hook carries the pip installs + date/TZ orientation; setup scripts are only for heavy client-specific deps. User asked about this explicitly; the full answer is `setup/docs/environment-setup.md` §4.
- Durable state in `System/state/` (not `/tmp`); graph change detection via git diff against `System/state/graph-last-sync` (not mtimes); all date math with explicit IANA timezone (containers are UTC).
- **Import with full history** (fb44aab sits on the old repo's history). GitHub's "Use this template" squashes to a single commit for clients, so history is maintainer-only. Do not squash during import.
- License stays exactly CC BY-NC-ND 4.0, unmodified.

## Next Steps

1. **Import the cloud edition into the org repo** (from a session whose source is `IntegralOrg/ClaudeCodeSystem-Cloud`):
   ```bash
   git fetch https://github.com/StackDev223/ClaudeCodeSystem.git claude/code-system-cloud-assessment-665w4x
   git checkout -B main FETCH_HEAD
   git rm .handoffs/claude-cloud-setup.md   # this briefing must NOT ship to clients
   git commit -m "Import cloud edition v1.0; remove rollout handoff"
   git push --force-with-lease origin main   # only the auto-init commit is being replaced (verified disposable)
   ```
   If branch restrictions block pushing `main`, push as `claude/cloud-edition-import` and tell the user to change the repo's default branch to it (or enable unrestricted branch pushes and re-push `main`).
2. **Verify at HEAD**: `LICENSE` (CC BY-NC-ND 4.0), `README.md`, exactly 23 files in `.claude/commands/`, `.claude/settings.json`, `.claude/hooks/session-start.sh` (executable bit), `.mcp.json`, `System/state/.gitkeep`, `setup/` present. Report the file count and license line to the user.
3. **Hand back to the user**: flip **Settings → Template repository** on the org repo (user does this — they said "I'll turn it into a template when you're done"). Then the first pilot: instantiate a scratch vault from the template, run `/onboard` in a web session, then `/automate` including its test run — that test answers the one open platform question (whether OAuth connectors survive unattended Routine runs; the system already degrades gracefully via the daily note's `EOD Errors` section + `/morning` catch-up, see `automate.md` Step 4).

## Load This Context Before Responding

- Bash: `git status -sb && git log --oneline -3` — confirm which repo/branch you are actually on before acting
- Read: `README.md` — the delivery model and client-facing framing
- Read: `setup/docs/environment-setup.md` — the four environment settings every client configures (TZ, network, branch pushes, setup script)
- Read: `CHANGELOG.md` — the complete architectural delta vs. the local edition
- Only if diagnosing command behavior: `setup/templates/CLAUDE.md` — the Runtime & Persistence Protocol every command follows

## Gotchas and Constraints

- **Sessions cannot mix repo owners** (platform v1). An org-repo session cannot `add_repo` the StackDev223 repo either — but it doesn't need to: the old repo is public, so `git fetch https://github.com/StackDev223/ClaudeCodeSystem.git <branch>` needs no credentials.
- **The org repo's auto-init commit is disposable** — verified nothing else was pushed there. `--force-with-lease` over it is correct; do not force-push anywhere else.
- **Do not "fix" the `[IANA-Timezone]` and `[Client A]` placeholders** in the commands — `/onboard` personalizes them per client. The template ships with placeholders by design.
- **The TZ warning at session start is expected** in unpersonalized repos — the SessionStart hook prints it until a client's environment sets `TZ`. It is a feature (proof the hook runs), not a bug.
- **The old repo's branch doubles as the import source.** Do not delete `claude/code-system-cloud-assessment-665w4x` until the import has landed on the org repo. Afterward the user may delete it or keep it as an archive; ask before deleting.
- **Do not modify the old repo's `main`** — it is the still-supported local edition for existing clients.
- The old repo is public; the org repo is public — consistent with the CC BY-NC-ND license (public sharing allowed, resale and modified redistribution forbidden).

## Open Questions

- Copyright line: `LICENSE` says "Copyright (c) 2026" with no name. User was offered "Copyright (c) 2026 Integral" and has not decided. One-line change if they say yes.
- Should the old repo's `main` README eventually point people to the cloud edition? Not requested yet — raise after the template is live.

---

*Handoff written 2026-07-08 15:32 UTC. Session topic: cloud edition build + org-repo import. If this file is older than a few hours when you read it, verify the org repo's state before acting — the import may already have landed.*
