# Graph Daily Sync -- Incremental Knowledge Graph Update (Cloud Edition)

Run this at the end of the day (it is built into `/eod` as the graph phase) to keep the knowledge graph current. Only processes files changed since the last sync, so it stays fast.

**When to use:** Daily via EOD, or manually after a burst of note-taking.

---

## Phase 1: Identify Changed Files (git-native)

File modification times are useless here — every cloud session starts from a fresh clone, which stamps all files with clone time. Change detection uses git instead:

1. Read the last-synced commit hash from `System/state/graph-last-sync` (single line, a commit SHA).
2. Build the changed-file list:
   ```bash
   # Committed changes since the last sync:
   git diff --name-only --diff-filter=ACM $(cat System/state/graph-last-sync)..HEAD -- '*.md'
   # Plus anything changed in this session but not yet committed:
   git status --porcelain -- '*.md' | awk '{print $2}'
   ```
   Deduplicate the combined list.
3. **First run / missing or invalid marker:** if `System/state/graph-last-sync` does not exist or the hash is unknown to git (history may have been rewritten), do NOT sweep the whole vault — tell the user to run `/graph-sync` for the full rebuild, then initialize the marker (Phase 6) and exit.
4. Filter out: `.claude/`, `.obsidian/`, `Graph/`, `System/`, `.handoffs/`, `Templates/`, `Archive/` files (outputs and machinery, not inputs).
5. If no files changed, report "No changes since last sync", update nothing, and exit.

---

## Phase 2: Frontmatter on Changed Files

For each changed file:
1. Check if frontmatter exists and is complete (type, tags)
2. If missing or incomplete, add using the same classification rules as `/graph-sync`
3. Read CLAUDE.md for client/company context

Report: `Frontmatter: N files checked, N updated`

---

## Phase 3: Wiki-Links on Changed Files

For each changed file:
1. Read the entity registry (`Graph/entity-registry.md`)
2. Scan for unlinked entity mentions
3. Add `[[wiki-links]]` on first mentions
4. Add or update a `## Related` section if new connections were found
5. Do not re-link entities already linked elsewhere in the file

Report: `Wiki-links: N links added across N files`

---

## Phase 4: Knowledge Extraction from Transcripts

Check if any changed files are transcripts (in `**/Transcripts/` or `type: transcript` frontmatter).

For each new transcript:
1. Extract 2-5 key takeaways: decisions made, action items assigned, important facts learned
2. Add a `key_takeaways` list to the transcript's frontmatter
3. Push each takeaway to the relevant entity page (usually a client Company Profile): `## Recent Activity` or `## Recent Decisions` section, source backlink, newest entries at top

If no transcripts changed, skip this phase.

Report: `Transcripts: N processed, N takeaways extracted`

---

## Phase 5: Index and MOC Updates

1. Identify **new files** in the changed list (`--diff-filter=A` entries plus untracked files)
2. For each new file that qualifies for the index (not a transcript, daily note, or archive):
   - Add an entry to `Graph/index.md` in the correct alphabetical position
   - Add to the relevant MOC file(s) based on type
3. If new entity pages were created, add them to `Graph/entity-registry.md`

Report: `Index: N new entries added`

---

## Phase 6: Record the Sync Point and Save

1. Write a brief sync report to `System/state/eod-graph-$TODAY.md` so the daily note can reference it:
   ```
   Graph sync: N files processed, N links added, N takeaways extracted, N index entries added
   ```
2. Commit everything, THEN record the new sync point as the resulting commit, so the marker always points at a commit that includes this sync's own changes:
   ```bash
   git add -A && git commit -m "Graph sync $TODAY: N files, N links" 
   git rev-parse HEAD > System/state/graph-last-sync
   git add System/state/graph-last-sync && git commit --amend --no-edit
   git push
   ```
   (When running inside `/eod`, fold this into the final EOD commit: stage everything, commit, write `git rev-parse HEAD` into the marker, amend, push once.)
