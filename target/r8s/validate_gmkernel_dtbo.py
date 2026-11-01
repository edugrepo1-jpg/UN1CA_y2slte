#!/usr/bin/env python3
"""Verify exact GMKernel / SM-G780F revision selectors in a built dtbo.img.

Android DT_TABLE magic/header and three custom fields are read from the actual
output image; a matching .cfg alone is not proof of the generated image.
"""
from __future__ import annotations

import pathlib
import struct
import sys

EXPECTED = [(0x00000000, 0x00000001),
            (0x00000002, 0x00000004),
            (0x00000005, 0x000000FF)]


def verify(path: pathlib.Path) -> None:
    with path.open("rb") as file:
        data = file.read()
    if len(data) < 32:
        raise ValueError("DTBO header is truncated")
    magic, total, header_size, entry_size, count, entries_offset, page_size, version = struct.unpack_from(">8I", data, 0)
    if magic != 0xD7B7AB1E:
        raise ValueError("Invalid Android DT_TABLE magic")
    if total > len(data) or total < 32:
        raise ValueError("DTBO image total size is invalid")
    if header_size < 32 or entry_size < 32 or count != 3:
        raise ValueError("Unexpected DTBO entry count or header geometry")
    if entries_offset < header_size or entries_offset + count * entry_size > total:
        raise ValueError("DTBO entries are out of bounds")
    selectors = []
    for index in range(count):
        off = entries_offset + index * entry_size
        length, dt_offset, dt_id, rev, custom0, custom1, custom2, custom3 = struct.unpack_from(">8I", data, off)
        if length == 0 or dt_offset + length > total:
            raise ValueError(f"DTBO entry {index} has an invalid payload offset")
        selectors.append((custom0, custom1))
    if selectors != EXPECTED:
        raise ValueError(f"Unexpected r8s DTBO selectors: {selectors} != {EXPECTED}")


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: validate_gmkernel_dtbo.py dtbo.img", file=sys.stderr)
        return 2
    try:
        verify(pathlib.Path(sys.argv[1]))
    except (OSError, ValueError) as e:
        print(f"GMKernel DTBO validation failed: {e}", file=sys.stderr)
        return 1
    print("GMKernel r8s DTBO selectors and geometry validated")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
