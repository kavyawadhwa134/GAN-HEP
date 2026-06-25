#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -eq 0 ]; then
  cat >&2 <<'EOF'
Usage:
  bash scripts/codex-binder.sh "your Codex task"

Optional:
  CODEX_SANDBOX=read-only bash scripts/codex-binder.sh "explain the repo"
  CODEX_SANDBOX=workspace-write bash scripts/codex-binder.sh "edit the notebook helper"
EOF
  exit 2
fi

if ! command -v codex >/dev/null 2>&1; then
  echo "codex was not found on PATH. Check the Binder build log for binder/postBuild." >&2
  exit 1
fi

if [ -n "${CODEX_API_KEY:-}" ]; then
  key="${CODEX_API_KEY}"
else
  printf "OpenAI API key (input hidden, not saved): "
  IFS= read -r -s key
  printf "\n"
fi

if [ -z "${key}" ]; then
  echo "No API key provided; aborting." >&2
  exit 1
fi

sandbox="${CODEX_SANDBOX:-workspace-write}"

CODEX_API_KEY="${key}" codex exec \
  --ephemeral \
  --skip-git-repo-check \
  --ask-for-approval never \
  --sandbox "${sandbox}" \
  "$*"

unset key
