"""Regression checks for declaration-aware GM HUB Smali patch helper.

The old pipeline could accept method names mentioned only in invoke statements,
and emitted Broken pipe warnings. Simulated Smali classes ensure that the
helper patches the exact method declaration and preserves unrelated methods.
"""
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
HELPER = ROOT / "scripts/utils/smali_utils.sh"


class SmaliMethodValidationTests(unittest.TestCase):
    def run_helper(self, class_text: str, operation: str, method: str, value: str = ""):
        with tempfile.TemporaryDirectory() as tmp:
            f = Path(tmp) / (
                "system/framework/services.jar/smali_classes2/com/example/Test.smali"
            )
            f.parent.mkdir(parents=True)
            f.write_text(class_text, encoding="utf-8")
            script = (
                "set -e\n"
                f"APKTOOL_DIR={tmp!r}\n"
                "_CHECK_NON_EMPTY_PARAM() { test -n \"$2\"; }\n"
                "IS_VALID_PARTITION_NAME() { [[ \"$1\" == system ]]; }\n"
                "DECODE_APK() { return 0; }\n"
                "LOG() { :; }\n"
                "LOGE() { echo \"LOGE:$*\" >&2; }\n"
                f"source {str(HELPER)!r}\n"
                "SMALI_PATCH system system/framework/services.jar "
                "smali_classes2/com/example/Test.smali "
                f"{operation} '{method}' '{value}'\n"
            )
            r = subprocess.run(
                ["bash", "-c", script], text=True, capture_output=True
            )
            return r, f.read_text(encoding="utf-8")

    def test_declared_void_method_can_be_nullified(self):
        original = (
            ".class public Lcom/example/Test;\n"
            ".method public foo()V\n"
            "    .locals 1\n"
            "    return-void\n"
            ".end method\n"
        )
        result, transformed = self.run_helper(original, "null", "foo()V")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(".method public foo()V", transformed)
        self.assertIn(".locals 0", transformed)
        self.assertIn("return-void", transformed)

    def test_invocation_is_not_mistaken_for_a_method_declaration(self):
        original = (
            ".class public Lcom/example/Test;\n"
            ".method public bar()V\n"
            "    .locals 0\n"
            "    invoke-virtual {p0}, Lcom/example/Test;->foo()V\n"
            "    return-void\n"
            ".end method\n"
        )
        result, transformed = self.run_helper(original, "null", "foo()V")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("not found", result.stderr)
        self.assertEqual(original, transformed)

    def test_static_method_uses_v_register_not_p0(self):
        original = (
            ".class public Lcom/example/Test;\n"
            ".method public static getAvailabilityStatus()I\n"
            "    .locals 1\n"
            "    const/4 v0, 0x0\n"
            "    return v0\n"
            ".end method\n"
        )
        result, transformed = self.run_helper(
            original, "return", "getAvailabilityStatus()I", "3"
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("const/4 v0, 0x3", transformed)
        self.assertIn("return v0", transformed)


if __name__ == "__main__":
    unittest.main()
