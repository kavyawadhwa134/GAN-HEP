#!/usr/bin/env bash
set -euo pipefail

if ! command -v claude >/dev/null 2>&1; then
  echo "claude was not found on PATH. Check the Binder build log for binder/postBuild." >&2
  exit 1
fi

cat <<'EOF'
Starting Claude Code login for Binder.

Use the fresh login URL printed by Claude. If your browser cannot redirect back
to Binder and instead shows a login code, paste that code back into this terminal.

For Anthropic Console billing instead of a Claude subscription, run:
  bash scripts/claude-login.sh --console
EOF

claude auth login "$@"
claude auth status --text
