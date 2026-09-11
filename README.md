# CARDINAL + MOOSE + NekRS on SSL BinderHub

This branch prepares an SSL BinderHub GPU session for building and running
[CARDINAL](https://cardinal.cels.anl.gov/) with MOOSE, OpenMC, and the NekRS
CUDA backend.

## Why the build runs after Binder starts

SSL BinderHub's image builder does not receive the large CPU, RAM, and GPU
allocation assigned to the interactive user pod. The image therefore contains
the CUDA compiler, MPI, CMake, and JupyterLab, while CARDINAL and its pinned
dependencies are compiled in the allocated GPU pod.

This environment intentionally does **not** install the `moose-dev` Conda
package. CARDINAL documents that MOOSE's Conda compiler wrappers expose HYPRE
headers incompatible with NekRS. MOOSE, PETSc, libMesh, WASP, NekRS, OpenMC,
and CARDINAL are built from source instead. Conda is used for Jupyter and the
CUDA development toolkit. Conda also supplies `libtirpc`; its XDR headers and
library paths and compiler/linker flags are passed explicitly to libMesh
because Ubuntu 24.04 no longer provides the legacy RPC headers in the default
include location. The CUDA static runtime package is included because
NekRS/HYPRE's CUDA compiler check links both `libcudadevrt.a` and
`libcudart_static.a`. The cuBLAS, cuSPARSE, cuSOLVER, and cuRAND development
packages provide every CUDA imported target linked by NekRS's GPU HYPRE build.
The tirpc compiler and linker flags are also propagated to CARDINAL's nested
NekRS/HYPRE configure step; libMesh records `-ltirpc` in its link interface, so
that step must retain the Conda library search path. `LIBRARY_PATH` is exported
as well because NekRS's CMake ExternalProject replaces `LDFLAGS` when launching
HYPRE's configure script.

## Launch and build

Launch the `cardinal` branch on SSL BinderHub using a CUDA-capable GPU profile:

<https://binderhub.ssl-hep.org/v2/gh/kavyawadhwa134/GAN-HEP/cardinal>

Open a JupyterLab terminal and run:

```bash
./scripts/check-cardinal-runtime.sh
BUILD_JOBS=8 ./scripts/build-cardinal.sh
```

`BUILD_JOBS` controls parallel compilation. Increase it only when the pod has
enough memory; MOOSE and libMesh can consume substantial RAM during parallel
builds.

The build is pinned to CARDINAL commit
`e8369a7058113315aa7f7c381aadc32b1c0f7115`. Override it when deliberately
testing another revision:

```bash
CARDINAL_REF=devel BUILD_JOBS=8 ./scripts/build-cardinal.sh
```

## Run

After a successful build:

```bash
export CARDINAL_ROOT="${HOME}/cardinal"
export NEKRS_HOME="${CARDINAL_ROOT}/install"
export OCCA_CACHE_DIR="${HOME}/.cache/occa"
export NEKRS_OCCA_MODE_DEFAULT=CUDA

"${CARDINAL_ROOT}/cardinal-opt" \
  -i /path/to/input.i \
  --nekrs-backend CUDA \
  --nekrs-device-id 0
```

For MPI:

```bash
mpiexec -n 2 "${HOME}/cardinal/cardinal-opt" \
  -i /path/to/input.i \
  --nekrs-backend CUDA \
  --nekrs-device-id 0
```

OpenMC-coupled cases additionally need cross-section data. Download it after
the CARDINAL source is available:

```bash
./scripts/download-openmc-data.sh
export OPENMC_CROSS_SECTIONS=/path/to/cross_sections.xml
```

## Persistence

The default source and build location is `${HOME}/cardinal`. If SSL BinderHub
mounts a persistent home volume, subsequent sessions can reuse the build. If
the home directory is ephemeral, point `CARDINAL_ROOT` and `OCCA_CACHE_DIR` at
an available persistent volume before building.

## Important runtime requirement

The Binder GPU profile must expose an NVIDIA device and driver to the user pod.
Both `nvidia-smi` and `nvcc` must succeed before the build begins. The
repository cannot request `nvidia.com/gpu` by itself; that allocation is part
of the SSL BinderHub profile selected at launch.
