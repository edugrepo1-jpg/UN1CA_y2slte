"""Prevent the r8s XML/enum mismatch without transplanting an older camera."""
import importlib.util
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('camera_compat', ROOT / 'target/r8s/patch_camera_resolutions.py')
camera = importlib.util.module_from_spec(spec)
spec.loader.exec_module(camera)

RES, RATIO = camera.RES, camera.RATIO
SAMPLE = f'''.class public final enum {RES}
.super Ljava/lang/Enum;
.field public static final enum RESOLUTION_4032X3024:{RES}
.field private static final synthetic $VALUES:[{RES}
.method static constructor <clinit>()V
    .locals 3
    const/16 v1, 0x7000
    invoke-static {{}}, {RES}->$values()[{RES}
    move-result-object v0
    sput-object v0, {RES}->$VALUES:[{RES}
    invoke-static {{}}, {RES}->values()[{RES}
    move-result-object v0
    return-void
.end method
.method private constructor {camera.CTOR}
    .locals 0
    invoke-direct {{p0, p1, p2}}, Ljava/lang/Enum;-><init>(Ljava/lang/String;I)V
    iput p3, p0, {RES}->mId:I
    iput p4, p0, {RES}->mWidth:I
    iput p5, p0, {RES}->mHeight:I
    iput-object p6, p0, {RES}->mRatio:{RATIO}
    iput p7, p0, {RES}->mMinFps:I
    iput p7, p0, {RES}->mMaxFps:I
    return-void
.end method
'''
RATIOS = f'.class public final enum {RATIO}\n.super Ljava/lang/Enum;\n.field public static final enum RATIO_4x3:{RATIO}\n'
XML = '<features><local name="FRONT_CAMERA_RESOLUTION_SUPER_RESOLUTION" value="6528x4896"/></features>'


class CameraCompatTests(unittest.TestCase):
    def test_hdr_mapping_preserves_other_nodes_and_rejects_missing_native_class(self):
        for complete in (True, False):
            with self.subTest(complete=complete), tempfile.TemporaryDirectory() as tmp:
                root = Path(tmp)
                apk = root / 'system/priv-app/SamsungCamera/SamsungCamera.apk'
                nodes = ['llhdr/arcsoft/ArcLlHdrNodeBase.smali',
                         'mfhdr/arcsoft/v4/ArcMfHdrNode.smali']
                for node in nodes if complete else nodes[:1]:
                    path = apk / 'smali_classes4/com/samsung/android/camera/core2/node' / node
                    path.parent.mkdir(parents=True, exist_ok=True)
                    path.write_text('.class public LFixture;\n', encoding='utf-8')
                output = root / 'mapped.txt'
                script = (
                    'set -e\nTARGET_CODENAME=r8s\nSOURCE_PLATFORM_SDK_VERSION=37\n'
                    f'APKTOOL_DIR={root.as_posix()!r}\n'
                    'DECODE_APK() { return 0; }\nLOG() { :; }\n'
                    'ABORT() { echo "$*" >&2; return 1; }\n'
                    'GET_FLOATING_FEATURE_CONFIG() { printf "%s" "llhdr.mpi.v1,mfhdr.mpi.v1,food.samsung.v1"; }\n'
                    f'SET_FLOATING_FEATURE_CONFIG() {{ printf "%s" "$2" > {output.as_posix()!r}; }}\n'
                    f'source {(ROOT / "unica/patches/camera/r8s_hdr.sh").as_posix()!r} || exit 1\n'
                )
                result = subprocess.run(['bash', '-c', script], capture_output=True, text=True)
                if complete:
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertEqual(output.read_text(), 'llhdr.arcsoft.v4,mfhdr.arcsoft.v4,food.samsung.v1')
                else:
                    self.assertNotEqual(result.returncode, 0)
                    self.assertFalse(output.exists())

    def test_adds_only_missing_size_and_preserves_original_id_and_initializer(self):
        changed, missing = camera.patch_text(SAMPLE, RATIOS, XML)
        self.assertEqual(missing, [(6528, 4896)])
        self.assertIn('const/16 v1, 0x7000', changed)
        self.assertIn('const/16 v5, 28673', changed)  # 0x7000 already reserved.
        self.assertIn(f'RESOLUTION_4032X3024:{RES}', changed)
        self.assertIn(f'const/16 v6, 6528', changed)
        self.assertIn(f'const/16 v7, 4896', changed)
        self.assertLess(changed.index('->r8sExtendXmlResolutions('),
                        changed.index('sput-object v0,'))
        self.assertEqual(camera.patch_text(changed, RATIOS, XML), (changed, []))

    def test_native_donor_sizes_are_not_replaced(self):
        native = '<features><local value="4032x3024"/></features>'
        self.assertEqual(camera.patch_text(SAMPLE, RATIOS, native), (SAMPLE, []))

    def test_android17_obfuscated_enums_preserve_descriptors(self):
        source = SAMPLE.replace(RES, 'Ll9/a2;').replace(RATIO, 'Ll9/b;')
        source = source.replace('.method private constructor', '.method public constructor')
        ratio = RATIOS.replace(RATIO, 'Ll9/b;')
        changed, missing = camera.patch_text(source, ratio, XML)
        self.assertEqual(missing, [(6528, 4896)])
        self.assertIn('Ll9/a2;->r8sExtendXmlResolutions([Ll9/a2;)[Ll9/a2;', changed)
        self.assertIn('Ll9/b;->RATIO_4x3:Ll9/b;', changed)
        self.assertNotIn(RES, changed)
        self.assertEqual(camera.patch_text(changed, ratio, XML), (changed, []))

    def test_unknown_dimensions_do_not_invent_hardware_support(self):
        with self.assertRaisesRegex(ValueError, 'Unverified r8s dimensions'):
            camera.patch_text(SAMPLE, RATIOS, XML.replace('6528x4896', '9999x9999'))

    def test_changed_constructor_semantics_are_rejected_before_editing(self):
        changed = SAMPLE.replace('iput p4, p0,', 'iput p5, p0,')
        with self.assertRaisesRegex(ValueError, 'parameter semantics changed'):
            camera.patch_text(changed, RATIOS, XML)

    def test_missing_aspect_ratio_is_rejected(self):
        with self.assertRaisesRegex(ValueError, 'aspect ratio is not available'):
            camera.patch_text(SAMPLE, '', XML)

    def test_moved_lookup_initialization_is_not_patched(self):
        changed = SAMPLE.replace(f'invoke-static {{}}, {RES}->values()[{RES}', 'nop')
        with self.assertRaisesRegex(ValueError, 'lookup map no longer derives'):
            camera.patch_text(changed, RATIOS, XML)

    def test_android17_build_calls_runtime_and_hdr_after_library_pruning(self):
        source = (ROOT / 'unica/patches/camera/customize.sh').read_text(encoding='utf-8')
        self.assertIn('"$SOURCE_PLATFORM_SDK_VERSION" -ge 37', source)
        self.assertGreater(source.index('. "$MODPATH/r8s_runtime.sh"'),
                           source.index('# Camera libs debloat'))
        self.assertIn('. "$MODPATH/r8s_hdr.sh" || return 1', source)
        runtime = (ROOT / 'unica/patches/camera/r8s_runtime.sh').read_text(encoding='utf-8')
        self.assertIn('patch_camera_resolutions.py', runtime)
        self.assertIn('libFoodDetector.camera.samsung.so', runtime)
        self.assertNotIn('r8s-legacy-camera.patch', runtime)


if __name__ == '__main__':
    unittest.main()
