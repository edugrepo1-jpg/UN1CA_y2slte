"""Keep NFC's JNI paired with its source APEX on compressed/uncompressed ROMs."""
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
HELPER = ROOT / 'scripts/utils/nfc_utils.sh'


class NfcApexTests(unittest.TestCase):
    def check(self, root):
        return subprocess.run(['bash', '-c',
                               f'source {HELPER.as_posix()!r}\n'
                               f'HAS_NFC_SERVICE_APEX {root.as_posix()!r}'],
                              capture_output=True, text=True).returncode

    def test_all_supported_apex_locations_and_both_encodings(self):
        for location in ('system/system/apex', 'system/apex', 'system_ext/apex', 'product/apex'):
            for extension in ('apex', 'capex'):
                with self.subTest(location=location, extension=extension), tempfile.TemporaryDirectory() as tmp:
                    root = Path(tmp)
                    package = root / location / f'com.android.nfcservices.{extension}'
                    package.parent.mkdir(parents=True)
                    package.write_bytes(b'fixture')
                    self.assertEqual(self.check(root), 0)

    def test_unrelated_packages_and_leftover_names_do_not_claim_jni_ownership(self):
        for name in ('com.android.bluetooth.apex', 'com.android.nfcservices.capex.backup',
                     'com.android.nfcservices.apex.disabled'):
            with self.subTest(name=name), tempfile.TemporaryDirectory() as tmp:
                root = Path(tmp)
                directory = root / 'system/system/apex'
                directory.mkdir(parents=True)
                (directory / name).write_bytes(b'fixture')
                self.assertNotEqual(self.check(root), 0)

    def test_directory_is_not_a_native_apex_package(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / 'system/system/apex/com.android.nfcservices.apex').mkdir(parents=True)
            self.assertNotEqual(self.check(root), 0)

    def test_nfc_build_checks_the_actual_work_tree_and_source(self):
        source = (ROOT / 'unica/patches/nfc/customize.sh').read_text(encoding='utf-8')
        self.assertIn('HAS_NFC_SERVICE_APEX "$WORK_DIR"', source)
        self.assertIn('HAS_NFC_SERVICE_APEX "$FW_DIR/$SOURCE_FIRMWARE_PATH"', source)
        self.assertNotIn('com.android.nfcservices.cap*', source)


if __name__ == '__main__':
    unittest.main()
