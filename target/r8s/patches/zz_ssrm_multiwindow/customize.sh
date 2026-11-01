# SPDX-License-Identifier: GPL-3.0-or-later
SKIPUNZIP=1

if [[ "$TARGET_CODENAME" != "r8s" || "$SOURCE_PLATFORM_SDK_VERSION" -lt 36 ]]; then
    return 0
fi

# Derive the exact method from the pinned Android 17 S926BXXSIEZJ1 framework
# and modify only SSRM's request to disable multi-window. Do not alter thermal
# sensor readings, SIOP, CPU/GPU frequency limits or battery protection.
DECODE_APK "system" "system/framework/framework.jar" || return 1
python3 "$SRC_DIR/target/r8s/patch_ssrm_multiwindow.py" \
    "$APKTOOL_DIR/system/framework/framework.jar" || return 1
LOG "- Guarded SSRM-only multi-window disable, preserving safety throttles"
