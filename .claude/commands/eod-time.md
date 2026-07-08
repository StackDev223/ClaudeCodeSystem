# EOD Phase 3: Time Tracking (Cloud Edition)

Fetches today's time tracking sessions, detects untracked gaps, classifies each session by client and work type, and prints a summary. This example uses Rize, but the pattern adapts to any time tracker with an API.

**This phase only runs if time tracking is configured** (check CLAUDE.md). It reads the manifest from Phase 1 and the calendar cache from `System/state/`.

**Critical rule: UTC conversion.** Time trackers store timestamps in UTC — and so does this container's clock. All date-range queries convert the user's local start/end of day to UTC, and all reported times convert back to [Your Timezone].

**Critical rule: Gap threshold.** Only flag untracked periods longer than 15 minutes. Shorter gaps are normal context-switch noise.

**Critical rule: Classification confidence.** Every session classification carries a confidence tag (high, medium, low). Low-confidence items are flagged for review before relabeling.

**Unattended mode:** skip the review pause (Step 5); apply only high-confidence relabels in Step 6 and log the rest as "needs review" for the daily note.

---

## Step 1: Setup

1. Get today's date **in the user's timezone**: `TZ="[IANA-Timezone]" date "+%Y-%m-%d %A %H:%M"`; set `TODAY`
2. Verify the credential is present: `printenv RIZE_API_KEY`. If missing, abort with: "RIZE_API_KEY is not set — add it in the Claude Code environment configuration (claude.ai/code → environment → Environment variables), then start a fresh session."
3. Compute UTC boundaries for the user's local day:
   ```bash
   START_UTC=$(TZ=UTC date -d "$(TZ="[IANA-Timezone]" date -d "$TODAY 00:00:00" -Iseconds)" +%Y-%m-%dT%H:%M:%SZ)
   END_UTC=$(TZ=UTC date -d "$(TZ="[IANA-Timezone]" date -d "$TODAY 23:59:59" -Iseconds)" +%Y-%m-%dT%H:%M:%SZ)
   ```

---

## Step 2: Fetch Sessions

1. Query the Rize GraphQL API for today's sessions:
   ```bash
   curl -s -X POST https://api.rize.io/api/v1/graphql \
     -H "Authorization: Bearer $RIZE_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"query":"{ sessions(startTime: \"'$START_UTC'\", endTime: \"'$END_UTC'\") { id title startTime endTime duration apps { name } } }"}'
   ```
   (A network error usually means `api.rize.io` is missing from the environment's network allowlist.)
2. Parse the response into a local sessions list
3. Write raw session data to `System/state/eod-rize-sessions-$TODAY.json`
4. Print count of sessions fetched and total tracked hours

---

## Step 3: Gap Detection

1. Read today's calendar events from `System/state/eod-calendar-$TODAY.md` (written by Phase 1)
2. Sort all sessions by startTime
3. Walk the timeline, identifying periods with no coverage
4. For each gap longer than 15 minutes during work hours ([their work hours] local):
   - Covered by a calendar event → log as "meeting (no screen)" with the event title
   - Not covered → log as "untracked" for review
5. Write the gap report to `System/state/eod-rize-gaps-$TODAY.md`
6. Print gap summary: count of gaps, total untracked minutes

---

## Step 4: Classification

Classify each session on two axes (use `scripts/rize-classify.py` if it exists — it reads `RIZE_API_KEY` from the environment; otherwise classify inline):

- **Client axis**: [Client A], [Client B], ..., or Internal — from app name patterns, calendar cross-reference, and transcript keyword matching
- **Work type axis**: `delivery`, `sales`, `audit`, `meeting`, `admin`, `internal`

Each classification includes a confidence level (high, medium, low). Write results to `System/state/eod-rize-classified-$TODAY.json`.

---

## Step 5: Review (interactive sessions only)

1. Present classifications as a table (session, start, end, hours, client, work type, confidence), converting times to [Your Timezone]
2. Flag low-confidence rows; list untracked gaps beneath for manual classification
3. Pause for user confirmation or corrections
4. **Unattended mode:** skip this step entirely; auto-approve high-confidence rows only

---

## Step 6: Relabeling

1. For each confirmed classification, update the session label via the Rize GraphQL mutation (`updateSession(id, title: "[Client] - WorkType")`)
2. Log each mutation result; skip unconfirmed sessions
3. Write relabel results to `System/state/eod-rize-relabeled-$TODAY.json`

---

## Step 7: Summary

1. **Hours per client** and **hours per work type** tables
2. **Totals**: tracked hours, untracked gap hours, sessions relabeled N of M
3. Write the summary to `System/state/eod-time-$TODAY.md` for handoff to Phase 4
4. **Save** (when running as a standalone session): `git add -A && git commit -m "EOD $TODAY phase 3: time tracking" && git push`
