# Environment Setup Guide (Claude Code on the Web)

Every vault runs inside a Claude Code **environment** — the container configuration attached to your repository at claude.ai/code. This guide covers the four settings that matter, what to put in them, and why. `/onboard` walks users through all of this interactively; this doc is the reference behind it.

## The four settings

| Setting | What to set | Why |
|---------|-------------|-----|
| Environment variables | `TZ` + API keys for key-based tools | Correct dates; credentials without files |
| Network access | Trusted, or Custom + tool domains | Lets scripts reach tool APIs |
| Branch permissions | Allow unrestricted branch pushes: ON | Routines and sessions save directly to main |
| Setup script | **Leave empty** (for the base system) | The repo's SessionStart hook covers it — see below |

---

## 1. Environment variables

Set these at claude.ai/code → your environment → **Environment variables**.

### TZ (required for everyone)

```
TZ=America/Chicago
```

Use the owner's IANA timezone name (`America/New_York`, `America/Denver`, `America/Los_Angeles`, `Europe/London`, ...). The cloud container's clock is UTC; without `TZ`, an 11 PM end-of-day run computes *tomorrow's* date and the daily loop misfiles everything. The vault's commands also carry an explicit timezone (personalized by `/onboard`) as a belt-and-suspenders measure, and the SessionStart hook warns loudly whenever `TZ` is missing.

### API keys (only for key-based tools)

One variable per tool that authenticates with an API key rather than a connector:

```
FATHOM_API_KEY=...
RIZE_API_KEY=...
```

Notes:
- Values here are visible to anyone who can edit the environment. For a personal vault where the client owns their environment, that is the intended trust boundary. Do not park other people's credentials here.
- New/changed variables attach when a **fresh session** starts.
- Never put these in any repo file. The repo's `.gitignore` blocks `.env` defensively, but the rule is simpler: secrets never touch the repo.

## 2. Network access

Connectors (Google, Slack, task managers via claude.ai) do **not** need network configuration — they are proxied by the platform. Network access matters only when the vault calls an API directly (curl or `scripts/*.py`).

- **Trusted** (default): package registries, GitHub, and common dev infrastructure. Fine if everything the client uses is connector-based.
- **Custom**: Trusted plus your own domain list. Needed for API-key tools. Common domains:

| Tool | Domains |
|------|---------|
| Fathom | `api.fathom.ai` |
| Rize | `api.rize.io` |
| Google APIs (full-control OAuth path, e.g. md-to-gdoc) | `oauth2.googleapis.com`, `www.googleapis.com`, `gmail.googleapis.com` |
| Slack (only if using raw API instead of the connector) | `slack.com` |

Symptom of a missing domain: curl/network errors from exactly one tool while everything else works. `/connect` and `/monthly-review` both check for this.

## 3. Branch permissions

Enable **Allow unrestricted branch pushes** for the vault repository (surfaced in the environment/Routine settings).

By default, cloud sessions may only push to `claude/*`-prefixed branches, with changes landing on main via manual pull requests. For a single-owner personal vault this is pure friction — worse, it strands the nightly Routine's output (tomorrow's plan!) on side branches that never get merged, so every morning session reads a stale main. The entire system is designed around committing directly to main; this setting is what allows it.

If a client's organization forbids the setting, the fallback is a small GitHub Action that auto-merges `claude/*` branches — ask Integral for it. Prefer the setting.

## 4. Setup script — and why the base system doesn't need one

The environment's **Setup script** field runs a bash script when a new container is provisioned, *before* Claude Code launches, and its results are cached (about a week) between sessions.

**For the base system, leave it empty.** Here's the reasoning:

- The only dependency the stock vault needs is `pip3 install markdown requests` (for `scripts/md-to-gdoc.py`). That install takes a few seconds and is handled by the repo's **SessionStart hook** (`.claude/hooks/session-start.sh`), which also benefits from container caching — after the first session it is effectively a no-op.
- The hook ships **inside the repo**, so every client gets it automatically with zero configuration, it is version-controlled, and Integral can improve it by shipping a template update. A setup script lives in each client's environment config — it must be pasted by hand during onboarding and drifts silently afterward. Fewer manual steps in the claude.ai UI means fewer broken onboardings.
- The hook doubles as session orientation: it prints today's date in the owner's timezone (and warns if `TZ` is unset) plus the vault's git sync state, giving every session correct grounding from message one.

**When a setup script becomes worth adding** (move slow things there; keep the hook for fast things + orientation):

- A client's vault grows dependencies that take real time to install — `pandoc`, `playwright`, a large pip/npm stack. The setup script's provision-time execution + ~7-day cache means those install once, not per session, and never delay the session start itself.
- System packages (`apt-get install ...`) that a hook shouldn't be doing mid-session.
- Anything that must exist *before* Claude Code launches (rare for this system).

Rule of thumb: **hook for fast + universal (ships with the template), setup script for slow + client-specific (configured per environment).** If you do add one, keep it idempotent and quiet, e.g.:

```bash
#!/bin/bash
# Example client-specific setup script (only if this vault needs heavy deps)
set -euo pipefail
command -v pandoc >/dev/null || (apt-get update -qq && apt-get install -y -qq pandoc)
pip3 install --quiet markdown requests
```

---

## Verifying an environment (what /onboard and /connect check)

From inside a session:

```bash
printenv TZ                       # timezone set?
printenv FATHOM_API_KEY           # expected keys present?
python3 -c "import markdown, requests"   # hook-installed deps present?
git push --dry-run                # can we save?
curl -sI https://api.fathom.ai | head -1  # network allowlist working? (per tool)
```

And the operational check: after `/automate` sets up the nightly Routine, trigger a test run and confirm a fresh `EOD ...` commit lands on main. That one test exercises the whole chain — schedule → connectors → timezone → branch permissions → push.
