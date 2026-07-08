# EOD Phase 4: Daily Note (Cloud Edition)

Generates the permanent daily note at `Work/Daily/YYYY-MM-DD.md`. Pulls from the manifest, calendar cache, client inbox files, and optional time tracking data.

**This is a short, non-interactive phase.** Read from disk, generate, write, done.

---

## Setup

1. Get today's date **in the user's timezone**: `TZ="[IANA-Timezone]" date "+%Y-%m-%d %A"` (never bare `date` — the container clock is UTC)
2. Read the manifest at `System/state/eod-manifest-$TODAY.md`
   - If missing: stop and say to run Phase 1 first (in unattended mode: generate what you can from inbox files and log the gap)
3. Read today's calendar cache at `System/state/eod-calendar-$TODAY.md`
   - If missing: note "No calendar data available" and continue
4. Read all client inbox files from `Inbox/` to pull Completed sections
5. Check for a time summary at `System/state/eod-time-$TODAY.md`
   - If missing: skip the time tracking section (don't warn)

---

## Generate

Build the daily note with these sections, in order. Omit any section that has no content.

```markdown
# YYYY-MM-DD (Day of Week)

## Meetings
- [Time] [Title] ([Attendees])

## Key Outcomes & Decisions
- [Decision or outcome from manifest, Type = decision/note]

## Tasks Completed
- [x] [Task description] ([Client])

## Tasks Added
- [ ] [Task description] ([Client]) -- Source: [source]

## Time Tracking
- Total tracked: [X hrs Y min]
- Top categories: [Category1] [time], [Category2] [time]

## Summary
[2-3 sentence narrative: what the day looked like, what moved forward,
what carries into tomorrow. First person, plain language.]

## EOD Errors
- [Only if anything failed this run: which integration, what was skipped,
  what /morning should catch up on. Omit the section when clean.]
```

**Section details:**

- **Meetings**: from the calendar cache; past tense framing ("attended").
- **Key Outcomes & Decisions**: manifest rows where Type is `decision`, `note`, or `research`; group by client.
- **Tasks Completed**: `- [x]` items completed today across `Inbox/*.md`, client in parentheses.
- **Tasks Added**: manifest rows with Type `action-owner`, `action-other`, or `followup`, with source.
- **Time Tracking**: one or two lines from the time summary.
- **Summary**: biggest win, blockers, what's queued for tomorrow.
- **EOD Errors**: everything logged as skipped/failed during this EOD run — this is what makes unattended runs debuggable the next morning.

---

## Write

1. Use the Write tool to create `Work/Daily/YYYY-MM-DD.md`
2. If the file already exists (EOD re-run), merge: keep existing content and append what is new, noting the re-run. In interactive mode, ask before overwriting instead.

---

## Confirm

```
Daily note written: Work/Daily/YYYY-MM-DD.md
  Meetings: N | Completed: N | Added: N | Decisions: N | Errors: N
```

**Save** (when running as a standalone session): `git add -A && git commit -m "EOD $TODAY phase 4: daily note" && git push`

Phase 4 complete. Handoff to Phase 5 (Today.md generation).
