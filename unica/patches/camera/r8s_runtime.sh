# Adapt the proven r8s camera fixes to the native Android 17 package.
# Never replace the donor APK, modern manifest or obfuscated UI classes.
if [[ "$TARGET_CODENAME" == "r8s" && "$SOURCE_PLATFORM_SDK_VERSION" -ge 37 ]]; then
    DECODE_APK "system" "system/priv-app/SamsungCamera/SamsungCamera.apk" || return 1
    R8S_CAMERA="$APKTOOL_DIR/system/priv-app/SamsungCamera/SamsungCamera.apk"
    python3 "$SRC_DIR/target/r8s/patch_camera_resolutions.py" "$R8S_CAMERA" \
        "$WORK_DIR/system/system/cameradata/camera-feature.xml" || return 1

    # The r8s XML exposes Food mode. Its detector must be visible inside the
    # APK namespace as well as system/lib64, as verified on the previous port.
    if [ ! -f "$WORK_DIR/system/system/lib64/libFoodDetector.camera.samsung.so" ]; then
        ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" \
            "system/lib64/libFoodDetector.camera.samsung.so" \
            0 0 644 "u:object_r:system_lib_file:s0" || return 1
    fi
    mkdir -p "$R8S_CAMERA/lib/arm64-v8a" || return 1
    cp -f "$WORK_DIR/system/system/lib64/libFoodDetector.camera.samsung.so" \
        "$R8S_CAMERA/lib/arm64-v8a/" || return 1
    unset R8S_CAMERA
fi
