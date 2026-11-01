#!/usr/bin/env python3
"""Static tests for the unified r8s GM Hub built on DZG1 SecSettings."""
from __future__ import annotations

from pathlib import Path
import re
import unittest
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "unica/mods/settings/SecSettings.apk"
XML = BASE / "res/xml"
VALUES = BASE / "res/values"
SMALI = BASE / "smali_classes4/com/paradox/hub"
ANDROID = "{http://schemas.android.com/apk/res/android}"


class GMHubSourceContracts(unittest.TestCase):
    def test_one_hub_entry_preserves_artisan_unica_features(self):
        root = ET.parse(XML / "unica_top_settings.xml").getroot()
        self.assertIn("GM HUB", ET.parse(VALUES / "strings.xml").getroot().find(
            "./string[@name='unica_settings_title']").text)
        fragments = [e.get(ANDROID + "fragment", "") for e in root.iter()]
        for fragment in (
            "com.paradox.hub.ParadoxCenterFragment",
            "com.paradox.hub.ParadoxCoreModesFragment",
            "com.paradox.hub.ParadoxMemoryFragment",
            "com.paradox.hub.ParadoxBatteryFragment",
            "io.mesalabs.unica.settings.ui.UISettingsFragment",
            "io.mesalabs.unica.settings.spoof.SpoofSettingsFragment",
            "io.mesalabs.unica.settings.extra.ExtraSettingsFragment",
            "io.mesalabs.unica.settings.about.AboutArtisanROMFragment",
        ):
            self.assertIn(fragment, fragments)
        # Do not present potentially destructive or uncalibrated screens.
        self.assertNotIn("com.paradox.hub.ParadoxAppManagerFragment", fragments)
        self.assertNotIn("com.paradox.hub.ParadoxThermalFragment", fragments)

    def test_branding_and_original_credits(self):
        strings = ET.parse(VALUES / "strings.xml").getroot()
        lookup = {e.get("name"): e.text for e in strings if e.tag == "string"}
        self.assertEqual(lookup["unica_settings_title"], "GM HUB")
        self.assertEqual(lookup["gm_hub_maintainer_name"], "GMNevz")
        self.assertEqual(lookup["gm_hub_kernel_name"], "GMKernel")
        self.assertEqual(lookup["unica_about_artisanrom_title"], "Sobre o GM HUB")
        top = ET.parse(XML / "unica_top_settings.xml").getroot()
        keys = {e.get(ANDROID + "key") for e in top.iter()}
        self.assertIn("gm_hub_maintainer", keys)
        self.assertIn("gm_hub_kernel", keys)
        credits = ET.parse(VALUES / "artisanrom.xml").getroot()
        people = {e.get("name"): e.text for e in credits if e.tag == "string"}
        self.assertEqual(people["maintainer_23_name"], "GMNevz")
        self.assertEqual(people["maintainer_23_role"].split(" ")[0], "Mantenedor")
        self.assertEqual(people["maintainer_1_name"], "Android Artisan")
        self.assertIn("UN1CA", people["artisanrom_about_description"])
        props = (ROOT / "target/r8s/patches/hardware_compat/system.prop").read_text(encoding="utf-8")
        self.assertIn("ro.gmhub.name=GM HUB", props)
        self.assertIn("ro.gmhub.maintainer=GMNevz", props)
        self.assertIn("ro.gmhub.kernel=GMKernel", props)

    def test_gm_hub_icons_are_bundled_and_not_donor_dependent(self):
        home = ET.parse(XML / "unica_top_settings.xml").getroot()
        for node in home.iter():
            key = node.get(ANDROID + "key", "")
            if not key.startswith("gm_hub_"):
                continue
            icon = node.get(ANDROID + "icon")
            if not icon:
                continue
            self.assertTrue(icon.startswith("@drawable/ic_unica_settings_"))
            expected = BASE / "res/drawable" / (icon.split("/")[-1] + ".xml")
            self.assertTrue(expected.is_file(), str(expected))

    def test_resource_names_do_not_conflict(self):
        names = []
        for filename in ("paradox.xml", "strings.xml", "artisanrom.xml"):
            resource = ET.parse(VALUES / filename).getroot()
            names.append({(e.tag, e.get("name")) for e in resource
                          if e.get("name")})
        self.assertFalse(names[0] & names[1])
        self.assertFalse(names[0] & names[2])

    def test_xml_resource_references_resolve(self):
        known = set()
        for xml_file in VALUES.glob("*.xml"):
            root = ET.parse(xml_file).getroot()
            known.update(e.get("name") for e in root if e.get("name"))
        for xml_file in XML.glob("paradox_*.xml"):
            xml_text = xml_file.read_text(encoding="utf-8")
            ET.fromstring(xml_text)
            for string_name in re.findall(r"@string/([a-zA-Z0-9_]+)", xml_text):
                self.assertIn(string_name, known, (xml_file, string_name))

    def test_unknown_hardware_controls_not_exposed(self):
        panel = ET.parse(XML / "paradox_center_preferences.xml").getroot()
        keys = [e.get(ANDROID + "key") for e in panel.iter()]
        for forbidden in (
            "screen_resolution", "paradox_wifi_ping", "cached_apps_freezer",
            "paradox_audio_dac", "paradox_anti_tracking",
        ):
            self.assertNotIn(forbidden, keys)
        for required in ("min_refresh_rate", "max_refresh_rate",
                         "reset_refresh_rate", "paradox_touch_overdrive"):
            self.assertIn(required, keys)

    def test_r8s_60_120_panel_modes(self):
        values = ET.parse(VALUES / "paradox.xml").getroot()
        refresh = values.find("./string-array[@name='paradox_refresh_rates']")
        self.assertIsNotNone(refresh)
        self.assertEqual([e.text for e in refresh], ["60", "120"])
        # 96 Hz needs runtime EA8079 detection; the pinned kernel supports it,
        # but the generic GM Hub must not offer it to S6E3FC3.
        for filename in ("ParadoxCoreModesFragment.smali",
                         "ParadoxCenterFragment.smali"):
            text = (SMALI / filename).read_text(encoding="utf-8")
            self.assertNotIn('"48.0"', text)
            self.assertNotIn("0x42400000    # 48.0f", text)

    def test_all_ported_classes_present(self):
        expected = (
            "ParadoxCenterFragment",
            "ParadoxCoreModesFragment",
            "ParadoxMemoryFragment",
            "ParadoxBatteryFragment",
            "ParadoxThermalFragment",
            "ParadoxAppManagerFragment",
            "ParadoxSystemMonitor",
        )
        for name in expected:
            with self.subTest(name=name):
                content = (SMALI / (name + ".smali")).read_text(encoding="utf-8")
                self.assertIn("Lcom/paradox/hub/" + name + ";", content)
                self.assertIn(".class", content)
        self.assertGreaterEqual(len(list(SMALI.glob("*.smali"))), 20)


if __name__ == "__main__":
    unittest.main()
