"""Exercise firmware identity, privilege handling and real mount preflight logic."""
from pathlib import Path
import importlib.util
import os
import subprocess
import tempfile
import unittest
from unittest.mock import patch
import zipfile

ROOT = Path(__file__).resolve().parents[1]
PIN = 'S926BXXSIEZJ1/S926BOXMIEZJ1/S926BXXSIEZJ1'


def shell(script, env=None):
    return subprocess.run(['bash', '-c', script], text=True, capture_output=True, env=env)


class FirmwareIdentityTests(unittest.TestCase):
    def compare(self, first, second):
        return shell(f'SRC_DIR={ROOT.as_posix()!r}; source "$SRC_DIR/scripts/utils/firmware_identity_utils.sh"; '
                     f'FIRMWARE_VERSIONS_EQUAL {first!r} {second!r}')

    def test_three_and_four_component_pins_match(self):
        self.assertEqual(self.compare(PIN, PIN + '/S926BXXSIEZJ1').returncode, 0)

    def test_different_csc_cp_or_newer_donor_does_not_match(self):
        for value in (PIN.replace('BOXMIEZJ1', 'BOXMIEZJ2'),
                      PIN.replace('/S926BXXSIEZJ1', '/S926BXXSIEZJ2'),
                      PIN.replace('EZJ1', 'EZJ2'), '', 'PDA/CSC', PIN + '/x/y'):
            with self.subTest(value=value):
                self.assertNotEqual(self.compare(PIN, value).returncode, 0)

    def extraction_fixture(self, downloaded):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        top = Path(temp.name)
        source = top / 'src/scripts/utils'
        source.mkdir(parents=True)
        (source / 'firmware_utils.sh').write_text(
            f'source {str(ROOT / "scripts/utils/firmware_identity_utils.sh").replace(chr(92), "/")!r}\n'
            'GET_LATEST_FIRMWARE() { echo UNEXPECTED_NETWORK >&2; return 1; }\n'
            'PARSE_FIRMWARE_STRING() { IFS=/ read -r MODEL CSC unused <<< "$1"; }\n'
            '_CHECK_NON_EMPTY_PARAM() { test -n "$2"; }\n'
            'LOG_STEP_IN() { :; }; LOG_STEP_OUT() { :; }\n'
            'LOG() { printf "%s\\n" "$*"; }; LOGE() { printf "%s\\n" "$*" >&2; }\n')
        firmware = top / 'fw/SM-S926B_EUX'
        firmware.mkdir(parents=True)
        odin = top / 'odin/SM-S926B_EUX'
        odin.mkdir(parents=True)
        (firmware / '.extracted').write_text(PIN if downloaded is None else PIN.replace('EZJ1', 'EZJ2'))
        (firmware / 'preserve-me').write_text('original cache')
        if downloaded:
            (odin / '.downloaded').write_text(downloaded)
        env = dict(os.environ, SRC_DIR=str(top / 'src').replace('\\', '/'),
                   FW_DIR=str(top / 'fw').replace('\\', '/'),
                   ODIN_DIR=str(top / 'odin').replace('\\', '/'),
                   TMPDIR=str(top).replace('\\', '/'),
                   SOURCE_FIRMWARE='SM-S926B/EUX/350330051234562',
                   SOURCE_FIRMWARE_VERSION=PIN, SOURCE_EXTRA_FIRMWARES='',
                   TARGET_FIRMWARE='', TARGET_FIRMWARE_VERSION='')
        return firmware, shell(f'source {str(ROOT / "scripts/extract_fw.sh").replace(chr(92), "/")!r} --ignore-target', env)

    def test_exact_extracted_pin_reused_without_network_or_odin_files(self):
        firmware, result = self.extraction_fixture(None)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('UNEXPECTED_NETWORK', result.stderr)
        self.assertEqual((firmware / 'preserve-me').read_text(), 'original cache')

    def test_wrong_download_cannot_erase_or_replace_existing_firmware(self):
        firmware, result = self.extraction_fixture(PIN.replace('EZJ1', 'EZJ3'))
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('differs from the configured pin', result.stderr)
        self.assertTrue((firmware / 'preserve-me').exists())

    def test_root_execution_retains_argument_boundaries(self):
        result = shell(f'SRC_DIR={ROOT.as_posix()!r}; source "$SRC_DIR/scripts/utils/common_utils.sh"; '
                       'id() { echo 0; }; capture() { printf "<%s>" "$@"; }; '
                       "RUN_AS_ROOT capture 'a b' 'literal;$(not-a-command)'")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, '<a b><literal;$(not-a-command)>')

    def test_nonroot_never_requests_interactive_sudo(self):
        result = shell(f'SRC_DIR={ROOT.as_posix()!r}; source "$SRC_DIR/scripts/utils/common_utils.sh"; '
                       'id() { echo 1000; }; sudo() { printf "<%s>" "$@"; return 23; }; '
                       'RUN_AS_ROOT printf "a b"')
        self.assertEqual(result.returncode, 23)
        self.assertEqual(result.stdout, '<-n><--><printf><a b>')


class FilesystemPreflightTests(unittest.TestCase):
    def run_preflight(self, package='unified', install_status=0, module_status=0, fuse=True):
        script = f'''
source {str(ROOT / 'scripts/internal/prepare_ci_filesystems.sh').replace(chr(92), '/')!r}
ready=0
uname() {{ echo 7.0.0-test; }}
apt-cache() {{
    case "$2" in
        linux-modules-extra-*) [[ {package!r} == legacy ]];;
        linux-modules-*) [[ {package!r} == unified ]];;
    esac
}}
as_root() {{
    if [[ "$1" == env ]]; then
        printf 'INSTALL:%s\\n' "$*"
        ready=1
        return {install_status}
    fi
    if [[ "$2" == fuse ]]; then return 0; fi
    [[ "$ready" == 1 ]] && return {module_status}
    return 1
}}
grep() {{ [[ "$ready" == 1 && {module_status} == 0 ]]; }}
test() {{ if [[ "$*" == '-c /dev/fuse' ]]; then return {0 if fuse else 1}; fi; builtin test "$@"; }}
prepare_filesystems
'''
        return shell(script)

    def test_unified_kernel_does_not_install_unavailable_extra_package(self):
        result = self.run_preflight()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('install -y linux-modules-7.0.0-test', result.stdout)
        self.assertNotIn('install -y linux-modules-extra', result.stdout)

    def test_legacy_extra_package_still_supported(self):
        result = self.run_preflight(package='legacy')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('install -y linux-modules-extra-', result.stdout)

    def test_no_available_module_package_fails_before_download(self):
        result = self.run_preflight(package='none')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('INSTALL:', result.stdout)
        self.assertIn('cannot mount F2FS', result.stderr)

    def test_install_failure_is_not_hidden(self):
        self.assertEqual(self.run_preflight(install_status=42).returncode, 42)

    def test_module_still_missing_after_install_is_rejected(self):
        self.assertNotEqual(self.run_preflight(module_status=1).returncode, 0)

    def test_fuse_missing_is_rejected(self):
        self.assertNotEqual(self.run_preflight(fuse=False).returncode, 0)


class AuditCollectorTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        spec = importlib.util.spec_from_file_location('source_audit', ROOT / 'scripts/internal/collect_source_audit.py')
        cls.module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(cls.module)

    def test_decoder_failure_still_retains_exact_original(self):
        with tempfile.TemporaryDirectory() as temp:
            top = Path(temp)
            firmware = top / 'fw'
            firmware.mkdir()
            original = firmware / 'framework.jar'
            original.write_bytes(b'exact input bytes')
            with patch.object(self.module.subprocess, 'run', side_effect=RuntimeError('decoder failure')):
                with self.assertRaisesRegex(RuntimeError, 'decoder failure'):
                    self.module.collect(firmware, top / 'apktool.jar', top / 'out')
            with zipfile.ZipFile(top / 'out/framework.zip') as package:
                self.assertEqual(package.read('originals/framework.jar'), original.read_bytes())
            self.assertTrue((top / 'out/manifest.json').is_file())

    def test_duplicate_apk_is_not_silently_selected(self):
        with tempfile.TemporaryDirectory() as temp:
            top = Path(temp)
            (top / 'a').mkdir()
            (top / 'b').mkdir()
            for path in (top / 'a/SystemUI.apk', top / 'b/SystemUI.apk'):
                path.write_bytes(b'APK')
            with self.assertRaisesRegex(ValueError, 'Expected one'):
                self.module.find_unique(top, 'SystemUI.apk')


if __name__ == '__main__':
    unittest.main()
