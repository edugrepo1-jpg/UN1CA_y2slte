import importlib.util
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("recording_timestamp", ROOT / "platform/exynos990/patches/camera/patch_recording_timestamp.py")
MOD = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MOD)


class RecordingTimestampTests(unittest.TestCase):
    def image(self, payload):
        header = bytearray(64)
        header[:7] = b"\x7fELF\x01\x01\x01"
        header[18:20] = b"\x28\x00"
        return bytes(header) + payload

    def test_changes_only_the_thumb_branch_and_preserves_size(self):
        data = self.image(MOD.BEFORE + b"tail")
        result = MOD.patch(data)
        self.assertEqual(len(result), len(data))
        self.assertEqual([i for i, pair in enumerate(zip(data, result)) if pair[0] != pair[1]], [74, 75])
        self.assertEqual(MOD.patch(result), result)

    def test_rejects_unknown_duplicate_mixed_and_unaligned_inputs(self):
        for payload in (b"unknown", MOD.BEFORE * 2, MOD.BEFORE + MOD.AFTER, b"x" + MOD.BEFORE):
            with self.subTest(payload=payload), self.assertRaises(ValueError):
                MOD.patch(self.image(payload))

    def test_rejects_other_abis(self):
        data = bytearray(self.image(MOD.BEFORE))
        data[4] = 2
        with self.assertRaises(ValueError):
            MOD.patch(bytes(data))
