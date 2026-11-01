#!/usr/bin/env python3
"""One UI 8.5 r8s: narrow, dark-mode-only AMOLED-black background patch.

This is NOT a global color-matrix filter, a panel/kernel change, or an
unconditional dark-mode force. It only modifies named resource colors in
night-qualified tables of the already-decoded Samsung SystemUI APK.
Fail closed on unknown DZG1 resource layout, instead of silently advertising
an AMOLED option that did not modify anything.
"""
from __future__ import annotations

import argparse
from pathlib import Path
import re
import sys

# Explicit Samsung background resources only. Do NOT change text, scrims,
# dimming, contrast or active tile colors.
BACKGROUND_NAMES = {
    "sec_qs_background",
    "qs_detail_background_color",
    "notification_panel_background",
    "notification_panel_background_color",
    "qs_panel_background_color",
    "qs_background_primary",
}
COLOR_TAG = re.compile(
    r'(<color\s+name="(?P<name>[^"]+)"\s*>)(?P<value>[^<]+)(</color>)'
)
HEX_COLOR = re.compile(r"^#(?P<hex>[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$")


def apply_systemui_dark_backgrounds(apk_root: Path) -> dict[str, int]:
    res = apk_root / "res"
    if not res.is_dir():
        raise ValueError(f"SystemUI resources are missing: {res}")
    files = sorted(
        p for p in res.glob("values-night*/colors.xml") if p.is_file()
    )
    if not files:
        raise ValueError("No night-qualified SystemUI color tables in DZG1")
    changes: dict[str, int] = {}
    found = set()
    for file in files:
        original = file.read_text(encoding="utf-8")
        touched = set()

        def replace(match: re.Match[str]) -> str:
            name = match.group("name")
            if name not in BACKGROUND_NAMES:
                return match.group(0)
            color = match.group("value").strip()
            parsed = HEX_COLOR.fullmatch(color)
            if parsed is None:
                # Do not overwrite theme attributes or dynamic color references.
                return match.group(0)
            value = parsed.group("hex")
            alpha = 255 if len(value) == 6 else int(value[0:2], 16)
            # Keep transparent and semi-transparent scrims unchanged.
            if alpha != 255:
                return match.group(0)
            found.add(name)
            touched.add(name)
            new = "#ff000000"
            return match.group(1) + new + match.group(4)

        changed = COLOR_TAG.sub(replace, original)
        if changed != original:
            file.write_text(changed, encoding="utf-8")
        if touched:
            changes[str(file.relative_to(apk_root))] = len(touched)

    if "sec_qs_background" not in found:
        raise ValueError(
            "Pure Black missing Samsung sec_qs_background in night resources: "
            "inspect the exact S926BXXSGDZG1 SystemUI resource map"
        )
    return changes


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("decoded_systemui", type=Path)
    args = parser.parse_args()
    changed = apply_systemui_dark_backgrounds(args.decoded_systemui)
    for path, count in changed.items():
        print(f"r8s Pure Black: {path}: {count} matched background resources")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError) as exc:
        print(f"r8s Pure Black: {exc}", file=sys.stderr)
        raise SystemExit(1) from exc
