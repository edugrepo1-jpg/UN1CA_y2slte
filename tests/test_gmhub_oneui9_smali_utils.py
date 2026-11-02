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
    def test_abstract_or_native_method_cannot_receive_an_invalid_body(self):
        for modifier, operation, signature in (
            ('abstract', 'null', 'event()V'),
            ('native', 'return', 'count()I'),
        ):
            with self.subTest(modifier=modifier):
                original = ('.class public Lcom/example/Test;\n'
                            f'.method public {modifier} {signature}\n.end method\n')
                result, transformed = self.run_helper(original, operation, signature, '1')
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('native/abstract', result.stderr)
                self.assertEqual(original, transformed)

    def test_constructor_cannot_return_without_super_initialization(self):
        original = ('.class public Lcom/example/Test;\n'
                    '.super Ljava/lang/Object;\n'
                    '.method public constructor <init>()V\n    .locals 0\n'
                    '    invoke-direct {p0}, Ljava/lang/Object;-><init>()V\n'
                    '    return-void\n.end method\n')
        result, transformed = self.run_helper(original, 'null', '<init>()V')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('constructor initialization', result.stderr)
        self.assertEqual(original, transformed)

    def test_strip_preserves_immediately_adjacent_method(self):
        other = ('.method public bar()V\n'
                 '    .locals 0\n    return-void\n.end method\n')
        original = ('.class public Lcom/example/Test;\n'
                    '.super Ljava/lang/Object;\n'
                    '.method public foo()V\n'
                    '    .locals 0\n    return-void\n.end method\n' + other)
        result, transformed = self.run_helper(original, 'strip', 'foo()V')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('.method public foo()V', transformed)
        self.assertIn(other, transformed)

    def run_helper(self, class_text: str, operation: str, method: str, value: str = ""):
        with tempfile.TemporaryDirectory() as tmp:
            f = Path(tmp) / (
                "system/framework/services.jar/smali_classes2/com/example/Test.smali"
            )
            f.parent.mkdir(parents=True)
            f.write_text(class_text, encoding="utf-8")
            script = (
                "set -e\n"
                f"SRC_DIR={ROOT.as_posix()!r}\n"
                f"APKTOOL_DIR={Path(tmp).as_posix()!r}\n"
                "_CHECK_NON_EMPTY_PARAM() { test -n \"$2\"; }\n"
                "IS_VALID_PARTITION_NAME() { [[ \"$1\" == system ]]; }\n"
                "DECODE_APK() { return 0; }\n"
                "LOG() { :; }\n"
                "LOGE() { echo \"LOGE:$*\" >&2; }\n"
                f"source {HELPER.as_posix()!r}\n"
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

    def test_method_suffix_does_not_match_a_different_declaration(self):
        original = (
            ".class public Lcom/example/Test;\n"
            ".method public prefixfoo()V\n"
            "    .locals 0\n    return-void\n.end method\n"
        )
        result, transformed = self.run_helper(original, "null", "foo()V")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(original, transformed)

    def test_only_exact_method_is_changed(self):
        other = ".method public prefixfoo()V\n    .locals 1\n    return-void\n.end method\n"
        original = (
            ".class public Lcom/example/Test;\n" + other
            + ".method public foo()V\n    .locals 1\n    return-void\n.end method\n"
        )
        result, transformed = self.run_helper(original, "null", "foo()V")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(other, transformed)

    def test_static_wide_return_has_two_locals_and_correct_constant_width(self):
        for signature, value, instruction in (
            ("counter()J", "65536", "const-wide/32 v0, 0x10000"),
            ("ratio()D", "0x3ff0000000000000", "const-wide v0, 0x3ff0000000000000"),
        ):
            with self.subTest(signature=signature):
                original = (
                    ".class public Lcom/example/Test;\n"
                    f".method public static {signature}\n"
                    "    .locals 2\n    const-wide/16 v0, 0x0\n"
                    "    return-wide v0\n.end method\n"
                )
                result, transformed = self.run_helper(original, "return", signature, value)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn(".locals 2", transformed)
                self.assertIn(instruction, transformed)
                self.assertIn("return-wide v0", transformed)
                if signature.endswith('D'):
                    self.assertIn('0x3ff0000000000000L', transformed)

    def test_negative_integer_is_a_signed_smali_literal(self):
        original = (
            '.class public Lcom/example/Test;\n'
            '.method public static count(II)I\n'
            '    .locals 1\n    const/4 v0, 0x0\n'
            '    return v0\n.end method\n'
        )
        result, transformed = self.run_helper(original, 'return', 'count(II)I', '-8')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('const/4 v0, -0x8', transformed)

    def test_primitive_array_uses_object_return(self):
        original = (
            ".class public Lcom/example/Test;\n"
            ".method public static values()[I\n"
            "    .locals 1\n    const/4 v0, 0x0\n"
            "    return-object v0\n.end method\n"
        )
        result, transformed = self.run_helper(original, "return", "values()[I", "null")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("return-object v0", transformed)

    def test_large_integer_uses_full_width_constant(self):
        original = (
            ".class public Lcom/example/Test;\n"
            ".method public count()I\n"
            "    .locals 1\n    const/4 v0, 0x0\n"
            "    return v0\n.end method\n"
        )
        result, transformed = self.run_helper(original, "return", "count()I", "65536")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("const v0, 0x10000", transformed)

    def test_reapplying_null_method_succeeds(self):
        original = (
            ".class public Lcom/example/Test;\n"
            ".method public foo()V\n"
            "    .locals 0\n    \n    return-void\n.end method\n"
        )
        result, transformed = self.run_helper(original, "null", "foo()V")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(original, transformed)


if __name__ == "__main__":
    unittest.main()
