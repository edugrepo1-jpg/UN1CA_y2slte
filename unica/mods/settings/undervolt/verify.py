#!/usr/bin/env python3
from pathlib import Path
import hashlib
import json

def verify(root):
    manifest=json.loads((root/'undervolt/compiled.json').read_text(encoding='utf-8'))
    for kind in ('sources','generated'):
        for path,expected in manifest[kind].items():
            target=root/path
            if not target.is_file() or hashlib.sha256(target.read_bytes()).hexdigest()!=expected:
                raise ValueError('Undervolt source/generated mismatch: '+path)

if __name__=='__main__':
    verify(Path(__file__).resolve().parents[1])
