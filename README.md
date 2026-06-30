# GAN-HEP
# Research on GAN's for HEP
REQUIRE
environment.yml
julia.ipynb
python-and-julia.ipynb
python.ipynb

## SSL-HEP Binder + Codex

Launch the `gpu-new` branch on SSL-HEP BinderHub:

```text
https://binderhub.ssl-hep.org/v2/gh/kavyawadhwa134/GAN-HEP/gpu-new?urlpath=lab
```

The Binder build installs the Codex CLI during `binder/postBuild` and makes it available in JupyterLab terminals through `binder/start`.

For the interactive Codex chat and coding UI, open a JupyterLab terminal and authenticate:

```bash
codex login --device-auth
```

If your selected ChatGPT workspace says device-code authentication is disabled, either choose your personal account or use API-key login:

```bash
bash scripts/codex-login-api-key.sh
```

If you do not have an API key, you can copy your local Codex login into the temporary Binder session. On your Mac, run:

```bash
python3 - <<'PY' | pbcopy
import base64
from pathlib import Path

print(base64.b64encode(Path.home().joinpath(".codex", "auth.json").read_bytes()).decode())
PY
```

Then in the Binder terminal, run:

```bash
bash scripts/codex-import-auth-json.sh
```

Paste when prompted. This is a sensitive login token; paste it only into your private Binder terminal, never into chat, notebooks, logs, or committed files.

Then start Codex chat:

```bash
bash scripts/codex-chat.sh
```

Inside the chat, ask Codex to inspect files, edit code, write tests, or explain errors. It starts with `workspace-write` sandboxing so it can modify files in the Binder session.

For one-shot Codex commands without opening the chat UI:

```bash
bash scripts/codex-binder.sh "summarize this repository and suggest the next coding step"
```

For read-only analysis:

```bash
CODEX_SANDBOX=read-only bash scripts/codex-binder.sh "explain GAN IMAGE.ipynb"
```

For code edits inside the Binder session:

```bash
CODEX_SANDBOX=workspace-write bash scripts/codex-binder.sh "make the smallest safe improvement to the training script"
```

The helper prompts for `CODEX_API_KEY` with hidden input and passes it only to that one `codex exec` invocation. Do not commit API keys, `auth.json`, `.codex/`, or `.env` files.

## SSL-HEP Binder + Claude Code

The Binder build also installs Claude Code during `binder/postBuild`.

Open a JupyterLab terminal and check the install:

```bash
claude --version
```

Start Claude Code:

```bash
bash scripts/claude-chat.sh
```

On first run, Claude Code prints or opens a browser login URL. Sign in with a Claude account that includes Claude Code access. If your browser shows a login code instead of redirecting back to Binder, paste that code into the terminal prompt.

If browser login is not available in Binder, generate a one-year OAuth token on a machine where Claude Code can log in:

```bash
claude setup-token
```

Then in Binder, run:

```bash
bash scripts/claude-token-chat.sh
```

Paste the token when prompted. This token is sensitive; paste it only into your private Binder terminal, never into chat, notebooks, logs, or committed files. Do not commit `.claude/`, API keys, OAuth tokens, or `.env` files.
