"""Sensor adaptation must not corrupt shared registers or other biometric flags."""
import importlib.util
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('sensor_flags', ROOT / 'target/r8s/patch_biometric_sensor_flags.py')
flags = importlib.util.module_from_spec(spec)
spec.loader.exec_module(flags)

SAMPLE = f'''.class public final {flags.CLASS}
.super Ljava/lang/Object;
.field public static final FP_FEATURE_SENSOR_IS_OPTICAL:Z
.field public static final FP_FEATURE_SENSOR_IS_ULTRASONIC:Z
.field public static final OTHER_FLAG:Z
.method static constructor <clinit>()V
    .locals 7
    const/4 v2, 0x1
    sput-boolean v2, {flags.CLASS}->FP_FEATURE_SENSOR_IS_OPTICAL:Z
    sput-boolean v2, {flags.CLASS}->OTHER_FLAG:Z
    const/4 v0, 0x0
    sput-boolean v0, {flags.CLASS}->FP_FEATURE_SENSOR_IS_ULTRASONIC:Z
    return-void
.end method
'''


class SensorFlagTests(unittest.TestCase):
    def test_old_donor_registers_and_other_flags_remain_unchanged(self):
        result, changed = flags.patch_text(SAMPLE)
        self.assertTrue(changed)
        self.assertIn('const/4 v2, 0x1', result)
        self.assertIn(f'sput-boolean v2, {flags.CLASS}->OTHER_FLAG:Z', result)
        self.assertIn('.locals 8', result)
        self.assertIn('const-string v7, "optical"', result)
        self.assertIn('const-string v7, "ultrasonic"', result)
        self.assertIn(flags.FEATURE, result)
        self.assertEqual(flags.patch_text(result), (result, False))

    def test_register_numbering_does_not_depend_on_api36_hunk(self):
        result, changed = flags.patch_text(SAMPLE.replace('.locals 7', '.locals 28'))
        self.assertTrue(changed)
        self.assertIn('invoke-static/range {v28 .. v28}', result)
        self.assertIn('.locals 29', result)

    def test_missing_or_ambiguous_assignment_is_rejected(self):
        store = f'    sput-boolean v0, {flags.CLASS}->FP_FEATURE_SENSOR_IS_ULTRASONIC:Z\n'
        for source in (SAMPLE.replace(store, ''), SAMPLE.replace(store, store + store)):
            with self.subTest(source=source), self.assertRaisesRegex(ValueError, 'one native initializer assignment'):
                flags.patch_text(source)

    def test_unknown_constant_field_layout_is_not_silently_modified(self):
        source = SAMPLE.replace('FP_FEATURE_SENSOR_IS_OPTICAL:Z\n', 'FP_FEATURE_SENSOR_IS_OPTICAL:Z = 0x0\n', 1)
        with self.assertRaisesRegex(ValueError, 'field declaration'):
            flags.patch_text(source)

    def test_android17_r8s_build_uses_adapter_and_keeps_legacy_branch(self):
        source = (ROOT / 'unica/patches/product_feature/customize.sh').read_text(encoding='utf-8')
        self.assertIn('patch_biometric_sensor_flags.py', source)
        self.assertIn('fingerprint/optical_fod/services.jar/0001-Add-optical-FOD-support.patch', source)


if __name__ == '__main__':
    unittest.main()
