#!/usr/bin/env bash
set -euo pipefail

if ! command -v codex >/dev/null 2>&1; then
  echo "codex was not found on PATH. Check the Binder build log for binder/postBuild." >&2
  exit 1
fi

printf "OpenAI API key (input hidden, saved only in this Binder session): "
IFS= read -r -s key
printf "\n"

if [ -z "${key}" ]; then
  echo "No API key provided; aborting." >&2
  exit 1
fi

printf "%s" "${key}" | codex login --with-api-key
unset key

codex login status
