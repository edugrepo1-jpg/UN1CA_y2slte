"""Exercise the entire modern entrypoint, not unreachable legacy fragments."""
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[1]
MODULE=ROOT/'unica/mods/deknox'


class ModernSettingsIntelligenceTests(unittest.TestCase):
    def test_full_modern_entrypoint_preserves_settings_intelligence(self):
        for sdk in (36,37):
            with self.subTest(sdk=sdk), tempfile.TemporaryDirectory() as directory:
                root=Path(directory)
                framework=root/'system/framework/framework.jar'
                rune=framework/'smali/com/samsung/android/ProductPackagesRune.smali'
                rune.parent.mkdir(parents=True)
                rune.write_text('.class public Lcom/samsung/android/ProductPackagesRune;\n'
                                '.field public static final SERVICE_SAMSUNG_BLOCKCHAIN:Z = true\n',encoding='utf-8')
                script=root/'run.sh'
                script.write_text('''set -euo pipefail
LOG() { :; }
SET_PROP_IF_DIFF() { printf 'PROP|%s\\n' "$2"; }
SET_FLOATING_FEATURE_CONFIG() { printf 'FEATURE|%s\\n' "$1"; }
DECODE_APK() { printf 'DECODE|%s\\n' "$2"; }
APPLY_PATCH() { printf 'PATCH|%s|%s\\n' "$2" "$3"; }
SMALI_PATCH() { printf 'SMALI|%s|%s\\n' "$2" "$3"; }
SOURCE_PLATFORM_SDK_VERSION='''+str(sdk)+'''
APKTOOL_DIR="$1"
MODPATH="$2"
. "$2/customize.sh"
printf 'DONE\\n'
''',encoding='utf-8')
                result=subprocess.run(['bash',str(script),str(root),str(MODULE)],capture_output=True,text=True,check=True)
                lines=result.stdout.splitlines()
                self.assertEqual(lines[-1],'DONE')
                self.assertEqual(sum(l.startswith('PATCH|') for l in lines),1)
                self.assertIn('/knoxguard/services.jar/0001-Disable-KnoxGuard.patch',result.stdout.replace('\\','/'))
                self.assertNotIn('SecSettingsIntelligence',result.stdout)
                self.assertNotIn('HdmManager',result.stdout)
                self.assertNotIn('DualDAR',result.stdout)
                self.assertIn('DECODE|system/framework/framework.jar',lines)

    def test_obsolete_api37_patch_selection_is_not_reintroduced(self):
        text=(MODULE/'customize.sh').read_text(encoding='utf-8')
        self.assertIn('if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge "36" ]; then',text)
        self.assertIn('    return 0\nfi',text)
        self.assertNotIn('0002-Android17-compatibility.patch',text)
        for kind,label in (('ddar','DualDAR'),('hdm','HDM')):
            self.assertTrue((MODULE/kind/'SecSettingsIntelligence.apk'/('0001-Nuke-Knox-'+label+'.patch')).exists())


if __name__=='__main__':unittest.main()
