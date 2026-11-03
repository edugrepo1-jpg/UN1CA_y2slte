"""Exercise raw image script generation against the real recovery map."""
from pathlib import Path
import hashlib
import re
import subprocess
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[1]
BUILDER=ROOT/'scripts/internal/build_flashable_zip.sh'

def function(path,name):
    match=re.search(r'^'+name+r'\(\)\n\{.*?^\}',path.read_text(encoding='utf8'),re.M|re.S)
    assert match,name
    return match[0]

class RawPartitionInstall(unittest.TestCase):
    def generate(self, mapping=None):
        with tempfile.TemporaryDirectory(prefix='raw-install-') as temp:
            root=Path(temp);tmp=root/'tmp';(tmp/'META-INF/com/google/android').mkdir(parents=True)
            src=root/'src';(src/'target/r8s/installer').mkdir(parents=True)
            fstab=src/'target/r8s/installer/recovery.fstab'
            if mapping is None:
                mapping=(ROOT/'platform/exynos990/installer/recovery.fstab').read_text()
            fstab.write_text(mapping,encoding='utf8')
            for image in ('boot.img','dtbo.img','up_param.bin'):(tmp/image).write_bytes(b'payload-'+image.encode())
            script="""set -euo pipefail
SRC_DIR="$1/src"
TMP_DIR="$1/tmp"
TARGET_CODENAME=r8s
TARGET_ASSERT_MODEL=SM-G780F
TARGET_USE_DYNAMIC_PARTITIONS=true
TARGET_OS_BOOT_DEVICE_PATH=
DEBUG=false
_CHECK_NON_EMPTY_PARAM() { test -n "$2"; }
IS_VALID_PARTITION_NAME() { return 1; }
LOGE() { printf '%s\\n' "$*" >&2; }
LOGW() { printf '%s\\n' "$*" >&2; }
PRINT_HEADER() { echo 'ui_print("fixture");'; }
"""
            script+=function(ROOT/'scripts/utils/install_utils.sh','GET_DEVICE_FROM_MOUNTPOINT')+'\n'
            for name in ('RESOLVE_RAW_IMAGE_DEVICE','PRINT_RAW_IMAGE_INSTALL','GENERATE_UPDATER_SCRIPT'):
                script+=function(BUILDER,name)+'\n'
            script+='if GENERATE_UPDATER_SCRIPT; then exit 0; else exit 9; fi\n'
            runner=root/'run.sh';runner.write_text(script,encoding='utf8')
            result=subprocess.run(['bash',str(runner),str(root).replace('\\','/')],capture_output=True,text=True)
            out=tmp/'META-INF/com/google/android/updater-script'
            return result,out.read_text() if out.exists() else ''

    def test_actual_fstab_writes_boot_dtbo_and_up_param_block_devices_with_readback(self):
        result,text=self.generate()
        self.assertEqual(result.returncode,0,result.stderr)
        for image in ('boot.img','dtbo.img','up_param.bin'):
            part=image.rsplit('.',1)[0]
            self.assertIn('assert(package_extract_file("'+image+'", "/dev/block/by-name/'+part+'"));',text)
            self.assertNotIn('package_extract_file("'+image+'", "/'+part+'")',text)
            digest=hashlib.sha256(b'payload-'+image.encode()).hexdigest()
            self.assertIn('head -c '+str(len(b'payload-'+image.encode()))+' /dev/block/by-name/'+part,text)
            self.assertIn(digest,text)
        self.assertNotIn('apply_patch_check',text)  # Removed from the exact updater binary.
        self.assertNotIn('sha1_check',text)

    def test_missing_or_unsafe_mapping_rejects_before_dynamic_partition_writes(self):
        for mapping in ('','/boot /boot emmc defaults recoveryonly\n',
                        '/dev/block/../file /boot emmc defaults recoveryonly\n'):
            with self.subTest(mapping=mapping):
                result,text=self.generate(mapping)
                self.assertEqual(result.returncode,9,result.stderr)
                self.assertNotIn('update_dynamic_partitions',text)

    def test_complete_generator_sources_partition_resolver_not_unset_prefix(self):
        text=BUILDER.read_text()
        self.assertIn('source "$SRC_DIR/scripts/utils/install_utils.sh" || exit 1',text)
        self.assertNotIn('$TARGET_OS_BOOT_DEVICE_PATH',text)
        self.assertIn('GENERATE_UPDATER_SCRIPT || exit 1',text)

if __name__=='__main__':unittest.main()
