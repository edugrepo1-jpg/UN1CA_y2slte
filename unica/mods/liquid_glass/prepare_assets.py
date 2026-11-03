#!/usr/bin/env python3
"""Extract pinned upstream shaders; do not substitute three names for one effect."""
from pathlib import Path
import hashlib
import json
import re
import textwrap


def extract(text, name):
    match = re.search(r'\b' + re.escape(name) + r'(?::\s*String)?\s*=\s*"""(.*?)"""', text, re.S)
    if not match:
        raise ValueError('Missing exact upstream shader ' + name)
    return textwrap.dedent(match[1]).strip() + '\n'


def generate(root):
    upstream = root / 'upstream'
    qwea = extract((upstream / 'qwea.kt').read_text(encoding='utf-8'), 'LENS_AGSL')
    kyant_source = (upstream / 'kyant.kt').read_text(encoding='utf-8')
    sdf = extract(kyant_source, 'RoundedRectSDF').rstrip()
    kyant = extract(kyant_source, 'RoundedRectRefractionWithDispersionShaderString').replace('$RoundedRectSDF', sdf)
    color = extract((upstream / 'color.kt').read_text(encoding='utf-8'), 'AGSL_SOURCE')
    shaders = {'qwea': qwea, 'kyant': kyant, 'color': color}
    output = root / 'assets/gmhub/liquid_glass'
    output.mkdir(parents=True, exist_ok=True)
    provenance = json.loads((upstream / 'manifest.json').read_text(encoding='utf-8'))
    for entry in provenance:
        name = entry['id']
        shader = shaders[name]
        if '$' in shader:
            raise ValueError('Unresolved Kotlin interpolation in ' + name)
        (output / (name + '.agsl')).write_text(shader, encoding='utf-8', newline='\n')
        entry['source_sha256'] = hashlib.sha256((upstream / (name + '.kt')).read_bytes()).hexdigest()
        entry['shader_sha256'] = hashlib.sha256(shader.encode()).hexdigest()
        license_bytes = (root / 'licenses' / (name + '.txt')).read_bytes()
        (output / (name + '-LICENSE.txt')).write_bytes(license_bytes)
    (output / 'provenance.json').write_text(json.dumps(provenance, indent=2) + '\n', encoding='utf-8')
    return shaders


if __name__ == '__main__':
    result = generate(Path(__file__).resolve().parent)
    print('Extracted three distinct pinned upstream shaders:', ', '.join(result))
