"""Select exact Android17 compatibility patches without affecting old donors."""
from pathlib import Path
import re
import subprocess
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[1]
MODULE=ROOT/'unica/mods/deknox'


class Android17IntelligenceTests(unittest.TestCase):
    def test_old_and_new_donors_select_only_their_own_patch(self):
        text=(MODULE/'customize.sh').read_text(encoding='utf-8')
        blocks=re.findall(r'(?m)^if \[\[ "\$SOURCE_PLATFORM_SDK_VERSION" -ge 37 \]\]; then\n(?:(?!^fi$)[\s\S])*?^fi$',text)
        blocks=[b for b in blocks if 'SecSettingsIntelligence.apk/0002-Android17-compatibility.patch' in b]
        self.assertEqual(len(blocks),2)
        for sdk in (33,36,37):
            with self.subTest(sdk=sdk), tempfile.TemporaryDirectory() as directory:
                script=Path(directory)/'select.sh'
                script.write_text('''set -euo pipefail
APPLY_PATCH() { printf 'PATCH %s\\n' "$3"; }
SMALI_PATCH() { :; }
MODPATH=module
HDM_VERSION=version
HDM_POLICY_TYPE=policy
SOURCE_PLATFORM_SDK_VERSION='''+str(sdk)+'\n'+'\n'.join(blocks)+'\n',encoding='utf-8')
                result=subprocess.run(['bash',str(script)],capture_output=True,text=True,check=True)
                selected=result.stdout.splitlines()
                self.assertEqual(len(selected),2)
                self.assertTrue(all(('0002-Android17-compatibility.patch' in line)==(sdk>=37) for line in selected))

    def test_exact_dual_version_is_not_applied_to_old_donors(self):
        old=(MODULE/'ddar/SecSettingsIntelligence.apk/0001-Nuke-Knox-DualDAR.patch').read_text(encoding='utf-8')
        new=(MODULE/'ddar/SecSettingsIntelligence.apk/0002-Android17-compatibility.patch').read_text(encoding='utf-8')
        self.assertIn('"1.8.0"',old)
        self.assertIn('"1.9.0"',new)
        self.assertIn('getDualDARVersion()Ljava/lang/String;',new)
        self.assertIn('isDualDarSupportedForManagedDevice()Z',new)

    def test_android17_hdm_keeps_the_existing_policy_and_method_interfaces(self):
        new=(MODULE/'hdm/SecSettingsIntelligence.apk/0002-Android17-compatibility.patch').read_text(encoding='utf-8')
        self.assertIn('getHdmVersion()Ljava/lang/String;',new)
        self.assertIn('getHdmPolicy(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;',new)
        self.assertIn('setHdmPolicy(Ljava/lang/String;)Ljava/lang/String;',new)
        self.assertIn('getHdmPolicy(Ljava/lang/String;)Ljava/lang/String;',new)
        self.assertIn('setHdmPolicy(Ljava/lang/String;Z)Ljava/lang/String;',new)
        self.assertNotRegex(new,r'(?m)^[-+]\.method ')
        self.assertNotRegex(new,r'(?m)^[-+]\.field ')
        self.assertNotIn('framework.jar/',new)


if __name__=='__main__':unittest.main()
