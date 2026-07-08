# Daily Note (Cloud Edition)

Lightweight daily capture. Just record what happened today and move on. (This is the simple alternative to the full `/eod` for light days or light users.)

---

## Step 1: Sync and Date

1. `git pull --ff-only`
2. Get today's date **in the user's timezone** and set `TODAY`:
   ```bash
   TZ="[IANA-Timezone]" date "+%Y-%m-%d"
   ```

---

## Step 2: What Happened Today

1. **AskUserQuestion**: "What did you work on today? Just talk -- bullets, sentences, whatever comes to mind."
2. Save the raw response as `USER_INPUT` for Step 4

---

## Step 3: Pull Supporting Data

Gather what you can. Skip anything that is not available.

1. **Calendar**: fetch today's meetings via the Calendar connector tools
   - List meeting titles and times (in [Your Timezone])
   - If unavailable, skip and note "No calendar data"
2. **Client inboxes**: scan `Inbox/*.md` for tasks marked `[x]` with today's date

---

## Step 4: Write the Daily Note

Create `Work/Daily/TODAY.md`:

```markdown
# TODAY

## Meetings
- (list from calendar, or "None captured")

## What I Worked On
- (user's response from Step 2, cleaned into bullets)

## Tasks Completed
- (completed items from inbox files, or "None captured")

## Summary
(2-3 sentence recap of the day)
```

---

## Step 5: Tomorrow's Plan (Optional)

1. **AskUserQuestion**: "Want me to draft a quick plan for tomorrow?"
2. If yes: check tomorrow's calendar, pull open tasks with upcoming deadlines from inbox files, append a `## Tomorrow` section with a short bullet list
3. If no: done

---

## Step 6: Save

```bash
git add -A && git commit -m "Daily note $TODAY" && git push
```
(If rejected: `git pull --rebase && git push`.) The note is saved only when this succeeds.
