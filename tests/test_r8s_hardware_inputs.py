"""Catch lost stock sensors/HALs and invalid multi-HAL loader inputs before packaging."""
import importlib.util
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('hardware_inputs', ROOT / 'target/r8s/validate_hardware_inputs.py')
hardware = importlib.util.module_from_spec(spec)
spec.loader.exec_module(hardware)


def fixture(root):
    for folder in ('vendor/etc/permissions', 'vendor/etc/sensors', 'vendor/etc/vintf', 'vendor/lib64'):
        (root / folder).mkdir(parents=True)
    (root / 'vendor/etc/permissions/android.hardware.sensor.accelerometer.xml').write_text(
        '<permissions><feature name="android.hardware.sensor.accelerometer"/></permissions>')
    (root / 'vendor/etc/vintf/manifest.xml').write_text(
        '<manifest><hal><name>android.hardware.sensors</name><version>2.0</version></hal></manifest>')
    (root / 'vendor/etc/sensors/hals.conf').write_text('/system/vendor/lib64/sensors.sensorhub.so\n')
    elf = bytearray(20)
    elf[:4] = b'\x7fELF'
    elf[4:6] = bytes((2, 1))
    elf[18:20] = (183).to_bytes(2, 'little')
    (root / 'vendor/lib64/sensors.sensorhub.so').write_bytes(elf)


class HardwareInputTests(unittest.TestCase):
    def run_case(self, change):
        with tempfile.TemporaryDirectory() as tmp:
            stock, final = Path(tmp) / 'stock', Path(tmp) / 'final'
            fixture(stock)
            fixture(final)
            change(stock, final)
            return hardware.verify(stock, final)

    def test_preserved_modules_resolve_legacy_system_vendor_path(self):
        result = self.run_case(lambda stock, final: None)
        self.assertEqual(result['stock_sensor_modules_preserved'], 1)

    def test_missing_sensor_library_is_a_build_failure(self):
        with self.assertRaisesRegex(ValueError, 'library is missing'):
            self.run_case(lambda stock, final: (final / 'vendor/lib64/sensors.sensorhub.so').unlink())

    def test_wrong_architecture_cannot_pass_with_valid_elf_magic(self):
        with self.assertRaisesRegex(ValueError, 'wrong ELF ABI'):
            self.run_case(lambda stock, final: (final / 'vendor/lib64/sensors.sensorhub.so').write_bytes(
                b'\x7fELF\x01\x01' + bytes(14)))

    def test_removed_accelerometer_feature_is_detected(self):
        with self.assertRaisesRegex(ValueError, 'hardware features missing'):
            self.run_case(lambda stock, final: (final / 'vendor/etc/permissions/android.hardware.sensor.accelerometer.xml').write_text('<permissions/>'))

    def test_missing_sensor_manifest_is_detected(self):
        with self.assertRaisesRegex(ValueError, 'HAL declarations missing'):
            self.run_case(lambda stock, final: (final / 'vendor/etc/vintf/manifest.xml').write_text('<manifest/>'))

    def test_hal_version_migration_is_not_mistaken_for_hardware_removal(self):
        self.run_case(lambda stock, final: (final / 'vendor/etc/vintf/manifest.xml').write_text(
            '<manifest><hal><name>android.hardware.sensors</name><version>2.1</version></hal></manifest>'))

    def test_unrelated_app_permission_templates_do_not_invalidate_hardware_inventory(self):
        self.run_case(lambda stock, final: (stock / 'vendor/etc/permissions/privapp-placeholder.xml').write_text(''))

    def test_check_runs_after_rom_mods_before_package_compilation(self):
        source = (ROOT / 'scripts/make_rom.sh').read_text(encoding='utf-8')
        self.assertGreater(source.index('target/r8s/validate_hardware_inputs.py'), source.index('"Applying ROM mods"'))
        self.assertLess(source.index('target/r8s/validate_hardware_inputs.py'), source.index('BUILD_APKS "$APK_BUILD_LIST"'))


if __name__ == '__main__':
    unittest.main()
