# GM Hub: three opt-in Liquid Glass shader ports

This module adapts the optical AGSL engines from QWEA Liquid-Glass-Android,
Kyant Backdrop and ColorOS16-LiquidGlass to the **captured QUICK_PANEL background**
in the audited API37 Samsung SystemUI. It does not install their demo control
centers, depend on Compose/OPPO/LSPosed, change the player or replace all system
blur. Live-window blur, notifications and authentication backgrounds retain the
Samsung renderer. Full-system integration and the separate editable Apple QS
layout remain outside this first adapter.

Settings > GM HUB > Liquid Glass provides one persistent engine selection:
original One UI, QWEA, Kyant or ColorOS. Default is original One UI. Only the
selected engine is instantiated on the next background capture. Installation
does not change a saved selection or force-restart SystemUI.

The hook uses Samsung's existing capture provider and leaves its native blur
calculation intact for an immediate fallback. QWEA and Kyant sample the blurred
backdrop; ColorOS samples the original authorized capture. Thus this initial
adapter does **not** claim to eliminate Samsung's original blur processing cost.
It adds no screen capture service, timer, sensor, bitmap readback or idle frame
loop. This is not a measured FPS/battery improvement.

The renderer uses original blur during power saving, moderate-or-higher thermal
status, high contrast, reduced transparency, low-RAM mode, software rendering,
oversized surfaces, recycled captures or a shader error. Failures are logged once
per engine and the failing engine is suppressed for that SystemUI process.
The original blurred drawable is retained; failure must never expose a raw
capture. Original capture security and keyguard source selection are unchanged.

Pinned originals and licenses are in `upstream/` and `licenses/`. Packaged shader
and adapter digests are checked before modifying the decoded APK. `prepare_assets.py`
extracts actual shader programs rather than substituting three parameter presets.
The Kyant SDF interpolation is resolved from the same pinned source file. These
are native shader ports, not complete ports of the libraries' widgets, editors,
sensor lighting or platform-specific hooks. No arbitrary apps are injected.

Rebuild the adapter after Java changes with `compile.py --sdk SDK --java-home JDK
--apktool APKTOOL_JAR`, then rerun the integration and linkage checks. The committed
smali avoids adding SDK/Gradle downloads to the normal ROM pipeline.

Host compilation/linkage/render tests are separate from device validation.
No physical r8s rendering, battery or jank result is established by this module.
