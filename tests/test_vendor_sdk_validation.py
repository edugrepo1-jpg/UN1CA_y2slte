"""Execute real vendor validation: a frozen vendor does not equal system SDK."""
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[1]
MODULE=ROOT/'unica/patches/vndk/customize.sh'

class VendorSdkValidation(unittest.TestCase):
    def run_case(self, stock='30', work='30', second=None, board='30', platform='33'):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory)
            vendor=root/'fw/SM-G780F_AUT/vendor';vendor.mkdir(parents=True)
            if stock is not None:
                (vendor/'default.prop').write_text('ro.vendor.build.version.sdk='+stock+'\n',encoding='utf-8')
            if second is not None:
                (vendor/'build.prop').write_text('ro.vendor.build.version.sdk='+second+'\n',encoding='utf-8')
            helpers=root/'helpers.sh'
            helpers.write_text(MODULE.read_text(encoding='utf-8').rsplit('# ]',1)[0],encoding='utf-8')
            script='''set -euo pipefail
SRC_DIR="$1"
FW_DIR="$2/fw"
WORK_DIR="$2/work"
TARGET_BOARD_API_LEVEL="$4"
TARGET_PLATFORM_SDK_VERSION="$5"
SOURCE_PLATFORM_SDK_VERSION=37
TARGET_FIRMWARE=SM-G780F/AUT/358558821234569
TARGET_OS_BUILD_SYSTEM_EXT_PARTITION=false
source "$SRC_DIR/scripts/utils/common_utils.sh"
source "$2/helpers.sh"
ABORT() { printf '%s\\n' "$*" >&2; return 1; }
mkdir -p "$WORK_DIR/vendor"
printf 'ro.vendor.build.version.sdk=%s\\n' "$3" > "$WORK_DIR/vendor/default.prop"
if VALIDATE_TARGET_VENDOR_SDK; then echo VALID; else exit 9; fi
'''
            return subprocess.run(['bash','-c',script,'vendor-test',str(ROOT),str(root),work,board,platform],
                                  capture_output=True,text=True)

    def test_frozen_r8s_vendor_api30_accepts_stock_system33_and_output37(self):
        r=self.run_case()
        self.assertEqual(r.returncode,0,r.stderr)
        self.assertIn('VALID',r.stdout)

    def test_reference_is_stock_vendor_not_board_or_system(self):
        # A newer stock vendor SDK is also legal on a chipset with an older
        # board level: compare to stock instead of assuming SDK == board.
        r=self.run_case(stock='33',work='33',board='30',platform='34')
        self.assertEqual(r.returncode,0,r.stderr)

    def test_real_vendor_change_and_corrupt_or_missing_stock_are_rejected(self):
        for args in ({'work':'33'}, {'stock':None}, {'stock':'30bad'},
                     {'work':''}, {'work':'30; exit 0'}, {'second':'33'}):
            with self.subTest(args=args):
                r=self.run_case(**args)
                self.assertEqual(r.returncode,9,r.stdout+r.stderr)
                self.assertNotIn('VALID',r.stdout)

    def test_consistent_duplicate_stock_properties_are_allowed(self):
        r=self.run_case(second='30')
        self.assertEqual(r.returncode,0,r.stderr)

if __name__=='__main__':unittest.main()
