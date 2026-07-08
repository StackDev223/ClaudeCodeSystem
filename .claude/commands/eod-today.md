# EOD Phase 5: Generate Tomorrow's Today.md (Cloud Edition)

Reads the manifest, inbox files, today's plan, and tomorrow's calendar. Produces a fresh `Inbox/Today.md` with schedule, prioritized tasks, meeting prep, and deadline radar.

**This phase is the last content phase in the pipeline.** It reads everything earlier phases wrote to disk and produces one output file.

**Critical rule: Full overwrite.** `Inbox/Today.md` is ephemeral. Write the entire file from scratch every run using the Write tool. (Git history preserves every prior version automatically.)

**Critical rule: Source every task.** Every work task must include a `<!-- src:Inbox/ClientA.md|fingerprint -->` tag. Fingerprint is a 30-40 char substring unique enough to locate the task via substring match.

**Critical rule: No empty sections.** Only include Meeting Prep, Carried Forward, Morning Exceptions, or Deadline Radar if they have content.

---

## Step 1: Setup

1. Get the date **in the user's timezone**: `TZ="[IANA-Timezone]" date "+%Y-%m-%d %A %H:%M"`
2. Compute `TOMORROW` (format: `YYYY-MM-DD` and display name like `Wednesday, March 18, 2026`):
   ```bash
   TZ="[IANA-Timezone]" date -d "tomorrow" "+%Y-%m-%d %A, %B %d, %Y"
   ```
3. Confirm the manifest exists at `System/state/eod-manifest-$TODAY.md` (warn if missing, continue)

---

## Step 2: Calendar

1. Read the cached calendar at `System/state/eod-calendar-$TODAY.md` (from Phase 1). If missing, fetch tomorrow's events now via the Calendar connector tools; convert times to [Your Timezone].
2. Build the schedule table from the daily skeleton in CLAUDE.md, slotting meetings into their times:

   | Time | Block | Notes |
   |------|-------|-------|
   | 8:00 | Morning review | Review this file, adjust if needed |
   | 8:05 | Deep Work 1 | _filled in Step 4_ |
   | 12:00 | Lunch | |
   | 1:00 | Meeting window | _filled from calendar_ |
   | 2:30 | Deep Work 2 | _filled in Step 4_ |
   | 5:30 | Wind down | |

---

## Step 3: Morning Exceptions

1. Scan tomorrow's events for anything before the meeting window
2. If found, list each with time, title, and impact (e.g., "cuts Deep Work 1 short")
3. If none: "None. Full deep work block protected."

---

## Step 4: Task Selection

1. Read all client inbox files (`Inbox/*.md`) and the manifest
2. Select 5-7 tasks by priority: Tier 1 clients first, hard deadlines first, manifest items ranked higher, quick wins that unblock others
3. Assign to time blocks: high-focus to Deep Work 1, meetings to Meeting Window, async/admin to Deep Work 2
4. Tag each task: `- [ ] **[Client]** Description <!-- src:Inbox/Client.md|fingerprint -->`
5. Tag each meeting: `- [ ] 1:00 Title (Client, duration) <!-- type:meeting -->`

---

## Step 5: Carry Forward Brain Dump + Unchecked Items

Before generating, read TODAY's `Inbox/Today.md` (the one being replaced).

### Brain Dump carry-forward
1. Personal items, ideas, and unrouted items carry forward into tomorrow's Brain Dump section as-is
2. Items routed by Phase 1 (strikethrough) are dropped

### Task carry-forward
1. Find unchecked non-meeting tasks (`- [ ]` without `<!-- type:meeting -->`)
2. If a task was re-selected in Step 4, increment its carry count:
   - No tag yet: add `<!-- carried:1 -->`
   - Existing `<!-- carried:N -->`: increment to N+1
3. Tasks at `<!-- carried:3 -->` or higher get a `**[STALE]**` warning prefix
4. If not re-selected, the task stays in the client inbox (drops off Today.md)
5. Place carried tasks under `### Carried Forward`

---

## Step 6: Meeting Prep

For each meeting tomorrow, pull context from the client Company Profile, recent transcripts, and open tasks:
```markdown
### HH:MM -- Meeting Title
**Attendees:** [Contact Name], [Your Name]
**Context:** Meeting purpose
**Recent activity:** [[YYYY-MM-DD - Previous Meeting Title]]
**Strategic context:** Current quarter goal
**Prep needed:**
- Item to review before the call
- Decision to push for
```

---

## Step 7: Deadline Radar

Scan all client inbox files for deadlines in the next 7 days. Table sorted by date; omit the section if none.

---

## Step 8: North Star Goals

Read strategic goals from each client Company Profile. One line per client; "Not yet set" where empty.

---

## Step 9: Team Priorities

Generate a copy/paste-ready Slack message with **Primary focus** (1-2 items), **Secondary (if time allows)** (1 item), and **Blockers to flag**.

---

## Step 10: Write Today.md

Assemble and write `Inbox/Today.md` using the Write tool. Section order:
1. `# Today -- DayOfWeek, Month DD, YYYY`
2. `## Brain Dump` -- quick capture area with carry-forward items (if any)
3. `## Schedule` (table)
4. `## Morning Exceptions`
5. `## Tasks` -- subsections: Deep Work 1, Meeting Window, Deep Work 2, Carried Forward
6. `## Meeting Prep` (if meetings exist)
7. `## Deadline Radar` (if deadlines exist)
8. `## This Week's North Star`
9. `## Team Priorities`
10. `## Adjustments` -- empty checkbox placeholder for morning review
11. Footer: `*Generated by EOD at HH:MM [Your Timezone]*`

---

## Step 11: Summary and Save

Print confirmation:
```
Today.md generated for Wednesday, March 18, 2026
  5 tasks selected | 2 meetings | 1 carried forward | 2 deadlines this week
```

**Save** (when running as a standalone session — inside single-command `/eod`, the final `/eod` save covers it):
```bash
git add -A && git commit -m "EOD $TODAY phase 5: Today.md for $TOMORROW" && git push
```
