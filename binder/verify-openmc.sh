#!/usr/bin/env bash
set -euo pipefail

nvidia-smi
printf 'OpenMC executable: %s\n' "$(command -v openmc)"
openmc --version

python - <<'PY'
import os
import openmc

print("OpenMC Python API:", openmc.__version__)
print("Cross sections:    ", os.environ["OPENMC_CROSS_SECTIONS"])
print("Depletion chain:   ", os.environ["OPENMC_DEPLETE_CHAIN"])
PY

python binder/validate-openmc-data.py

smoke_dir="$(mktemp -d)"
cleanup() {
  rm -rf "${smoke_dir}"
}
trap cleanup EXIT

cp binder/openmc-smoke.py "${smoke_dir}/"
cd "${smoke_dir}"

# A missing/incompatible target image must fail rather than silently running on
# the CPU, so this is also proof that the event loop reached the NVIDIA device.
OMP_TARGET_OFFLOAD=MANDATORY python openmc-smoke.py
printf 'OpenMC GPU smoke test passed.\n'
