# SPDX-License-Identifier: GPL-3.0-or-later
# GM HUB r8s: Android 17 (EZJ1) virtual vibration *sound* compatibility.
# Preserve Samsung's native haptic service, Bluetooth routing, methods,
# synthetic lambdas and constructors. Do not apply the old 10-class patch
# (written for a different services.jar) to One UI 9.
#
# Requirements: SOURCE_AUDIO_SUPPORT_VIRTUAL_VIBRATION_SOUND=true,
# TARGET_AUDIO_SUPPORT_VIRTUAL_VIBRATION_SOUND=false, API >= 37.
# This script intentionally fails closed when a sound helper is referenced
# but its implementation/method contract cannot be identified.

DECODE_APK "system" "system/framework/services.jar" || return 1
R8S_VIB_ROOT="$APKTOOL_DIR/system/framework/services.jar"
R8S_VIB_HELPER="$(find "$R8S_VIB_ROOT" -type f \
    -path '*/com/android/server/vibrator/VirtualVibSoundHelper.smali' -printf '%P\n')"
if [[ "$R8S_VIB_HELPER" == *$'\n'* ]]; then
    ABORT "More than one VirtualVibSoundHelper found in EZJ1 services.jar"
fi

if [[ -z "$R8S_VIB_HELPER" ]]; then
    # Some API 37 releases remove the helper entirely. Do not inject a
    # fictitious class: first verify no existing code references it.
    if grep -R -l -F 'Lcom/android/server/vibrator/VirtualVibSoundHelper;' \
         "$R8S_VIB_ROOT"/smali* >/dev/null 2>&1; then
        ABORT "EZJ1 references VirtualVibSoundHelper but its class is missing"
    fi
    LOG "- GM HUB: EZJ1 lacks legacy virtual-vibration sound helper; no framework rewrite needed"
else
    R8S_VIB_CLASS="$R8S_VIB_ROOT/$R8S_VIB_HELPER"
    for R8S_VIB_METHOD in \
        'playVirtualSoundIfNeeded(Ljava/lang/String;Landroid/os/VibrationAttributes;Z)V' \
        'stopVirtualSound(Ljava/lang/String;)V'; do
        if ! grep -E '^\.method[[:space:]]' "$R8S_VIB_CLASS" | \
                grep -Fq -- "$R8S_VIB_METHOD"; then
            LOGE "GM HUB: missing API37 virtual vibration method: $R8S_VIB_METHOD"
            grep -E '^\.method[[:space:]]' "$R8S_VIB_CLASS" || true
            ABORT "Cannot safely disable virtual vibration sound in One UI 9 without exact method"
        fi
    done

    SMALI_PATCH "system" "system/framework/services.jar" "$R8S_VIB_HELPER" \
        "null" "playVirtualSoundIfNeeded(Ljava/lang/String;Landroid/os/VibrationAttributes;Z)V" || return 1
    SMALI_PATCH "system" "system/framework/services.jar" "$R8S_VIB_HELPER" \
        "null" "stopVirtualSound(Ljava/lang/String;)V" || return 1
    LOG "- GM HUB: disabled only EZJ1 virtual-vibration sound playback and stop callbacks"
fi

# Samsung Settings may move/delete this preference controller between One
# UI 8.5 and 9. Suppress the UI only when this precise method still exists.
DECODE_APK "system" "system/priv-app/SecSettings/SecSettings.apk" || return 1
R8S_VIB_SETTINGS_ROOT="$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk"
R8S_VIB_CONTROLLER="$(find "$R8S_VIB_SETTINGS_ROOT" -type f \
    -path '*/com/samsung/android/settings/asbase/vibration/VirtualVibrationSoundPreferenceController.smali' \
    -printf '%P\n')"
if [[ "$R8S_VIB_CONTROLLER" == *$'\n'* ]]; then
    ABORT "More than one virtual vibration Settings controller found"
elif [[ -z "$R8S_VIB_CONTROLLER" ]]; then
    LOG "- GM HUB: One UI 9 has no legacy virtual-vibration Settings controller"
elif grep -E '^\.method[[:space:]]' "$R8S_VIB_SETTINGS_ROOT/$R8S_VIB_CONTROLLER" | \
        grep -Fq 'getAvailabilityStatus()I'; then
    SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
        "$R8S_VIB_CONTROLLER" "return" "getAvailabilityStatus()I" "3" || return 1
    LOG "- GM HUB: hidden unsupported virtual-vibration sound setting"
else
    LOG "- GM HUB: One UI 9 controller has a new availability method; leaving native Settings class intact"
fi

# Keeping the donor's SettingsProvider migration prevents corrupting the
# settings database. Non-sound vibration hardware is unaffected.
unset R8S_VIB_ROOT R8S_VIB_HELPER R8S_VIB_CLASS R8S_VIB_METHOD
unset R8S_VIB_SETTINGS_ROOT R8S_VIB_CONTROLLER
