#!/usr/bin/env python3
"""GM HUB Pure Black for Samsung SystemUI on One UI 8.5/9.0.

The One UI 9 EZJ1 SystemUI resource map is not the DZG1 map: in particular
sec_qs_background need not exist in values-night/colors.xml. Resolve resource
candidates by *semantic name + opaque dark literal*, plus the exact primary
detail surfaces verified in the EZJ1 inventory, across Samsung values,
color-state XML and shape-drawable XML, while editing only night-qualified
resources. Never change light-mode colors, text, tile accents, dim/scrims,
wallpaper effects, or kernel/panel behavior.

If the donor contains no safe target, fail with a resource inventory rather
than reporting a fake working feature or editing unrelated colors.
"""
from __future__ import annotations

import argparse
from pathlib import Path
import re
import sys

COLOR_TAG = re.compile(
    r'(<color\b[^>]*\bname="(?P<name>[^"]+)"[^>]*>\s*)'
    r'(?P<value>#[0-9A-Fa-f]{6}(?:[0-9A-Fa-f]{2})?)'
    r'(\s*</color>)',
    re.I,
)
HEX = re.compile(r"^#(?:[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$")
# API37 Samsung often stores background colors as theme/resource references,
# rather than a literal dark value. Change these only in night variants.
REF_COLOR_TAG = re.compile(
    r'(<color\b[^>]*\bname="(?P<name>[^"]+)"[^>]*>\s*)'
    r'(?P<value>[@?][^<\s]+)'
    r'(\s*</color>)',
    re.I,
)

ATTR_COLOR = re.compile(r'(\bandroid:color\s*=\s*")(?P<value>#[a-fA-F0-9]{6}(?:[a-fA-F0-9]{2})?)(")')
IN_XML = re.compile(r"(?s)<resources\b[^>]*>")
EXCLUDED = (
    "tile", "icon", "text", "scrim", "dim", "blur", "stroke", "divider",
    "ripple", "ripple_effect", "shadow", "outline", "border", "accent",
    "pressed", "active", "selected", "foreground", "disabled", "transparent",
    "alpha", "highlight", "status_icon", "nav_icon", "error", "warning",
    "gradient", "notif_row", "notification_row", "card", "button",
    "subscreen", "clear_cover", "cover", "media_art", "media_player",
    "avatar", "onboarding", "guts", "controls_panel", "content_image",
)
# One UI resource names changed between DZG1 / EZJ1. Reject generic app
# backgrounds; target the actual notification shade and Quick Settings.
# Do not recolor unrelated Samsung subscreen panels or notification imagery.
# The actual EZJ1 package contains those alongside the main notification shade.
UI_PARTS = (
    "qs", "quicksetting", "quick_setting",
    "notification_shade", "notification_panel", "sec_panel", "shade"
)
BG_PARTS = ("background", "bg", "surface", "backplate", "backdrop", "base_color")
ALWAYS_ALLOWED = {
    "sec_qs_background", "qs_detail_background_color",
    "notification_panel_background", "notification_panel_background_color",
    "qs_panel_background_color", "qs_background_primary",
    "notification_shade_background_color", "qs_panel_bg",
}
# Exact primary surfaces observed in the EZJ1 donor artifact. They use light
# translucent defaults even though qs_detail_background_color aliases them.
# Give these surfaces opaque black *only at night*, while preserving every
# day resource, shade animation alpha and translucent icon/tile/scrim color.
PRIMARY_SURFACES = {
    "sec_qs_detail_bg_color", "sec_qs_detailed_container_background",
}


def night_files(res: Path, resource_type: str) -> list[Path]:
    # Android qualifier order allows values-land-night and drawable-sw600dp-
    # night, not just values-night-vNN. Match the qualifier token itself.
    return sorted(p for p in res.glob(f"{resource_type}*/*.xml")
                  if p.is_file() and "night" in p.parent.name.split("-")[1:])


def is_target(name: str) -> bool:
    name = name.lower()
    if name in ALWAYS_ALLOWED:
        return True
    if any(bad in name for bad in EXCLUDED):
        return False
    return any(part in name for part in UI_PARTS) and any(
        part in name for part in BG_PARTS
    )


def is_opaque_near_black(value: str) -> bool:
    if HEX.fullmatch(value) is None:
        return False
    h = value[1:]
    if len(h) == 8:
        if int(h[:2], 16) != 255:
            return False
        h = h[2:]
    return all(int(h[i:i + 2], 16) <= 96 for i in (0, 2, 4))


def is_surface_color(name: str, value: str) -> bool:
    if is_opaque_near_black(value):
        return True
    return (name.lower() in PRIMARY_SURFACES and HEX.fullmatch(value) is not None
            and (len(value) == 7 or int(value[1:3], 16) != 0))


def replace_color_tags(content: str, matched: set[str]) -> str:
    def change(match: re.Match[str]) -> str:
        name = match.group("name")
        if not is_target(name) or not is_surface_color(name, match.group("value")):
            return match.group(0)
        matched.add(name)
        return match.group(1) + "#ff000000" + match.group(4)
    content = COLOR_TAG.sub(change, content)

    def change_reference(match: re.Match[str]) -> str:
        name, ref = match.group("name"), match.group("value")
        if not is_target(name):
            return match.group(0)
        if any(bad in ref.lower() for bad in (
            "transparent", "scrim", "dim", "alpha", "gradient", "ripple"
        )):
            return match.group(0)
        matched.add(name)
        return match.group(1) + "#ff000000" + match.group(4)

    return REF_COLOR_TAG.sub(change_reference, content)


def replace_flat_color_attr(content: str, matched: set[str], name: str) -> str:
    if not is_target(name):
        return content
    # Don't rewrite arbitrary stateful selectors or gradient layers: one
    # opaque color controls the entire matching XML resource.
    attrs = list(ATTR_COLOR.finditer(content))
    if len(attrs) != 1 or not is_surface_color(name, attrs[0].group("value")):
        return content
    match = attrs[0]
    matched.add(name)
    return content[:match.start("value")] + "#ff000000" + content[match.end("value"):]


def collect_base_colors(res: Path, inventory: list[str]) -> dict[str, str]:
    """Find unique named dark base colors that can receive night overlays."""
    collected: dict[str, str] = {}
    conflicts: set[str] = set()
    for p in sorted(res.glob("values*/*.xml")):
        if "night" in p.parent.name.split("-")[1:]:
            continue
        try:
            source = p.read_text(encoding="utf-8")
        except UnicodeError:
            continue
        for m in (*COLOR_TAG.finditer(source), *REF_COLOR_TAG.finditer(source)):
            name, value = m.group("name"), m.group("value")
            if not is_target(name):
                continue
            inventory.append(f"{p.relative_to(res)} | {name} = {value}")
            is_opaque = is_surface_color(name, value)
            is_safe_ref = value.startswith(("@", "?")) and not any(
                bad in value.lower() for bad in (
                    "transparent", "scrim", "dim", "alpha", "gradient", "ripple"
                )
            )
            if not (is_opaque or is_safe_ref):
                continue
            if name in collected and collected[name].lower() != value.lower():
                conflicts.add(name)
            else:
                collected[name] = value
    for name in conflicts:
        collected.pop(name, None)
    return collected


def add_night_overrides(res: Path, candidates: dict[str, str],
                        matched: set[str], changes: dict[str, int]) -> None:
    """Give API37 flat base resources a dark-only variant; no day edits."""
    if not candidates:
        return
    target = res / "values-night" / "colors.xml"
    if target.is_file():
        original = target.read_text(encoding="utf-8")
        if IN_XML.search(original) is None or "</resources>" not in original:
            raise ValueError("Invalid values-night/colors.xml resource table")
    else:
        original = '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n</resources>\n'
    # APKTool may split an Android qualifier across several XML files.
    # Re-declaring one resource in the same values-night qualifier would
    # cause aapt2 duplicate-resource failures.
    defined_at_night: set[str] = set()
    for existing in night_files(res, "values"):
        source = existing.read_text(encoding="utf-8")
        defined_at_night.update(
            re.findall(r'<color\b[^>]*\bname="([^"]+)"', source)
        )
    # File-based color selectors share the same resource namespace as
    # <color> entries. Adding both in one qualifier breaks aapt2.
    defined_at_night.update(p.stem for p in night_files(res, "color"))
    added = sorted(set(candidates) - defined_at_night)
    if not added:
        return
    block = "".join(f'    <color name="{name}">#ff000000</color>\n'
                    for name in added)
    target.parent.mkdir(parents=True, exist_ok=True)
    content = original.replace("</resources>", block + "</resources>", 1)
    target.write_text(content, encoding="utf-8")
    matched.update(added)
    changes[target.relative_to(res.parent).as_posix()] = len(added)


def apply_systemui_dark_backgrounds(apk_root: Path,
                                    report_path: Path | None = None) -> dict[str, int]:
    res = apk_root / "res"
    if not res.is_dir():
        raise ValueError(f"SystemUI resources are missing: {res}")

    matched: set[str] = set()
    changes: dict[str, int] = {}
    inventory: list[str] = []
    base_colors = collect_base_colors(res, inventory)

    # Android / Samsung use both values-night and values-night-vNN.
    night_values = night_files(res, "values")
    for file in night_values:
        original = file.read_text(encoding="utf-8")
        names: set[str] = set()
        updated = replace_color_tags(original, names)
        if names:
            inventory.extend(
                f"{file.relative_to(res)} | {name} = night color"
                for name in sorted(names)
            )
            matched.update(names)
            changes[file.relative_to(apk_root).as_posix()] = len(names)
        if updated != original:
            file.write_text(updated, encoding="utf-8")

    # In APKTool, a color can also be a file-based selector in color-night.
    # A solid/drawable night background may be XML instead of a color entry.
    for folder in ("color", "drawable"):
        for file in night_files(res, folder):
            original = file.read_text(encoding="utf-8")
            names: set[str] = set()
            updated = replace_flat_color_attr(original, names, file.stem)
            if names:
                matched.update(names)
                inventory.append(f"{file.relative_to(res)} | {file.stem} = night XML")
                changes[file.relative_to(apk_root).as_posix()] = len(names)
            if original != updated:
                file.write_text(updated, encoding="utf-8")

    # One UI 9 may define QS background solely in unqualified values/colors
    # and rely on a dark theme at runtime. Provide a *night-only* override,
    # never changing the unqualified value used in day mode.
    add_night_overrides(res, base_colors, matched, changes)

    # Flat unqualified XML colors/shapes also need night-only copies.
    for folder in ("color", "drawable"):
        night_root = res / (folder + "-night")
        for file in sorted(p for p in (res / folder).glob("*.xml") if p.is_file()):
            if not is_target(file.stem):
                continue
            original = file.read_text(encoding="utf-8")
            names: set[str] = set()
            updated = replace_flat_color_attr(original, names, file.stem)
            if not names:
                continue
            target = night_root / file.name
            # A donor-supplied specific night file is authoritative.
            if any(p.name == file.name for p in night_files(res, folder)):
                continue
            if folder == "color" and any(
                re.search(r'<color\b[^>]*\bname="' + re.escape(file.stem) + r'"',
                          table.read_text(encoding="utf-8"))
                for table in night_files(res, "values")
            ):
                continue
            night_root.mkdir(parents=True, exist_ok=True)
            target.write_text(updated, encoding="utf-8")
            matched.add(file.stem)
            inventory.append(f"{file.relative_to(res)} -> {target.relative_to(res)}")
            changes[target.relative_to(apk_root).as_posix()] = 1

    if report_path is not None:
        report_path.parent.mkdir(parents=True, exist_ok=True)
        report_path.write_text(
            "GM HUB Pure Black EZJ1 candidate inventory\n"
            + "\n".join(sorted(set(inventory))) + "\n"
            + f"Applied dark-only resource names: {sorted(matched)}\n",
            encoding="utf-8",
        )

    if not matched:
        # Avoid another "sec_qs_background missing" stale-version error.
        hints = sorted(set(inventory))[:15]
        raise ValueError(
            "No safe opaque dark Quick Settings / notification-shade "
            "resource found in this One UI 9 SystemUI; inspect generated "
            f"inventory (candidates={hints!r}). "
            "Do not blindly change framework colors."
        )
    print(f"GM HUB Pure Black: mapped {len(matched)} resource names: "
          + ", ".join(sorted(matched)))
    return changes


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("decoded_systemui", type=Path)
    parser.add_argument("--report", type=Path, default=None,
                        help="Save donor resource-map inventory for CI inspection")
    args = parser.parse_args()
    changes = apply_systemui_dark_backgrounds(
        args.decoded_systemui, report_path=args.report
    )
    for path, count in sorted(changes.items()):
        print(f"GM HUB Pure Black: {path}: {count} background resources")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError) as exc:
        print(f"GM HUB Pure Black: {exc}", file=sys.stderr)
        raise SystemExit(1) from exc
