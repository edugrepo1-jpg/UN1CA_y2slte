"""Execute the real cache functions; failed copies must not become cache hits."""
from pathlib import Path
import re
import subprocess
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[1]

class ApkCacheTransactions(unittest.TestCase):
    def case(self,commands):
        with tempfile.TemporaryDirectory(prefix='cache-contract-') as directory:
            root=Path(directory).resolve()
            decoded=root/'decoded/system/framework/test.jar';decoded.mkdir(parents=True)
            (decoded/'class.smali').write_text('original decoded source\n')
            built=root/'work/system/system/framework/test.jar';built.parent.mkdir(parents=True)
            built.write_bytes(b'valid built jar')
            source=(ROOT/'scripts/make_rom.sh').read_text(encoding='utf-8')
            helpers='\n'.join(re.search(r'^'+name+r'\(\)\n\{.*?^\}',source,re.M|re.S)[0]
                              for name in ('GET_PATCHED_APK_HASH','GET_BUILT_APK_PATH','RESTORE_APK_CACHE','UPDATE_APK_CACHE'))
            script='''set -euo pipefail
SRC_DIR="$1"
WORK_DIR="$2/work"
APKTOOL_DIR="$2/decoded"
APK_CACHE_DIR="$2/cache"
APK_BUILD_LIST="$2/build.list"
APK_CACHE_FORMAT=unica-apk-cache-v3
ROM_IS_OFFICIAL=false
TARGET_OS_BUILD_SYSTEM_EXT_PARTITION=false
LOG() { :; }
LOGE() { printf '%s\\n' "$*" >&2; }
'''+helpers+'\n'+commands
            r=subprocess.run(['bash','-c',script,'cache-test',ROOT.as_posix(),root.as_posix()],capture_output=True,text=True)
            result={'built':built.read_bytes() if built.exists() else None,
                    'sentinel':(root/'cache/sentinel').exists(),
                    'queued':(root/'build.list').read_bytes() if (root/'build.list').exists() else b''}
            return r,result

    def test_valid_cache_round_trip_and_corrupt_bytes_force_rebuild(self):
        for corrupt in (False,True):
            commands='UPDATE_APK_CACHE || exit 11\n'
            if corrupt:commands+='printf bad > "$APK_CACHE_DIR/files/system/framework/test.jar"\n'
            commands+='rm "$WORK_DIR/system/system/framework/test.jar"\nRESTORE_APK_CACHE || exit 12\n'
            with self.subTest(corrupt=corrupt):
                r,state=self.case(commands)
                self.assertEqual(r.returncode,0,r.stderr)
                if corrupt:
                    self.assertIsNone(state['built'])
                    self.assertTrue(state['queued'].endswith(b'test.jar\0'))
                else:
                    self.assertEqual(state['built'],b'valid built jar')
                    self.assertEqual(state['queued'],b'')

    def test_failed_update_copy_preserves_previous_cache_even_in_if_context(self):
        r,state=self.case('''mkdir "$APK_CACHE_DIR"
touch "$APK_CACHE_DIR/sentinel"
cp() { echo COPY_FAILURE >&2; return 17; }
if UPDATE_APK_CACHE; then exit 99; fi
''')
        self.assertEqual(r.returncode,0,r.stderr)
        self.assertTrue(state['sentinel'])
        self.assertIn('COPY_FAILURE',r.stderr)

    def test_failed_promotion_restores_previous_cache(self):
        r,state=self.case('''mkdir "$APK_CACHE_DIR"
touch "$APK_CACHE_DIR/sentinel"
mv() { if [[ "$1" == *.tmp.* ]]; then echo PROMOTION_FAILURE >&2; return 18; else command mv "$@"; fi; }
if UPDATE_APK_CACHE; then exit 99; fi
''')
        self.assertEqual(r.returncode,0,r.stderr)
        self.assertTrue(state['sentinel'])
        self.assertIn('PROMOTION_FAILURE',r.stderr)

    def test_failed_restore_copy_does_not_report_a_cache_hit(self):
        r,state=self.case('''UPDATE_APK_CACHE || exit 11
rm "$WORK_DIR/system/system/framework/test.jar"
cp() { echo RESTORE_FAILURE >&2; return 19; }
if RESTORE_APK_CACHE; then exit 99; fi
''')
        self.assertEqual(r.returncode,0,r.stderr)
        self.assertIsNone(state['built'])
        self.assertIn('RESTORE_FAILURE',r.stderr)

if __name__=='__main__':unittest.main()
