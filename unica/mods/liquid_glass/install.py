#!/usr/bin/env python3
"""Narrow API37 Samsung hook. Refuse a changed contract instead of guessing."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import sys

OWNER = 'Lcom/android/systemui/blur/domain/interactor/SecCapturedBlurBitmapGenerator;'
SIGNATURE = '.method public final getBlurredBitmapWithEffect(Lcom/android/systemui/blur/di/SecPanelBlurBinding$BlurType;)Landroid/graphics/drawable/BitmapDrawable;'
HOOK = 'Lcom/gmhub/glass/GlassDrawable;->wrap('


def patch(text):
    if HOOK in text:
        return text
    if text.count(SIGNATURE) != 1 or '.class public final ' + OWNER not in text:
        raise ValueError('Unsupported captured-blur class contract')
    start = text.index(SIGNATURE)
    end = text.index('.end method', start)
    method = text[start:end]
    if method.count('    .locals 8') != 1:
        raise ValueError('Changed blur register allocation')
    # v8/v9 remain untouched by the original body; p0/p1 shift automatically.
    method = method.replace('    .locals 8', '''    .locals 10

    iget-object v8, p0, Lcom/android/systemui/blur/domain/interactor/SecCapturedBlurBitmapGenerator;->context:Landroid/content/Context;

    invoke-virtual {p1}, Ljava/lang/Enum;->name()Ljava/lang/String;

    move-result-object v9''', 1)
    anchor = '    return-object v4'
    if method.count(anchor) != 1:
        raise ValueError('Changed blur return contract')
    method = method.replace(anchor, '''    invoke-static {v8, v0, v4, v9}, Lcom/gmhub/glass/GlassDrawable;->wrap(Landroid/content/Context;Landroid/graphics/Bitmap;Landroid/graphics/drawable/BitmapDrawable;Ljava/lang/String;)Landroid/graphics/drawable/BitmapDrawable;

    move-result-object v4

    return-object v4''')
    return text[:start] + method + text[end:]


def install(decoded, module):
    # Verify every packaged shader against its pinned provenance before editing.
    assets = module / 'assets/gmhub/liquid_glass'
    provenance = json.loads((assets / 'provenance.json').read_text(encoding='utf-8'))
    if {p['id'] for p in provenance} != {'qwea', 'kyant', 'color'}:
        raise ValueError('Incomplete renderer set')
    for p in provenance:
        actual = hashlib.sha256((assets / (p['id'] + '.agsl')).read_bytes()).hexdigest()
        if actual != p['shader_sha256']:
            raise ValueError('Changed shader asset: ' + p['id'])
    adapter = json.loads((module / 'compiled.json').read_text(encoding='utf-8'))
    for key, path in [('java_sha256', 'src/com/gmhub/glass/GlassDrawable.java'),
                      ('smali_sha256', 'smali/com/gmhub/glass/GlassDrawable.smali')]:
        if hashlib.sha256((module / path).read_bytes()).hexdigest() != adapter[key]:
            raise ValueError('Adapter source and generated smali are out of sync: ' + path)
    candidates = list(decoded.glob('smali*/com/android/systemui/blur/domain/interactor/SecCapturedBlurBitmapGenerator.smali'))
    if len(candidates) != 1:
        raise ValueError('Expected one Samsung captured-blur generator')
    target = candidates[0]
    text = patch(target.read_text(encoding='utf-8'))
    existing = list(decoded.glob('smali*/com/gmhub/glass/GlassDrawable.smali'))
    if len(existing) > 1:
        raise ValueError('Duplicate glass class definitions')
    if existing:
        dest = existing[0].parents[3]
    else:
        indices = [int(p.name[13:]) if p.name.startswith('smali_classes') else 1
                   for p in decoded.iterdir() if p.is_dir() and re.fullmatch(r'smali(?:_classes\d+)?', p.name)]
        dest = decoded / ('smali_classes' + str(max(indices, default=1) + 1))
    compiled = module / 'smali/com/gmhub/glass/GlassDrawable.smali'
    if not compiled.is_file():
        raise ValueError('GlassDrawable has not been compiled from source')
    # All validation precedes mutation. This runs on the decoded build work-dir.
    shutil.copytree(module / 'smali', dest, dirs_exist_ok=True)
    shutil.copytree(module / 'assets', decoded / 'assets', dirs_exist_ok=True)
    target.write_text(text, encoding='utf-8', newline='\n')
    print('Installed three opt-in AGSL ports on Samsung captured Quick Settings; native fallback retained')


if __name__ == '__main__':
    install(Path(sys.argv[1]), Path(__file__).resolve().parent)
