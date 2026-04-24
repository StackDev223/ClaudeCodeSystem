# Handoff

Hand off the current conversation to a fresh Claude Code session (new window, post-clear, or after context compaction). Writes a self-contained briefing to `~/.claude/handoff.md` (global, works from any project or cwd) that a new agent can read cold and continue the work without losing momentum.

Optional argument: a short label for the handoff topic (e.g., `/handoff trussi workflow fix`). If omitted, infer from the conversation.

Topic: $ARGUMENTS

---

## Principles

The handoff file is written **to the next Claude**, not to Stephen. It should read like a briefing for a smart colleague who just walked in: they haven't seen this conversation, don't know what's been tried, don't know why this matters. Be specific. Include file paths with line numbers, exact commands, and the reasoning behind decisions — not just the decisions themselves.

**Never delegate understanding.** Don't write "figure out what needs to happen next." Write what specifically needs to happen next, with enough context that the next agent can make judgment calls.

---

## Step 1: Synthesize Current State

Before writing anything, silently review the conversation and answer these questions for yourself:

1. **What is the goal?** One sentence. What is Stephen actually trying to accomplish? Not the immediate task, the underlying objective.
2. **What have we done so far?** Concrete actions: files edited, commands run, things discovered, decisions made. Include file paths and line numbers where relevant.
3. **What was tried and rejected?** Dead ends the next agent should not re-explore. Include *why* each was rejected.
4. **What is the current state of the work?** Is code half-written? Are there uncommitted changes? Is something running in the background? Are there open questions waiting on Stephen?
5. **What are the next concrete steps?** Not "continue the work" — the actual next 1-3 actions. If blocked, what is it blocked on?
6. **What context does the next agent need to pull?** Specific files to read, memory entries to check, git state to inspect, external systems to query. Give exact paths and commands.
7. **What gotchas or constraints apply?** Decisions Stephen made, approaches he rejected, things that look simple but aren't, things already verified so they don't need re-verifying.

If any of these are unclear, **ask Stephen before writing the handoff**. A vague handoff is worse than no handoff — it wastes the next session's context budget on re-discovery.

## Step 2: Verify Current Environment State

Run these in parallel and include relevant output in the handoff:

- `date` — timestamp the handoff
- `pwd` — capture the current working directory so the next session knows where to operate
- `git status` and `git log --oneline -5` — if relevant files are in a git repo, capture uncommitted state and recent commits
- Check for any running background processes the next agent will inherit (builds, dev servers, long-running tasks)
- If work touches a specific file, note its current length and any in-progress edits

## Step 3: Write the Handoff File

Write to `~/.claude/handoff.md` (absolute path, overwrites any previous handoff). This is a global location so `/pickup` works from any project. Use this structure:

```markdown
# Handoff -- [Topic] -- [YYYY-MM-DD HH:MM ET]

> **For the next Claude reading this:** Stephen just cleared context or opened a new window. You are continuing work mid-stream. Read this entire file before taking any action. Then pull the context listed in "Load This Context" before responding to Stephen. Do not ask Stephen to re-explain what is already documented here.

**Working directory:** `[cwd from pwd]`
**Project context:** [e.g., "Brain vault", "DevProjects/agent-browser", "none"]

## The Goal

[One or two sentences. Why this work matters, what success looks like.]

## Where We Are Right Now

[Concrete state: what's been done, what's in-progress, what's blocked. File paths and line numbers. If code is half-written, say exactly where. If something is running in the background, say so. If waiting on Stephen to decide something, say what.]

## What Has Been Tried (and Rejected)

[Dead ends with reasons. "Tried X, didn't work because Y." "Considered Z, rejected because Stephen wants W." Skip this section if nothing was rejected.]

## Decisions Made This Session

[Non-obvious choices Stephen approved. Things the next agent should NOT re-litigate. Include the why.]

## Next Steps

1. [First concrete action]
2. [Second concrete action]
3. [Third concrete action, or "then check in with Stephen before proceeding"]

## Load This Context Before Responding

Run these reads/commands in parallel at the start of your response, before saying anything to Stephen:

- Read: `[path]` -- [why: what you'll learn from it]
- Read: `[path]:[lineStart]-[lineEnd]` -- [why]
- Bash: `git status` in `[dir]` -- [why]
- Bash: `[any other command]` -- [why]
- Check memory: `[memory filename]` -- [why]

[Only list context actually needed. Don't pad. The next agent has a fresh context budget — spend it on what matters.]

## Gotchas and Constraints

- [Things that look simple but aren't]
- [Things already verified so you don't need to re-verify]
- [Stephen's preferences specific to this work]
- [External state that might change (someone else editing a file, a cron about to fire, etc.)]

## Open Questions for Stephen

[If there are questions waiting on Stephen that blocked progress, list them here so the next session can raise them immediately. If none, omit this section.]

---

*Handoff written [timestamp]. Session topic: [topic]. If this file is older than a few hours when you read it, verify it's still current before acting on it -- state may have changed.*
```

## Step 4: Confirm With Stephen

After writing the file, show Stephen a compact summary:

```
Handoff written to ~/.claude/handoff.md

  Goal: [one line]
  Next steps: [1-line summary of first next action]
  Context to pull: [count] files, [count] commands

To resume in a new window, run: /pickup
```

Do not dump the full file content into the chat. Stephen can read it if he wants to verify. The point is the file exists and is ready for the next session.

---

## Notes on Using This

- **When to run**: Before `/clear`, before closing a window mid-task, or when context is getting long and you want a checkpoint before compaction.
- **Global, not project-specific**: `~/.claude/handoff.md` is a single global file, so handoffs work across any project. There is only ever one active handoff at a time. Running `/handoff` in a new project overwrites the previous one.
- **Ephemeral**: The file gets overwritten every run. If Stephen needs to preserve a handoff long-term, he'll rename or copy it himself.
- **Not a replacement for EOD**: This is for mid-stream work handoffs, not end-of-day wrap-ups. EOD still routes items to client inboxes and updates ClickUp.
- **Not a replacement for tasks**: Ongoing project state belongs in ClickUp or client inbox files. Handoff is for the immediate thread of work the current session is in the middle of.
