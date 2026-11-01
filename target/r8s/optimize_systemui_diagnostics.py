#!/usr/bin/env python3
"""Keep expensive QS animation diagnostics behind their Android debug log tag."""
from pathlib import Path
import re
import sys

CLASS = "Lcom/android/systemui/qs/animator/QSAnimView;"
VISUAL = f"    iget-object p0, p0, {CLASS}->view:Landroid/view/View;"
GATE = '''

    # Diagnostic state is opt-in; rendering and animation behavior are unchanged.
    const-string v2, "QSAnimView"
    const/4 v1, 0x3
    invoke-static {v2, v1}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z
    move-result v2
    if-eqz v2, :r8s_apply_visual
'''


def optimize(text: str) -> str:
    original = text
    # Modern One UI 9 builds may no longer invoke expensive legacy Debug
    # caller tracing from QSAnimView. There is nothing to optimize in that case.
    if "Landroid/os/Debug;->getCallers" not in text:
        return text
    if text.count(":r8s_apply_visual") == 4:
        return text
    if ":r8s_apply_visual" in text:
        raise ValueError("Partially modified QSAnimView; review the source")
    for signature in ("setAlpha(F)V", "setVisibility(I)V"):
        pattern = r"(?ms)^\.method public " + re.escape(signature) + r"\n.*?^\.end method"
        match = re.search(pattern, text)
        if not match:
            # One UI 9 can rename/restructure these methods while retaining
            # QSAnimView; this diagnostic-only optimization is not required
            # for boot. Never mutate a method with an unknown API37 layout.
            return original
        body = match[0]
        if (body.count("    .locals 3") != 1 or body.count(VISUAL) != 1
                or body.count("Landroid/os/Debug;->getCallers") != 1
                or body.count(f"{CLASS}->addState(") != 1):
            # The donor changed its registers/visual flow; silently editing
            # the old anchors could break SystemUI verification or the QS.
            # Preserve the complete original class, even if an earlier
            # method was tentatively optimized during this same invocation.
            return original
        insertion = body.index("    .locals 3") + len("    .locals 3")
        changed = body[:insertion] + GATE + body[insertion:]
        changed = changed.replace(VISUAL, "    :r8s_apply_visual\n" + VISUAL, 1)
        # Preserve null handling, the exact setter, and its return path.
        if changed[changed.index(VISUAL):] != body[body.index(VISUAL):]:
            raise ValueError("Visual operation changed")
        text = text[:match.start()] + changed + text[match.end():]
    return text


def main() -> None:
    root = Path(sys.argv[1])
    candidates = list(root.glob("smali*/com/android/systemui/qs/animator/QSAnimView.smali"))
    if not candidates:
        print("GM HUB: One UI 9 has no legacy QSAnimView class; diagnostic patch not applicable")
        return
    if len(candidates) != 1:
        raise ValueError(f"Ambiguous QSAnimView class count: {len(candidates)}")
    path = candidates[0]
    before = path.read_text(encoding="utf-8")
    after = optimize(before)
    if after != before:
        path.write_text(after, encoding="utf-8", newline="\n")
    if after == before:
        print("GM HUB: QSAnimView does not contain legacy caller tracing or is already patched")
    else:
        print("GM HUB: QS caller diagnostics are opt-in; enable with log.tag.QSAnimView=DEBUG")


if __name__ == "__main__":
    main()
