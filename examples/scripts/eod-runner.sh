#!/bin/bash
# EOD Runner -- Runs EOD phases sequentially in separate Claude contexts
# Each phase gets a fresh context window. The manifest file on disk is the handoff.
#
# Usage:
#   ./scripts/eod-runner.sh              # Run all phases
#   ./scripts/eod-runner.sh --phase 2    # Run a single phase (1-4)
#   ./scripts/eod-runner.sh --dry-run    # Show what would run without executing
#
# Logs: Work/Daily/EOD Logs/ (per-phase + summary, searchable in Obsidian)
# Schedule via launchd nightly (see com.brain.eod-runner.plist)

set -euo pipefail

VAULT="/path/to/vault"
# Use pinned version from eod-cron.sh (EOD_CLAUDE env var), fall back to symlink
CLAUDE="${EOD_CLAUDE:-$HOME/.local/bin/claude}"
LOG_DIR="$VAULT/Work/Daily/EOD Logs"
TODAY=$(date +%Y-%m-%d)
SUMMARY_LOG="$LOG_DIR/$TODAY-summary.log"
SINGLE_PHASE=""
DRY_RUN=false
PHASE_RESULTS=""
FAILURES=0

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --phase) SINGLE_PHASE="$2"; shift 2 ;;
        --dry-run) DRY_RUN=true; shift ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

mkdir -p "$LOG_DIR"

# Summary log: timestamps, exit codes, durations
summary() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$SUMMARY_LOG"
}

run_phase() {
    local phase_num="$1"
    local skill="$2"
    local description="$3"
    local max_minutes="${4:-15}"
    local phase_log="$LOG_DIR/$TODAY-phase${phase_num}-${skill}.log"

    summary "Phase $phase_num ($skill): STARTING -- $description"

    if $DRY_RUN; then
        summary "Phase $phase_num ($skill): [DRY RUN] Would run: $CLAUDE -p \"/$skill\" --dangerously-skip-permissions"
        summary "Phase $phase_num ($skill): Log would be: $phase_log"
        return 0
    fi

    local start_time=$(date +%s)

    # Run claude in print mode with fresh context
    # --dangerously-skip-permissions: no human to approve tools at 11:30 PM
    # Timeout via perl alarm (macOS has no GNU timeout)
    local timeout_secs=$((max_minutes * 60))
    local exit_code=0

    cd "$VAULT"
    perl -e 'alarm shift; exec @ARGV' "$timeout_secs" \
        "$CLAUDE" -p "/$skill" --dangerously-skip-permissions \
        > "$phase_log" 2>&1 || exit_code=$?
    # perl alarm sends SIGALRM -> exit 142 (128+14)
    if [ $exit_code -eq 142 ]; then exit_code=124; fi

    local end_time=$(date +%s)
    local duration=$(( (end_time - start_time) / 60 ))
    local duration_secs=$(( (end_time - start_time) % 60 ))

    if [ $exit_code -eq 0 ]; then
        summary "Phase $phase_num ($skill): COMPLETED in ${duration}m${duration_secs}s -- log: $phase_log"
        PHASE_RESULTS="${PHASE_RESULTS}P${phase_num}:ok "
    elif [ $exit_code -eq 124 ]; then
        summary "Phase $phase_num ($skill): TIMEOUT after ${max_minutes}m -- log: $phase_log"
        PHASE_RESULTS="${PHASE_RESULTS}P${phase_num}:TIMEOUT "
        FAILURES=$((FAILURES + 1))
    else
        summary "Phase $phase_num ($skill): FAILED (exit $exit_code) in ${duration}m${duration_secs}s -- log: $phase_log"
        PHASE_RESULTS="${PHASE_RESULTS}P${phase_num}:FAIL($exit_code) "
        FAILURES=$((FAILURES + 1))
    fi

    # Don't exit on failure -- later phases can still run with partial data
    return 0
}

summary "========================================="
summary "EOD Runner starting for $TODAY"
summary "========================================="

# Check claude CLI exists
if [ ! -x "$CLAUDE" ]; then
    summary "FATAL: Claude CLI not found at $CLAUDE"
    exit 1
fi

RUN_START=$(date +%s)

# Phase definitions: number, skill name, description, timeout in minutes
# Customize these to match your slash command names
PHASES=(
    "1|eod-gather|Fathom + Email + Slack + Calendar|25"
    "2|eod-sync|Verify + Sync + Task Manager + Hygiene|15"
    "3|eod-rize|Time tracking review|15"
    "4|eod-note|Daily note + summary|5"
)

for phase_def in "${PHASES[@]}"; do
    IFS='|' read -r num skill desc timeout <<< "$phase_def"

    # If single phase requested, skip others
    if [ -n "$SINGLE_PHASE" ] && [ "$SINGLE_PHASE" != "$num" ]; then
        continue
    fi

    run_phase "$num" "$skill" "$desc" "$timeout"
done

RUN_END=$(date +%s)
TOTAL_MIN=$(( (RUN_END - RUN_START) / 60 ))
TOTAL_SEC=$(( (RUN_END - RUN_START) % 60 ))

summary "========================================="
summary "EOD Runner complete for $TODAY -- total: ${TOTAL_MIN}m${TOTAL_SEC}s"
summary "Results: $PHASE_RESULTS"
summary "========================================="

# Notify: macOS notification + optional Slack DM on failure
if ! $DRY_RUN; then
    if [ "$FAILURES" -gt 0 ]; then
        NOTIFY_TITLE="EOD Failed ($FAILURES phase(s))"
        NOTIFY_MSG="$PHASE_RESULTS| ${TOTAL_MIN}m${TOTAL_SEC}s"
        NOTIFY_SOUND="Basso"
    else
        NOTIFY_TITLE="EOD Complete"
        NOTIFY_MSG="$PHASE_RESULTS| ${TOTAL_MIN}m${TOTAL_SEC}s"
        NOTIFY_SOUND="Submarine"
    fi

    # macOS notification (works from launchd user agents)
    osascript -e "display notification \"$NOTIFY_MSG\" with title \"$NOTIFY_TITLE\" sound name \"$NOTIFY_SOUND\"" 2>/dev/null || true

    # Optional: Slack DM on failure
    # Uncomment and configure with your workspace token and user ID
    # if [ "$FAILURES" -gt 0 ] && [ -f "$VAULT/.env" ]; then
    #     SLACK_TOKEN=$(grep '^SLACK_TOKEN_WORKSPACE_A=' "$VAULT/.env" | cut -d'=' -f2- | tr -d '"' | tr -d "'")
    #     OWNER_SLACK_ID=$(grep '^SLACK_USER_ID_OWNER=' "$VAULT/.env" | cut -d'=' -f2- | tr -d '"' | tr -d "'")
    #     if [ -n "$SLACK_TOKEN" ] && [ -n "$OWNER_SLACK_ID" ]; then
    #         curl -s -X POST "https://slack.com/api/chat.postMessage" \
    #             -H "Authorization: Bearer $SLACK_TOKEN" \
    #             -H "Content-Type: application/json" \
    #             -d "{\"channel\":\"$OWNER_SLACK_ID\",\"text\":\"EOD automation failed ($FAILURES phase(s)):\n$PHASE_RESULTS\nTotal: ${TOTAL_MIN}m${TOTAL_SEC}s\nCheck logs: Work/Daily/EOD Logs/$TODAY-summary.log\"}" \
    #             > /dev/null 2>&1 || true
    #     fi
    # fi
fi

# Cleanup old logs (keep 30 days)
find "$LOG_DIR" -name "*.log" -mtime +30 -delete 2>/dev/null || true
