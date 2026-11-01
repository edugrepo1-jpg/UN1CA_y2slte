#!/usr/bin/env python3
"""Port OneLab's narrow SSRM multi-window policy into the donor framework.

Target: Samsung SemMultiWindowManager.setMultiWindowEnabled(String, boolean).
Only the requester 'SSRM' setting enabled=false is converted to enabled=true.
This deliberately does not alter SDHMS temperatures, thermal trip points,
battery protection, CPU/GPU throttling, or non-SSRM window requests.

Keep the original method body and enforce its exact descriptor to avoid
silently injecting an invalid or obsolete DZG1 Smali patch.
"""
from __future__ import annotations

import argparse
from pathlib import Path
import re
import sys

METHOD = re.compile(
    r"(?ms)^\.method\s+(?P<attrs>[^\n]*\s)?"
    r"setMultiWindowEnabled\(Ljava/lang/String;Z\)V\s*$"
    r"(?P<body>.*?)^\.end method\s*$"
)
LOCALS = re.compile(r"(?m)^([ \t]*)\.locals[ \t]+(\d+)[ \t]*$")
SENTINEL = ":gm_r8s_ssrm_multiwindow_continue"
TARGET_CLASS = "com/samsung/android/app/SemMultiWindowManager.smali"


def patch_text(text: str) -> tuple[str, bool]:
    matches = list(METHOD.finditer(text))
    if len(matches) != 1:
        near = re.findall(
            r"(?m)^\\.method[^\\n]*setMultiWindowEnabled[^\\n]*$",
            text
        )
        raise ValueError(
            f"EZJ1 needs one {TARGET_CLASS}."
            "setMultiWindowEnabled(Ljava/lang/String;Z)V; found "
            f"{len(matches)}. Related method descriptors: {near[:8]}"
        )
    method = matches[0]
    if re.search(r"\b(static|native|abstract)\b", method.group("attrs") or ""):
        raise ValueError("Unsupported static/native/abstract multi-window method")
    body = method.group("body")
    if SENTINEL in body:
        return text, False

    local = LOCALS.search(body)
    if local is None or len(LOCALS.findall(body)) != 1:
        raise ValueError("Expected one .locals directive in EZJ1 SemMultiWindowManager")
    locals_count = int(local.group(2))
    if locals_count == 0 and re.search(r"\bv\d+\b", body):
        raise ValueError("Zero-locals method uses v aliases; unsafe to increase registers")
    if locals_count == 0:
        body = body[:local.start()] + local.group(1) + ".locals 1" + body[local.end():]
        local = LOCALS.search(body)
        assert local is not None

    # Guard the exact OneLab call: SSRM requests a false multi-window state.
    # No new branches or field changes in Samsung's original method body.
    injection = (
        "\n"
        "    const-string v0, \"SSRM\"\n"
        "    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n"
        "    move-result v0\n"
        f"    if-eqz v0, {SENTINEL}\n"
        f"    if-nez p2, {SENTINEL}\n"
        "    const/4 p2, 0x1\n"
        f"    {SENTINEL}\n"
    )
    # Smali allows .param/.annotation declarations after .locals. Insert code
    # after those directives and before the first original opcode/label.
    # This avoids putting bytecode inside an annotation block.
    position = local.end()
    in_annotation = False
    while position < len(body):
        eol = body.find("\n", position)
        eol = len(body) if eol < 0 else eol + 1
        line = body[position:eol].strip()
        if line.startswith(".annotation"):
            in_annotation = True
        elif line.startswith(".end annotation"):
            in_annotation = False
        elif not in_annotation and line and not line.startswith((
            "#", ".param", ".line", ".prologue", ".local", ".restart local",
            ".end local",
        )):
            break
        position = eol
    if in_annotation:
        raise ValueError("Unterminated Smali annotation in EZJ1 multi-window method")
    body = body[:position] + injection + body[position:]
    return text[:method.start("body")] + body + text[method.end("body"):], True


def patch_tree(root: Path) -> bool:
    matches = sorted(root.rglob(TARGET_CLASS))
    if len(matches) != 1:
        nearby = sorted(
            str(p.relative_to(root))
            for p in root.rglob("*MultiWindowManager*.smali")
        )[:15]
        raise ValueError(
            f"EZJ1 framework must contain one {TARGET_CLASS}; found "
            f"{len(matches)}. Candidate classes: {nearby}"
        )
    path = matches[0]
    original = path.read_text(encoding="utf-8")
    updated, changed = patch_text(original)
    if changed:
        path.write_text(updated, encoding="utf-8")
    return changed


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("decoded_framework_jar", type=Path)
    args = parser.parse_args()
    result = patch_tree(args.decoded_framework_jar)
    print("r8s OneLab SSRM multi-window: " + ("patched" if result else "already patched"))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError) as exc:
        print(f"r8s OneLab SSRM multi-window: {exc}", file=sys.stderr)
        raise SystemExit(1) from exc
