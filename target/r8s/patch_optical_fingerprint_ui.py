#!/usr/bin/env python3
"""Connect the existing r8s optical-capability correction to native SystemUI.

Do not transplant the obsolete whole optical UI patch. Preserve the native
cache, callers and authentication flow, replacing only its donor-specific
constant initialization after checking the complete simple method contract.
"""
from pathlib import Path
import re
import sys

CLASS = 'com/android/systemui/util/DeviceType.smali'
FIELD = 'Lcom/android/systemui/util/DeviceType;->supportOpticalFingerprint:I'
FEATURE = 'SEC_FLOATING_FEATURE_BIOAUTH_CONFIG_FINGERPRINT_FEATURES'
METHOD = re.compile(
    r'(?m)^\.method public static isOpticalFingerprintSupported\(\)Z[^\S\n]*\n'
    r'(?P<body>[\s\S]*?)^\.end method[^\S\n]*$'
)
INSERT = f'''    invoke-static {{}}, Lcom/samsung/android/feature/SemFloatingFeature;->getInstance()Lcom/samsung/android/feature/SemFloatingFeature;
    move-result-object v0
    const-string v1, "{FEATURE}"
    invoke-virtual {{v0, v1}}, Lcom/samsung/android/feature/SemFloatingFeature;->getString(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    const-string v1, "optical"
    invoke-virtual {{v0, v1}}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v0
    sput v0, {FIELD}'''


def patch_text(text):
    matches = list(METHOD.finditer(text))
    if len(matches) != 1:
        raise ValueError('Native SystemUI optical capability method changed; inspect exact donor DeviceType')
    match = matches[0]
    body = match['body']
    if INSERT in body:
        return text, False
    # Validate the original cache/return flow, ignoring only debug directives.
    instructions = [line.strip() for line in body.splitlines()
                    if line.strip() and not line.strip().startswith(('.', '#'))]
    canonical = (
        rf'sget v0, {re.escape(FIELD)}\n'
        r'const/4 v1, -0x1\nconst/4 v2, 0x0\n'
        r'if-ne v0, v1, (?P<cached>:[\w$]+)\n'
        rf'sput v2, {re.escape(FIELD)}\n'
        r'(?P=cached)\n'
        rf'sget v0, {re.escape(FIELD)}\n'
        r'const/4 v1, 0x1\nif-ne v0, v1, (?P<no>:[\w$]+)\n'
        r'return v1\n(?P=no)\nreturn v2'
    )
    if not re.fullmatch(canonical, '\n'.join(instructions)):
        raise ValueError('Native optical cache has a different control flow; no SystemUI changes made')
    if not re.search(r'(?m)^\s*\.locals 3\s*$', body):
        raise ValueError('Unexpected native optical register contract')
    original = f'    sput v2, {FIELD}'
    if body.count(original) != 1:
        raise ValueError('Ambiguous native optical cache assignment')
    updated = body.replace(original, INSERT, 1)
    return text[:match.start('body')] + updated + text[match.end('body'):], True


def patch_tree(root):
    paths = list(root.glob('smali*/' + CLASS))
    if len(paths) != 1:
        raise ValueError(f'Expected one native optical DeviceType, found {len(paths)}')
    source = paths[0]
    updated, changed = patch_text(source.read_text(encoding='utf-8'))
    if changed:
        source.write_text(updated, encoding='utf-8', newline='\n')
    return changed


if __name__ == '__main__':
    try:
        changed = patch_tree(Path(sys.argv[1]))
        print('r8s native optical fingerprint capability: ' + ('patched' if changed else 'already patched'))
    except (OSError, ValueError, IndexError) as exc:
        print('r8s native optical fingerprint capability: ' + str(exc), file=sys.stderr)
        raise SystemExit(1) from exc
