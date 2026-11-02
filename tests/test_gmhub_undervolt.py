"""Run the real JVM backend guards, and require source/generated parity."""
from pathlib import Path
import importlib.util
import os
import shutil
import subprocess
import tempfile
import unittest
import xml.etree.ElementTree as ET

ROOT=Path(__file__).resolve().parents[1]
MODULE=ROOT/'unica/mods/settings'
SOURCE=MODULE/'undervolt/src/com/gmhub/uv/UvBackend.java'

class UndervoltContracts(unittest.TestCase):
    def test_generated_code_matches_sdk_sources(self):
        spec=importlib.util.spec_from_file_location('uvverify',MODULE/'undervolt/verify.py')
        mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
        mod.verify(MODULE)

    def test_selected_controls_and_shell_injection_guards_real_jvm(self):
        java=shutil.which('java');javac=shutil.which('javac')
        if not java or not javac:self.skipTest('JDK is unavailable on this host')
        with tempfile.TemporaryDirectory() as directory:
            folder=Path(directory)
            harness=folder/'UvContract.java'
            harness.write_text('''import com.gmhub.uv.UvBackend;
import java.util.Arrays;
public final class UvContract {
 static void check(boolean result) { if (!result) throw new AssertionError(); }
 interface Call { void run() throws Exception; }
 static void rejected(Call c) throws Exception {
   try { c.run(); throw new AssertionError("unexpectedly accepted"); }
   catch (IllegalArgumentException expected) {}
 }
 public static void main(String[] args) throws Exception {
   check(Arrays.equals(UvBackend.DOMAINS, new String[]{"lit","mid","big","g3d","mif"}));
   check(UvBackend.MIN == -10 && UvBackend.MAX == 0);
   for (int n=-100;n<=100;n++) check(UvBackend.parsePercent(Integer.toString(n))==n);
   for (String s : new String[]{"", "-101", "101", "-5; reboot", "1\\n0", "00", "NaN", "2147483648"})
     rejected(() -> UvBackend.parsePercent(s));
   for (String domain : new String[]{"../lit", "lit; reboot", "cam", "fsys0", ""})
     rejected(() -> UvBackend.apply(domain, 0));
   rejected(() -> UvBackend.apply("lit", -11));
   rejected(() -> UvBackend.apply("g3d", 1));
   System.out.println("Real undervolt backend: selected domains, percent parser, ranges and injection rejection passed");
 }
}
''',encoding='utf-8')
            subprocess.run([javac,'--release','8','-d',str(folder),str(SOURCE),str(harness)],check=True,capture_output=True)
            result=subprocess.run([java,'-Xverify:all','-cp',str(folder),'UvContract'],check=True,capture_output=True,text=True)
            self.assertIn('injection rejection passed',result.stdout)

    def test_hub_entry_and_native_view_resolve(self):
        ns='{http://schemas.android.com/apk/res/android}'
        screen=ET.parse(MODULE/'SecSettings.apk/res/xml/unica_top_settings.xml').getroot()
        entries=[e for e in screen if e.get(ns+'key')=='gm_hub_undervolt']
        self.assertEqual(len(entries),1)
        self.assertEqual(entries[0].get(ns+'fragment'),'com.paradox.hub.UndervoltFragment')
        view=ET.parse(MODULE/'SecSettings.apk/res/layout/gm_undervolt_panel.xml').getroot()
        self.assertTrue((MODULE/('SecSettings.apk/smali_classes4/'+view.tag.replace('.','/')+'.smali')).is_file())

if __name__=='__main__':unittest.main()
