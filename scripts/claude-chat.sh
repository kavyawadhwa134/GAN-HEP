#!/usr/bin/env bash
set -euo pipefail

if ! command -v claude >/dev/null 2>&1; then
  echo "claude was not found on PATH. Check the Binder build log for binder/postBuild." >&2
  exit 1
fi

cat <<'EOF'
Starting Claude Code for this Binder session.

If this is your first run in Binder, authenticate first:
  bash scripts/claude-login.sh

If your browser shows a login code instead of redirecting back, paste that code
back into the login terminal when Claude asks for it.
EOF

exec claude "$@"
