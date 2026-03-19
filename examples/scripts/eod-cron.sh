#!/bin/bash
# EOD Cron Wrapper - launches the vault's eod-runner.sh from outside iCloud
# Lives at ~/scripts/ to avoid macOS Gatekeeper blocking iCloud-synced scripts.
# Launchd runs this nightly (see com.brain.eod-runner.plist)

BRAIN_DIR="/path/to/vault"
RUNNER="$HOME/scripts/eod-runner.sh"
CLAUDE_DIR="$HOME/.local/share/claude/versions"
PIN_FILE="$HOME/scripts/eod-claude-version"

# Verify runner exists
if [ ! -f "$RUNNER" ]; then
  echo "FATAL: eod-runner.sh not found at $RUNNER" >&2
  exit 1
fi

# Use pinned Claude version (avoids TCC dialogs from auto-updates).
# The pinned version has macOS file access permissions already granted.
# To update: grant FDA/permissions to the new version, then update the pin:
#   echo "2.1.XX" > ~/scripts/eod-claude-version
if [ -f "$PIN_FILE" ]; then
  PINNED_VER=$(cat "$PIN_FILE")
  PINNED_BIN="$CLAUDE_DIR/$PINNED_VER"
  if [ -x "$PINNED_BIN" ]; then
    export EOD_CLAUDE="$PINNED_BIN"
  else
    echo "WARNING: Pinned version $PINNED_VER not found, falling back to symlink" >&2
    export EOD_CLAUDE="$HOME/.local/bin/claude"
  fi
  # Check if a newer version exists and alert
  LATEST_VER=$(ls "$CLAUDE_DIR" 2>/dev/null | sort -V | tail -1)
  if [ -n "$LATEST_VER" ] && [ "$LATEST_VER" != "$PINNED_VER" ]; then
    echo "NOTE: Claude $LATEST_VER available but EOD pinned to $PINNED_VER" >&2
    # Send macOS notification about available update
    osascript -e "display notification \"Claude $LATEST_VER available. EOD pinned to $PINNED_VER. Update pin after granting permissions.\" with title \"EOD: Claude Update Available\"" 2>/dev/null || true
  fi
else
  export EOD_CLAUDE="$HOME/.local/bin/claude"
fi

# Strip provenance from pinned binary (Gatekeeper, separate from TCC)
xattr -d com.apple.provenance "$EOD_CLAUDE" 2>/dev/null || true

# Lockfile to prevent overlapping runs
LOCKFILE="/tmp/eod-runner.lock"
if [ -f "$LOCKFILE" ]; then
  LOCK_PID=$(cat "$LOCKFILE" 2>/dev/null)
  if kill -0 "$LOCK_PID" 2>/dev/null; then
    echo "SKIPPED: Previous run still active (PID $LOCK_PID)" >&2
    exit 0
  fi
  # Stale lockfile, remove it
  rm -f "$LOCKFILE"
fi
echo $$ > "$LOCKFILE"
trap 'rm -f "$LOCKFILE"' EXIT

cd "$BRAIN_DIR" || { echo "Failed to cd to vault dir" >&2; exit 1; }

# Run the local copy (outside iCloud, no com.apple.provenance xattr issues)
source "$RUNNER"
