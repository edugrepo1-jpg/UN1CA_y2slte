"""Exercise the real OTA generators with Android 17 / API37 kept distinct."""
from pathlib import Path
import re
import subprocess
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[1]
BUILDERS=('build_flashable_zip.sh','build_full_ota_zip.sh','build_incremental_ota_zip.sh')

def function(file,name):
    match=re.search(r'^'+name+r'\(\)\n\{.*?^\}',file.read_text(encoding='utf-8'),re.M|re.S)
    assert match,name
    return match[0]

class OtaSdkMetadataTests(unittest.TestCase):
    def generate(self, builder, sdk='37', proto=False):
        with tempfile.TemporaryDirectory(prefix='ota-sdk-') as directory:
            root=Path(directory);tmp=root/'tmp';tmp.mkdir()
            if proto:
                p=root/'src/external/android-tools/vendor/build/tools/releasetools/ota_metadata.proto'
                p.parent.mkdir(parents=True);p.touch()
            info='device=r8s\nos_version=17\nbuild_incremental=EZJ1\nbuild_date=1793610000\nsecurity_patch=2026-10-01\nsource_fingerprint=samsung/r8s/r8s:17/EZJ1/user/release-keys\n'
            if sdk is not None: info+='platform_sdk_version='+sdk+'\n'
            script='''SRC_DIR="$1/src"
TMP_DIR="$1/tmp"
TARGET_CODENAME=r8s
SOURCE_FINGERPRINT=samsung/r8s/r8s:17/EZJ1/user/release-keys
LOGE() { printf '%s\\n' "$*" >&2; }
GET_PROP() {
 case "$2" in
 ro.build.version.sdk) printf '%s\\n' "$3" ;;
 ro.build.version.release) echo 17 ;;
 ro.build.version.incremental) echo EZJ1 ;;
 ro.build.version.security_patch) echo 2026-10-01 ;;
 ro.build.date.utc) echo 1793610000 ;;
 esac
}
CALCULATE_MIN_CACHE_SIZE() { echo 0; }
EVAL() { printf '%s' "$1" > "$TMP_DIR/protoc-command.txt"; }
'''
            # GET_PROP is called with two args by the actual function; bind the
            # fixture value in a literal fixed function argument, never a shell eval.
            script=script.replace('printf \'%s\\n\' "$3"','printf \'%s\\n\' "$SDK_FIXTURE"')
            script+='SDK_FIXTURE="$2"\n'
            (root/'info.txt').write_text(info,encoding='utf-8')
            script+='BUILD_INFO="$(cat "$1/info.txt")"\nTARGET_BUILD_INFO="$BUILD_INFO"\nSOURCE_BUILD_INFO="$BUILD_INFO"\n'
            script+=function(ROOT/'scripts/internal'/builder,'GENERATE_OTA_METADATA')+'\n'
            script+='if GENERATE_OTA_METADATA; then exit 0; else exit 7; fi\n'
            path=root/'run.sh';path.write_text(script,encoding='utf-8')
            r=subprocess.run(['bash',str(path),str(root),sdk or ''],capture_output=True,text=True)
            metadata=tmp/'META-INF/com/android/metadata'
            cmd=tmp/'protoc-command.txt'
            return r,metadata.read_text() if metadata.exists() else '',cmd.read_text() if cmd.exists() else ''

    def test_all_generators_use_api37_in_text_and_protobuf_metadata(self):
        for builder in BUILDERS:
            for proto in (False,True):
                with self.subTest(builder=builder,proto=proto):
                    r,text,cmd=self.generate(builder,proto=proto)
                    self.assertEqual(r.returncode,0,r.stderr)
                    self.assertIn('post-sdk-level=37\n',text)
                    self.assertNotIn('post-sdk-level=17\n',text)
                    if proto:
                        self.assertRegex(cmd,r'sdk_level: [\\"]+37[\\"]+')

    def test_invalid_or_absent_sdk_never_creates_misleading_metadata(self):
        for builder in BUILDERS:
            for sdk in (None,'bad','0'):
                with self.subTest(builder=builder,sdk=sdk):
                    r,text,cmd=self.generate(builder,sdk)
                    self.assertEqual(r.returncode,7,r.stderr)
                    self.assertEqual(text,'')

    def test_target_files_record_both_release_and_api(self):
        text=function(ROOT/'scripts/internal/create_target_files_zip.sh','GENERATE_BUILD_INFO')
        self.assertIn('ro.build.version.sdk',text)
        self.assertIn('echo "platform_sdk_version=$SDK_LEVEL"',text)
        self.assertIn('ro.build.version.release',text)

if __name__=='__main__':unittest.main()
