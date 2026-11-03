"""Regressions for the failures reproduced and fixed during physical boot."""
from pathlib import Path
import hashlib
import importlib.util
import tempfile
import unittest
from unittest.mock import patch
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('boot_graphics', ROOT/'target/r8s/finalize_boot_graphics.py')
boot = importlib.util.module_from_spec(spec)
spec.loader.exec_module(boot)
MANIFEST = '''<manifest version="1.0" type="device" target-level="4">
<hal format="hidl"><name>android.hardware.graphics.allocator</name><transport>hwbinder</transport>
<version>2.0</version><interface><name>IAllocator</name><instance>default</instance></interface>
<fqname>@2.0::IAllocator/default</fqname></hal>
<hal format="hidl"><name>android.hardware.keymaster</name><version>4.0</version></hal>
</manifest>'''
RC = '''service vendor.gralloc-4-0 /vendor/bin/hw/android.hardware.graphics.allocator@4.0-service-sgr
    class hal animation
    interface android.hardware.graphics.allocator@4.0::IAllocator default
    user system
    group graphics drmrpc
    capabilities SYS_NICE SYS_RESOURCE
    onrestart restart surfaceflinger
'''


class BootGraphicsTests(unittest.TestCase):
    def make_tree(self, root):
        ui = bytearray(0x59000)
        for off, original in boot.GATES:
            ui[off:off+4] = bytes.fromhex(original)
        expected = bytearray(ui)
        for off, _ in boot.GATES:
            expected[off:off+4] = boot.NOP
        files = {'system/system/lib64/libui.so': bytes(ui),
                 'vendor/etc/vintf/manifest.xml': MANIFEST.encode(),
                 'vendor/etc/init/android.hardware.graphics.allocator@4.0-service-sgr.rc': RC.encode()}
        hashes, fs, contexts = {}, '', ''
        for name in boot.DONORS:
            data = ('exact donor ' + name).encode()
            files[f'vendor/lib64/{name}.so'] = data
            hashes[name] = hashlib.sha256(data).hexdigest()
            fs += f'vendor/lib64/{name}.so 0 2000 644 capabilities=0x0\n'
            contexts += f'/vendor/lib64/{name}\\.so u:object_r:same_process_hal_file:s0\n'
        files['configs/fs_config-vendor'] = fs.encode()
        files['configs/file_context-vendor'] = contexts.encode()
        for name, data in files.items():
            path = root/name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(data)
        return hashes, hashlib.sha256(expected).hexdigest(), files

    def test_finalizer_is_idempotent_and_keeps_private_donor_bytes(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            hashes, ui_hash, original = self.make_tree(root)
            with patch.object(boot, 'DONORS', hashes), patch.object(boot, 'UI_FINAL_SHA256', ui_hash):
                boot.finalize(root)
                snapshot = {p.relative_to(root): p.read_bytes() for p in root.rglob('*') if p.is_file()}
                boot.finalize(root)
            self.assertEqual(snapshot, {p.relative_to(root):p.read_bytes() for p in root.rglob('*') if p.is_file()})
            for name in hashes:
                self.assertFalse((root/f'vendor/lib64/{name}.so').exists())
                self.assertEqual((root/f'vendor/lib64/{name}.gm').read_bytes(), original[f'vendor/lib64/{name}.so'])
            self.assertIn(boot.PRELOAD, (root/'vendor/etc/init/android.hardware.graphics.allocator@4.0-service-sgr.rc').read_text())
            self.assertIn('onrestart restart surfaceflinger', (root/'vendor/etc/init/android.hardware.graphics.allocator@4.0-service-sgr.rc').read_text())
            for part in ['fs_config-vendor', 'file_context-vendor']:
                self.assertNotIn('.so ', (root/'configs'/part).read_text())

    def test_unknown_donor_aborts_before_any_file_changes(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            hashes, ui_hash, _ = self.make_tree(root)
            (root/'vendor/lib64/libhardware.so').write_bytes(b'changed ABI')
            before = {p.relative_to(root):p.read_bytes() for p in root.rglob('*') if p.is_file()}
            with patch.object(boot, 'DONORS', hashes), patch.object(boot, 'UI_FINAL_SHA256', ui_hash):
                with self.assertRaisesRegex(ValueError, 'Unknown donor library'):
                    boot.finalize(root)
            self.assertEqual(before, {p.relative_to(root):p.read_bytes() for p in root.rglob('*') if p.is_file()})

    def test_unknown_libui_is_rejected(self):
        with self.assertRaisesRegex(ValueError, 'Unknown libui'):
            boot.prepare_ui(bytes(0x59000))

    def test_manifest_preserves_stock_allocator_and_keymaster(self):
        changed = boot.prepare_manifest(MANIFEST)
        result = ET.fromstring(changed)
        self.assertEqual([ET.tostring(h).strip() for h in ET.fromstring(MANIFEST)],
                         [ET.tostring(h).strip() for h in result][:-1])
        self.assertEqual(boot.prepare_manifest(changed), changed)
        self.assertEqual(result[-1].findtext('transport'), 'hwbinder')
        self.assertEqual(result[-1].findtext('fqname'), '@4.0::IAllocator/default')

    def test_conflicting_preload_is_not_overwritten(self):
        with self.assertRaisesRegex(ValueError, 'Conflicting allocator4'):
            boot.prepare_rc(RC.replace('    class', '    setenv LD_PRELOAD unexpected.so\n    class', 1))

    def test_finalization_runs_after_all_modules_and_before_hardware_validation(self):
        source = (ROOT/'scripts/make_rom.sh').read_text(encoding='utf-8')
        end = source.index('target/r8s/finalize_boot_graphics.py')
        self.assertLess(source.index('"$SRC_DIR/unica/mods" || exit 1'), end)
        self.assertLess(end, source.index('target/r8s/validate_hardware_inputs.py'))


if __name__ == '__main__':
    unittest.main()
