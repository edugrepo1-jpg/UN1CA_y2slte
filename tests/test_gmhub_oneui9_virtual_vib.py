"""One UI 9 virtual-vibration source/contract checks for r8s.

Samsung EZJ1 framework differs from the older patch; avoid removing Bluetooth,
audio routing, vendor haptics or Android 17 synthetic lambda classes.
These fixture tests check control flow and fail-closed behavior. They DO NOT
prove that the actual EZJ1 APK has the same class names or method signatures.
"""
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SHELL = ROOT / "unica/patches/product_feature/audio/virtual_vib/disable_native.sh"
PRODUCT = ROOT / "unica/patches/product_feature/customize.sh"


class VirtualVibCompatibilityTests(unittest.TestCase):
    def test_bash_syntax_and_r8s_sdk37_gate(self):
        for script in (SHELL, PRODUCT):
            proc = subprocess.run(
                ["bash", "-n", str(script)], text=True, capture_output=True
            )
            self.assertEqual(proc.returncode, 0, proc.stderr)
        code = PRODUCT.read_text(encoding="utf-8")
        self.assertIn('"$TARGET_CODENAME" == "r8s"', code)
        self.assertIn('"$SOURCE_PLATFORM_SDK_VERSION" -ge 37', code)
        self.assertIn(
            '. "$MODPATH/audio/virtual_vib/disable_native.sh" || return 1',
            code,
        )
        self.assertLess(
            code.index('audio/virtual_vib/disable_native.sh'),
            code.index('audio/virtual_vib/services.jar/0001-Disable-virtual-vibration'),
        )

    def test_no_destructive_bluetooth_or_vibrator_removal(self):
        script = SHELL.read_text(encoding="utf-8")
        self.assertIn("VirtualVibSoundHelper.smali", script)
        self.assertIn(
            "playVirtualSoundIfNeeded(Ljava/lang/String;Landroid/os/VibrationAttributes;Z)V",
            script,
        )
        self.assertIn('stopVirtualSound(Ljava/lang/String;)V', script)
        self.assertIn('"null"', script)
        self.assertIn('getAvailabilityStatus()I', script)
        self.assertNotIn('"remove"', script)
        self.assertNotIn('BtHelper\\$\\$ExternalSyntheticLambda', script)
        self.assertNotIn('VibratorManagerInternal.smali', script)

    def invoke_with_fixture(self, helper: bool, methods: bool = True):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            smali = root / "system/framework/services.jar/smali_classes2"
            smali.mkdir(parents=True)
            helper_path = (
                smali / "com/android/server/vibrator/VirtualVibSoundHelper.smali"
            )
            helper_path.parent.mkdir(parents=True)
            if helper:
                helper_path.write_text(
                    ".class public Lcom/android/server/vibrator/VirtualVibSoundHelper;\n"
                    + (
                        ".method public playVirtualSoundIfNeeded("
                        "Ljava/lang/String;Landroid/os/VibrationAttributes;Z)V\n"
                        ".end method\n"
                        ".method public stopVirtualSound(Ljava/lang/String;)V\n"
                        ".end method\n"
                        if methods else
                        ".method public changedAudioMethod()V\n.end method\n"
                    ),
                    encoding="utf-8",
                )
            settings = (
                root / "system/priv-app/SecSettings/SecSettings.apk/smali"
                "/com/samsung/android/settings/asbase/vibration"
            )
            settings.mkdir(parents=True)
            (settings / "VirtualVibrationSoundPreferenceController.smali").write_text(
                ".method public getAvailabilityStatus()I\n.end method\n",
                encoding="utf-8",
            )
            # The two helpers call simulated SMALI_PATCH methods. Test the
            # dispatch contract without modifying any actual donor files.
            bash = (
                "set -euo pipefail\n"
                f"APKTOOL_DIR={str(root)!r}\n"
                "DECODE_APK() { return 0; }\n"
                "LOG() { :; }\n"
                "LOGE() { echo \"LOGE:$*\" >&2; }\n"
                "ABORT() { echo \"ABORT:$*\" >&2; exit 95; }\n"
                "SMALI_PATCH() { printf '%s|%s|%s\n' \"$3\" \"$4\" \"$5\"; }\n"
                f"source {str(SHELL)!r}\n"
            )
            return subprocess.run(
                ["bash", "-c", bash], text=True, capture_output=True
            )

    def test_helper_with_exact_methods_is_nullified_by_contract(self):
        result = self.invoke_with_fixture(helper=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("playVirtualSoundIfNeeded", result.stdout)
        self.assertIn("|null|", result.stdout)
        self.assertIn("getAvailabilityStatus()I", result.stdout)

    def test_missing_legacy_helper_can_be_omitted(self):
        result = self.invoke_with_fixture(helper=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("playVirtualSoundIfNeeded", result.stdout)
        self.assertIn("getAvailabilityStatus()I", result.stdout)

    def test_changed_method_aborts_instead_of_breaking_android17(self):
        result = self.invoke_with_fixture(helper=True, methods=False)
        self.assertEqual(result.returncode, 95)
        self.assertIn("missing API37 virtual vibration method", result.stderr)


if __name__ == "__main__":
    unittest.main()
