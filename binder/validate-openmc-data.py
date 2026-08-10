#!/usr/bin/env python3
"""Fail if OpenMC's configured nuclear-data links are incomplete."""

from __future__ import annotations

import os
from pathlib import Path
import xml.etree.ElementTree as ET


cross_sections = Path(os.environ["OPENMC_CROSS_SECTIONS"]).resolve()
chain_file = Path(os.environ["OPENMC_CHAIN_FILE"]).resolve()

if not cross_sections.is_file():
    raise SystemExit(f"Cross-section index is missing: {cross_sections}")
if not chain_file.is_file():
    raise SystemExit(f"Depletion chain is missing: {chain_file}")

root = ET.parse(cross_sections).getroot()
ET.parse(chain_file)
directory_node = root.find("directory")
if directory_node is not None and directory_node.text:
    library_root = Path(directory_node.text)
    if not library_root.is_absolute():
        library_root = cross_sections.parent / library_root
else:
    library_root = cross_sections.parent

libraries = root.findall("library")
missing = []
for library in libraries:
    path = Path(library.attrib["path"])
    if not path.is_absolute():
        path = library_root / path
    if not path.is_file():
        missing.append(path)

if missing:
    preview = "\n".join(f"  - {path}" for path in missing[:20])
    more = f"\n  ... and {len(missing) - 20} more" if len(missing) > 20 else ""
    raise SystemExit(
        f"{len(missing)} of {len(libraries)} nuclear-data files are missing:\n"
        f"{preview}{more}"
    )

print(f"Cross sections: {cross_sections}")
print(f"Libraries:      {len(libraries)} (all linked files exist)")
print(f"Depletion:      {chain_file}")
