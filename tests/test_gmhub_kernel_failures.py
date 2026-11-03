"""Kernel verification must fail even when Bash calls it inside if/!.

Those contexts suppress errexit recursively. ABORT logs and returns; callers
must propagate the failure explicitly rather than cache stale boot artifacts.
The tests run helper functions only, never build or install a kernel.
"""
from pathlib import Path
import hashlib
import os
import struct
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'platform/exynos990/patches/extremekrnl/customize.sh'


class KernelFailureTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.out = self.root / 'out'
        self.kernel = self.out / 'kernel_tmp-exynos990'
        self.package = self.kernel / 'build/out/r8s'
        self.package.mkdir(parents=True)
        self.helpers = self.root / 'helpers.sh'
        # Stop before the module's entrypoint; all tested functions are real.
        self.helpers.write_text(SOURCE.read_text().rsplit('# ]', 1)[0], encoding='utf-8')
        # The bundled Windows shell has od/stat/hash utilities but no dd.
        # Supply only dd's read operations there; Linux CI uses real GNU dd.
        self.io_shim = ''
        if os.name == 'nt':
            reader = self.root / 'read_bytes.py'
            reader.write_text('import sys\n'
                              'args=dict(a.split("=",1) for a in sys.argv[1:])\n'
                              'bs=int(args.get("bs","512").removesuffix("M"))*(1048576 if args.get("bs","").endswith("M") else 1)\n'
                              'flags=args.get("iflag","").split(",")\n'
                              'offset=int(args.get("skip","0"))*(1 if "skip_bytes" in flags else bs)\n'
                              'length=int(args["count"])*(1 if "count_bytes" in flags else bs)\n'
                              'with open(args["if"],"rb") as f:\n'
                              ' f.seek(offset);sys.stdout.buffer.write(f.read(length))\n')
            self.io_shim = f'dd() {{ {Path(sys.executable).as_posix()!r} {reader.as_posix()!r} "$@"; }}\n'

    def run_case(self, code):
        script = (f'TARGET_CODENAME=r8s\nMODPATH={self.root.as_posix()!r}\n'
                  f'OUT_DIR={self.out.as_posix()!r}\n'
                  f'source {self.helpers.as_posix()!r}\n'
                  f'KERNEL_TMP_DIR={self.kernel.as_posix()!r}\n'
                  'LOG() { printf "%s\\n" "$*"; }\n'
                  'LOGE() { printf "%s\\n" "$*" >&2; }\n'
                  'ABORT() { LOGE "$*"; return 1; }\n' + self.io_shim + code)
        return subprocess.run(['bash', '-c', script], text=True, capture_output=True)

    def create_image(self, payload=b'kernel payload', declared=None, page=4096):
        header = bytearray(4096)
        header[:8] = b'ANDROID!'
        struct.pack_into('<I', header, 8, len(payload) if declared is None else declared)
        struct.pack_into('<I', header, 36, page)
        path = self.package / 'boot.img'
        path.write_bytes(header + payload)
        return path

    def test_missing_build_outputs_cannot_be_accepted_inside_if(self):
        result = self.run_case('if VERIFY_BUILT_KERNEL_ARTIFACTS; then exit 99; else exit 0; fi')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('non-empty Image', result.stderr)

    def test_mismatched_packaged_image_cannot_be_accepted_inside_if(self):
        (self.package / 'Image').write_bytes(b'old image')
        source = self.kernel / 'out/arch/arm64/boot/Image'
        source.parent.mkdir(parents=True)
        source.write_bytes(b'new image')
        (self.kernel / 'out/vmlinux').write_bytes(b'vmlinux')
        result = self.run_case('if VERIFY_BUILT_KERNEL_ARTIFACTS; then exit 99; else exit 0; fi')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('does not match', result.stderr)

    def test_cleanup_rejects_bad_path_before_calling_rm(self):
        result = self.run_case('KERNEL_TMP_DIR=/unexpected-kernel-root\n'
                               'rm() { echo UNEXPECTED_DELETE; }\n'
                               'if CLEAN_KERNEL_BUILD_OUTPUTS; then exit 99; else exit 0; fi')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('UNEXPECTED_DELETE', result.stdout)

    def test_wrong_remote_is_rejected_before_fetch(self):
        result = self.run_case('git() { if [[ "$*" == *"remote get-url origin" ]]; then '
                               'echo https://example.invalid/wrong; else echo UNEXPECTED_GIT; fi; }\n'
                               'if SAFE_PULL_CHANGES; then exit 99; else exit 0; fi')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('UNEXPECTED_GIT', result.stdout)
        self.assertIn('Unexpected GMKernel remote', result.stderr)

    def test_declared_kernel_cannot_extend_past_end_of_boot_image(self):
        self.create_image(declared=5000)
        result = self.run_case('if GET_BOOT_KERNEL_SHA256 "$KERNEL_TMP_DIR/build/out/r8s/boot.img"; '
                               'then exit 99; else exit 0; fi')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_invalid_boot_page_size_cannot_pass(self):
        self.create_image(page=3)
        result = self.run_case('if GET_BOOT_KERNEL_SHA256 "$KERNEL_TMP_DIR/build/out/r8s/boot.img"; '
                               'then exit 99; else exit 0; fi')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_valid_boot_kernel_hash_stays_identical(self):
        payload = b'this is a host fixture, not an Android kernel'
        self.create_image(payload=payload)
        result = self.run_case('GET_BOOT_KERNEL_SHA256 "$KERNEL_TMP_DIR/build/out/r8s/boot.img"')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), hashlib.sha256(payload).hexdigest())

    def test_missing_file_hash_does_not_report_success(self):
        result = self.run_case('if GET_FILE_SHA256 "$KERNEL_TMP_DIR/missing-file"; then exit 99; else exit 0; fi')
        self.assertEqual(result.returncode, 0)


if __name__ == '__main__':
    unittest.main()
