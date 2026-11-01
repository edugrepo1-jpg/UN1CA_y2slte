#!/usr/bin/env python3
"""Static source contracts for the r8s UN1CA port.

These checks do NOT prove successful firmware extraction, patched APK/Dex
compatibility, correct boot, charging performance or thermal behavior.
"""
import ast
from pathlib import Path
import re
import subprocess
import unittest
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]


def source(path):
    return (ROOT / path).read_text(encoding="utf-8")


class R8sSourceContracts(unittest.TestCase):
    def test_stock_device_and_boot_geometry(self):
        conf = source("target/r8s/config.sh")
        self.assertIn('TARGET_ASSERT_MODEL=("SM-G780F")', conf)
        self.assertIn("TARGET_BOOT_PARTITION_SIZE=61865984", conf)
        self.assertIn("TARGET_PLATFORM_SDK_VERSION=33", conf)
        self.assertIn('TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE="60,96,120"', conf)
        self.assertIn('TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE_NS="60"', conf)

    def test_preserve_original_one_ui_donor(self):
        conf = source("unica/configs/essi.sh")
        self.assertIn('SOURCE_FIRMWARE_VERSION="S926BXXSGDZG1/', conf)
        self.assertIn("SOURCE_PLATFORM_SDK_VERSION=36", conf)
        self.assertIn("SOURCE_USE_NATIVE_DISPLAY_STACK=true", conf)
        self.assertIn("SOURCE_USE_NATIVE_FINGERPRINT_UI=true", conf)

    def test_full_gm_kernel_fork_is_pinned(self):
        script = source("platform/exynos990/patches/extremekrnl/r8s-own-kernel.sh")
        self.assertIn("edugrepo1-jpg/android_kernel_samsung_exynos990.git", script)
        self.assertIn('R8S_GM_KERNEL_BRANCH="r8s-unica-full-20261101"', script)
        self.assertRegex(script, r'R8S_GM_KERNEL_SHA="[a-f0-9]{40}"')
        self.assertIn('R8S_GM_KERNEL_SHA="b1d26ec2d933696f5d3ec25fa02965456d50ac1d"', script)
        self.assertIn("./build.sh -m r8s -k y -r n", script)
        self.assertIn("61865984", script)
        self.assertIn("0xD7B7AB1E", script)
        self.assertIn("expected = [(0, 1), (2, 4), (5, 255)]", script)

    def test_only_r8s_uses_our_kernel(self):
        customize = source("platform/exynos990/patches/extremekrnl/customize.sh")
        self.assertIn('if [[ "$TARGET_CODENAME" == "r8s" ]]; then', customize)
        self.assertIn('source "$SRC_DIR/platform/exynos990/patches/extremekrnl/r8s-own-kernel.sh"', customize)
        self.assertIn("At30c/SSM_990v2BYEXTREME", customize)

    def test_camera_keeps_unica_configuration(self):
        content = source("target/r8s/camera/camera-feature.xml")
        root = ET.fromstring(content)
        values = {e.get("name"): e.get("value") for e in root.findall("local")}
        self.assertEqual(values.get("BACK_WIDE_CAMERA_ID"), "2")
        self.assertEqual(values.get("BACK_TELE_CAMERA_ID"), "50")
        self.assertTrue(any(e.get("name") == "SHOOTING_MODE_PRO_VIDEO" for e in root.findall("local")))
        self.assertTrue(any(e.get("name") == "SHOOTING_MODE_SUPER_SLOW_MOTION" for e in root.findall("local")))

    def test_r8s_display_and_framework_patches_are_gated(self):
        self.assertIn("SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE=60,96,120",
                      source("target/r8s/sff.sh"))
        self.assertIn("0002-Backport-SehLights-with-VintfHalCache.patch",
                      source("unica/patches/legacy/customize.sh"))
        self.assertIn("0002-Read-optical-sensor-feature-in-native-UI.patch",
                      source("unica/patches/product_feature/customize.sh"))
        self.assertIn("TARGET_CODENAME", source("target/r8s/patches/graphics_v6/customize.sh"))
        self.assertIn("ART", source("target/r8s/optimize_biometric_dexopt.py"))

    def test_release_targets_owned_fork(self):
        workflow = source(".github/workflows/build.yml")
        self.assertNotIn("ArtisanROM/rom_resources", workflow)
        self.assertIn('RELEASE_REPO: "${{ github.repository }}"', workflow)
        self.assertIn('GH_TOKEN: ${{ github.token }}', workflow)
        self.assertNotIn("    branches:\n      - 'sixteen'", workflow)
        self.assertIn("target: [r8s]", workflow)

    def test_python_sources_are_parseable(self):
        paths = [
            "target/r8s/optimize_biometric_dexopt.py",
            "target/r8s/optimize_systemui_diagnostics.py",
            "target/r8s/validate_graphics_dso.py",
        ]
        for path in paths:
            with self.subTest(path=path):
                ast.parse(source(path), filename=path)

    def test_shell_sources_are_parseable(self):
        paths = [
            "platform/exynos990/patches/extremekrnl/customize.sh",
            "platform/exynos990/patches/extremekrnl/r8s-own-kernel.sh",
            "unica/patches/product_feature/customize.sh",
            "unica/patches/legacy/customize.sh",
            "unica/patches/__floating_feature/customize.sh",
            "unica/patches/product_feature/audio/virtual_vib/disable_native.sh",
            "target/r8s/patches/graphics_v6/customize.sh",
            "target/r8s/patches/hfr/customize.sh",
            "target/r8s/patches/zz_biometric_dexopt/customize.sh",
            "target/r8s/patches/zz_sysui_diagnostics/customize.sh",
        ]
        for path in paths:
            with self.subTest(path=path):
                result = subprocess.run(
                    ["bash", "-n", str(ROOT / path)],
                    capture_output=True,
                    text=True,
                    check=False,
                )
                self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == "__main__":
    unittest.main()
