#!/usr/bin/env python3
"""Extend a compatible Samsung camera enum from the r8s XML, never its APK.

Keep every donor enum/ID/ordinal and derive the missing set from the actual
target XML. Refuse unknown constructor or lookup contracts instead of applying
the Android 16 patch's obfuscated class names to an Android 17 APK.
"""
from pathlib import Path
import re
import sys
import xml.etree.ElementTree as ET

PACKAGE = 'com/sec/android/app/camera/interfaces/'
RES = f'L{PACKAGE}Resolution;'
RATIO = f'L{PACKAGE}AspectRatio;'
CTOR = f'<init>(Ljava/lang/String;IIII{RATIO}I)V'
HELPER = 'r8sExtendXmlResolutions'
# These are r8s XML sizes covered by the earlier real-enum JVM validation and
# camera tests. This is not permission to advertise new sensor capabilities.
KNOWN = {
    (2944, 1324): 'RATIO_20x9', (2944, 1656): 'RATIO_16x9',
    (3648, 1640): 'RATIO_20x9', (4000, 1712): 'RATIO_21x9',
    (4000, 2250): 'RATIO_16x9', (4000, 2256): 'RATIO_16x9',
    (4032, 1728): 'RATIO_21x9', (6528, 4896): 'RATIO_4x3',
    (5264, 3948): 'RATIO_4x3',
}


def xml_dimensions(source: str) -> set[tuple[int, int]]:
    root = ET.fromstring(source)
    return {tuple(map(int, size)) for node in root.iter()
            for value in node.attrib.values()
            for size in re.findall(r'(?<![\w])([0-9]{2,5})[xX]([0-9]{2,5})(?![\w])', value)}


def patch_text(text: str, ratios: str, feature: str) -> tuple[str, list[tuple[int, int]]]:
    if not re.search(r'^\.class\b[^\n]* ' + re.escape(RES) + r'$', text, re.M):
        raise ValueError('Unexpected Samsung Resolution class descriptor')
    declared = set(re.findall(
        r'^\.field[^\n]* enum (RESOLUTION_\w+):' + re.escape(RES) + r'$', text, re.M))
    existing = set()
    for field in declared:
        dimensions = re.fullmatch(r'RESOLUTION_(\d+)X(\d+)', field)
        if dimensions:
            existing.add(tuple(map(int, dimensions.groups())))
    missing = sorted(xml_dimensions(feature) - existing)
    if not missing:
        return text, []
    if HELPER in text:
        raise ValueError('Camera XML changed after a partial resolution extension')
    unknown = set(missing) - set(KNOWN)
    if unknown:
        raise ValueError(f'Unverified r8s dimensions need donor/HAL review: {sorted(unknown)}')
    constructor = re.search(r'^\.method private constructor ' + re.escape(CTOR)
                            + r'\n[\s\S]*?^\.end method$', text, re.M)
    if constructor is None:
        raise ValueError('Samsung camera Resolution constructor changed')
    # Verify parameter semantics, not merely the constructor descriptor.
    required = [
        f'invoke-direct {{p0, p1, p2}}, Ljava/lang/Enum;-><init>(Ljava/lang/String;I)V',
        f'iput p3, p0, {RES}->mId:I', f'iput p4, p0, {RES}->mWidth:I',
        f'iput p5, p0, {RES}->mHeight:I', f'iput-object p6, p0, {RES}->mRatio:{RATIO}',
        f'iput p7, p0, {RES}->mMinFps:I', f'iput p7, p0, {RES}->mMaxFps:I',
    ]
    body = [line.strip() for line in constructor[0].splitlines()]
    if any(body.count(line) != 1 for line in required):
        raise ValueError('Samsung camera Resolution constructor parameter semantics changed')
    for size in missing:
        field = KNOWN[size]
        if not re.search(r'^\.field[^\n]* enum ' + re.escape(field + ':' + RATIO)
                         + r'$', ratios, re.M):
            raise ValueError(f'Camera aspect ratio is not available: {field}')
    clinit = re.search(r'^\.method static constructor <clinit>\(\)V\n[\s\S]*?^\.end method$',
                       text, re.M)
    if clinit is None:
        raise ValueError('Missing Samsung camera enum initializer')
    stores = list(re.finditer(r'^    sput-object ([vp]\d+), ' + re.escape(RES)
                              + r'->\$VALUES:\[' + re.escape(RES) + r'$', clinit[0], re.M))
    if len(stores) != 1:
        raise ValueError('Ambiguous camera enum values initialization')
    store = stores[0]
    if f'{RES}->values()[{RES}' not in clinit[0][store.end():]:
        raise ValueError('Camera lookup map no longer derives from the initialized enum')
    # Conservatively reserve every integer literal already used by the donor.
    # The reserved r8s range remains within a signed 16-bit const instruction.
    used = set()
    for literal in re.findall(r'\bconst(?:/[a-z0-9]+)? [vp]\d+, (-?0x[0-9a-fA-F]+|-?\d+)\b', text):
        used.add(int(literal, 16) if 'x' in literal else int(literal, 10))
    available = iter(value for value in range(0x7000, 0x8000) if value not in used)
    lines = [f'.method private static {HELPER}([{RES})[{RES}', '    .locals 10',
             '    array-length v1, p0', f'    const/16 v2, {len(missing)}',
             '    add-int v2, v1, v2',
             '    invoke-static {p0, v2}, Ljava/util/Arrays;->copyOf([Ljava/lang/Object;I)[Ljava/lang/Object;',
             '    move-result-object v0', f'    check-cast v0, [{RES}']
    fields = []
    for width, height in missing:
        field = f'RESOLUTION_{width}X{height}'
        ident = next(available, None)
        if ident is None:
            raise ValueError('No unused r8s camera resolution ID')
        fields.append(f'.field public static final enum {field}:{RES}')
        lines.extend([
            f'    new-instance v2, {RES}', f'    const-string v3, "{field}"',
            '    move v4, v1', f'    const/16 v5, {ident}',
            f'    const/16 v6, {width}', f'    const/16 v7, {height}',
            f'    sget-object v8, {RATIO}->{KNOWN[(width, height)]}:{RATIO}',
            '    const/16 v9, 30', f'    invoke-direct/range {{v2 .. v9}}, {RES}->{CTOR}',
            f'    sput-object v2, {RES}->{field}:{RES}',
            '    aput-object v2, v0, v1', '    add-int/lit8 v1, v1, 1',
        ])
    lines.extend(['    return-object v0', '.end method', ''])
    reg = store[1]
    hook = (f'    invoke-static/range {{{reg} .. {reg}}}, {RES}->{HELPER}([{RES})[{RES}\n'
            f'    move-result-object {reg}\n')
    position = clinit.start() + store.start()
    updated = text[:position] + hook + text[position:]
    field_anchor = re.search(r'^\.field ', updated, re.M)
    if field_anchor is None:
        raise ValueError('Camera enum field declaration block is absent')
    position = field_anchor.start()
    return (updated[:position] + '\n'.join(fields) + '\n\n' + updated[position:]
            + '\n' + '\n'.join(lines)), missing


def patch_tree(root: Path, xml: Path) -> list[tuple[int, int]]:
    paths = list(root.glob('smali*/' + PACKAGE + 'Resolution.smali'))
    ratios = list(root.glob('smali*/' + PACKAGE + 'AspectRatio.smali'))
    if len(paths) != 1 or len(ratios) != 1:
        raise ValueError('Expected one native Resolution and AspectRatio class')
    source = paths[0]
    updated, missing = patch_text(source.read_text(encoding='utf-8'),
                                  ratios[0].read_text(encoding='utf-8'),
                                  xml.read_text(encoding='utf-8'))
    if missing:
        source.write_text(updated, encoding='utf-8', newline='\n')
    return missing


if __name__ == '__main__':
    try:
        added = patch_tree(Path(sys.argv[1]), Path(sys.argv[2]))
        print('r8s native camera XML resolutions: ' + (str(added) if added else 'already present'))
    except (OSError, ValueError, ET.ParseError, IndexError) as exc:
        print(f'r8s camera resolution compatibility: {exc}', file=sys.stderr)
        raise SystemExit(1) from exc
