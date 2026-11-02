#!/usr/bin/env python3
"""Keep the legacy ARM32 encoder's timestamp state valid between sessions.

Port of ArtisanROM f6c39fcbe5bb7a043d9eb8909d4197f8860be61a.
Only the target vendor library is changed; Android 17 media libraries retain
their own ABI. Reject unknown, duplicate or mixed instruction sequences.
"""
from pathlib import Path
import sys

BEFORE = bytes.fromhex("d7e94601401b71eb060006da")
AFTER = bytes.fromhex("d7e94601401b71eb060000bf")


def patch(data: bytes) -> bytes:
    if len(data) < 52 or data[:7] != b"\x7fELF\x01\x01\x01" or data[18:20] != b"\x28\x00":
        raise ValueError("Expected the stock little-endian ARM32 ELF")
    original, fixed = data.count(BEFORE), data.count(AFTER)
    if (original, fixed) == (0, 1):
        return data
    if (original, fixed) != (1, 0):
        raise ValueError(f"Unknown or ambiguous timestamp guard: {original} original, {fixed} fixed")
    offset = data.index(BEFORE)
    if offset % 2:
        raise ValueError("Timestamp guard is not Thumb instruction aligned")
    return data[:offset] + AFTER + data[offset + len(BEFORE):]


if __name__ == "__main__":
    path = Path(sys.argv[1])
    original = path.read_bytes()
    result = patch(original)
    if result != original:
        path.write_bytes(result)
    print("Legacy video encoder timestamp reset is compatible with consecutive recordings")
