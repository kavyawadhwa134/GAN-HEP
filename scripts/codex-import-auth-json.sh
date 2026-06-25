#!/usr/bin/env bash
set -euo pipefail

if ! command -v codex >/dev/null 2>&1; then
  echo "codex was not found on PATH. Check the Binder build log for binder/postBuild." >&2
  exit 1
fi

cat <<'EOF'
Paste the base64-encoded contents of your local ~/.codex/auth.json.
This is a sensitive login token. Paste it only into your private Binder terminal,
never into chat, notebooks, logs, or committed files.
EOF

printf "auth.json base64 (input hidden): "
IFS= read -r -s AUTH_JSON_B64
printf "\n"

if [ -z "${AUTH_JSON_B64}" ]; then
  echo "No auth data provided; aborting." >&2
  exit 1
fi

mkdir -p "${HOME}/.codex"
chmod 700 "${HOME}/.codex"

AUTH_JSON_B64="${AUTH_JSON_B64}" python - <<'PY'
import base64
import os
from pathlib import Path

payload = os.environ["AUTH_JSON_B64"].strip()
auth_path = Path.home() / ".codex" / "auth.json"

try:
    decoded = base64.b64decode(payload, validate=True)
except Exception as exc:
    raise SystemExit(f"Could not decode base64 auth data: {exc}")

auth_path.write_bytes(decoded)
auth_path.chmod(0o600)
PY

unset AUTH_JSON_B64

codex login status
