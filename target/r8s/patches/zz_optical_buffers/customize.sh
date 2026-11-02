# SPDX-License-Identifier: GPL-3.0-or-later
SKIPUNZIP=1

if [[ "$TARGET_CODENAME" != "r8s" || "$SOURCE_PLATFORM_SDK_VERSION" -lt 37 ]]; then
    return 0
fi

python3 "$SRC_DIR/target/r8s/patch_optical_buffers.py" \
    "$WORK_DIR/system/system/lib64/libgui.so" \
    "$WORK_DIR/system/system/lib64/libui.so" || return 1
