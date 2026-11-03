"""Read-only check of the real Samsung classes before future panel installation.

The staged panel is not auto-installed by adding this file. Its final installer
must call this validation before changing any decoded APK/resource/Smali file.
"""
from pathlib import Path
import argparse
import json


def public_members(text, kind):
    members = set()
    for line in text.splitlines():
        parts = line.strip().split(' =', 1)[0].split()
        if parts and parts[0] == '.' + kind and 'public' in parts[1:-1]:
            members.add(parts[-1])
    return members


def verify(decoded, contract=None):
    contract = contract or json.loads((Path(__file__).with_name('native-contracts.json')).read_text(encoding='utf-8'))
    if contract['api'] != 37 or not contract['classes']:
        raise ValueError('Unsupported or empty Samsung QS contract')
    count = 0
    for name, required in contract['classes'].items():
        files = list(Path(decoded).glob('smali*/' + name + '.smali'))
        if len(files) != 1:
            raise ValueError('Expected exactly one native class: ' + name)
        text = files[0].read_text(encoding='utf-8')
        declaration = next((line.split()[-1] for line in text.splitlines() if line.startswith('.class ')), None)
        if declaration != 'L' + name + ';':
            raise ValueError('Wrong native class declaration: ' + name)
        for kind, key in [('field', 'fields'), ('method', 'methods')]:
            present = public_members(text, kind)
            missing = set(required[key]) - present
            if missing:
                raise ValueError(name + ': changed public ' + kind + ' contract: ' + ', '.join(sorted(missing)))
            count += len(required[key])
    return {'classes': len(contract['classes']), 'members': count, 'modified_files': 0}


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('decoded', type=Path)
    args = parser.parse_args()
    print(json.dumps(verify(args.decoded)))
