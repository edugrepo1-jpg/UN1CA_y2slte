SKIPUNZIP=1
# No firmware, kernel, compositor or player replacement. This hook is specific
# to the audited r8s API37 donor; other targets retain their original renderer.
if [[ "$TARGET_CODENAME" == "r8s" ]]; then
    DECODE_APK "system_ext" "priv-app/SystemUI/SystemUI.apk"
    python3 "$MODPATH/install.py" "$APKTOOL_DIR/system_ext/priv-app/SystemUI/SystemUI.apk" || \
        ABORT "GM Hub Liquid Glass integration contract failed"
    SET_PROP "system" "ro.gmhub.glass.renderers" "3"
fi
