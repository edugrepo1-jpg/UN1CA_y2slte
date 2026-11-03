"""Exercise real compiler preparation with a tiny local Git fixture, no kernel build."""
from pathlib import Path
import os
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / 'scripts/internal/prepare_gmkernel_toolchain.sh'


class CompilerPreparationTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.top = Path(self.temporary.name)
        self.origin = self.top / 'source'
        compiler = self.origin / 'clang-r450784d'
        (compiler / 'bin').mkdir(parents=True)
        (compiler / 'lib64').mkdir()
        for name in ('clang-14', 'ld.lld'):
            binary = compiler / 'bin' / name
            binary.write_text('#!/bin/sh\nprintf "fixture compiler\\n"\n')
            binary.chmod(0o755)
        (compiler / 'lib64/libc++.so.1').write_text('fixture runtime')
        for command in (['init', '-q'], ['add', '.'],
                        ['update-index', '--chmod=+x', 'clang-r450784d/bin/clang-14', 'clang-r450784d/bin/ld.lld'],
                        ['-c', 'user.name=Fixture', '-c', 'user.email=fixture@example.invalid', 'commit', '-qm', 'compiler fixture']):
            subprocess.run(['git', '-C', str(self.origin), *command], check=True, capture_output=True)
        self.commit = subprocess.check_output(['git', '-C', str(self.origin), 'rev-parse', 'HEAD'], text=True).strip()
        self.destination = self.top / 'cache/clang_14'

    def run_prepare(self, prefix='', suffix=''):
        body = (f'source {SCRIPT.as_posix()!r}\n'
                f'CLANG_COMMIT={self.commit!r}\n'
                f'CLANG_REPOSITORY={self.origin.as_posix()!r}\n' + prefix +
                f'prepare_toolchain {self.destination.as_posix()!r}\n' + suffix)
        return subprocess.run(['bash', '-c', body], capture_output=True, text=True)

    def test_git_install_and_integrity_verified_reuse(self):
        first = self.run_prepare()
        self.assertEqual(first.returncode, 0, first.stderr)
        self.assertIn('Installed integrity-verified', first.stdout)
        second = self.run_prepare('git() { echo UNEXPECTED_DOWNLOAD >&2; return 99; }\n')
        self.assertEqual(second.returncode, 0, second.stderr)
        self.assertIn('Reusing integrity-verified', second.stdout)
        self.assertNotIn('UNEXPECTED_DOWNLOAD', second.stderr)

    def test_corrupt_cached_binary_is_replaced_by_verified_git_content(self):
        self.assertEqual(self.run_prepare().returncode, 0)
        (self.destination / 'bin/clang-14').write_text('corrupted download')
        result = self.run_prepare()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('fixture compiler', (self.destination / 'bin/clang-14').read_text())

    def test_failed_transfer_never_replaces_existing_cache(self):
        self.destination.mkdir(parents=True)
        sentinel = self.destination / 'keep.txt'
        sentinel.write_text('existing cache')
        result = self.run_prepare('git() { return 1; }\n')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(sentinel.read_text(), 'existing cache')

    def test_missing_runtime_rejects_checkout_and_preserves_existing_cache(self):
        (self.origin / 'clang-r450784d/lib64/libc++.so.1').unlink()
        subprocess.run(['git', '-C', str(self.origin), 'add', '-u'], check=True, capture_output=True)
        subprocess.run(['git', '-C', str(self.origin), '-c', 'user.name=Fixture', '-c',
                        'user.email=fixture@example.invalid', 'commit', '-qm', 'incomplete compiler'], check=True, capture_output=True)
        self.commit = subprocess.check_output(['git', '-C', str(self.origin), 'rev-parse', 'HEAD'], text=True).strip()
        self.destination.mkdir(parents=True)
        sentinel = self.destination / 'keep.txt'
        sentinel.write_text('existing cache')
        result = self.run_prepare()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(sentinel.read_text(), 'existing cache')

    def test_nonworking_compiler_does_not_promote_cache(self):
        compiler = self.origin / 'clang-r450784d/bin/clang-14'
        compiler.write_text('#!/bin/sh\nexit 8\n')
        subprocess.run(['git', '-C', str(self.origin), 'add', '.'], check=True, capture_output=True)
        subprocess.run(['git', '-C', str(self.origin), '-c', 'user.name=Fixture', '-c',
                        'user.email=fixture@example.invalid', 'commit', '-qm', 'nonworking compiler'], check=True, capture_output=True)
        self.commit = subprocess.check_output(['git', '-C', str(self.origin), 'rev-parse', 'HEAD'], text=True).strip()
        result = self.run_prepare()
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.destination.exists())

    def test_compiler_preflight_precedes_firmware_in_full_workflow(self):
        workflow = (ROOT / '.github/workflows/build.yml').read_text()
        self.assertLess(workflow.index('Verify exact GMKernel compiler'), workflow.index('Download stock firmwares'))
        source = (ROOT / 'platform/exynos990/patches/extremekrnl/customize.sh').read_text()
        body = source.split('BUILD_KERNEL()', 1)[1]
        self.assertLess(body.index('PREPARE_KERNEL_COMPILER'), body.index('./build.sh'))
        self.assertIn('gmkernel-build.log', body)


if __name__ == '__main__':
    unittest.main()
