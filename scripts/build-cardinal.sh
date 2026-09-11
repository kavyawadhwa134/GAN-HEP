#!/usr/bin/env bash
set -Eeuo pipefail

# Pinned for reproducibility. Override CARDINAL_REF to test another revision.
CARDINAL_REF="${CARDINAL_REF:-e8369a7058113315aa7f7c381aadc32b1c0f7115}"
CARDINAL_ROOT="${CARDINAL_ROOT:-${HOME}/cardinal}"
BUILD_JOBS="${BUILD_JOBS:-$(nproc)}"

if ! [[ "${BUILD_JOBS}" =~ ^[1-9][0-9]*$ ]]; then
  echo "BUILD_JOBS must be a positive integer, received: ${BUILD_JOBS}" >&2
  exit 2
fi

script_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"${script_root}/check-cardinal-runtime.sh"

cuda_compiler="$(command -v nvcc)"
cuda_root="${CUDA_HOME:-$(cd "$(dirname "${cuda_compiler}")/.." && pwd)}"
xdr_include="${CONDA_PREFIX}/include/tirpc"
xdr_libdir="${CONDA_PREFIX}/lib"
xdr_cppflags="-I${xdr_include} ${CPPFLAGS:-}"
xdr_ldflags="-L${xdr_libdir} -Wl,-rpath,${xdr_libdir} ${LDFLAGS:-}"
xdr_libs="-ltirpc ${LIBS:-}"

# Use the system MPI wrappers. The MOOSE conda compiler wrappers are deliberately
# excluded because CARDINAL documents that they conflict with NekRS's HYPRE.
export CC=/usr/bin/mpicc
export CXX=/usr/bin/mpicxx
export FC=/usr/bin/mpifort
export CUDA_HOME="${cuda_root}"
export CUDAToolkit_ROOT="${cuda_root}"
export ENABLE_NEK=yes
export ENABLE_OPENMC=yes
export ENABLE_DAGMC=no
export ENABLE_DOUBLE_DOWN=off
export NEKRS_HOME="${CARDINAL_ROOT}/install"
export NEKRS_OCCA_MODE_DEFAULT=CUDA
export OCCA_CACHE_DIR="${OCCA_CACHE_DIR:-${HOME}/.cache/occa}"
export JOBS="${BUILD_JOBS}"
export LIBMESH_JOBS="${BUILD_JOBS}"
export MOOSE_JOBS="${BUILD_JOBS}"

mkdir -p "$(dirname "${CARDINAL_ROOT}")" "${OCCA_CACHE_DIR}"

if [[ ! -d "${CARDINAL_ROOT}/.git" ]]; then
  git clone https://github.com/neams-th-coe/cardinal.git "${CARDINAL_ROOT}"
fi

cd "${CARDINAL_ROOT}"
git fetch origin "${CARDINAL_REF}"
git checkout --detach "${CARDINAL_REF}"

echo "Fetching MOOSE, NekRS, OpenMC, and nuclear-data revisions pinned by CARDINAL."
./scripts/get-dependencies.sh

echo "Building PETSc."
./contrib/moose/scripts/update_and_rebuild_petsc.sh

echo "Building libMesh."
CPPFLAGS="${xdr_cppflags}" \
LDFLAGS="${xdr_ldflags}" \
LIBS="${xdr_libs}" \
TIRPC_DIR="${xdr_include}" \
  ./contrib/moose/scripts/update_and_rebuild_libmesh.sh \
  --with-xdr-include="${xdr_include}" \
  --with-xdr-libdir="${xdr_libdir}" \
  --with-xdr-libname=tirpc \
  --with-vexcl=no

echo "Building WASP."
./contrib/moose/scripts/update_and_rebuild_wasp.sh

echo "Building CARDINAL with OpenMC and the NekRS CUDA backend."
make -j"${BUILD_JOBS}" \
  MAKEFLAGS="-j${BUILD_JOBS}" \
  ENABLE_NEK=yes \
  ENABLE_OPENMC=yes \
  ENABLE_DAGMC=no \
  OCCA_CUDA_ENABLED=1 \
  OCCA_HIP_ENABLED=0 \
  OCCA_OPENCL_ENABLED=0

if [[ ! -x "${CARDINAL_ROOT}/cardinal-opt" ]]; then
  echo "Build finished without producing ${CARDINAL_ROOT}/cardinal-opt" >&2
  exit 1
fi

echo
echo "CARDINAL build completed successfully."
echo "Executable: ${CARDINAL_ROOT}/cardinal-opt"
echo "Run a CUDA NekRS case with:"
echo "  ${CARDINAL_ROOT}/cardinal-opt -i INPUT.i --nekrs-backend CUDA --nekrs-device-id 0"
