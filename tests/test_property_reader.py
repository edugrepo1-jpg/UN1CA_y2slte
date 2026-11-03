"""Property reads used by every firmware phase must survive strict shell mode."""
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[1]

class PropertyReaderTests(unittest.TestCase):
    def read(self, files, key, partition='vendor'):
        with tempfile.TemporaryDirectory(prefix='props with spaces ') as directory:
            root=Path(directory)
            for path,value in files.items():
                dest=root/path;dest.parent.mkdir(parents=True,exist_ok=True)
                dest.write_bytes(value.encode())
            script='''set -euo pipefail
SRC_DIR="$1"
WORK_DIR="$2"
source "$SRC_DIR/scripts/utils/common_utils.sh"
if [ "$4" = direct ]; then GET_PROP "$WORK_DIR/vendor/default.prop" "$3";
else GET_PROP "$4" "$3"; fi
'''
            return subprocess.run(['bash','-c',script,'properties',str(ROOT),str(root),key,partition],
                                  text=True,capture_output=True)

    def test_one_optional_file_missing_is_not_a_shell_failure(self):
        for path in ('vendor/default.prop','vendor/build.prop'):
            with self.subTest(path=path):
                r=self.read({path:'ro.vendor.build.version.sdk=30\n'},'ro.vendor.build.version.sdk')
                self.assertEqual(r.returncode,0,r.stderr)
                self.assertEqual(r.stdout,'30\n')

    def test_key_is_literal_and_value_can_contain_equals(self):
        r=self.read({'vendor/default.prop':'roXtestXvalue=wrong\nro.test.value=a=b\n'},'ro.test.value')
        self.assertEqual(r.stdout,'a=b\n')

    def test_first_definition_including_empty_value_keeps_precedence(self):
        r=self.read({'vendor/default.prop':'a=\na=second\n','vendor/build.prop':'a=third\n'},'a')
        self.assertEqual(r.stdout,'\n')
        self.assertEqual(r.returncode,0,r.stderr)

    def test_no_files_and_no_matching_property_return_empty_success(self):
        for files in ({},{'vendor/build.prop':'a=b\n'}):
            with self.subTest(files=files):
                r=self.read(files,'missing')
                self.assertEqual((r.returncode,r.stdout),(0,''),r.stderr)

    def test_large_file_and_direct_crlf_path_do_not_raise_sigpipe(self):
        for partition in ('vendor','direct'):
            r=self.read({'vendor/default.prop':'a=first\r\n'+('unused.value=x\n'*50000)},'a',partition)
            self.assertEqual((r.returncode,r.stdout),(0,'first\n'),r.stderr)

if __name__=='__main__':unittest.main()
