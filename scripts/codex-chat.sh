#!/usr/bin/env bash
set -euo pipefail

if ! command -v codex >/dev/null 2>&1; then
  echo "codex was not found on PATH. Check the Binder build log for binder/postBuild." >&2
  exit 1
fi

cat <<'EOF'
Starting Codex chat for this Binder session.

First-time login in Binder:
  codex login --device-auth

Then run this helper again.
EOF

sandbox="${CODEX_SANDBOX:-workspace-write}"
approvals="${CODEX_APPROVALS:-on-request}"

exec codex \
  --sandbox "${sandbox}" \
  --ask-for-approval "${approvals}" \
  "$@"
