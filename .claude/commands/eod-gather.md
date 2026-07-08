# EOD Phase 1: Gather (Cloud Edition)

Data gathering phase. Triages the Brain Dump first, then fetches call transcripts, tomorrow's calendar, email, and Slack. Routes all items to inbox files immediately. Creates the manifest.

**This phase writes all state to disk** — the manifest and caches to `System/state/` (committed at the end), routed items to inbox files. Later phases read from disk, not from conversation context. If the phases run in separate sessions, each phase commits and pushes at its end and the next phase starts with `git pull --ff-only`.

**Critical rule: Route-as-you-go.** Every item extracted MUST be routed to the correct client file AND logged to the manifest IMMEDIATELY.

**Critical rule: Tasks are flat bullets.** Do NOT create `### New from <source>` subsection headers for tasks. Append new tasks directly under `## Open Tasks` as flat bullets. Source context lives in the italic suffix at the end of each task (e.g., `*from Fathom: [Call Name] MM/DD*`). (`### Notes from <source>` headers under `## Notes` are still fine — meeting notes benefit from source grouping, tasks do not.)

**Critical rule: EOD deduplication.** Before adding a task from a call recap, check if the same task already exists in the client file. If it does, update the source note (append "*also discussed X/X*") instead of creating a duplicate.

**Critical rule: EOD task ownership.** Team member actions become follow-up items for you (e.g., "Follow up: [Team Member] to deliver X"). Never frame other people's responsibilities as your direct tasks.

**Unattended mode:** if running from a scheduled Routine, never ask questions; skip unavailable sources and log them for the daily note's `## EOD Errors` section.

---

## Setup

1. **Sync:** `git pull --ff-only`
2. Get today's date **in the user's timezone**: `TZ="[IANA-Timezone]" date "+%Y-%m-%d %A %H:%M"`. Set `TODAY` (YYYY-MM-DD) and `TOMORROW` (next calendar day).
3. Inventory access for this session: which connector tools are present (Calendar, Gmail, Slack), which env vars exist (`printenv FATHOM_API_KEY` etc.).
4. **Create the manifest file** at `System/state/eod-manifest-$TODAY.md`:
   ```markdown
   # EOD Manifest -- YYYY-MM-DD

   ## Items

   | # | Item | Client | Type | Source | Routed To | Status |
   |---|------|--------|------|--------|-----------|--------|
   ```

### Manifest Column Definitions
- **#**: Sequential number (1, 2, 3...)
- **Item**: Brief description of the action item
- **Client**: Client name ([Client A], [Client B], etc.) or "Cross-Client"
- **Type**: `action-owner`, `action-other`, `research`, `decision`, `followup`, `email-response`, `note`
- **Source**: Where it came from (e.g., "Fathom: [Contact Name] call", "Email: from jack@...", "Slack: [Client A] DM")
- **Routed To**: File path where item was written (e.g., `Inbox/[Client A].md`)
- **Status**: checkmark once routed, `ORPHAN` if couldn't determine destination

---

## Section 0: Brain Dump Triage

Process the Brain Dump section in `Inbox/Today.md`. This is the user's quick-capture area throughout the day. Classify each item, route client-specific items to the correct client file, and clean up the Brain Dump.

1. **Read** `Inbox/Today.md` and extract the Brain Dump section (everything between `## Brain Dump` and the next `##` header).

2. **Parse each item** (bullets and sub-bullets). Skip items that are:
   - Already completed: `- [x]`
   - Already routed: contains `~~` strikethrough + "moved to"
   - Empty lines or section headers (`###`)

3. **Classify each remaining item** by client using these signals (in priority order):
   - **Explicit client name**: "[Client A]", "[Client B]", etc.
   - **Contact names**: Map each contact to their client (from client Company Profiles and the entity registry)
   - **Tool/product names**: Map tools to clients (e.g., their e-commerce platform → the client that uses it)
   - **Internal context** (hiring, team, SOPs, strategy): route to `Inbox/[YourCompany].md` Open Tasks
   - **Personal items** (health, travel, errands): leave in Brain Dump, do not route
   - **Ideas**: leave in Brain Dump, do not route
   - **Unclassifiable work items**: leave in Brain Dump, log as `ORPHAN` in manifest

4. **For Notes subsections** (e.g., `### Notes from Agency Check-in 3/16`):
   - Client-specific notes → that client's `## Notes` section
   - Cross-client notes → `Inbox/[YourCompany].md` Notes section
   - Mixed-client meeting notes: split by client, route each subset
   - Always route as plain bullets (NOT checkboxes) under a `### Notes from <source>` header

5. **Route each item**:
   a. Tasks (`- [ ]` items): append under `## Open Tasks` as flat bullets with the `*from Brain Dump MM/DD*` suffix; dedup check first
   b. Mark routed items in Today.md's Brain Dump: tasks become `- [x] ~~<original text>~~ moved to <Client>.md ✅ TODAY`; notes are removed (they now live in the client file); personal items and ideas stay put (they carry forward)
   c. Append a manifest row for each routed item with Source = "Brain Dump"

6. **Summary**: Print count of items routed per client, items left in Brain Dump, orphans.

---

## Section 1: Call Transcripts

**Skip (and log) if no transcript service is configured.**

1. Fetch today's calls. Preference order:
   - A fetch script if one exists (`scripts/fathom-fetch.py --date $TODAY --json`) — it reads `FATHOM_API_KEY` from the environment
   - Direct REST otherwise:
     ```bash
     curl -s -H "X-Api-Key: ${FATHOM_API_KEY}" "https://api.fathom.ai/external/v1/meetings?created_after=${TODAY}T00:00:00Z&include_transcript=true"
     ```
     (A network error here usually means `api.fathom.ai` is missing from the environment's network allowlist — log that exact hint.)
2. For each call: save the transcript to the correct folder (client contacts → `Work/Clients/<Client>/Transcripts/`, team-only → `Work/Transcripts/`, private → `[YourCompany]/Transcripts/`), then extract:
   - **Action items** for you (with deadlines if mentioned)
   - **Action items for others** (framed as follow-ups)
   - **Research items**, **decisions made**, **follow-ups needed**

   **Task vs. Note distinction**: Only create `- [ ]` items for clear, specific next actions. Meeting recaps without action items, status updates, and finalized decisions are Type `note`.
3. **ROUTE IMMEDIATELY**:
   a. Tasks → `Inbox/<Client>.md` under `Open Tasks`; cross-client/internal → `Inbox/[YourCompany].md`
   b. Notes/decisions → `## Notes` section (plain bullets)
   c. Append a manifest row per item; unknown client → `Inbox/[YourCompany].md` and mark `ORPHAN`
4. Confirm manifest item count matches extraction count

---

## Section 2: Tomorrow's Calendar

1. Fetch tomorrow's events — **connector Calendar tools first** (list events for $TOMORROW). REST fallback only if Google env-var credentials are configured.
2. Convert all times to [Your Timezone] before formatting (API timestamps are usually UTC).
3. Format as a readable list: times, titles, attendees
4. Flag early meetings (before the preferred meeting window) and back-to-backs
5. Write the formatted schedule to `System/state/eod-calendar-$TODAY.md` for later phases

---

## Section 3: Email Check

1. Fetch today's emails — **connector Gmail tools first** (today's messages, first 15-20)
2. Surface emails requiring response, client/team emails, time-sensitive items

   **Task vs. Note distinction**: Only create tasks for emails needing a specific action. Meeting recaps, calendar acceptances, FYI emails, and auto-notifications are NOT tasks.
3. **ROUTE IMMEDIATELY**: tasks → client file `Open Tasks`; notes → `## Notes`; manifest rows for all

---

## Section 4: Slack Check

For each connected workspace:
1. Check unread DMs and mentions via the Slack connector tools
2. Surface unread DMs, mentions, time-sensitive items; skip channels with no unread activity
3. **ROUTE IMMEDIATELY**: append items to client file `Open Tasks`; manifest rows

---

## Phase 1 Complete

1. Read back the manifest and print a summary: total items extracted, routed, orphaned; note any skipped sources
2. Print the calendar preview for tomorrow
3. **Save:** `git add -A && git commit -m "EOD $TODAY phase 1: gathered [N] items" && git push`
   (When running as part of the single-command `/eod`, this commit is optional — the final `/eod` save covers it — but committing per-phase is required whenever phases run in separate sessions.)
