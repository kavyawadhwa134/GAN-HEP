#!/usr/bin/env bash
set -euo pipefail

failed=0

check_command() {
  local command_name="$1"
  if command -v "${command_name}" >/dev/null 2>&1; then
    printf '%-12s %s\n' "${command_name}" "$(command -v "${command_name}")"
  else
    printf '%-12s %s\n' "${command_name}" "MISSING"
    failed=1
  fi
}

echo "Required build commands"
for command_name in git cmake make gcc g++ gfortran mpicc mpicxx mpifort nvcc; do
  check_command "${command_name}"
done

echo
echo "GPU visibility"
if command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader
else
  echo "nvidia-smi is missing. Launch this branch with an SSL GPU profile."
  failed=1
fi

if [[ "${failed}" -ne 0 ]]; then
  echo
  echo "Runtime validation failed; CARDINAL/NekRS compilation has not started."
  exit 1
fi

echo
echo "Runtime is ready for a CUDA-enabled CARDINAL/NekRS build."
