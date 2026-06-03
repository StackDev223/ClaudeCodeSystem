# Resume

Resume a handed-off conversation. Reads `~/.claude/handoff.md` (global, works from any project or cwd), pulls the context it lists, and reports back where we left off so the user can keep moving without re-explaining anything.

Pair with `/handoff` (which writes the file in the previous session).

> **Note:** This is the legacy single-file resume command. The current system is the named `/handoff` + `/pickup` pair, which stores per-project handoffs in `.claude/handoffs/<name>.md` and supports multiple active handoffs at once. Prefer `/pickup`. This command is kept only for older setups that still write a single global `~/.claude/handoff.md`.

---

## Step 1: Read the Handoff File

Read `~/.claude/handoff.md`.

- **If the file does not exist**: Tell the user `No handoff found at ~/.claude/handoff.md. Nothing to resume -- either run /handoff in a previous session first, or just tell me what you're working on.` Stop.
- **If the file exists**: Continue to Step 2.
- **Note the "Working directory" line** from the handoff header. If it doesn't match the current `pwd`, tell the user and ask whether to `cd` into the handoff's working dir or operate from the current one before loading any context.

## Step 2: Freshness Check

Run `date` and compare to the timestamp in the handoff's `# Handoff -- [Topic] -- [YYYY-MM-DD HH:MM ET]` header.

- **Under 6 hours old**: Fresh. Proceed.
- **6-24 hours old**: Note this to the user in the summary (`Handoff is [N] hours old -- state may have drifted`) but proceed.
- **Over 24 hours old**: Warn the user explicitly before loading context: `Handoff is [N] days old. State has almost certainly drifted since then. Want me to resume from it anyway, or start fresh?` Wait for confirmation.

## Step 3: Load the Context

Parse the `## Load This Context Before Responding` section of the handoff file. For each listed item:

- **Read:** entries -- use the Read tool on the exact path (and line range if given)
- **Bash:** entries -- run via Bash tool
- **Check memory:** entries -- Read the file from the memory directory for the project named in the handoff's "Working directory" line. The path follows the pattern `~/.claude/projects/<escaped-cwd>/memory/[filename]`, where `<escaped-cwd>` is the working directory with slashes and dots replaced by hyphens.
- **Grep/Glob:** entries -- use the appropriate tool

Run all independent reads/commands **in parallel** in a single tool-call block. Do not serialize them.

If any context item fails (file moved, command errors, memory entry missing), note it but continue -- don't abort the resume. A stale pointer is information: it tells you something changed since the handoff was written.

## Step 4: Sanity-Check Against Reality

The handoff is a snapshot. Before trusting it, verify the parts that could have changed:

- If the handoff references uncommitted git state, run `git status` and compare
- If it references a file at a specific line number, confirm the line numbers still match after your Read
- If it says "waiting on the user to decide X", note that the question is still open
- If it says something is "running in the background", check whether it actually still is

If reality diverges from the handoff in a way that affects the next steps, flag it in your summary.

## Step 5: Report Back

Give the user a compact resume summary. Target: under 200 words. Format:

```
Resumed from handoff written [relative time, e.g., "2h ago" or "yesterday 4:30 PM"].

**Goal:** [one line from handoff]

**Where we left off:** [2-3 sentences synthesizing current state -- your own words, not a copy-paste from the file]

**Loaded context:** [N files, M commands] -- [one-line summary of anything surprising you found, or "matches handoff" if nothing changed]

**Next step:** [first concrete action from the handoff's Next Steps list]

[If there are open questions for the user from the handoff, list them here as a short bulleted block. Otherwise omit.]

[If reality diverged from the handoff, flag it here in 1-2 lines. Otherwise omit.]

Ready to continue. Want me to proceed with [next step], or something different?
```

Do not dump the full handoff into the chat. The user wrote it (via the previous session) -- they don't need to re-read it. Your job is to prove you understood it and are ready to pick up the thread.

## Step 6: Wait for Go-Ahead

Stop after the summary. Wait for the user to confirm or redirect before taking any action on the actual work. Resuming is about re-establishing shared context, not auto-executing. The user may want to change direction now that they're back in the chair.

---

## Notes

- **Don't delete `~/.claude/handoff.md`** after reading. Leave it in place -- if the user clears again mid-session, the previous handoff is still there as a fallback until `/handoff` overwrites it.
- **If the handoff references files from a different working directory** (e.g., a DevProject), cd into that directory or use absolute paths for the context loads. The handoff should have captured the working dir; if it didn't, ask the user where to operate.
- **If the user runs `/resume` without ever having run `/handoff`**, the file won't exist. Don't try to synthesize a resume from thin air -- just tell them there's nothing to resume.
