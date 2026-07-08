# Morning Review (Cloud Edition)

Interactive morning review command. Reviews Today.md client-by-client, interviews the user for gaps, then creates calendar time blocks. Works the same from the web, the phone app, or a local CLI session.

---

## Step 1: Load

1. **Sync:** `git pull --ff-only` (the nightly Routine pushed Today.md while you were asleep — make sure this session has it)
2. Get today's date **in the user's timezone**: `TZ="[IANA-Timezone]" date "+%Y-%m-%d %A %H:%M"` (never bare `date` — the container clock is UTC)
3. Read `Inbox/Today.md`
4. **Stale check**: Compare today's actual date to the date in the `# Today --` header
   - If the file is missing: offer to generate it inline (run the eod-today logic with live data)
   - If the date doesn't match today: warn "Today.md is stale (shows [file date], today is [actual date]). The nightly run may have failed — want me to regenerate?" (Check `git log --oneline -3` — if there is no EOD commit from last night, say so; the Routine may need attention via `/automate`.)
   - If it matches: proceed
5. **EOD error catch-up**: Read yesterday's daily note (`Work/Daily/[yesterday].md`). If it has an `## EOD Errors` section (e.g., email or calendar was unreachable in the unattended run), do the catch-up NOW: fetch what was missed via the connector tools, route anything actionable, and update Today.md before presenting it. Tell the user what was caught up in one line.
6. **Carried-forward detection**: Check the `### Carried Forward` section in `## Tasks` — count items and extract their `<!-- carried:N -->` values

---

## Step 2: Summary

Present a concise 8-10 line overview:

```
Good morning. [Day of week], [Month DD].

[N] meetings today -- first at [time], last at [time]
[Morning exceptions: N calls before 1 PM / "Full deep work block protected"]
Top priority: [#1 item from Top Priorities]
[Deadline alert if anything due today/tomorrow, or "No imminent deadlines"]

North Star this week:
  [Client A]: [goal]
  [Client B]: [goal]
```

Keep it scannable. No filler.

Then say: **"Let's walk through each client. I'll confirm what's on the plan and flag anything that looks off."**

---

## Step 3: Client Review (Batch + Select)

Present ALL clients at once in a single output, then use `AskUserQuestion` to collect feedback efficiently.

**Order**: Tier 1 clients first, then Tier 2, then others.

### 3a: Present the full picture

Show every client with items in Today.md's Top Priorities, Meeting Prep, or Deadline Radar in one batch:

```
### [Client A]
- [Task 1] -- ~30 min
- [Task 2] -- ~45 min
- Meeting: 1:30 PM [Contact Name] sync
- (warning) [Any flag: conflict, missing estimate, risk]
- Deep work needed: ~75 min

### [Client B]
- [Task 1] -- ~20 min
- Meeting: 2:00 PM [Contact Name] check-in
- Looks clean.
- Deep work needed: ~20 min
```

**What to flag:**
- Tasks with no clear time estimate
- Tasks too ambitious for available deep work
- Meeting prep items that reference unverified things
- Conflicts between tasks competing for the same slot
- "Waiting on" items where you could unblock
- Deadlines today/tomorrow without a clear slot

Then show the capacity check:

```
Total deep work needed: ~[X] hrs
Available deep work: ~[A] hrs (DW1: [B] hrs, DW2: [C] hrs)
[Warning if overcommitted]
```

### 3b: Collect feedback via AskUserQuestion

Use `AskUserQuestion` with **multiSelect: true**:

```
Question: "Any clients need adjustments?"
Header: "Review"
Options:
  - "All good" / "No changes needed, move to scheduling"
  - "[Client1]" / "[Brief flag summary, e.g. 'has conflict']"
  - "[Client2]" / "[Brief flag summary]"
  - "[Client3]" / "[Brief flag summary]"
```

Build the options dynamically from the clients that have items. Include up to 4 options (prioritize clients with flags). If more than 3 clients have items, group the clean ones and only list flagged clients individually.

### 3c: Handle adjustments

- "All good" → proceed to Step 4 immediately.
- Specific clients selected → for each, use another `AskUserQuestion` with common actions (Drop a task / Push to tomorrow / Adjust time / Add a task), then apply the change.
- Free-text via "Other": parse, apply changes, route any brain dump items to the appropriate client inbox files.

### 3d: Confirm if changes were made

If any adjustments were made, show a brief diff (client, change, time saved) and updated totals. No confirmation needed; proceed.

---

## Step 4: Goal Check

Read each client's Company Profile `## Strategic Goals` section.

Staleness: placeholder text = empty; `*Last updated:*` more than 7 days ago = stale.

If any are empty or stale, use `AskUserQuestion`:

```
Question: "Strategic goals are stale for [Client1, Client2] (last updated [date]). Refresh now?"
Header: "Goals"
Options:
  - "Skip" / "Move on, I'll update later"
  - "Quick refresh" / "I'll dictate updated goals for each"
```

If all goals are current: skip this step entirely, no output.

---

## Step 5: Create Calendar Time Blocks

1. **Fetch today's calendar** via the Calendar connector tools to see what's already there
2. **Identify open windows** between fixed events (meetings, lunch, breaks)
3. **Assign tasks to time blocks**: highest priority in Deep Work 1 (freshest energy), meeting follow-ups and async work in Deep Work 2, respecting the review's time estimates
4. **Present the proposed blocks** as a table, then `AskUserQuestion`:

```
Question: "Create these time blocks on the calendar?"
Header: "Schedule"
Options:
  - "Create all (Recommended)" / "Add all blocks to the calendar as shown"
  - "Adjust first" / "I want to move or change some blocks"
  - "Skip blocks" / "Don't create calendar events today"
```

5. **Create the calendar events** for each approved block via the connector tools
6. **Update Today.md** with the finalized schedule table

---

## Step 6: Send-off and Save

```bash
git add -A && git commit -m "Morning $TODAY: plan locked, [N] blocks created" && git push
```
(If push is rejected: `git pull --rebase && git push`.)

Confirm the plan is locked:

```
Plan locked. [N] time blocks created. Saved.
First meeting at [time] ([title]).
[Top priority] starts now in Deep Work 1.
Have a good one.
```

If no meetings: "No meetings today. Full deep work runway. [Top priority] starts now."

---

## Notes

- Use `AskUserQuestion` for ALL interaction points. Every decision point must use selectable options — this is what makes `/morning` three taps from a phone.
- If the plan is clean, the entire review is: "All good" → "Create all" → done.
- Today.md is ephemeral (overwritten each EOD run). The daily note (`Work/Daily/YYYY-MM-DD.md`) is the permanent record. Git history keeps every version of both.
- **Time block granularity**: group related small tasks into blocks of 30-90 minutes; no 15-minute confetti.
- **Overcommitment guard**: if estimated work exceeds available deep work time, force a prioritization conversation in Step 3 before creating blocks.
- **Calendar cleanup**: if `/morning` already ran today, offer to replace this morning's existing blocks rather than duplicating them.
