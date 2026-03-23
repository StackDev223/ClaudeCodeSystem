# Brain Dump

Manual brain dump command. The user dictates everything on their mind and the assistant parses, classifies, and routes each item to the correct location in the vault.

**Critical rule: Atomic writes.** The vault lives on iCloud. Background sync WILL modify files between reads and writes.
- **ALWAYS use Python atomic writes** (read -> modify -> write in a single `python3` script via Bash) when editing existing files.
- The Write tool is acceptable for NEW files since there's no read-modify-write race.

**Critical rule: No empty section headers.** Only create `### New from ...` headers if there are items to put under them.

---

## Step 1: Collect Brain Dump

1. Use AskUserQuestion: "Go ahead -- dump everything on your mind. Tasks, notes, ideas, reminders, personal stuff, anything. I'll sort it all out."
2. Wait for the full response. If the user seems to have more, ask: "Anything else, or is that everything?"

---

## Step 2: Parse and Classify

1. Break the response into individual items (one per bullet or distinct thought)
2. Classify each item along two dimensions:
   - **Client**: [Client A], [Client B], etc., Cross-Client, or Personal
   - **Type**: `task` (clear next action), `note` (information/context), `idea` (brainstorm/someday), `personal` (non-work)
3. Use contact names, tool names, and project context to infer client when not explicit
4. Flag any items that cannot be confidently classified

---

## Step 3: Route Items

1. For each classified item, route via atomic write:
   - **Client tasks** -> `Inbox/<Client>.md` under `## Open Tasks` as `- [ ]` items
   - **Client notes** -> `Inbox/<Client>.md` under `## Notes` as plain bullets
   - **Cross-client tasks/notes** -> `Inbox/Incoming.md` under `## Cross-Client Tasks` or `## Notes`
   - **Ideas** -> `Inbox/Incoming.md` under `## Brain Dump` (keep as-is)
   - **Personal items** -> `Inbox/Incoming.md` under `## Brain Dump` with a `(personal)` tag
2. Dedup check: before adding a task, verify it does not already exist in the target file
3. If any items could not be classified, present them to the user and ask where they should go

---

## Step 4: Log to Manifest

1. If an EOD manifest exists at `/tmp/eod-manifest-TODAY.md`, append rows for each routed item with Source = "Brain Dump"
2. If no manifest exists, skip this step (brain dump can run standalone)

---

## Step 5: Summary

1. Print a table of what was routed and where:
   - Item description | Client | Type | Routed To
2. Call out any items left unrouted or flagged for user decision
3. Print totals: tasks created, notes filed, ideas saved, personal items parked
