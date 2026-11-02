#!/usr/bin/env python3
"""Bind native biometric sensor flags to r8s floating features on API37.

Do not replay an API36 hunk at fixed registers. Preserve each donor producer
and every unrelated consumer; use a new local solely for each field store.
No authentication, HBM timing, lockscreen or HAL method is bypassed.
"""
from pathlib import Path
import re
import sys

PATH = 'com/android/server/biometrics/SemBiometricFeature.smali'
CLASS = 'Lcom/android/server/biometrics/SemBiometricFeature;'
HELPER = 'r8sHasFingerprintFeature'
FEATURE = 'SEC_FLOATING_FEATURE_BIOAUTH_CONFIG_FINGERPRINT_FEATURES'
SENSORS = {'FP_FEATURE_SENSOR_IS_OPTICAL': 'optical',
           'FP_FEATURE_SENSOR_IS_ULTRASONIC': 'ultrasonic'}
METHOD = re.compile(r'^\.method static constructor <clinit>\(\)V\n(?P<body>[\s\S]*?)^\.end method$', re.M)
FUNCTION = f'''.method private static {HELPER}(Ljava/lang/String;)Z
    .locals 2
    invoke-static {{}}, Lcom/samsung/android/feature/SemFloatingFeature;->getInstance()Lcom/samsung/android/feature/SemFloatingFeature;
    move-result-object v0
    const-string v1, "{FEATURE}"
    invoke-virtual {{v0, v1}}, Lcom/samsung/android/feature/SemFloatingFeature;->getString(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    invoke-virtual {{v0, p0}}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v0
    return v0
.end method
'''


def patch_text(text: str, descriptor: str = CLASS) -> tuple[str, bool]:
    function = FUNCTION.replace(CLASS, descriptor)
    if not re.search(r'^\.class\b[^\n]* ' + re.escape(descriptor) + '$', text, re.M):
        raise ValueError('Unexpected native biometric feature class')
    methods = list(METHOD.finditer(text))
    if len(methods) != 1:
        raise ValueError('Expected one native biometric static initializer')
    method = methods[0]
    body = method['body']
    if HELPER in text:
        if function not in text or body.count(f'->{HELPER}(') != len(SENSORS):
            raise ValueError('Partial biometric sensor flag adaptation')
        return text, False
    registers = list(re.finditer(r'^    \.(locals|registers) (\d+)\s*$', body, re.M))
    if len(registers) != 1:
        raise ValueError('Unknown native biometric initializer register contract')
    count = int(registers[0][2])
    if count > 254:
        raise ValueError('No encodable extra register for biometric feature stores')
    edits = []
    for field, sensor in SENSORS.items():
        declarations = re.findall(r'^\.field[^\n]* ' + re.escape(field + ':Z') + r'$', text, re.M)
        if len(declarations) != 1:
            raise ValueError(f'Unknown biometric field declaration: {field}')
        pattern = r'^    sput-boolean [vp]\d+, ' + re.escape(descriptor + '->' + field + ':Z') + r'$'
        stores = list(re.finditer(pattern, body, re.M))
        if len(stores) != 1 or len(re.findall(pattern, text, re.M)) != 1:
            raise ValueError(f'Expected one native initializer assignment for {field}')
        store = stores[0]
        new_reg = f'v{count}'
        code = (f'    const-string {new_reg}, "{sensor}"\n'
                f'    invoke-static/range {{{new_reg} .. {new_reg}}}, {descriptor}->{HELPER}(Ljava/lang/String;)Z\n'
                f'    move-result {new_reg}\n'
                f'    sput-boolean {new_reg}, {descriptor}->{field}:Z')
        edits.append((store.start(), store.end(), code))
    directive = registers[0]
    edits.append((directive.start(), directive.end(), f'    .{directive[1]} {count + 1}\n'))
    for start, end, code in sorted(edits, reverse=True):
        body = body[:start] + code + body[end:]
    return (text[:method.start('body')] + body + text[method.end('body'):]
            + '\n' + function), True


def patch_tree(root: Path, ui: bool = False) -> bool:
    path = 'com/samsung/android/biometrics/app/setting/Utils$Config.smali' if ui else PATH
    descriptor = 'L' + path[:-6] + ';' if ui else CLASS
    files = list(root.glob('smali*/' + path))
    if len(files) != 1:
        raise ValueError(f'Expected one native SemBiometricFeature class, found {len(files)}')
    source = files[0]
    updated, changed = patch_text(source.read_text(encoding='utf-8'), descriptor)
    if changed:
        source.write_text(updated, encoding='utf-8', newline='\n')
    return changed


if __name__ == '__main__':
    try:
        changed = patch_tree(Path(sys.argv[1]), ui='--ui' in sys.argv[2:])
        print('r8s native biometric sensor flags: ' + ('adapted' if changed else 'already adapted'))
    except (OSError, ValueError, IndexError) as exc:
        print(f'r8s native biometric sensor adaptation: {exc}', file=sys.stderr)
        raise SystemExit(1) from exc
