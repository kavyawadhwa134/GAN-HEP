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
elif [[ "${CARDINAL_REQUIRE_GPU:-1}" == "0" ]]; then
  echo "nvidia-smi is missing; allowed for this CPU-only image build."
else
  echo "nvidia-smi is missing. Launch this branch with an SSL GPU profile."
  failed=1
fi

echo
echo "XDR/libtirpc support"
if [[ -n "${CONDA_PREFIX:-}" && -f "${CONDA_PREFIX}/include/tirpc/rpc/xdr.h" ]]; then
  echo "XDR header   ${CONDA_PREFIX}/include/tirpc/rpc/xdr.h"
else
  echo "XDR header   MISSING (expected under CONDA_PREFIX/include/tirpc)"
  failed=1
fi

echo
echo "CUDA static runtime"
for cuda_library in libcudadevrt.a libcudart_static.a; do
  if [[ -n "${CONDA_PREFIX:-}" && -f "${CONDA_PREFIX}/lib/${cuda_library}" ]]; then
    echo "${cuda_library} ${CONDA_PREFIX}/lib/${cuda_library}"
  else
    echo "${cuda_library} MISSING (install cuda-cudart-static)"
    failed=1
  fi
done

echo
echo "CUDA math libraries for NekRS/HYPRE"
for cuda_library in libcublas.so libcurand.so libcusolver.so libcusparse.so libnvJitLink.so.12; do
  if [[ -n "${CONDA_PREFIX:-}" && -e "${CONDA_PREFIX}/lib/${cuda_library}" ]]; then
    echo "${cuda_library} ${CONDA_PREFIX}/lib/${cuda_library}"
  else
    echo "${cuda_library} MISSING"
    failed=1
  fi
done

echo
echo "CUDA profiler API required by HYPRE"
if [[ -n "${CONDA_PREFIX:-}" && -f "${CONDA_PREFIX}/include/cuda_profiler_api.h" ]]; then
  echo "cuda_profiler_api.h ${CONDA_PREFIX}/include/cuda_profiler_api.h"
else
  echo "cuda_profiler_api.h MISSING"
  failed=1
fi

if [[ "${failed}" -ne 0 ]]; then
  echo
  echo "Runtime validation failed; CARDINAL/NekRS compilation has not started."
  exit 1
fi

echo
echo "Runtime is ready for a CUDA-enabled CARDINAL/NekRS build."
