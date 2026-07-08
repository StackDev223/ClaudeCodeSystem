# Finish: Take It for a Spin and Learn to Maximize It (Cloud Edition)

This is Part 4 of 4 in the setup process. The user has run `/onboard` (personalized vault), `/train` (learned the system), and `/connect` (connected tools). Now we demo the system with real data, switch on the nightly automation, and teach them how to get the most value over time.

**Prerequisites:** Vault personalized, CLAUDE.md customized, tools connected and tested.

**Voice:** Encouraging, practical. This is the payoff — show them what they built actually working.

**Important:** Use `AskUserQuestion` for every decision point. This step should feel like a victory lap, not more work.

---

## Step 1: Live Demo with Real Data

"Everything is set up. Let me show you what your system can actually do. I am going to pull real data from your tools right now."

### Calendar Check
Pull tomorrow's calendar (or today's if it is morning) via the connector tools. Show the schedule:
- Events with times (in their timezone), attendees, duration
- Flag conflicts or back-to-back meetings
- Note protected deep work time

### Email Scan
If email is connected, surface the top 3-5 items needing attention: sender, subject, one-line summary, urgency flags.

### Task Overview
If a task manager is connected, pull current tasks: top items by priority, what is due this week.

### Meeting Prep (if applicable)
If they have a meeting coming up, prep it: recent context (transcripts, open tasks for that client, last discussion points) and suggested talking points.

Present all of this, then:

AskUserQuestion: "This is what your morning review will look like every day. How does it feel?"
Options:
- This is amazing, I can see how this saves time
- Cool but I want to adjust some things
- I have questions about how some of this works
- Can you show me something else?

---

## Step 2: Build Tomorrow's Plan

"Let me build your plan for tomorrow, just like the system will do automatically every night."

Generate `Inbox/Today.md` for tomorrow (follow `/eod-today`): calendar events, open tasks from inbox files, priority tiers, their schedule preferences.

Commit and push, then show them where to read it on their chosen surface: "Open [Today.md on their reading surface]. This is what will be waiting for you every morning."

AskUserQuestion: "Want to adjust anything in tomorrow's plan?"
Options:
- Looks good as is
- Move [task] to a different time block
- Add something I forgot
- Remove something

---

## Step 3: Switch On the Nightly Automation

"Now the part that makes this system special: putting it on autopilot."

If their onboarding preference was an automatic EOD (check CLAUDE.md), run `/automate` now — full flow including the test run. If they preferred manual, explain what `/automate` offers and ask:

AskUserQuestion: "Want your end-of-day to run automatically every night, even with your computer off?"
Options:
- Yes, set up the nightly routine (recommended)
- Not yet, I will run /eod manually for a while first
- Tell me more about how it works

---

## Step 4: Improvement Prompts

"The system gets better the more you use it. Here are things you can say to me anytime:"

### Adding Rules
- "Never schedule deep work after 4 PM"
- "Always put [Client] tasks before [Client] tasks"
- "When you write emails for me, keep them under 3 sentences"
- "Stop asking me about [thing], just do it"

"I add these to your instruction manual (CLAUDE.md) and save it, so every future session follows them."

### Turning Tasks into Skills
- "Turn this into a skill"
- "I want to do this every week"

"I create a text file with the steps we used, save it to your vault, and you can run it anytime with `/skill-name` — from any device."

### Teaching Claude About Your Work
- "Here is how [Client] likes their deliverables formatted..."
- "When I say 'urgent' for [Client], it means within 2 hours."
- "My team member [Name] handles [responsibility]."

### Fixing Mistakes
- Instead of: "No, put that in the other folder" (fixes it once)
- Say: "Always put [type of item] in [folder]. Add this to CLAUDE.md." (fixes it permanently)

AskUserQuestion: "Makes sense? Any rules you want to add right now?"
Options:
- Yes, I want to add a few things
- No, I will add rules as they come up
- Can you give me more examples?

If they add rules, update CLAUDE.md together and commit.

---

## Step 5: The Monthly Review

"Once a month, I will nudge you to do a system review. It takes about 15 minutes and keeps everything running smoothly:"
- **System feedback:** what is working and what is not
- **Health check:** I audit my own instruction manual against reality, verify every connection still works, and check the vault's repository health (including whether the nightly routine ran every night)
- **Vault cleanup:** stuck tasks, outdated notes, misplaced files
- **Testimonial scan:** if Slack is connected, I search for positive client feedback worth saving

"You do not have to remember this. I mention it once at the start of each new month."

---

## Step 6: Power Tips

Share 3-4 tips based on their specific setup:

### For everyone
"You can ask me anything about your system: 'What did I do last Tuesday?' (I check the daily notes and the vault history), 'What is pending for [Client]?', 'What meetings do I have this week?'"

### Phone workflows
"Two that people love: dictate a `/brain-dump` from the car — everything gets filed before you park. And run `/morning` from your phone with three taps while you have coffee."

### If they have clients
"Ask 'What is the status of [Client]?' and I will check their inbox file, recent transcripts, and task manager for a full picture."

### If they have meeting transcripts
"After every call, the nightly routine pulls the transcript, extracts action items, and routes them to the right client file. You do not have to take notes during calls."

### The undo button
"Everything I do is a save point. If anything ever looks wrong — a plan overwritten, a note misfiled — say 'undo that' or 'what changed yesterday?' and I can show or restore any previous version."

---

## Step 7: Archive the Setup Files

"One last piece of housekeeping. The `setup/` folder in your vault holds the original templates and guides used to build your system. You do not need them day-to-day, so I will move them to your Archive — and because your vault keeps full history, the originals are also permanently recoverable from any point in time."

**Action:**
1. Move `setup/` to `Archive/Setup-Original/`:
   ```bash
   git mv setup Archive/Setup-Original
   ```
2. Update the root CLAUDE.md Quick Reference row for "Original setup files" to point at `Archive/Setup-Original/`.
3. Commit and push:
   ```bash
   git add -A && git commit -m "Finish: setup complete, scaffolding archived" && git push
   ```

---

## Step 8: Wrap Up

"Your personal assistant system is fully set up and running. Here is the complete picture:"

```
Your system:
- Vault: your private GitHub repository (every change saved with full history)
- Instruction manual: CLAUDE.md (customized for you)
- Tools connected: [list with ✓]
- Skills: [list their skills]
- Nightly automation: [Routine time + days, or "manual /eod for now"]

Your daily rhythm:
- Overnight: the system processes your day and builds tomorrow's plan
- Morning: read Today.md, run /morning (5 min, works from your phone)
- During the day: ask Claude anything, /brain-dump freely
- Monthly: run /monthly-review when nudged

How to improve:
- Tell Claude when it gets something wrong (rules, not one-off fixes)
- Turn successful tasks into skills
```

AskUserQuestion: "You are all set. Anything else you want to adjust or ask about before we wrap up?"
Options:
- I am good, thanks!
- I want to change something
- One more question
- Can we do a practice run of /morning?

If they want a practice `/morning`, do it right now with real data — the perfect ending: they see the full system working end to end.

**Final message:** "Welcome to your new system. Tonight it runs on its own for the first time. Tomorrow morning, check Today.md and type `/morning`. I will be there."
