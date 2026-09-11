#!/usr/bin/env bash
set -Eeuo pipefail

download_root="${OPENMC_DATA_ROOT:-${HOME}/cross_sections}"
library="${OPENMC_DATA_LIBRARY:-endfb-vii.1-hdf5}"

case "${library}" in
  endfb-vii.1-hdf5)
    archive_url="https://anl.box.com/shared/static/9igk353zpy8fn9ttvtrqgzvw1vtejoz6.xz"
    ;;
  endfb-viii.0-hdf5)
    archive_url="https://anl.box.com/shared/static/uhbxlrx7hvxqw27psymfbhi7bx7s6u6a.xz"
    ;;
  *)
    echo "Unsupported OPENMC_DATA_LIBRARY: ${library}" >&2
    echo "Choose endfb-vii.1-hdf5 or endfb-viii.0-hdf5." >&2
    exit 2
    ;;
esac

target_dir="${download_root}/${library}"
cross_sections="${target_dir}/cross_sections.xml"

if [[ -f "${cross_sections}" ]]; then
  echo "OpenMC data already exists at ${target_dir}"
else
  if [[ -e "${target_dir}" ]]; then
    echo "Incomplete target exists at ${target_dir}; move it aside before retrying." >&2
    exit 1
  fi

  mkdir -p "${download_root}"
  staging_dir="$(mktemp -d "${download_root}/.${library}.download.XXXXXX")"
  trap 'rm -rf "${staging_dir}"' EXIT

  echo "Downloading ${library} to ${target_dir}"
  curl --fail --location --retry 5 --retry-delay 5 "${archive_url}" |
    tar -xJ --no-same-owner -C "${staging_dir}"

  if [[ ! -f "${staging_dir}/${library}/cross_sections.xml" ]]; then
    echo "Downloaded archive did not contain ${library}/cross_sections.xml" >&2
    exit 1
  fi

  mv "${staging_dir}/${library}" "${target_dir}"
fi

echo
echo "Set:"
echo "export OPENMC_CROSS_SECTIONS=${cross_sections}"
