# SPDX-License-Identifier: GPL-3.0-or-later
SKIPUNZIP=1

if [[ "$TARGET_CODENAME" != "r8s" || "$SOURCE_PLATFORM_SDK_VERSION" -lt 36 ]]; then
    return 0
fi

# No copied/older SystemUI: patch Samsung S926BXXSGDZG1 in place.
DECODE_APK "system_ext" "priv-app/SystemUI/SystemUI.apk" || return 1
python3 "$SRC_DIR/target/r8s/apply_pure_black.py" \
    "$APKTOOL_DIR/system_ext/priv-app/SystemUI/SystemUI.apk" || return 1
LOG "- Applied Samsung Pure Black dark-only SystemUI resource mapping"
