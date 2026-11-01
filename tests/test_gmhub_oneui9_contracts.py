"""One UI 9 GM HUB Android 17 / Exynos990 source readiness checks."""
import ast
import pathlib
import re
import subprocess
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]


def contents(path):
    return (ROOT / path).read_text(encoding="utf-8")


class OneUI9BuildContracts(unittest.TestCase):
    def test_android17_official_donor(self):
        cfg = contents("unica/configs/essi.sh")
        self.assertIn("SOURCE_PLATFORM_SDK_VERSION=37", cfg)
        self.assertIn('SOURCE_FIRMWARE="SM-S926B/EUX/350330051234562"', cfg)
        self.assertIn('SOURCE_FIRMWARE_VERSION="S926BXXSIEZJ1/S926BOXMIEZJ1/S926BXXSIEZJ1"', cfg)
        self.assertNotIn('SOURCE_FIRMWARE_VERSION=""', cfg)

    def test_stock_r8s_boot_vendor_geometry(self):
        cfg = contents("target/r8s/config.sh")
        self.assertIn('TARGET_ASSERT_MODEL=("SM-G780F")', cfg)
        self.assertIn("TARGET_PLATFORM_SDK_VERSION=33", cfg)
        self.assertIn("TARGET_BOOT_PARTITION_SIZE=61865984", cfg)
        self.assertIn('TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE="60,96,120"', cfg)

    def test_gmkernel_and_android17_backports(self):
        shell = contents("platform/exynos990/patches/extremekrnl/customize.sh")
        self.assertIn('GMKERNEL_BRANCH="gmkernel-android17-r8s-20261101"', shell)
        self.assertIn('GMKERNEL_SHA="0ac4cc0d535e67fd0ab6a822f303acef1377300f"', shell)
        self.assertIn("edugrepo1-jpg/android_kernel_samsung_exynos990.git", shell)
        self.assertIn("GMKernel r8s DTBO", shell)
        self.assertIn("APPLY_KERNEL_PATCHES", shell)
        for index in range(1, 4):
            patches = sorted((ROOT / "platform/exynos990/patches/extremekrnl/patches").glob(f"000{index}-*.patch"))
            self.assertEqual(len(patches), 1)
        ast.parse(contents("target/r8s/validate_gmkernel_dtbo.py"))

    def test_never_publish_unvalidated_ports(self):
        workflow = contents(".github/workflows/build.yml")
        self.assertIn("target: [r8s]", workflow)
        self.assertIn("compile", workflow)
        self.assertNotIn("ArtisanROM/rom_resources", workflow)
        self.assertNotIn("S24+_ONEUI9_ZZHL-ZZI4", workflow)
        self.assertNotIn("1vmVtu542y3ORsmj_yNsWA0k2Z5x77JDI", workflow)

    def test_scripts_valid_shell(self):
        scripts = [
            "platform/exynos990/patches/extremekrnl/customize.sh",
            "unica/mods/settings/customize.sh",
            "unica/patches/product_feature/customize.sh",
            "unica/patches/legacy/customize.sh",
        ]
        for script in scripts:
            with self.subTest(script=script):
                result = subprocess.run(["bash", "-n", str(ROOT / script)], capture_output=True, text=True)
                self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == "__main__":
    unittest.main()
