#!/usr/bin/env python3
"""Index exact donor ELF dependencies; APEX containers are retained separately.

Dependencies found here are necessary but do not prove namespace access or
runtime ABI compatibility. In particular, an APEX-contained library must not be
reported as missing until its container has also been inspected.
"""
from pathlib import Path
import hashlib
import io
import json
import zipfile


def index_elf(stream):
    from elftools.elf.elffile import ELFFile
    elf = ELFFile(stream)
    result = {'bits': elf.elfclass, 'machine': elf.header['e_machine'],
              'soname': None, 'needed': [], 'imports': [], 'exports': []}
    dynamic = elf.get_section_by_name('.dynamic')
    if dynamic:
        for tag in dynamic.iter_tags():
            if tag.entry.d_tag == 'DT_NEEDED':
                result['needed'].append(tag.needed)
            elif tag.entry.d_tag == 'DT_SONAME':
                result['soname'] = tag.soname
    symbols = elf.get_section_by_name('.dynsym')
    if symbols:
        for symbol in symbols.iter_symbols():
            if not symbol.name:
                continue
            bind = symbol['st_info']['bind']
            entry = {'name': symbol.name, 'binding': bind,
                     'type': symbol['st_info']['type']}
            if symbol['st_shndx'] == 'SHN_UNDEF':
                if bind in {'STB_GLOBAL', 'STB_WEAK'}:
                    result['imports'].append(entry)
            elif bind in {'STB_GLOBAL', 'STB_WEAK', 'STB_GNU_UNIQUE'} and symbol['st_other']['visibility'] in {'STV_DEFAULT', 'STV_PROTECTED'}:
                result['exports'].append(entry)
    return result


def write_index(root, destination):
    result = {'scope': 'loose firmware ELFs and APK-embedded libraries; APEX payloads archived separately',
              'libraries': [], 'apex_containers': []}
    for path in sorted(root.rglob('*')):
        if not path.is_file():
            continue
        relative = path.relative_to(root).as_posix()
        with path.open('rb') as stream:
            header = stream.read(4)
            if header == b'\x7fELF':
                stream.seek(0)
                entry = index_elf(stream)
                stream.seek(0)
                entry.update(path=relative, size=path.stat().st_size,
                             sha256=hashlib.file_digest(stream, 'sha256').hexdigest())
                result['libraries'].append(entry)
        if path.suffix in {'.apex', '.capex'}:
            result['apex_containers'].append(relative)
        elif path.suffix == '.apk':
            with zipfile.ZipFile(path) as package:
                for name in package.namelist():
                    if not name.startswith('lib/') or not name.endswith('.so'):
                        continue
                    raw = package.read(name)
                    if raw[:4] == b'\x7fELF':
                        entry = index_elf(io.BytesIO(raw))
                        entry.update(path=relative + '!/' + name, size=len(raw),
                                     sha256=hashlib.sha256(raw).hexdigest())
                        result['libraries'].append(entry)
    destination.write_text(json.dumps(result, separators=(',', ':')) + '\n')
