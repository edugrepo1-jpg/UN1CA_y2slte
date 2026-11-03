"""Reject a damaged supplicant before it can be packaged into the ROM."""
from pathlib import Path
import hashlib
import struct
import unittest

ROOT=Path(__file__).resolve().parents[1]
WPA=ROOT/'target/r8s/patches/vendor/vendor/bin/hw/wpa_supplicant'


class WifiBinaryTests(unittest.TestCase):
    def test_supplicant_matches_exact_stock_r8s_and_has_a_valid_dynamic_table(self):
        data=WPA.read_bytes()
        self.assertEqual(hashlib.sha256(data).hexdigest(),
                         'e1c3cf6d9e371975962e7ca8a8c1e9b34ebc3f381b8cf322e2d3c7e1c23d2be2')
        self.assertEqual(data[:6],b'\x7fELF\x02\x01')
        self.assertEqual(struct.unpack_from('<H',data,18)[0],183)
        phoff=struct.unpack_from('<Q',data,32)[0]
        entsize,count=struct.unpack_from('<HH',data,54)
        self.assertEqual(entsize,56)
        self.assertLessEqual(phoff+entsize*count,len(data))
        dynamic=[]
        for i in range(count):
            typ,flags,offset,vaddr,paddr,filesz,memsz,align=struct.unpack_from('<IIQQQQQQ',data,phoff+i*entsize)
            self.assertLessEqual(offset+filesz,len(data))
            if typ==2:
                self.assertEqual(filesz%16,0)
                dynamic=[struct.unpack_from('<QQ',data,j) for j in range(offset,offset+filesz,16)]
        self.assertTrue(dynamic)
        tags={tag for tag,value in dynamic}
        self.assertIn(0,tags)  # DT_NULL terminates the intact dynamic table.
        self.assertIn(1,tags)  # DT_NEEDED
        self.assertIn(5,tags)  # DT_STRTAB
        self.assertTrue({4,0x6ffffef5}&tags)  # DT_HASH / DT_GNU_HASH
