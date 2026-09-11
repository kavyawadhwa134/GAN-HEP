#!/usr/bin/env bash
set -euo pipefail

CARDINAL_ROOT="${CARDINAL_ROOT:-${HOME}/cardinal}"

if [[ ! -x "${CARDINAL_ROOT}/scripts/download-openmc-cross-sections.sh" ]]; then
  echo "Build or clone CARDINAL first with ./scripts/build-cardinal.sh" >&2
  exit 1
fi

cd "${CARDINAL_ROOT}"
./scripts/download-openmc-cross-sections.sh

echo
echo "Set OPENMC_CROSS_SECTIONS to the cross_sections.xml path printed above."
