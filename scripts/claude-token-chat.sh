#!/usr/bin/env bash
set -euo pipefail

if ! command -v claude >/dev/null 2>&1; then
  echo "claude was not found on PATH. Check the Binder build log for binder/postBuild." >&2
  exit 1
fi

cat <<'EOF'
Paste a CLAUDE_CODE_OAUTH_TOKEN generated with `claude setup-token`.
This token is sensitive. Paste it only into your private Binder terminal.
EOF

printf "Claude OAuth token (input hidden): "
IFS= read -r -s token
printf "\n"

if [ -z "${token}" ]; then
  echo "No token provided; aborting." >&2
  exit 1
fi

CLAUDE_CODE_OAUTH_TOKEN="${token}" claude "$@"
unset token
