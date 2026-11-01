# GM Hub: Artisan + Paradox + UN1CA (SM-G780F / r8s)

> **Development port only.** These components are installed into the **existing Samsung SecSettings** APK on the **One UI 8.5 / Android 16 (API 36)** donor `S926BXXSGDZG1`. This is **not One UI 9**.
>
> Source-level CI does **not** prove Android 16 resource linking, dex verification, boot or on-device behavior. Use only after building and checking the resulting app and ROM.

## Architecture

One top-level Samsung **GM Hub - Artisan + Paradox** screen. No second or third control center APK is installed.

- UN1CA / Artisan existing `io.mesalabs.unica.settings` fragments are preserved (UI, privacy/spoof, extra settings, Artisan information).
- Paradox source `com.paradox.hub` Smali classes are imported from the owner's `edugrepo1-jpg/ParadoxUI:sixteenQPR2`, with changes only for r8s compatibility.
- Settings patch input: `unica/mods/settings/SecSettings.apk`. Both the existing settings-injection scripts and DZG1 firmware APK remain the source of truth.
- Hardware-dependent capabilities are gated at the UI level until their kernel/panel/runtime ABI is confirmed. The 59-MiB boot partition and user-pinned GM Kernel remain unchanged.
- Credit: ArtisanROM, ParadoxUI/ExtremeXT/miguelbarretoo/EliteUI, Salvo Giangreco/UN1CA, other upstream contributors. Retain existing GPLv3 and third-party license notices.

## Paradox Hub component inventory

| Feature | Integrated source | Exposed in the GM Hub | r8s adaptation and constraints |
|---|---|---|---|
| Paradox control panel | Yes | Yes | Integrated under one Settings home |
| Minimum/maximum refresh rate + reset | Yes | Yes | **60/120 Hz only**; 48 excluded. EA8079-only 96 Hz cannot be shown globally until runtime panel detection is implemented |
| Core Modes: Smooth, Gaming, Battery, Stock+ restore | Yes | Yes | All old 48-Hz values changed to 60 Hz. Settings backup/restore retained; runtime behavior not yet confirmed |
| Additional Samsung touch sensitivity | Yes | Yes | This toggles `touch_sensitivity_enabled`; **does not** change physical digitizer voltage or sampling frequency |
| RAM, active/cached memory, ZRAM monitoring | Yes | Yes | Reads `/proc/meminfo`; numerical units and UI refresh still require device validation |
| Battery capacity/current/cycles/health | Yes | Yes | Reads battery power_supply attributes; absence or unit mapping must be handled after physical test |
| CPU/GPU temperature monitor | Yes | **No** | Original source hardcodes thermal_zone0–3; r8s sensor labels must be verified |
| Paradox application manager | Yes | **No** | Does not yet protect boot-critical Samsung packages from being disabled |
| Screen resolution (720p/1080p/WQHD) | Source staged | **No** | r8s physical 1080x2400 panel, optical FOD and display compositor geometry; WQHD must not be offered as real hardware mode |
| Bluetooth absolute-volume switch | Source staged | **No** | Original writes a Secure database key, while AOSP developer-option flow uses `persist.bluetooth.disableabsvol`; requires DZG1-stack verification |
| Wi-Fi Ping Stabilizer | Source staged | **No** | Original toggles Wi-Fi scan throttling; its latency/location claims are unsupported |
| Anti-tracking | Source staged | **No** | Original only switches `send_action_info`, not firewall ports or all Samsung telemetry |
| Cached-app freezer | Source staged | **No** | May disrupt foreground/background work; evaluate interaction with lmkd before exposure |
| Thermal performance/CPU overclocking | No compatible implementation | **No** | No disabling thermal checks or forcing unsupported GPU/CPU frequencies |
| System Monitor diagnostics | Source staged | **No** | Hardcoded thermal-zone indices and health interpretations require physical sensor calibration |

## Artisan / UN1CA settings retained in the GM Hub

| Feature | Source / availability |
|---|---|
| Native/live blur | Existing UN1CA UI settings |
| Launcher animation selector | Existing UN1CA UI settings |
| Vulkan rendering option | Existing UN1CA UI settings; experimental |
| Force maximum refresh rate | Existing UN1CA UI settings; hardware capability still applies |
| Boot sound option | Existing UN1CA UI settings |
| App downgrade and old target SDK allowance | Existing UN1CA extra settings |
| Screenshot flags and detection settings | Existing UN1CA extra settings |
| Hide app list, developer-status options, spoof features | Existing UN1CA settings and related modules |
| Game FPS unlock and Google Photos policy | Existing UN1CA modules; feature compatibility not equivalent to guaranteed service support |
| Call recording / CSC / user profiles / FlipFont / Outdoor mode | Existing UN1CA / Artisan modules, service/regional limitations apply |
| Artisan ROM info | Existing Artisan fragment |
| Artisan OTA / updater | Existing updater module, **only enabled for official builds**; this port is unofficial. Do not silently ship official signing keys |
| Device Image Changer | Artisan source reviewed, **not yet integrated**; requires validation of `SemSystemProperties` write permission and About Phone image cache |
| Galaxy AI / Now Brief / Picture remaster / Audio eraser | Existing platform/Paradigm adaptations; require functional hardware/app testing |
| Pure Black | Build-time Samsung SystemUI dark-background patch already present; not a dynamic toggle |
| Keep SSRM multi-windows | Build-time `framework.jar` policy already present; not a dynamic toggle |
| GM Kernel / ChargeMax V3 | User kernel `r8s-unica-full-20261101`, charging changes on by default; no unverified extra +500 mA/+3 °C |

## Required validation before calling the unified Hub functional

1. Compile `SecSettings.apk` against **S926BXXSGDZG1** and inspect AAPT resources and Smali/Dex errors.
2. Confirm nested Settings fragments open without `isValidFragment` rejection or `NoSuchMethodError`.
3. Verify 60/120-Hz refresh behavior on both r8s panels. Implement capability probe before enabling EA8079-only 96 Hz in the Hub.
4. Check Core Mode backup/restore, restart behavior, animation scaling, and power-saving mode.
5. Check battery sysfs units and thermal zones on the real Exynos 990. Never present raw thermal zone indices as certain CPU/GPU sensor identities.
6. Validate permissions for Bluetooth, telemetry and app-management APIs **before** exposing them.
7. Verify other ROM features, charging safety, camera, fingerprint, GPU, LTE, Wi-Fi and audio on the phone.

## Build and review

- ROM branch: `edugrepo1-jpg/UN1CA_y2slte:r8s-artisan-port-20261101`.
- Kernel branch: `edugrepo1-jpg/android_kernel_samsung_exynos990:r8s-unica-full-20261101`.
- Draft PR: https://github.com/edugrepo1-jpg/UN1CA_y2slte/pull/1
- Static check: `python3 -m unittest discover -s tests -p 'test_r8s*.py' -v`
- Real ROM build: GitHub Actions > Build > branch > `compile` (no publishing).
