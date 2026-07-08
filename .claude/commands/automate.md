# Automate: Put Your System on a Schedule

Set up cloud Routines so the system runs without you. This replaces every cron job, launchd script, and "leave the computer on overnight" hack from the local edition — Routines run in the cloud on Anthropic's infrastructure.

**When to use:** during `/finish`, or anytime the user says "run this automatically", "every night", "on a schedule".

**What a Routine is (explain to the user in these terms):** "A Routine is a saved instruction with a schedule. At the scheduled time, a fresh Claude session starts on your vault, follows the instruction, saves its work to your repository, and shuts down. Your computer is not involved."

**Key facts to design around:**
- Each firing is a **fresh session on a fresh clone** of the repo's default branch — which is why every workflow commits and pushes (Runtime & Persistence Protocol). A Routine cannot see work that was never pushed.
- Schedules run **hourly at minimum** (no sub-hourly), and accounts have a **daily run allowance** — a nightly EOD plus an optional morning brief fits comfortably.
- Routines run **unattended**: the prompt must stand alone, and the workflow must never wait for a human (the `/eod` command has an unattended mode for exactly this).
- Routine times are entered in the user's local timezone in the claude.ai interface.

---

## Step 1: Choose What to Automate

Read CLAUDE.md for their end-of-day preference. Then:

AskUserQuestion: "What should run automatically?"
Options:
- Nightly EOD (recommended): process the day and build tomorrow's plan every night
- Nightly EOD + weekday morning brief: also refresh the plan with any overnight email before your day starts
- Something else (a custom recurring job)
- Just show me how Routines work

## Step 2: Pick the Schedule

For the nightly EOD:

AskUserQuestion: "What time should the nightly wrap-up run? Pick a time after you are done working but before midnight **in your timezone** — if it runs after midnight, it will process the wrong day."
Options:
- 10:00 PM
- 10:30 PM
- 11:00 PM
- Different time

Weekdays only or every day?

AskUserQuestion: "Should it run on weekends too?"
Options:
- Weekdays only (recommended)
- Every day
- Weekdays + Sunday night (so Monday morning has a plan)

## Step 3: Create the Routine

Walk the user through the claude.ai interface (you cannot create Routines for them):

1. "Go to **claude.ai/code** and find **Routines** (or the schedule option when starting a task)."
2. "Create a new Routine with these settings:"
   - **Repository:** this vault repo (default branch)
   - **Prompt:** paste exactly:
     ```
     Run /eod in unattended mode. No one is watching this session: do not ask questions, apply defaults, log any integration failures into the daily note's "EOD Errors" section, and always finish by committing and pushing, even if some steps failed.
     ```
   - **Connectors:** include their connectors (calendar, email, Slack) — these are what the gather step uses
   - **Schedule:** [their chosen time and days]
   - **Branch permissions:** enable **Allow unrestricted branch pushes** for this repo if prompted — the routine must save to main
3. "Save the Routine."

AskUserQuestion: "Is the Routine created?"
Options:
- Yes, it is saved
- I cannot find Routines
- I got stuck on one of the settings

For the optional morning brief, repeat with:
- **Prompt:** `Run the morning refresh: git pull, check overnight email and today's calendar via connectors, update Inbox/Today.md's schedule and Morning Exceptions sections if anything changed, commit and push. Unattended mode: no questions, log issues in Today.md.`
- **Schedule:** weekdays, ~1 hour before their workday starts

## Step 4: Test It Now

Do not wait for tonight to find out it does not work.

1. "Most Routine screens have a **run now** option — trigger it once." (If there is no run-now option, schedule a one-off run a few minutes out.)
2. Wait for the run to finish, then verify from this session:
   ```bash
   git pull --ff-only && git log --oneline -3
   ```
3. Confirm you see the routine's commit (e.g., `EOD 2026-07-08: ...`). Open `Inbox/Today.md` and check it looks right.
4. **Check the daily note for an "EOD Errors" section.** The most important thing to catch here: whether the connectors (calendar, email) worked in the unattended run. If the errors section shows connector failures, tell the user plainly: "The nightly run could not reach [tool] — this can happen with connector logins in scheduled sessions. Your plan will still build every night from your notes and tasks; I will catch up on email and calendar when you run /morning." Then make sure `/morning`'s catch-up step is understood.

AskUserQuestion: "Did the test run produce a fresh Today.md?"
Options:
- Yes, it worked!
- It ran but something looks wrong
- It did not run / I cannot tell

## Step 5: Document and Save

1. Update CLAUDE.md's Quick Reference (Scheduled automation row) with what is scheduled and when.
2. Add a note under Common Workflows → EOD Pipeline: "Runs automatically via Routine at [time] [days]."
3. Commit and push: `git add -A && git commit -m "Automate: nightly EOD routine configured ([time] [days])" && git push`

Tell the user: "From tonight onward, your day gets processed and tomorrow's plan gets built automatically. Check `Inbox/Today.md` in the morning — and if anything ever looks stale, just run `/eod` manually; it is the same process."
