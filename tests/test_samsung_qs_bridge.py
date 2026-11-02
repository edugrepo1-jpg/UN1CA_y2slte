"""Execute the staged native QS adapter; never launch an Android runtime."""
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


@unittest.skipUnless(shutil.which('java') and shutil.which('javac'), 'JDK unavailable')
class SamsungQsBridge(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.classes = tempfile.TemporaryDirectory(prefix='samsung-qs-classes-')
        cls.addClassCleanup(cls.classes.cleanup)
        sources = [
            *(ROOT / 'target/r8s/ui/apple_qs/src/com/gmhub/qs').glob('*.java'),
            *(ROOT / 'target/r8s/ui/apple_qs/android/com/gmhub/qs').glob('*.java'),
            *(ROOT / 'tests/java').glob('*Contract.java'),
            *(ROOT / 'tests/java/view-fixtures').rglob('*.java'),
        ]
        # One host compilation per suite, separate JVM execution per contract.
        # Platform fixtures never enter the production SDK/D8 compilation.
        compiled = subprocess.run([
            shutil.which('javac'), '--release', '8', '-Xlint:-options', '-d', cls.classes.name,
            *[str(p) for p in sources],
        ], capture_output=True, text=True, timeout=60)
        if compiled.returncode:
            raise RuntimeError(compiled.stdout + compiled.stderr)

    def test_native_actions_policy_user_and_listener_lifecycle(self):
        self.run_contract('SamsungTilesContract', 'Samsung QS behavioral checks passed:')

    def test_editor_geometry_transactions_rotation_and_cancel(self):
        self.run_contract('QsLayoutContract', 'QS layout invariants passed:')

    def test_pointer_identity_multitouch_cancel_and_touch_slop(self):
        self.run_contract('EditPointerContract', 'QS pointer ownership/cancel checks passed:')

    def test_persistence_restart_backup_stale_saves_and_user_isolation(self):
        self.run_contract('LayoutPersistenceContract', 'QS persistence/restart/atomic-save checks passed:')

    def test_native_view_transfer_restore_and_configuration_ownership(self):
        self.run_contract('NativeViewLeaseContract', 'Native view loan/rollback/ownership checks passed:')

    def test_samsung_compose_scene_native_models_gallery_and_lock_policy(self):
        self.run_contract('SamsungSceneContract', 'Samsung Compose scene/native item/security checks passed:')

    def run_contract(self, contract, success):
        with tempfile.TemporaryDirectory(prefix='samsung-qs-contract-') as temp:
            executed = subprocess.run([
                shutil.which('java'), '-Xverify:all', '-Dqs.contract.tmp=' + temp,
                '-cp', self.classes.name, contract,
            ], capture_output=True, text=True, timeout=30)
            self.assertEqual(executed.returncode, 0, executed.stdout + executed.stderr)
            self.assertIn(success, executed.stdout)


if __name__ == '__main__':
    unittest.main()
