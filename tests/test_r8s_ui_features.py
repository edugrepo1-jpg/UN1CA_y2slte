#!/usr/bin/env python3
"""No-firmware contract tests for Pure Black and OneLab SSRM r8s ports."""
from __future__ import annotations

import importlib.util
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


def load(name: str, path: str):
    spec = importlib.util.spec_from_file_location(name, ROOT / path)
    if spec is None or spec.loader is None:
        raise RuntimeError(path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


pure_black = load("r8s_pure_black", "target/r8s/apply_pure_black.py")
ssrm = load("r8s_ssrm", "target/r8s/patch_ssrm_multiwindow.py")
qs_anim = load("r8s_qs_anim", "target/r8s/optimize_systemui_diagnostics.py")


class PureBlackTests(unittest.TestCase):
    def test_landscape_night_qualifiers_are_patched_without_day_changes(self):
        with tempfile.TemporaryDirectory() as tmp:
            apk = Path(tmp)
            for folder in ('values-land-night-v37', 'values-land-notnight-v37',
                           'color-land-night-v37'):
                (apk / 'res' / folder).mkdir(parents=True)
            original = ('<resources><color name="sec_qs_detail_bg_color">'
                        '#e6fcfcfc</color></resources>')
            night = apk / 'res/values-land-night-v37/colors.xml'
            day = apk / 'res/values-land-notnight-v37/colors.xml'
            night.write_text(original, encoding='utf-8')
            day.write_text(original, encoding='utf-8')
            selector = apk / 'res/color-land-night-v37/notification_shade_bg.xml'
            selector.write_text(
                '<selector xmlns:android="http://schemas.android.com/apk/res/android">'
                '<item android:color="#ff202020" /></selector>', encoding='utf-8')
            pure_black.apply_systemui_dark_backgrounds(apk)
            self.assertIn('#ff000000', night.read_text(encoding='utf-8'))
            self.assertIn('#ff000000', selector.read_text(encoding='utf-8'))
            self.assertEqual(day.read_text(encoding='utf-8'), original)

    def test_exact_ezj1_primary_surfaces_are_opaque_black_only_at_night(self):
        with tempfile.TemporaryDirectory() as tmp:
            apk = Path(tmp)
            (apk / 'res/values').mkdir(parents=True)
            base = apk / 'res/values/colors.xml'
            original = (
                '<resources>'
                '<color name="qs_detail_background_color">@color/sec_qs_detail_bg_color</color>'
                '<color name="sec_qs_detail_bg_color">#e6fcfcfc</color>'
                '<color name="sec_qs_detailed_container_background">#4d000000</color>'
                '<color name="sec_qs_switch_on_background_color">#598fff</color>'
                '<color name="qs_switch_off_background_color">#33ffffff</color>'
                '</resources>'
            )
            base.write_text(original, encoding='utf-8')
            pure_black.apply_systemui_dark_backgrounds(apk)
            self.assertEqual(base.read_text(encoding='utf-8'), original)
            night = (apk / 'res/values-night/colors.xml').read_text(encoding='utf-8')
            for name in ('qs_detail_background_color', 'sec_qs_detail_bg_color',
                         'sec_qs_detailed_container_background'):
                self.assertIn(f'<color name="{name}">#ff000000</color>', night)
            self.assertNotIn('switch_on_background', night)
            self.assertNotIn('switch_off_background', night)
    def test_only_dark_opaque_named_backgrounds_change(self):
        with tempfile.TemporaryDirectory() as tmp:
            apk = Path(tmp)
            (apk / "res/values-night").mkdir(parents=True)
            (apk / "res/values").mkdir(parents=True)
            night = apk / "res/values-night/colors.xml"
            day = apk / "res/values/colors.xml"
            night.write_text(
                '<resources>\n'
                '<color name="sec_qs_background">#ff080808</color>\n'
                '<color name="qs_detail_background_color">#121212</color>\n'
                '<color name="qs_panel_background_color">#80080808</color>\n'
                '<color name="qs_tile_text">#ffffffff</color>\n'
                '<color name="other_background">#ff111111</color>\n'
                '</resources>\n', encoding="utf-8")
            day.write_text(
                '<resources><color name="sec_qs_background">#ffdddddd</color></resources>',
                encoding="utf-8")
            changes = pure_black.apply_systemui_dark_backgrounds(apk)
            result = night.read_text(encoding="utf-8")
            self.assertEqual(sum(changes.values()), 2)
            self.assertIn('<color name="sec_qs_background">#ff000000</color>', result)
            self.assertIn('<color name="qs_detail_background_color">#ff000000</color>', result)
            self.assertIn("#80080808", result)
            self.assertIn("#ffffffff", result)
            self.assertIn("#ff111111", result)
            self.assertIn("#ffdddddd", day.read_text(encoding="utf-8"))
            self.assertEqual(pure_black.apply_systemui_dark_backgrounds(apk), changes)

    def test_oneui9_base_colors_generate_night_only_override(self):
        """EZJ1 may not ship sec_qs_background or values-night/colors.xml."""
        with tempfile.TemporaryDirectory() as tmp:
            apk = Path(tmp)
            (apk / "res/values").mkdir(parents=True)
            base = apk / "res/values/colors.xml"
            original = (
                '<resources>\n'
                '<color name="quick_settings_panel_background">#ff161616</color>\n'
                '<color name="quick_settings_tile_background">#ff222222</color>\n'
                '<color name="qs_panel_scrim">#ff111111</color>\n'
                '</resources>'
            )
            base.write_text(original, encoding="utf-8")
            report = apk / "pure-black-report.txt"
            changes = pure_black.apply_systemui_dark_backgrounds(apk, report)
            self.assertTrue(changes)
            self.assertEqual(base.read_text(encoding="utf-8"), original)
            overlay = (apk / "res/values-night/colors.xml").read_text(
                encoding="utf-8"
            )
            self.assertIn(
                '<color name="quick_settings_panel_background">#ff000000</color>',
                overlay,
            )
            self.assertNotIn("tile_background", overlay)
            self.assertNotIn("panel_scrim", overlay)
            self.assertIn("quick_settings_panel_background", report.read_text())

    def test_does_not_blacken_subscreen_media_or_avatar_content(self):
        unsafe = (
            "clear_cover_subscreen_notification_hun_top_background",
            "qs_media_art_background",
            "qs_user_switcher_avatar_background",
            "subscreen_notification_detail_content_image_background",
            "sec_qs_media_player_guts_background_color",
            "controls_panel_background",
            "notification_material_background_media_default_color",
        )
        for resource in unsafe:
            with self.subTest(resource=resource):
                self.assertFalse(pure_black.is_target(resource))
        self.assertTrue(pure_black.is_target("sec_panel_background_color"))
        self.assertTrue(pure_black.is_target("qs_detail_background_color"))

    def test_oneui9_reference_background_gets_dark_only_override(self):
        with tempfile.TemporaryDirectory() as tmp:
            apk = Path(tmp)
            (apk / "res/values").mkdir(parents=True)
            base = apk / "res/values/colors.xml"
            original = (
                '<resources>'
                '<color name="sec_qs_panel_bg">@color/system_surface</color>'
                '<color name="qs_panel_scrim">@color/system_scrim</color>'
                '</resources>'
            )
            base.write_text(original, encoding="utf-8")
            changes = pure_black.apply_systemui_dark_backgrounds(apk)
            self.assertTrue(changes)
            self.assertEqual(base.read_text(encoding="utf-8"), original)
            overlay = (apk / "res/values-night/colors.xml").read_text(
                encoding="utf-8")
            self.assertIn(
                '<color name="sec_qs_panel_bg">#ff000000</color>', overlay
            )
            self.assertNotIn("qs_panel_scrim", overlay)

    def test_existing_night_name_in_another_file_is_not_redeclared(self):
        with tempfile.TemporaryDirectory() as tmp:
            apk = Path(tmp)
            (apk / "res/values").mkdir(parents=True)
            (apk / "res/values-night").mkdir(parents=True)
            (apk / "res/values/colors.xml").write_text(
                '<resources><color name="qs_panel_background_color">'
                '@color/dynamic_surface</color></resources>',
                encoding="utf-8",
            )
            existing = apk / "res/values-night/panel_colors.xml"
            existing.write_text(
                '<resources><color name="qs_panel_background_color">'
                '#ff292929</color></resources>',
                encoding="utf-8",
            )
            pure_black.apply_systemui_dark_backgrounds(apk)
            self.assertIn("#ff000000", existing.read_text(encoding="utf-8"))
            new = apk / "res/values-night/colors.xml"
            if new.exists():
                self.assertNotIn(
                    'name="qs_panel_background_color"',
                    new.read_text(encoding="utf-8"),
                )

    def test_oneui9_qualified_night_xml_is_patched_without_day_changes(self):
        with tempfile.TemporaryDirectory() as tmp:
            apk = Path(tmp)
            (apk / "res/color-night-v31").mkdir(parents=True)
            night = apk / "res/color-night-v31/notification_shade_bg.xml"
            night.write_text(
                '<selector xmlns:android="http://schemas.android.com/apk/res/android">'
                '<item android:color="#ff202020" />'
                '</selector>',
                encoding="utf-8",
            )
            changes = pure_black.apply_systemui_dark_backgrounds(apk)
            self.assertEqual(changes["res/color-night-v31/notification_shade_bg.xml"], 1)
            self.assertIn("#ff000000", night.read_text(encoding="utf-8"))

    def test_night_file_color_is_not_redeclared_in_values(self):
        with tempfile.TemporaryDirectory() as tmp:
            apk = Path(tmp)
            (apk / "res/values").mkdir(parents=True)
            (apk / "res/color-night").mkdir(parents=True)
            (apk / "res/values/colors.xml").write_text(
                '<resources><color name="notification_shade_bg">#ff202020</color></resources>',
                encoding="utf-8",
            )
            night = apk / "res/color-night/notification_shade_bg.xml"
            night.write_text(
                '<selector xmlns:android="http://schemas.android.com/apk/res/android">'
                '<item android:color="#ff202020" /></selector>', encoding="utf-8",
            )
            pure_black.apply_systemui_dark_backgrounds(apk)
            self.assertIn("#ff000000", night.read_text(encoding="utf-8"))
            generated = apk / "res/values-night/colors.xml"
            self.assertFalse(generated.exists())

    def test_values_night_color_blocks_duplicate_file_overlay(self):
        with tempfile.TemporaryDirectory() as tmp:
            apk = Path(tmp)
            (apk / "res/values-night").mkdir(parents=True)
            (apk / "res/color").mkdir(parents=True)
            night = apk / "res/values-night/colors.xml"
            night.write_text(
                '<resources><color name="notification_shade_bg">#ff202020</color></resources>',
                encoding="utf-8",
            )
            (apk / "res/color/notification_shade_bg.xml").write_text(
                '<selector xmlns:android="http://schemas.android.com/apk/res/android">'
                '<item android:color="#ff202020" /></selector>', encoding="utf-8",
            )
            pure_black.apply_systemui_dark_backgrounds(apk)
            self.assertIn("#ff000000", night.read_text(encoding="utf-8"))
            self.assertFalse((apk / "res/color-night/notification_shade_bg.xml").exists())

    def test_night_only_drawable_shape_override(self):
        with tempfile.TemporaryDirectory() as tmp:
            apk = Path(tmp)
            (apk / "res/drawable").mkdir(parents=True)
            original = (
                '<shape xmlns:android="http://schemas.android.com/apk/res/android">'
                '<solid android:color="#ff1b1b1b" /></shape>'
            )
            (apk / "res/drawable/sec_qs_panel_background.xml").write_text(
                original, encoding="utf-8"
            )
            changes = pure_black.apply_systemui_dark_backgrounds(apk)
            self.assertTrue(changes)
            self.assertIn(
                "#ff000000",
                (apk / "res/drawable-night/sec_qs_panel_background.xml")
                .read_text(encoding="utf-8"),
            )
            self.assertIn(
                "#ff1b1b1b",
                (apk / "res/drawable/sec_qs_panel_background.xml")
                .read_text(encoding="utf-8"),
            )

    def test_missing_donor_resource_fails_closed(self):
        with tempfile.TemporaryDirectory() as tmp:
            apk = Path(tmp)
            (apk / "res/values-night").mkdir(parents=True)
            (apk / "res/values-night/colors.xml").write_text(
                '<resources><color name="qs_tile_text">#ffffffff</color></resources>',
                encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "No safe opaque dark"):
                pure_black.apply_systemui_dark_backgrounds(apk)


class OneUI9QSTests(unittest.TestCase):
    def test_android17_qs_method_layout_divergence_fails_safe(self):
        """Do not break API37 SystemUI when diagnostic method layout changed."""
        original = (
            ".class public Lcom/android/systemui/qs/animator/QSAnimView;\n"
            ".super Ljava/lang/Object;\n"
            ".method public setAlpha(F)V\n"
            "    .locals 5\n"
            "    invoke-static {}, Landroid/os/Debug;->getCallers()Ljava/lang/String;\n"
            "    return-void\n"
            ".end method\n"
            ".method public setVisibility(I)V\n"
            "    .locals 5\n"
            "    return-void\n"
            ".end method\n"
        )
        self.assertEqual(qs_anim.optimize(original), original)

    def test_new_systemui_without_debug_callers_is_not_modified(self):
        source = (
            ".class public Lcom/android/systemui/qs/animator/QSAnimView;\n"
            ".super Ljava/lang/Object;\n"
            ".method public setAlpha(F)V\n"
            "    .locals 2\n"
            "    return-void\n"
            ".end method\n"
        )
        self.assertEqual(qs_anim.optimize(source), source)


class MultiWindowTests(unittest.TestCase):
    def test_large_method_uses_encodable_parameter_instructions(self):
        original = (
            '.method public setMultiWindowEnabled(Ljava/lang/String;Z)V\n'
            '    .locals 20\n    return-void\n.end method\n'
        )
        changed, applied = ssrm.patch_text(original)
        self.assertTrue(applied)
        self.assertIn('move-object/from16 v1, p1', changed)
        self.assertIn('invoke-virtual {v0, v1}', changed)
        self.assertIn('const/16 p2, 0x1', changed)

    def test_parameter_annotations_finish_before_injected_bytecode(self):
        original = (
            '.method public setMultiWindowEnabled(Ljava/lang/String;Z)V\n'
            '    .locals 1\n'
            '    .param p1, "requester"\n'
            '        .annotation runtime Ljava/lang/Deprecated;\n'
            '        .end annotation\n'
            '    .end param\n'
            '    return-void\n.end method\n'
        )
        changed, applied = ssrm.patch_text(original)
        self.assertTrue(applied)
        self.assertLess(changed.index('.end param'), changed.index('const-string v0, "SSRM"'))
    SAMPLE = (
        ".class public Lcom/samsung/android/app/SemMultiWindowManager;\n"
        ".super Ljava/lang/Object;\n"
        ".method public whitelist setMultiWindowEnabled(Ljava/lang/String;Z)V\n"
        "    .locals 1\n"
        "    .param p1, \"requester\"    # Ljava/lang/String;\n"
        "    .param p2, \"enabled\"    # Z\n"
        "    iget-object v0, p0, Lcom/samsung/android/app/SemMultiWindowManager;"
        "->mMultiWindowManager:Lcom/samsung/android/multiwindow/MultiWindowManager;\n"
        "    invoke-virtual {v0, p1, p2}, Lcom/samsung/android/multiwindow/"
        "MultiWindowManager;->setMultiWindowEnabled(Ljava/lang/String;Z)V\n"
        "    return-void\n"
        ".end method\n"
    )

    def test_strict_ssrm_case_is_injected_and_idempotent(self):
        updated, changed = ssrm.patch_text(self.SAMPLE)
        self.assertTrue(changed)
        self.assertIn('const-string v0, "SSRM"', updated)
        self.assertIn("if-nez p2", updated)
        self.assertIn("const/4 p2, 0x1", updated)
        self.assertIn("invoke-virtual {v0, p1, p2},", updated)
        self.assertLess(updated.index(".param p2"), updated.index("const-string v0"))
        self.assertEqual(ssrm.patch_text(updated), (updated, False))

    def test_unrecognized_firmware_method_fails(self):
        with self.assertRaisesRegex(ValueError, "needs one"):
            ssrm.patch_text(".method public other(Ljava/lang/String;Z)V\n.end method\n")

    def test_real_file_layout(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            path = root / "smali_classes3" / ssrm.TARGET_CLASS
            path.parent.mkdir(parents=True)
            path.write_text(self.SAMPLE, encoding="utf-8")
            self.assertTrue(ssrm.patch_tree(root))
            self.assertFalse(ssrm.patch_tree(root))


if __name__ == "__main__":
    unittest.main()
