# End of Day (Cloud Edition)

Run this before wrapping up for the day — or let the nightly Routine run it for you. It processes everything that happened today and builds tomorrow's plan.

Default mode: run the full EOD in this one command, in one session. Do not split into sub-agents unless this specific vault proves too large in practice.

---

## Core Rules

Follow these rules exactly:

1. Work in one session unless there is a concrete reason not to.
2. **Git is the save button.** This workflow ends with commit + push, always — including after partial failures. In a cloud session, work that is not pushed is destroyed with the container.
3. Write important state to disk as you go: manifest and caches to `System/state/`, routed items to inbox files. Never hold large batches in conversation memory.
4. Route items immediately when you extract them.
5. If time tracking is not configured, skip that section entirely.
6. If one external integration fails, continue with the rest and record the failure in the daily note's `## EOD Errors` section.
7. Keep the final output user-focused: what was gathered, what changed, and what tomorrow looks like.

**Unattended mode (Routine runs):** if this was triggered by a scheduled Routine (no human present — the triggering prompt says so, or no user is responding):
- Never use AskUserQuestion; apply the default at every decision point
- Log every problem to the daily note's `## EOD Errors` section instead of asking
- If a connector (calendar, email, Slack) is unavailable in this session, skip that source, log it, and continue — `/morning` catches up interactively
- ALWAYS finish with commit + push, even if half the steps failed. Partial data pushed beats complete data lost.

---

## Setup

1. **Sync:** `git pull --ff-only`
2. Get the date **in the user's timezone** (container clock is UTC):
   ```bash
   TZ="[IANA-Timezone]" date "+%Y-%m-%d %A %H:%M"
   ```
3. Set variables:
   - `TODAY` = current date in YYYY-MM-DD format ([Your Timezone], not UTC)
   - `TOMORROW` = next calendar day in YYYY-MM-DD format
   - `STATE` = `System/state`
   - `MANIFEST` = `$STATE/eod-manifest-$TODAY.md`
4. Create the manifest file at `$MANIFEST`:
   ```markdown
   # EOD Manifest -- TODAY

   ## Items

   | # | Item | Client | Type | Source | Routed To | Status |
   |---|------|--------|------|--------|-----------|--------|
   ```
   (If it already exists, EOD already ran today — append to it and note the re-run.)
5. Check CLAUDE.md for a time tracking integration. Set `HAS_TIME_TRACKING` = true or false.
6. Inventory your access for this session: which connector tools are available (Calendar, Gmail, Slack), which env vars are present (`printenv FATHOM_API_KEY` etc.). Note anything expected-but-missing for the errors section.

---

## 1. Gather

Critical rules:
- Route-as-you-go: route every item and log it to the manifest immediately.
- Dedup: before adding a task, check if it already exists in the target file.
- Only create `- [ ]` tasks for clear next actions. Recaps and status updates are notes, not tasks.
- No empty section headers.

Execute these steps in order:

1. **BRAIN DUMP TRIAGE**: Read the `## Brain Dump` section of `Inbox/Today.md`. Classify each item by client. Route work items to the correct client inbox file. Mark routed items with strikethrough; leave personal items and ideas in place. Log every routed item to the manifest.
2. **CALL TRANSCRIPTS**: If a transcript service is configured (e.g. `FATHOM_API_KEY` env var, or a fetch script in `scripts/`), pull today's calls. For each call, extract action items, decisions, and follow-ups; save transcripts to the correct client `Transcripts/` folder; route items to client inbox files. Log to manifest. If not configured or unavailable, skip and log.
3. **TOMORROW'S CALENDAR**: Fetch $TOMORROW's events — connector Calendar tools first; REST with env-var credentials as fallback. Convert all times to [Your Timezone]. Format as a readable schedule and write to `$STATE/eod-calendar-$TODAY.md`.
4. **EMAIL CHECK**: Fetch today's emails (connector Gmail tools first; first 15-20 messages). Surface emails needing response. Route actionable items to client inbox files. Log to manifest.
5. **SLACK CHECK**: For each connected workspace, check unread DMs and mentions (connector Slack tools). Route items to client inbox files. Log to manifest.

When done, read back `$MANIFEST` and confirm it has entries. Report totals by source and client.

---

## 2. Sync

Read the manifest at `$MANIFEST` for context on what was gathered.

1. **DEDUPLICATION**: Read each client inbox file in `Inbox/`. Find duplicate tasks (same or very similar text). Merge source notes and remove the duplicate. Count merges.
2. **COMPLETED TASK CLEANUP**: Find checked items (`- [x]`) in client files. Move them to the Completed section of the same file with today's date.
3. **TASK SYNC**: For new `action-owner` items in the manifest, create corresponding tasks in the task manager (connector/MCP tools). For tasks marked done today, update their status. If the task manager is unavailable this session, log and continue.
4. **VAULT HYGIENE**: Flag items in Open Tasks older than 14 days with a `(stale)` marker. If today is Monday, archive all Completed sections to `Archive/Completed Week of $TODAY.md` and clear them from client files.

Report: items deduped, completed moved, tasks synced, stale items flagged.

---

## 3. Time Tracking (Optional)

Only run this section if `HAS_TIME_TRACKING` is true. Follow `/eod-time` (reads credentials from env vars, writes to `$STATE/`). In unattended mode, skip the review/relabel confirmation and only apply high-confidence labels.

---

## 4. Daily Note

Read the manifest, the calendar cache at `$STATE/eod-calendar-$TODAY.md`, and (if present) `$STATE/eod-time-$TODAY.md`.

Create the daily note at `Work/Daily/$TODAY.md`:

1. Date and day of week as the title
2. MEETINGS: meetings attended today
3. KEY OUTCOMES: decisions and important results
4. TASKS COMPLETED: items marked done today
5. TASKS ADDED: new items routed today
6. TIME SUMMARY: hours per client and work type, or "Time tracking not configured"
7. SUMMARY: 2-3 sentence narrative of the day
8. **EOD ERRORS** (only if anything failed): each integration that failed or was unavailable, what was skipped, and what `/morning` should catch up on

---

## 5. Tomorrow's Plan

Follow `/eod-today` to generate `Inbox/Today.md` for `$TOMORROW`: schedule table from the calendar cache, morning exceptions, top 5-7 tasks by tier/deadline/freshness, carry-forward with `<!-- carried:N -->` counts, meeting prep from profiles and transcripts, deadline radar, north star goals, team priorities message.

Overwrite the file completely using the Write tool.

---

## 6. Graph Sync (Incremental)

Run the incremental graph sync from `/graph-daily`: it diffs against the commit recorded in `System/state/graph-last-sync` (plus uncommitted changes), updates frontmatter/wiki-links/index on changed files, extracts transcript takeaways, then records the new sync point.

If the Graph folder does not exist or `/graph-sync` has never been run, skip and note: "Graph sync skipped -- run `/graph-sync` first to initialize."

---

## 7. Save (never skip, even on failure)

```bash
git add -A && git commit -m "EOD $TODAY: [N] items routed, plan built for $TOMORROW[, N errors]" && git push
```

If the push is rejected: `git pull --rebase && git push`. Retry up to 3 times with short waits. If it still fails in unattended mode, commit locally anyway and make the failure the FIRST line of your final report; in interactive mode, tell the user immediately — the work is not saved until this succeeds.

---

## Summary

After all sections complete, print the final summary:

1. Read `$MANIFEST` and count total items by status
2. Report:
   - Gathered: [N] items from [sources]
   - Synced: [N] deduped, [N] tasks synced to task manager
   - Time: [N] hours tracked, or "skipped"
   - Daily note: `Work/Daily/$TODAY.md`
   - Tomorrow's plan: `Inbox/Today.md` generated for `$TOMORROW`
   - Errors: list any integration or section failures (also recorded in the daily note)
   - **Saved: pushed to main as [commit hash]** (or the loud failure message)
3. Print tomorrow's top 3 priorities from the generated `Today.md`
