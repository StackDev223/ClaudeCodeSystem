# Monthly Review (Cloud Edition)

Runs a full system review: collects user feedback, audits CLAUDE.md against reality, cleans the vault, checks repository health, scans for testimonials, applies improvements, and updates the review date. Run this on the last workday of each month.

---

## Step 0: Sync

1. `git pull --ff-only`
2. Get today's date in the user's timezone: `TZ="[IANA-Timezone]" date "+%Y-%m-%d"`

---

## Step 1: System Feedback

1. Use AskUserQuestion to collect feedback on each of the following (one question at a time):
   - What's working well in the current system?
   - What feels clunky or takes too many steps?
   - Any tools or integrations you wish you had?
   - Any behavior changes you'd like from the assistant?
2. Summarize responses to `System/state/monthly-review-feedback-$TODAY.md`

---

## Step 2: CLAUDE.md Self-Audit

Read CLAUDE.md in full. Audit it against the actual state of the vault and connected tools. Collect every discrepancy before presenting anything.

### 2a: Integrations

For each integration listed in CLAUDE.md:
1. **Connectors**: attempt a lightweight call (list calendar events, list Slack channels) to confirm the connector is attached and live in this session.
2. **API-key tools**: `printenv <VAR>` to confirm the environment variable exists; then one lightweight API call to confirm it works (a network error suggests the domain is missing from the environment's network allowlist — note that specifically).
3. **`.mcp.json` servers**: confirm their tools are available in this session.
4. Flag: integrations listed but not actually connected, and integrations that are connected but missing from CLAUDE.md.

### 2b: Scripts

For each script listed under the integrations/scripts sections:
1. Check the file exists at the listed path
2. Check it parses (`python3 -c "import ast; ast.parse(open('path').read())"` for Python)
3. Flag: scripts listed but missing, scripts in `scripts/` but undocumented

### 2c: Folder Structure

1. Compare the "Folder Structure" section of CLAUDE.md against actual `ls` output (top level + one level deep for documented subfolders)
2. Flag mismatches both directions

### 2d: Skills

1. List all `.md` files in `.claude/commands/`
2. Compare against skills referenced in CLAUDE.md
3. Flag mismatches both directions

### 2e: File Size Check

1. `wc -c CLAUDE.md`
2. Over 25,000 characters: flag as approaching the limit; identify sections to extract to reference files
3. Over 30,000 characters: flag as urgent

### 2f: Repository Health (cloud-specific)

1. **Stray branches**: `git branch -r` — list any `claude/*` branches on the remote other than the default branch. These are usually leftovers from one-off cloud sessions (a session that ran before "Allow unrestricted branch pushes" was enabled, or an experiment). For each: `git log main..origin/<branch> --oneline` to see if it has unmerged work. Flag branches with unmerged commits for the user to decide; propose deleting the empty ones.
2. **Unpushed state**: `git status -sb` — confirm the working tree is clean and main is not ahead of origin.
3. **Repo weight**: `git count-objects -vH` and check for large files (`git ls-files | xargs -r du -h 2>/dev/null | sort -rh | head -10`). Flag binaries that snuck into git (they belong in Drive) — growing clone size slows every future session.
4. **Routine freshness**: check the git log for last night's EOD commit and count EOD commits over the past week (`git log --oneline --since="7 days ago" | grep -c "EOD"`). If nights are missing, the Routine may be failing or hitting its run cap — suggest re-testing via `/automate`.

### 2g: Present Findings

Present all findings grouped by category (what CLAUDE.md says vs. what reality shows).

AskUserQuestion: "Here is what I found. Which issues should I fix?"
Options:
- Fix all of them
- Let me pick which ones to fix
- Skip this, move on to vault cleanup

Apply approved fixes. For missing scripts or dead integrations, update CLAUDE.md to remove stale entries. For undocumented real tools, add entries.

---

## Step 3: Vault Cleanup

1. Scan `Inbox/` for items older than 14 days — stuck items needing triage or archival
2. Check for notes filed in wrong folders
3. Flag files with outdated information (past dates, completed projects still marked active)
4. Identify empty or unused files (no content beyond template headers)
5. Present findings; apply approved changes

---

## Step 4: Testimonial Scan

1. Find the last testimonial scan date (in `[YourCompany]/Testimonials.md`)
2. Search Slack (connector tools, all workspaces) for positive client feedback since that date:
   - Keywords: "thank", "great job", "love", "amazing", "impressed", "saved", "clutch", "game changer"
   - Filter to DMs and client channels
3. Search vault transcript files for the same patterns
4. Present findings with source and context
5. Append approved quotes to `[YourCompany]/Testimonials.md` (quote, client, date, source); update the Last Scan date

---

## Step 5: Apply Updates

1. System improvements → `Resources/Reference/System Improvements.md`
2. Workflow changes → CLAUDE.md Common Workflows
3. Preference updates → CLAUDE.md Assistant Guidelines
4. Operational lessons → `System/memory/`

---

## Step 6: Update Review Date and Save

1. Update the "Last Monthly Review" date in CLAUDE.md to today
2. **Save:**
   ```bash
   git add -A && git commit -m "Monthly review $TODAY: [N] fixes, [N] testimonials" && git push
   ```
3. Print a final summary: feedback items logged, audit issues found/fixed, repo health notes, testimonials added, improvements routed
