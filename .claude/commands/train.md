# Train: Learn How Your System Works (Cloud Edition)

This is Part 2 of 4 in the setup process. The user just ran `/onboard`, which personalized their vault. They are now in a fresh session on their repository.

**Prerequisites:** `/onboard` completed. CLAUDE.md personalized. Vault folder structure exists.

**Voice:** Friendly, patient teacher. Explain everything in plain language. Use everyday analogies. Never assume they know what a repository, commit, or markdown file is.

**Important:** Use `AskUserQuestion` for EVERY check-in. Do not lecture — show, then ask if it makes sense. Keep each explanation to 3-4 sentences max before checking in.

---

## Step 1: Verify Setup

Before starting, confirm everything from `/onboard` is in place:
- Read CLAUDE.md and confirm it has the user's name and details
- Check that Inbox/, Work/, and other folders exist
- Check that `.claude/commands/` has their skills
- Run `git log --oneline -5` and confirm the "Onboard:" commits are there

If anything is missing, tell the user and offer to fix it or re-run `/onboard`.

If everything looks good: "Everything from the onboard step is here. Let me show you how it all works."

---

## Step 2: Where Your Vault Lives

"Your vault is a collection of plain text files — your tasks, your notes, your plans. It lives in a **private GitHub repository** that only you (and the people you invite) can access. Think of it as a filing cabinet in a vault with your name on the door."

"When we work together, I get a fresh copy of it, do the work, and **save everything back with a commit** — a save point with a description. You will see me say things like 'Saved' at the end of routines. Every save is permanent history: nothing I do can be truly lost, and anything can be undone."

Show them, live:

```bash
git log --oneline -5
```

"See those lines? That is your vault's history so far — each line is one save, newest first. This history is yours forever."

AskUserQuestion: "Does that make sense — your notes live in a private repository, and every change is a save point?"
Options:
- Makes sense, keep going
- What happens if something goes wrong mid-save?
- Who can see my data?
- What is GitHub exactly?

If "who can see my data": "The repository is private — only your GitHub account has access. When I work on it, the work happens in an isolated, temporary workspace tied to your Claude account. You can also invite a person you trust (like whoever set this system up for you) to help maintain it."

If "what if something goes wrong": "Unsaved work in a closed session can be lost — which is why every routine ends by saving. If a save ever fails, I will tell you loudly rather than pretend it worked."

---

## Step 2B: The Folder Tour

Walk through the key folders (list them from the actual repo):

- **Inbox/** — "Your command center. Today's plan and per-client task lists live here. Think of it as your desk where active work sits."
- **Work/** — "Professional projects. Each client gets their own subfolder with call transcripts, archives, and notes."
- **[CompanyName]/** — "Your company's private docs. Hiring, SOPs, internal strategy."
- **Resources/** — "Reference material. Contacts, concepts, learning notes. Stuff you look up, not stuff you do."
- **Graph/** — "The map. An index and registry that connects everything (more on this in a minute)."
- **Archive/** — "Where completed work goes each week so active files stay clean."
- **System/** — "My machinery — state files and memory. You will rarely open this one."

AskUserQuestion: "Does the folder structure make sense?"
Options:
- Makes sense, keep going
- Why is [folder] separate from [folder]?
- I want to rename or reorganize something
- What about personal stuff?

---

## Step 3: Your Reading Surface

Check `READING_SURFACE` from the onboard interview (it is reflected in CLAUDE.md's Morning Routine section). Teach the one they chose:

**If "In a Claude session" (default):**
"Every morning, open Claude Code — on your computer or the Claude app on your phone — start a session on your vault, and type `/morning`. I will have your plan ready and walk you through it in about 3 minutes. Your phone is enough: the whole review works with taps."

**If "Obsidian on my computer":**
"Obsidian is a free app that turns your vault into a beautiful notes app. Because your vault lives on GitHub, we connect them with a small plugin that syncs automatically."
1. "Download Obsidian from **obsidian.md** and install it."
2. "You will also need your vault on your computer: install **GitHub Desktop** (desktop.github.com), sign in, and clone your repository to your Documents folder."
3. "Open Obsidian → **Open folder as vault** → pick the cloned folder."
4. "In Obsidian, enable **Community plugins** and install **Git** (the obsidian-git plugin). Set it to pull automatically every few minutes and push after you edit."
5. "Now: what I do in the cloud shows up in Obsidian, and notes you jot in Obsidian show up for me. Two-way sync, powered by the same save-point system."

AskUserQuestion at each numbered step to confirm before moving on.

**If "On GitHub":**
"Install the GitHub app on your phone or bookmark your repository. Your plan is at `Inbox/Today.md` — GitHub renders it nicely. Reading is easy there; for changes, talk to me."

---

## Step 4: Your Instruction Manual (CLAUDE.md)

"Now the most important file in the system."

Open CLAUDE.md and highlight the key parts (do NOT read the whole thing out loud):

### The Runtime & Persistence Protocol
"The rules I follow every session: save everything with commits, compute dates in your timezone, keep secrets out of your files. You never have to think about this — but it is why the system is trustworthy."

### The Startup Checklist
"Every time we start a conversation, I read this file first — the date check, your pending items, whether a monthly review is due."

### Your Schedule and Preferences
"Your daily schedule, meeting preferences, and work style. See how it says [their actual schedule]? And your clients are listed as [actual client names]? That came from our onboarding conversation."

### Available Integrations
"Every tool I can connect to. Right now some are placeholders — we connect them for real in the next step (`/connect`)."

AskUserQuestion: "Any questions about CLAUDE.md? This file is yours to change anytime. If I ever do something wrong, you can add a rule here and I will follow it."
Options:
- Got it, makes sense
- Can I change [specific thing]?
- What if I want to add something later?
- Show me how to edit it

If they want to see editing: make a small change together (like adjusting lunch time), commit it, and point out the save: "That preference is now permanent — every future session follows it."

---

## Step 5: How Skills Work

"A skill is a successful task turned into a repeatable routine. Every skill is just a text file in a specific folder. You type a short name and I run the whole thing."

Show them what is in their `.claude/commands/` folder — list each skill with a one-sentence description.

"These are just text files. You can read them, change them, and create new ones. When we do something together that works well, I will offer to save it as a skill. Because skills live in your repository, a skill created once is available in every future session — web, phone, or desktop."

AskUserQuestion: "Want to look inside one of these to see how they work?"
Options:
- Yes, show me what is inside /morning
- No, I trust it, keep going
- How do I create a new one?

---

## Step 6: The Knowledge Graph

"Your vault is not just folders. Files link to each other with wiki-links, and there is an index that maps everything."

- **Graph/index.md** — "Master directory of every important file."
- **Graph/entity-registry.md** — "The lookup table: names and terms mapped to their pages. When the graph syncs, it auto-links mentions of your clients, contacts, and concepts."

"Maintenance is automatic: your nightly routine updates links and metadata for anything that changed that day. `/graph-sync` does a full rebuild when needed."

AskUserQuestion: "Make sense?"
Options:
- Got it
- What are wiki-links?
- How do I add to the entity registry?
- Show me an example

---

## Step 6B: Integral Strategy Skills

"You also have a set of strategy skills from Integral — thinking frameworks you can use anytime:"

- **`/strategy`** — "Structured decision-making: evaluate what you have, assess reversibility, plan in stages, reach a clear recommendation."
- **`/optimize`** — "Audit your tools, processes, or time; find consolidation opportunities."
- **`/build-skill`** — "Turn a successful task into a repeatable workflow."
- **`/learn`** — "Capture important knowledge so it connects to your existing work and resurfaces when relevant."

AskUserQuestion: "Any questions about the strategy skills?"
Options:
- Got it, keep going
- Show me what /strategy looks like
- When would I use /optimize vs /strategy?
- Can I modify these?

---

## Step 7: The Daily Loop

"Here is how a typical day works. This is the big picture."

1. **Overnight (automatic):** "While you sleep, a scheduled routine processes your calls, emails, and messages, organizes everything, and builds tomorrow's plan. Your computer plays no part — it runs in the cloud. (We switch this on in `/finish`.)"
2. **Morning (5 minutes):** "Open your plan ([their reading surface]), then type `/morning` in a Claude session. I walk you through the day and lock in your schedule — it works great from your phone."
3. **During the day (as needed):** "Ask me for anything: draft an email, look up a client, prep for a meeting, `/brain-dump` whatever is on your mind. I work from your vault and save as I go."
4. **Evening:** "The cycle repeats on its own. If you prefer to watch it run, type `/eod` before wrapping up — same process."

AskUserQuestion: "Does the daily loop make sense?"
Options:
- Yes, that is clear
- What if the overnight run misses something?
- What happens on weekends?
- What if I skip the morning review?

(If "misses something": "Every overnight run writes an errors section into your daily note when a tool was unreachable, and `/morning` automatically catches up on anything that was missed. Nothing silently disappears.")

---

## Step 8: How to Work with an AI Assistant

### Think of me as a new hire
"I am like a very capable employee who just started. The first few weeks, you will correct me. Each correction becomes a rule in your instruction manual, which raises the floor. The frequency of mistakes drops as the system learns your preferences."

### Tell me what to do, not how to do it
- Instead of: "Open the Gmail API and search for emails from John with is:unread"
- Say: "Check if John sent me anything today"

### Let successful tasks become skills
"When we complete a task that works well, I will ask if you want it saved as a skill. You can also say: 'turn this into a skill.'"

### Correct me with rules, not just fixes
- Instead of: "No, put that in the other folder" (fixes it once)
- Say: "Always put [type of item] in [folder]. Add this to CLAUDE.md." (fixes it permanently — and I commit it, so it sticks)

### Anywhere, anytime
"Because everything lives in the cloud: start a session from your phone in a waiting room, dictate a brain dump from the car (your phone's microphone button works great for this), check your plan from any computer. Nothing depends on your machine being on."

AskUserQuestion: "Does this make sense? Any questions about how to work with me?"
Options:
- Makes sense, let us keep going
- How do I know when to use a skill vs. just asking?
- What can you NOT do?
- I have other questions

---

## Step 9: Ready for Connections

"Next we connect your actual tools — calendar, email, and the rest — so the daily loop runs on real data."

AskUserQuestion: "Ready to move on to connecting your tools?"
Options:
- Yes, let us connect my tools
- I have more questions about the system
- I want to take a break and come back later

If ready: "Type `/connect` and I will walk you through each tool one by one."

If break: "No problem. When you come back, start a session on this repository and type `/connect`. Everything we did today is saved."
