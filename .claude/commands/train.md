# Train: Learn How Your System Works

This is Part 2 of 4 in the setup process. The user just ran `/onboard`, which built their vault and customized their files. Now they are in a fresh Claude Code session inside their vault.

**Prerequisites:** `/onboard` has been completed. CLAUDE.md exists. Vault folder structure exists.

**Voice:** Friendly, patient teacher. Explain everything in plain language. Use everyday analogies. Never assume they know what a file path, terminal, or markdown file is.

**Important:** Use `AskUserQuestion` for EVERY check-in. Do not lecture -- show, then ask if it makes sense. Keep each explanation to 3-4 sentences max before checking in.

---

## Step 1: Verify Setup

Before starting, confirm everything from `/onboard` is in place:
- Read CLAUDE.md and confirm it has the user's name and details
- Check that Inbox/, Work/, and other folders exist
- Check that `.claude/commands/` has their skills

If anything is missing, tell the user and offer to fix it or re-run `/onboard`.

If everything looks good: "Everything from the onboard step is here. Let me show you how it all works."

---

## Step 2: What Is This Folder?

"You are looking at your notes folder (Obsidian calls it a 'vault'). It is just a folder of text files on your computer. Nothing is in the cloud, nothing is on someone else's server. Claude can read and write these files instantly because they are right here on your machine."

Open Obsidian and walk them through the key folders:

"Let me give you a quick tour. You should be able to see these folders in Obsidian's sidebar:"

- **Inbox/** -- "This is your command center. New tasks, today's plan, and per-client task lists all live here. Think of it as your desk where active work sits."
- **Work/** -- "Professional projects. Each client gets their own subfolder with call transcripts, archives, and notes."
- **[CompanyName]/** -- "Your company's private docs. Hiring, SOPs, internal strategy. Separate from Work/ so it is never accidentally shared."
- **Resources/** -- "Reference material. Contacts, health notes, learning notes, recipes. Stuff you look up, not stuff you do."
- **Archive/** -- "Where completed work goes. Every week, done tasks get moved here so your active files stay clean."

AskUserQuestion: "Does the folder structure make sense? Any questions about where things go?"
Options:
- Makes sense, keep going
- Why is [folder] separate from [folder]?
- I want to rename or reorganize something
- What about personal stuff?

---

## Step 3: Your Instruction Manual (CLAUDE.md)

"Now let me show you the most important file in the system."

Open CLAUDE.md and walk through it section by section. Do NOT read the whole thing out loud. Highlight the key parts:

### The Startup Checklist
"Every time we start a conversation, I read this file first. The checklist at the top tells me to check the date, look for pending items, and see if a monthly review is due."

### About This System
"This section explains what I am and how I work. If you ever forget how the system works, this is where to look."

### The Quick Reference Table
"This is my cheat sheet. It tells me where to find things -- your inbox, your credentials, client profiles, today's plan."

### Your Schedule and Preferences
"This is where your daily schedule, meeting preferences, and work style are defined. I follow these rules every session."

Point out their specific customizations: "See how it says [their actual schedule]? And your clients are listed as [actual client names]? That all came from our conversation during onboard."

### Available Integrations
"This section lists every tool I can connect to. Right now some of these are placeholders -- we will actually connect them in the next step (`/connect`)."

AskUserQuestion: "Any questions about CLAUDE.md? This file is yours to change anytime. If I ever do something wrong, you can add a rule here and I will follow it."
Options:
- Got it, makes sense
- Can I change [specific thing]?
- What if I want to add something later?
- Show me how to edit it

If they want to see how to edit: walk them through opening CLAUDE.md in Obsidian and making a small change (like adjusting lunch time). Show them that it is just a text file they can type in.

---

## Step 4: How Skills Work

"A skill is a successful task that has been turned into a repeatable routine. When you complete something that could be useful again, you or I can save it as a skill. Over time, your system gets smarter because your skills library grows from your actual work."

"Every skill is just a text file in a specific folder. You type a short name and I run the whole thing."

Show them what is in their `.claude/commands/` folder:

"Here are the skills we set up for you:"
- List each skill file and explain what it does in one sentence
- For example: "`/morning` -- reviews your day, shows your schedule, helps you adjust priorities"

"These are just text files. You can open them, read them, change them. And here is the important part: you can create new skills anytime. If we do something together that works well and you might want to do it again, I can save it as a skill for you."

AskUserQuestion: "Want to look inside one of these to see how they work?"
Options:
- Yes, show me what is inside /morning (or whichever they have)
- No, I trust it, keep going
- How do I create a new one?

If yes: open the skill file and walk through it briefly. "See how it is just instructions written in plain English? I read these instructions and follow them step by step."

If "How do I create a new one?": "Any time we complete a task together that seems like something you would do again, I will offer to save it as a skill. Or you can just tell me: 'turn this into a skill.' I will write the steps into a file and you can run it anytime with one tap."

---

## Step 5: The Daily Loop

"Here is how a typical day works with this system. This is the big picture."

Explain the daily loop in 4 simple beats:

1. **End of day:** "Before you wrap up, type `/eod`. I process your calls, emails, and messages, organize everything, and build tomorrow's plan. You can walk away while it runs."

2. **Morning (5 minutes):** "You open Obsidian, look at `Inbox/Today.md` which I built during the EOD run, then type `/morning`. I walk you through the plan and help you adjust if needed."

3. **During the day (as needed):** "Ask me to do things: draft an email, look up a client, create a task, prep for a meeting. I work from the notes in your vault."

4. **Evening (automatic):** "The cycle repeats. I process the day and build tomorrow's plan."

AskUserQuestion: "Does the daily loop make sense?"
Options:
- Yes, that is clear
- What if I forget to run /eod?
- What happens on weekends?
- What if I miss the morning review?

Address their question, then continue.

---

## Step 6: How to Work with an AI Assistant

"Before we connect your tools, I want to share a few things about how to get the most out of working with me. This is different from using a search engine or a simple chatbot."

### Think of me as a new hire

"I am like a very capable employee who just started. I can do a lot, but I need you to show me how you like things done. The first few weeks, you will correct me. That is normal and expected. Each correction makes me permanently better because we add it to your instruction manual."

### Tell me what to do, not how to do it

"You do not need to write detailed instructions. Just say what you want:"
- Instead of: "Open the Gmail API and search for emails from John with is:unread"
- Say: "Check if John sent me anything today"

"I know how to use your tools. You just need to tell me the goal."

### Let successful tasks become skills

"When we complete a task together that works well, I will ask if you want to save it as a skill. If you say yes, I create a reusable routine you can run with one tap. The goal is that your system gets smarter over time because it learns from the actual work you do."

"You can also tell me directly: 'turn this into a skill' or 'I want to do this every week.' I will build it."

### Correct me with rules, not just fixes

"When I get something wrong, the best response is a rule:"
- Instead of: "No, put that in the other folder" (fixes it once)
- Say: "Always put [type of item] in [folder]. Add this to CLAUDE.md." (fixes it forever)

### The daily rhythm

"The system works best when you build a rhythm:"
- **End of day**: Run `/eod` before wrapping up. I process everything and build tomorrow's plan. You can walk away.
- **Morning**: Read `Today.md`, run `/morning`. Confirm the plan in 3-5 minutes.
- **During the day**: Ask me for anything. The more you use me, the more context I have.

"This is not about adding more work to your day. It is about replacing the 30-60 minutes you already spend organizing, planning, and chasing loose ends."

AskUserQuestion: "Does this make sense? Any questions about how to work with me?"
Options:
- Makes sense, let us keep going
- How do I know when to use a skill vs. just asking?
- What can you NOT do?
- I have other questions

Address their question, then continue.

---

## Step 7: How to Give Claude Feedback

"One more important thing: **you can teach me**. If I do something wrong, or you want me to do something differently, just tell me. I will add it to your instruction manual so I never make the same mistake twice."

Give examples:
- "If I send an email that sounds too formal, say 'write more casually' and I will add that as a preference."
- "If I keep putting tasks in the wrong place, say 'always put [Client] tasks in [location]' and I will update the routing rules."
- "If you discover a new workflow you like, say 'turn this into a skill' and I will build one."

"The system is not static. It gets better every week because you refine it as you use it."

AskUserQuestion: "Ready to move on to connecting your tools?"
Options:
- Yes, let us connect my tools
- I have more questions about the system
- I want to take a break and come back later

If ready: "Type `/connect` and I will walk you through connecting each of your tools one by one."

If break: "No problem. When you come back, open Claude Code in this folder and type `/connect`. I will pick up right where we left off."
