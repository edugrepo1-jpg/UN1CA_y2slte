#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Restore the r8s optical buffer tag in the exact EZJ1 native graphics stack.

Keep the Android 17 ABI, dependencies, authentication and HBM sequencing.
The BLAST consumer must mark FP Maskview with Samsung usage bit 34; the
legacy Gralloc2 validator must admit that bit without allowing other reserved
bits. These are the two linked fixes verified on the prior Android 16 port,
rebased against the exact S926BXXSIEZJ1 code and object layout.
"""
from pathlib import Path
import argparse
import hashlib
import struct

GUI_SOURCE = 'aff919fec79a2636533d8026a07ccaa31b3c92673142f68f64e0b60570329b04'
UI_SOURCE = '466dffbd2087a5a0c18b84717437e7204128af9343a9ec42657ba9839a309d0f'
HOOK, CAVE, RX_HEADER = 0xf2f30, 0x1c8870, 176
GUI_BRANCH = bytes.fromhex('50560314')
GUI_HELPER = bytes.fromhex(
    'fd7bbfa9fd03009168a24039691e40f96aa600911f0100724001899a81010010'
    '5cf3ff97e00000b4602646f9a00000b4012081d28100c0f2015400f98daafd97'
    'fd7bc1a868a240399fa9fc174650204d61736b7669657700')
GUI_COMPAT = (
    ('3f05007161000054698a43b909e500b9', '3f0500711f2003d5698a43b909e500b9'),
    ('40000035748a03b9', '1f2003d5748a03b9'),
    ('09c841b908e540b91f01096be1190054', '09c841b908e540b91f01096b1f2003d5'),
)
UI_COMPAT = (
    ('8fbc00941f8c0071ac03005400028052', '8fbc00941f8c00711f2003d500028052'),
    ('fdb800941f8c0071ac05005400028052', 'fdb800941f8c00711f2003d500028052'),
)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def original_compat(data, pairs):
    # Other existing modules run later. Recognize only their exact changes
    # when verifying an incremental build, without reverting them in output.
    for before, after in pairs:
        before, after = bytes.fromhex(before), bytes.fromhex(after)
        if data.count(after) == 1 and data.count(before) == 0:
            data = data.replace(after, before, 1)
    return data


def prepare_gui(data):
    # Recognize a fully applied patch by reconstructing the exact known
    # original. Never accept an arbitrary library merely containing our text.
    candidate = bytearray(data)
    if data[HOOK:HOOK + 4] == GUI_BRANCH:
        if data[CAVE:CAVE + len(GUI_HELPER)] != GUI_HELPER:
            raise ValueError('Partial optical BLAST helper')
        candidate[HOOK:HOOK + 4] = bytes.fromhex('68a24039')
        candidate[CAVE:CAVE + len(GUI_HELPER)] = bytes(len(GUI_HELPER))
        struct.pack_into('<QQ', candidate, RX_HEADER + 32, 1083504, 1083504)
    if digest(original_compat(candidate, GUI_COMPAT)) != GUI_SOURCE:
        raise ValueError('Unknown libgui.so: inspect the new source before rebasing optical BLAST')
    if any(candidate[CAVE:0x1cc000]):
        raise ValueError('Optical BLAST executable padding is occupied')
    result = bytearray(data)
    result[HOOK:HOOK + 4] = GUI_BRANCH
    result[CAVE:CAVE + len(GUI_HELPER)] = GUI_HELPER
    struct.pack_into('<QQ', result, RX_HEADER + 32, 1083504 + len(GUI_HELPER),
                     1083504 + len(GUI_HELPER))
    return bytes(result)


def prepare_ui(data):
    candidate = bytearray(data)
    for offset, before, after in ((0x41124, 'e9ffdff2', '69ffdff2'),
                                  (0x4112c, 'eaffdff2', '6affdff2')):
        if data[offset:offset + 4] == bytes.fromhex(after):
            candidate[offset:offset + 4] = bytes.fromhex(before)
    if digest(original_compat(candidate, UI_COMPAT)) != UI_SOURCE:
        raise ValueError('Unknown libui.so: inspect the new Gralloc2 validator before rebasing')
    result = bytearray(data)
    result[0x41124:0x41128] = bytes.fromhex('69ffdff2')
    result[0x4112c:0x41130] = bytes.fromhex('6affdff2')
    return bytes(result)


def apply_pair(gui, ui):
    original_gui, original_ui = gui.read_bytes(), ui.read_bytes()
    # Validate both libraries completely before changing either file.
    updated_gui, updated_ui = prepare_gui(original_gui), prepare_ui(original_ui)
    if original_gui != updated_gui:
        gui.write_bytes(updated_gui)
    if original_ui != updated_ui:
        ui.write_bytes(updated_ui)
    return digest(updated_gui), digest(updated_ui)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('libgui', type=Path)
    parser.add_argument('libui', type=Path)
    args = parser.parse_args()
    print('r8s API37 optical BLAST/Gralloc2:', *apply_pair(args.libgui, args.libui))
