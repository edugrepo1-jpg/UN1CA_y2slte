"""Tests of actual integration contracts, fallback and renderer provenance."""
from pathlib import Path
import hashlib
import importlib.util
import json
import shutil
import tempfile
import unittest
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / 'unica/mods/liquid_glass'
SETTINGS = ROOT / 'unica/mods/settings/SecSettings.apk'
spec = importlib.util.spec_from_file_location('glass_install', MODULE / 'install.py')
installer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(installer)
A = '{http://schemas.android.com/apk/res/android}'


def fixture():
    return ('.class public final ' + installer.OWNER + '\n' + installer.SIGNATURE
            + '\n    .locals 8\n'
            + '    invoke-virtual {p0, v0}, Lcom/samsung/android/graphics/SemGfxImageFilter;->applyToBitmap(Landroid/graphics/Bitmap;)Landroid/graphics/Bitmap;\n'
            + '    return-object v4\n.end method\n')


class LiquidGlassIntegration(unittest.TestCase):
    def test_three_real_pinned_shaders_and_licenses(self):
        assets = MODULE / 'assets/gmhub/liquid_glass'
        provenance = json.loads((assets / 'provenance.json').read_text(encoding='utf-8'))
        self.assertEqual([p['id'] for p in provenance], ['qwea', 'kyant', 'color'])
        digests = []
        for item in provenance:
            self.assertEqual(len(item['commit']), 40)
            source = MODULE / 'upstream' / (item['id'] + '.kt')
            shader = assets / (item['id'] + '.agsl')
            digest = hashlib.sha256(shader.read_bytes()).hexdigest()
            self.assertEqual(digest, item['shader_sha256'])
            self.assertEqual(hashlib.sha256(source.read_bytes()).hexdigest(), item['source_sha256'])
            self.assertIn('main(', shader.read_text(encoding='utf-8'))
            self.assertNotIn('$RoundedRectSDF', shader.read_text(encoding='utf-8'))
            self.assertTrue((assets / (item['id'] + '-LICENSE.txt')).is_file())
            digests.append(digest)
        self.assertEqual(len(set(digests)), 3)

    def test_hook_keeps_native_filter_and_is_idempotent(self):
        original = fixture()
        patched = installer.patch(original)
        self.assertIn('    .locals 10', patched)
        self.assertIn('->applyToBitmap(', patched)
        self.assertEqual(patched.count(installer.HOOK), 1)
        self.assertGreater(patched.index(installer.HOOK), patched.index('->applyToBitmap('))
        self.assertEqual(installer.patch(patched), patched)
        self.assertIn('move-result-object v9', patched)

    def test_unknown_contract_is_rejected(self):
        for changed in (fixture().replace('.locals 8', '.locals 9'),
                        fixture().replace('return-object v4', 'return-object v3'),
                        fixture().replace('getBlurredBitmapWithEffect', 'unknownMethod')):
            with self.assertRaises(ValueError):
                installer.patch(changed)

    def test_install_reuses_dex_directory_and_never_touches_other_scenes(self):
        with tempfile.TemporaryDirectory() as directory:
            decoded = Path(directory)
            target = decoded / 'smali_classes2/com/android/systemui/blur/domain/interactor/SecCapturedBlurBitmapGenerator.smali'
            target.parent.mkdir(parents=True)
            target.write_text(fixture(), encoding='utf-8')
            installer.install(decoded, MODULE)
            installer.install(decoded, MODULE)
            definitions = list(decoded.glob('smali*/com/gmhub/glass/GlassDrawable.smali'))
            self.assertEqual(len(definitions), 1)
            self.assertTrue((decoded / 'assets/gmhub/liquid_glass/kyant.agsl').is_file())
            java = (MODULE / 'src/com/gmhub/glass/GlassDrawable.java').read_text(encoding='utf-8')
            self.assertIn('!"QUICK_PANEL".equals(scene)', java)
            self.assertNotIn('takeScreenshot', java)
            self.assertNotIn('FLAG_SECURE', java)

    def test_stale_adapter_rejected_before_apk_changes(self):
        with tempfile.TemporaryDirectory() as directory:
            module = Path(directory) / 'module'
            shutil.copytree(MODULE, module)
            java = module / 'src/com/gmhub/glass/GlassDrawable.java'
            java.write_text(java.read_text(encoding='utf-8') + '\n// changed\n', encoding='utf-8')
            decoded = Path(directory) / 'decoded'
            decoded.mkdir()
            with self.assertRaisesRegex(ValueError, 'out of sync'):
                installer.install(decoded, module)
            self.assertEqual(list(decoded.iterdir()), [])

    def test_no_fake_success_or_extra_idle_work(self):
        java = (MODULE / 'src/com/gmhub/glass/GlassDrawable.java').read_text(encoding='utf-8')
        self.assertIn('return original;', java)
        self.assertIn('fallback.draw(canvas)', java)
        self.assertIn('!canvas.isHardwareAccelerated()', java)
        self.assertIn('!pm.isPowerSaveMode()', java)
        self.assertIn('pm.getCurrentThermalStatus() < 2', java)
        self.assertIn('high_text_contrast_enabled', java)
        self.assertIn('accessibility_reduce_transparency', java)
        self.assertIn('MAX_PIXELS', java)
        for forbidden in ('postInvalidate', 'postDelayed', 'SensorManager', 'PixelCopy', 'new Timer', 'new Thread'):
            self.assertNotIn(forbidden, java)

    def test_hub_has_three_exclusive_choices_and_native_restore(self):
        resources = ET.parse(SETTINGS / 'res/values/gm_glass.xml').getroot()
        values = resources.find("./string-array[@name='gm_glass_engine_values']")
        self.assertEqual([n.text for n in values], ['0', '1', '2', '3'])
        xml = ET.parse(SETTINGS / 'res/xml/gm_glass_preferences.xml').getroot()
        prefs = xml.findall('ListPreference')
        self.assertEqual(len(prefs), 1)
        self.assertEqual(prefs[0].get(A + 'persistent'), 'false')
        fragment = (SETTINGS / 'smali_classes4/com/paradox/hub/GlassSettingsFragment.smali').read_text(encoding='utf-8')
        self.assertIn('Settings$Global;->putInt', fragment)
        self.assertIn('Settings$Global;->getInt', fragment)
        self.assertIn('->findIndexOfValue(', fragment)
        self.assertIn('ro.gmhub.glass.renderers', fragment)
        self.assertNotIn('->reboot(', fragment)
        top = ET.parse(SETTINGS / 'res/xml/unica_top_settings.xml').getroot()
        self.assertTrue(any(n.get(A + 'fragment') == 'com.paradox.hub.GlassSettingsFragment' for n in top))


if __name__ == '__main__':
    unittest.main()
