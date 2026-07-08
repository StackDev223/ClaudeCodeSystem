#!/bin/bash
# SessionStart hook — runs at the start of every Claude Code session on this vault.
# 1. Installs the small Python dependencies vault scripts rely on (cloud only;
#    the container caches installed state, so this is a no-op after the first run).
# 2. Orients the session: today's date in the owner's timezone + vault sync state.
# Never blocks a session: failures degrade to warnings.
set -uo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" = "true" ]; then
  python3 -c "import markdown, requests" 2>/dev/null || \
    pip3 install --quiet markdown requests >/dev/null 2>&1 || \
    echo "NOTE: could not install python packages 'markdown'/'requests' (needed only by scripts/md-to-gdoc.py)."
fi

if [ -n "${TZ:-}" ]; then
  echo "Today is $(date '+%A, %Y-%m-%d %H:%M %Z') in the vault owner's timezone (TZ=$TZ)."
else
  echo "Today is $(date -u '+%A, %Y-%m-%d %H:%M') UTC."
  echo "WARNING: TZ is not set. The container clock is UTC — set a TZ environment variable (e.g. TZ=America/Chicago) in this Claude Code environment's configuration so dates are computed in the owner's timezone. See setup/docs/environment-setup.md. Until then, compute dates with an explicit TZ prefix per CLAUDE.md."
fi

git -C "${CLAUDE_PROJECT_DIR:-.}" status -sb 2>/dev/null | head -1 || true

exit 0
