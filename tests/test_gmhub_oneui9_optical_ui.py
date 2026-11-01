"""Check the native optical capability adaptation without transplanting UI."""
import importlib.util
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('optical_ui', ROOT / 'target/r8s/patch_optical_fingerprint_ui.py')
optical = importlib.util.module_from_spec(spec)
spec.loader.exec_module(optical)

ORIGINAL = '''.class public Lcom/android/systemui/util/DeviceType;
.super Ljava/lang/Object;
.field private static supportOpticalFingerprint:I = -0x1
.method public static isOpticalFingerprintSupported()Z
    .locals 3
    sget v0, Lcom/android/systemui/util/DeviceType;->supportOpticalFingerprint:I
    const/4 v1, -0x1
    const/4 v2, 0x0
    if-ne v0, v1, :cond_0
    sput v2, Lcom/android/systemui/util/DeviceType;->supportOpticalFingerprint:I
    :cond_0
    sget v0, Lcom/android/systemui/util/DeviceType;->supportOpticalFingerprint:I
    const/4 v1, 0x1
    if-ne v0, v1, :cond_1
    return v1
    :cond_1
    return v2
.end method
'''


class OpticalUiTests(unittest.TestCase):
    def test_native_cache_reads_target_feature_and_is_idempotent(self):
        changed, did_change = optical.patch_text(ORIGINAL)
        self.assertTrue(did_change)
        self.assertIn(optical.FEATURE, changed)
        self.assertIn('->contains(Ljava/lang/CharSequence;)Z', changed)
        self.assertEqual(optical.patch_text(changed), (changed, False))

    def test_changed_control_flow_is_not_rewritten(self):
        changed = ORIGINAL.replace('return v1', 'invoke-static {}, Lcom/example/Other;->action()V\n    return v1')
        with self.assertRaisesRegex(ValueError, 'different control flow'):
            optical.patch_text(changed)

    def test_native_r8s_flow_actually_calls_the_adapter(self):
        source = (ROOT / 'unica/patches/product_feature/customize.sh').read_text(encoding='utf-8')
        block = source[source.index('if $PRESERVE_NATIVE_FINGERPRINT_UI; then'):]
        self.assertIn('"$TARGET_CODENAME" == "r8s"', block)
        self.assertIn('target/r8s/patch_optical_fingerprint_ui.py', block)
        self.assertIn('"$APKTOOL_DIR/system_ext/priv-app/SystemUI/SystemUI.apk" || return 1', block)


if __name__ == '__main__':
    unittest.main()
