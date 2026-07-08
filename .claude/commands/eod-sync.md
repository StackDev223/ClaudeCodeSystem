# EOD Phase 2: Sync (Cloud Edition)

Cleanup, deduplication, and external sync phase. Reads state from disk (manifest + inbox files written by Phase 1). Reconciles the vault and syncs with your task manager (if configured).

**This phase can run in a fresh session.** It reads from the manifest and inbox files on disk — no conversation state carries over from Phase 1. If running in a separate session from Phase 1, start with `git pull --ff-only` so Phase 1's pushed work is present.

**Critical rule: Route-as-you-go.** Every change (dedup merge, completed-task move, archive) is written to disk immediately. Do not batch changes in memory across multiple files.

**Unattended mode:** never ask questions; log problems for the daily note's `## EOD Errors` section and continue.

---

## Setup

1. **Sync:** `git pull --ff-only`
2. Get today's date **in the user's timezone**: `TZ="[IANA-Timezone]" date "+%Y-%m-%d %A"`
3. Set `TODAY` (YYYY-MM-DD) and `DOW` (day of week, for Monday archive logic)
4. **Read the manifest** from `System/state/eod-manifest-$TODAY.md`. Confirm it exists and contains at least one item row. If missing, abort with a clear error: "No manifest found. Run Phase 1 first."
5. Initialize counters: `SYNCED_BACK=0`, `DEDUPED=0`, `CLEANED=0`, `SYNCED=0`

---

## Step 1: Today.md Reverse Sync

Sync task completions from today's `Inbox/Today.md` back to their source inbox files. This closes the loop: tasks checked off during the day in Today.md get marked complete in the client file they came from.

1. **Read `Inbox/Today.md`**. If the file is missing or has a stale date header, skip this step.
2. **Find all checked tasks** (`- [x]`) that have a source tag: `<!-- src:path/to/file.md|fingerprint -->`
3. **Skip meetings** (`<!-- type:meeting -->`). Meeting checkboxes are attendance tracking, not task completion.
4. **For each completed task**:
   - Parse the source file path and fingerprint from the `<!-- src:... -->` tag
   - Search the source file for the matching task by substring-matching the fingerprint against `- [ ]` lines
   - If found: change `- [ ]` to `- [x]` for that line
   - If not found (already completed, moved, or reworded): skip silently
   - Increment `SYNCED_BACK`
5. **Batch by file**: apply all changes to the same source file in one edit.
6. Log: `"Synced {SYNCED_BACK} completions from Today.md back to inbox files"`

---

## Step 2: Deduplication

Scan all client inbox files for duplicate tasks. Two tasks are duplicates if their text matches after stripping checkbox prefix, whitespace, and trailing source notes.

1. **Read each client file** in `Inbox/`
2. **Extract all `- [ ]` items** from each file's `## Open Tasks` section
3. **Compare within each file** using fuzzy matching:
   - Normalize: lowercase, strip leading `- [ ] `, strip trailing parenthetical source notes
   - Match threshold: identical after normalization, or differing only by date references or source annotations
4. **When a duplicate is found**:
   - Keep the first occurrence
   - Merge source notes from the duplicate into the kept item (append `*also from <source>*`)
   - Remove the duplicate line
   - Increment `DEDUPED`
5. Do NOT deduplicate across different client files. Only within the same file.

---

## Step 3: Completed Task Cleanup

1. **For each client file**:
   - Find all `- [x]` items in `## Open Tasks`
   - Move them to `## Completed` (create the section if needed, insert before `## Notes`)
   - Append `(completed TODAY)` to each moved item
   - Remove any empty or legacy `###` subsection headers left behind
   - Increment `CLEANED` per item moved

---

## Step 4: Task Manager Sync

**Skip this step if no task manager is configured** (check CLAUDE.md). In unattended mode, also skip (and log) if the task manager's tools are not available in this session.

1. **New tasks** (from manifest): for each row with Type `action-owner`:
   - Create a task in the matching client list/project via the task manager's connector/MCP tools
   - Name = Item text, description = Source note, due date if captured
   - Log the external task ID back into the manifest's Status column
   - Increment `SYNCED`
2. **Completed tasks**: for each item moved to Completed in Step 3, find the matching task and mark it done.
3. If task manager calls fail, log the error and continue. Do not abort the phase for sync failures.

---

## Step 5: Vault Hygiene

1. **Stale item flagging**: flag `- [ ]` items in `## Open Tasks` older than 14 days (from the date in the task's italic source note) with a `- [ ] **STALE**` prefix
2. **Monday archive** (only if `DOW` = Monday):
   - Append each client file's non-empty `## Completed` section to `Archive/Completed Week of YYYY-MM-DD.md` (Monday's date)
   - Clear the `## Completed` section in the client file (keep the header)

---

## Phase 2 Complete

1. Update remaining manifest Status fields
2. Print summary:
   ```
   Phase 2 complete.
   - Today.md completions synced back: {SYNCED_BACK}
   - Duplicates merged: {DEDUPED}
   - Completed tasks cleaned: {CLEANED}
   - Tasks synced to task manager: {SYNCED}
   - Stale items flagged: {count}
   - Monday archive: {yes/no, file path if yes}
   ```
3. **Save:** `git add -A && git commit -m "EOD $TODAY phase 2: sync ({DEDUPED} deduped, {CLEANED} cleaned)" && git push` (required when phases run in separate sessions; optional inside single-command `/eod`)
