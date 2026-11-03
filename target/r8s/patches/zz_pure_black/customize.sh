# SPDX-License-Identifier: GPL-3.0-or-later
SKIPUNZIP=1

if [[ "$TARGET_CODENAME" != "r8s" || "$SOURCE_PLATFORM_SDK_VERSION" -lt 36 ]]; then
    return 0
fi

# Patch Samsung One UI 9 S926BXXSIEZJ1 directly. Enumerate resource map
# and preserve a diagnostic report on the build runner.
DECODE_APK "system_ext" "priv-app/SystemUI/SystemUI.apk" || return 1
python3 "$SRC_DIR/target/r8s/apply_pure_black.py" \
    "$APKTOOL_DIR/system_ext/priv-app/SystemUI/SystemUI.apk" \
    --report "$OUT_DIR/gmhub-oneui9-pure-black-resources.txt" || return 1
LOG "- Applied GM HUB Pure Black dark-only SystemUI background overrides"
