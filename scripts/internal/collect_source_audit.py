#!/usr/bin/env python3
"""Retain exact Samsung inputs for the r8s API 37 compatibility audit.

This only decodes and archives inputs. It does not patch a ROM or compile a
kernel. Each output is a standalone ZIP below the connector's 512 MiB limit.
"""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import zipfile


LIMIT = 450 * 1024 * 1024
PACKAGES = {
    'framework': ('framework.jar', 'services.jar', 'telephony-common.jar', 'semwifi-service.jar'),
    'camera': ('SamsungCamera.apk',),
    'systemui': ('SystemUI.apk',),
    'settings': ('SecSettings.apk',),
    'biometric': ('BiometricSetting.apk',),
}
SUPPLEMENTAL_PACKAGES = {
    'aux-framework': ('gamemanager.jar', 'secinputdev-service.jar', 'ssrm.jar'),
    'aux-settings': ('SettingsProvider.apk', 'SecSettingsIntelligence.apk'),
    'aux-health-ese': ('SamsungDeviceHealthManagerService.apk', 'SecureElement.apk'),
}


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            h.update(chunk)
    return h.hexdigest()


def find_unique(root, name, required=True):
    paths = sorted(p for p in root.rglob(name) if p.is_file())
    if len(paths) != 1 and (required or paths):
        raise ValueError(f'Expected one {name}, found {paths}')
    return paths[0] if paths else None


def archive(destination, entries):
    with zipfile.ZipFile(destination, 'w', zipfile.ZIP_DEFLATED, compresslevel=5) as output:
        for path, name in entries:
            output.write(path, name)
    if destination.stat().st_size >= LIMIT:
        raise ValueError(f'Audit artifact exceeds safe download limit: {destination}')


def collect(root, tool, output):
    output.mkdir(parents=True, exist_ok=True)
    metadata = {'source': str(root.name), 'files': []}
    # Optical FOD needs both Java capability handling and native buffer usage.
    # Retain exact code bytes for allocator/BLAST review, never old API36 DSOs.
    native_names = {'surfaceflinger', 'libgui.so', 'libui.so', 'libhwui.so',
                    'libandroid_runtime.so', 'libbinder.so', 'libhidlbase.so',
                    'libutils.so', 'libcutils.so', 'liblog.so',
                    'libOpenCv.camera.samsung.so', 'libFoodDetector.camera.samsung.so'}
    native_entries = [(p, p.relative_to(root).as_posix()) for p in sorted(root.rglob('*'))
                      if p.is_file() and p.name in native_names]
    archive(output / 'native-display.zip', native_entries)
    for group, names in PACKAGES.items():
        entries = []
        for name in names:
            path = find_unique(root, name, required=name in {
                'framework.jar', 'services.jar', 'SamsungCamera.apk', 'SystemUI.apk',
                'SecSettings.apk', 'BiometricSetting.apk'})
            if path is None:
                metadata.setdefault('optional_absent', []).append(name)
                continue
            relative = path.relative_to(root).as_posix()
            metadata['files'].append({'path': relative, 'sha256': digest(path),
                                      'size': path.stat().st_size})
            entries.append((path, 'originals/' + relative))
            decoded = output / 'decoded' / group / name
            command = ['java', '-Xmx3072m', '-jar', str(tool), 'd', '-f', '-r', '--no-debug-info',
                       '-j', '1', '-o', str(decoded), str(path)]
            print(f'Decoding exact source {relative}', flush=True)
            try:
                subprocess.run(command, check=True)
            finally:
                # Even a decoder incompatibility must retain the exact original
                # and any decoded classes, rather than another empty artifact.
                entries.extend((p, 'decoded/' + name + '/' + p.relative_to(decoded).as_posix())
                               for p in sorted(decoded.rglob('*')) if p.is_file())
                archive(output / f'{group}.zip', entries)
                (output / 'manifest.json').write_text(json.dumps(metadata, indent=2) + '\n')
            if not any(decoded.glob('smali*/**/*.smali')):
                raise ValueError(f'No classes decoded from {path}')
        archive(output / f'{group}.zip', entries)

    # Keep original permissions/HAL/ld.config and camera XMLs together with the
    # actual APKtool used to decode this DEX version. Do not copy private keys.
    config_entries = [(tool, 'tools/apktool.jar')]
    config_names = {'build.prop', 'firmware-version.txt', '.extracted',
                    'sensors_list.txt', 'sensorhals.conf', 'linker.config.json'}
    for p in root.rglob('*'):
        if not p.is_file():
            continue
        rel = p.relative_to(root)
        parts = rel.parts
        if (p.name in config_names or (p.suffix in {'.xml', '.conf', '.rc', '.json'}
                and any(part in {'etc', 'configs'} for part in parts))):
            config_entries.append((p, rel.as_posix()))
    # The ELF index includes weak/strong imports and GNU IFUNC exports directly
    # from the symbol tables, avoiding column-based readelf parsing errors.
    from native_input_index import write_index
    write_index(root, output / 'native-index.json')
    config_entries.append((output / 'native-index.json', 'native-index.json'))
    archive(output / 'configs-tools.zip', config_entries)

    # Preserve original APEX containers in bounded standalone archives. The
    # native runtime index cannot assume their libraries are missing just
    # because they are not installed as loose /system/lib* files.
    apex = sorted(p for p in root.rglob('*') if p.is_file()
                  and p.suffix in {'.apex', '.capex'})
    shard, size, entries = 0, 0, []
    for path in apex:
        length = path.stat().st_size
        if length >= LIMIT:
            raise ValueError(f'Single APEX exceeds artifact limit: {path}')
        if entries and size + length >= 350 * 1024 * 1024:
            archive(output / f'apex-{shard}.zip', entries)
            shard, size, entries = shard + 1, 0, []
        entries.append((path, path.relative_to(root).as_posix()))
        size += length
    if entries:
        archive(output / f'apex-{shard}.zip', entries)
    if shard > 5:
        raise ValueError('More APEX shards than the workflow upload slots')

    (output / 'manifest.json').write_text(json.dumps(metadata, indent=2) + '\n')
    print('Exact inputs collected; no ROM or kernel build was started.', flush=True)


def collect_supplemental(root, tool, output, target=None):
    """Collect concrete remaining gaps without decoding the five retained apps again."""
    output.mkdir(parents=True, exist_ok=True)
    metadata = {'source': str(root.name), 'scope': 'supplemental exact inputs', 'files': []}
    for group, names in SUPPLEMENTAL_PACKAGES.items():
        entries = []
        try:
            for name in names:
                path = find_unique(root, name)
                relative = path.relative_to(root).as_posix()
                metadata['files'].append({'path': relative, 'sha256': digest(path),
                                          'size': path.stat().st_size})
                entries.append((path, 'originals/' + relative))
                decoded = output / 'decoded' / group / name
                print('Decoding remaining input ' + relative, flush=True)
                try:
                    subprocess.run(['java', '-Xmx3072m', '-jar', str(tool), 'd', '-f', '-r',
                                    '--no-debug-info', '-j', '1', '-o', str(decoded), str(path)], check=True)
                finally:
                    entries.extend((p, 'decoded/' + name + '/' + p.relative_to(decoded).as_posix())
                                   for p in sorted(decoded.rglob('*')) if p.is_file())
                if not any(decoded.glob('smali*/**/*.smali')):
                    raise ValueError('No classes decoded from ' + relative)
        finally:
            archive(output / (group + '.zip'), entries)
            (output / 'manifest.json').write_text(json.dumps(metadata, indent=2) + '\n')
    resources = find_unique(root, 'framework-res.apk')
    archive(output / 'aux-resources.zip', [(resources, 'originals/' + resources.relative_to(root).as_posix())])
    native = [(p, p.relative_to(root).as_posix()) for p in root.rglob('*')
              if p.is_file() and p.name in {'libstagefright.so', 'libexynosdisplay.so'}]
    archive(output / 'aux-native.zip', native)
    if target is not None:
        timestamp = target / 'vendor/lib/libstagefright_bufferqueue_helper_vendor.so'
        if not timestamp.is_file():
            raise ValueError('Pinned r8s vendor recording library is absent')
        entries = [(timestamp, timestamp.relative_to(target).as_posix())]
        metadata['target_recording_library'] = {'sha256': digest(timestamp), 'size': timestamp.stat().st_size}
        archive(output / 'aux-target.zip', entries)
    (output / 'manifest.json').write_text(json.dumps(metadata, indent=2) + '\n')
    print('Supplemental inputs collected; no ROM or kernel build started.', flush=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--firmware', type=Path, required=True)
    parser.add_argument('--apktool', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--supplemental', action='store_true')
    parser.add_argument('--target-firmware', type=Path)
    args = parser.parse_args()
    if args.supplemental:
        collect_supplemental(args.firmware.resolve(), args.apktool.resolve(), args.out.resolve(),
                             args.target_firmware.resolve() if args.target_firmware else None)
    else:
        collect(args.firmware.resolve(), args.apktool.resolve(), args.out.resolve())
