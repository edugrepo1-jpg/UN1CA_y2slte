#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Consolidate the API37 r8s boot fixes validated together on the phone.

Run after every module: the target vendor manifest follows the platform WFD
module and previously discarded allocator4's registration. Keep allocator2,
private donor dependencies, the modern graphics ABI and optical buffer fixes.
No runtime daemon, SDK spoof, protection removal or kernel change is needed.
"""
from pathlib import Path
import argparse
import hashlib
import re
import xml.etree.ElementTree as ET

DONORS = {
    'libhidlbase': '0f83520d5da7a4c6e82dc179e6722e41c302721ae8f9fe09bd206022db49808a',
    'libhardware': '458a29ec47d7ef383e2652ca390bab38b9352aa4ebbe796633a794646cc47155',
    'libgralloctypes': '4bfe20a3d639700f07678b7a4db684251a105ab153711ede556ccdb14bad73f3',
}
UI_FINAL_SHA256 = 'df951279e16319ad77f99297448da618860eddc0a1323d26cbbfcc00c91ba6dc'
GATES = ((0x326ec, 'ac030054'), (0x33534, 'ac050054'), (0x586b0, '6c000054'))
NOP = bytes.fromhex('1f2003d5')
PRELOAD = '    setenv LD_PRELOAD libhidlbase.gm:libhardware.gm'
INTERFACE = 'android.hardware.graphics.allocator@4.0::IAllocator default'
ALLOCATOR = '''    <hal format="hidl">
        <name>android.hardware.graphics.allocator</name>
        <transport>hwbinder</transport>
        <version>4.0</version>
        <interface>
            <name>IAllocator</name>
            <instance>default</instance>
        </interface>
        <fqname>@4.0::IAllocator/default</fqname>
    </hal>
'''


def digest(data):
    return hashlib.sha256(data).hexdigest()


def prepare_ui(data):
    result = bytearray(data)
    for offset, original in GATES:
        if data[offset:offset + 4] not in (bytes.fromhex(original), NOP):
            raise ValueError(f'Unknown libui legacy mapper gate at {offset:#x}')
        result[offset:offset + 4] = NOP
    # All bytes, including the two optical usage masks, must match test6.
    if digest(result) != UI_FINAL_SHA256:
        raise ValueError('Unknown libui.so; rebase against exact firmware before patching')
    return bytes(result)


def prepare_manifest(text):
    root = ET.fromstring(text)
    if root.tag != 'manifest':
        raise ValueError('Expected a device manifest')
    allocators = [h for h in root.findall('hal')
                  if h.findtext('name') == 'android.hardware.graphics.allocator']
    if not any(h.findtext('transport') == 'hwbinder'
               and h.findtext('fqname') == '@2.0::IAllocator/default' for h in allocators):
        raise ValueError('Stock r8s allocator2 declaration missing')
    existing = [h for h in allocators if h.findtext('version') == '4.0']
    if existing:
        if len(existing) != 1 or existing[0].findtext('transport') != 'hwbinder' or \
                existing[0].findtext('fqname') != '@4.0::IAllocator/default':
            raise ValueError('Conflicting allocator4 declaration')
        return text
    if text.count('</manifest>') != 1:
        raise ValueError('Ambiguous manifest terminator')
    return text.replace('</manifest>', ALLOCATOR + '</manifest>', 1)


def prepare_rc(text):
    services = re.findall(r'^service ([^\n]+)', text, re.M)
    expected = 'vendor.gralloc-4-0 /vendor/bin/hw/android.hardware.graphics.allocator@4.0-service-sgr'
    if services != [expected] or f'interface {INTERFACE}' not in text:
        raise ValueError('Unexpected allocator4 init service')
    preloads = re.findall(r'^\s*setenv LD_PRELOAD[^\n]*', text, re.M)
    if preloads:
        if len(preloads) != 1 or preloads[0].strip() != PRELOAD.strip():
            raise ValueError('Conflicting allocator4 private dependencies')
        return text
    return text.replace('service ' + expected + '\n',
                        'service ' + expected + '\n' + PRELOAD + '\n', 1)


def rename_metadata(text, old, new):
    lines = text.splitlines(keepends=True)
    previous = [i for i, line in enumerate(lines) if line.split(maxsplit=1)[0:1] == [old]]
    present = [i for i, line in enumerate(lines) if line.split(maxsplit=1)[0:1] == [new]]
    if previous and not present and len(previous) == 1:
        i = previous[0]
        lines[i] = new + lines[i][len(old):]
    elif previous or len(present) != 1:
        raise ValueError(f'Missing or ambiguous donor metadata: {old}')
    return ''.join(lines)


def finalize(root):
    root = Path(root)
    ui = root / 'system/system/lib64/libui.so'
    manifest = root / 'vendor/etc/vintf/manifest.xml'
    rc = root / 'vendor/etc/init/android.hardware.graphics.allocator@4.0-service-sgr.rc'
    fs = root / 'configs/fs_config-vendor'
    contexts = root / 'configs/file_context-vendor'
    updates = {ui: prepare_ui(ui.read_bytes()),
               manifest: prepare_manifest(manifest.read_text(encoding='utf-8')).encode(),
               rc: prepare_rc(rc.read_text(encoding='utf-8')).encode()}
    fs_text, ctx_text = fs.read_text(encoding='utf-8'), contexts.read_text(encoding='utf-8')
    moves = []
    for name, expected in DONORS.items():
        public = root / f'vendor/lib64/{name}.so'
        private = public.with_suffix('.gm')
        if public.exists() == private.exists():
            raise ValueError(f'Expected exactly one staged donor: {name}')
        source = public if public.exists() else private
        if digest(source.read_bytes()) != expected:
            raise ValueError(f'Unknown donor library: {source}')
        if source == public:
            moves.append((public, private))
        fs_text = rename_metadata(fs_text, f'vendor/lib64/{name}.so', f'vendor/lib64/{name}.gm')
        ctx_text = rename_metadata(ctx_text, f'/vendor/lib64/{name}\\.so', f'/vendor/lib64/{name}\\.gm')
    updates[fs], updates[contexts] = fs_text.encode(), ctx_text.encode()
    # Validate every file first. A changed donor or ABI never gets partially
    # rewritten by this step. Renames retain donor bytes and image permissions.
    for path, content in updates.items():
        if path.read_bytes() != content:
            path.write_bytes(content)
    for source, dest in moves:
        source.rename(dest)
    print('r8s boot graphics: private donor scope, legacy mapper and allocator VINTF finalized')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('work_dir', type=Path)
    finalize(parser.parse_args().work_dir)
