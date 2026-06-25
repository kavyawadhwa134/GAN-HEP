# Repository Instructions

- This repository is intended to run on the `gpu` branch in SSL-HEP BinderHub.
- Keep Binder and GPU environment changes small. Avoid changing CUDA, RAPIDS, PyTorch, or Python pins unless the task explicitly needs it.
- Binder configuration lives in `binder/`. Standard repo2docker action files are named `postBuild` and `start` with no `.txt` suffix.
- Do not commit API keys, access tokens, `auth.json`, `.codex/`, `.env`, or notebook output containing credentials.
- For GPU checks in Binder, start with `nvidia-smi`. If CUDA compilation is relevant, run `bash tests/run_tests.sh` from `tests/`.
- For notebook work, preserve existing outputs unless asked to clear or regenerate them.
