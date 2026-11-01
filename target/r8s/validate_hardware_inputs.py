#!/usr/bin/env python3
"""Check final hardware inputs against the r8s stock, not the donor's hardware.

These checks prove preservation of loader inputs, features and HAL names.
They do not prove HAL execution, linker namespaces or physical operation.
"""
from pathlib import Path, PurePosixPath
import sys
import xml.etree.ElementTree as ET

PARTITIONS = ('vendor', 'odm', 'system/system', 'system', 'system_ext', 'product')
HALS = {
    'android.hardware.sensors', 'android.hardware.nfc', 'vendor.samsung.hardware.nfc',
    'android.hardware.camera.provider', 'android.hardware.biometrics.fingerprint',
    'android.hardware.biometrics.face', 'android.hardware.gnss',
    'vendor.samsung.hardware.biometrics.face',
    'vendor.samsung.hardware.biometrics.fingerprint',
    'vendor.samsung.hardware.gnss', 'android.hardware.usb',
    'vendor.samsung.hardware.light', 'android.hardware.bluetooth',
    'android.hardware.wifi', 'vendor.samsung.hardware.wifi',
    'android.hardware.audio', 'android.hardware.audio.effect',
    'android.hardware.health', 'android.hardware.power', 'android.hardware.thermal',
    'android.hardware.keymaster',
}
FEATURES = ('android.hardware.sensor.', 'android.hardware.camera',
            'android.hardware.nfc', 'android.hardware.wifi',
            'android.hardware.bluetooth', 'android.hardware.location.gps',
            'android.hardware.usb', 'android.hardware.fingerprint',
            'android.hardware.strongbox_keystore')


def hardware_features(root: Path) -> set[str]:
    return {node.attrib['name'] for partition in PARTITIONS
            for xml in (root / partition / 'etc/permissions').glob('*.xml')
            if xml.name.startswith('android.hardware.') or xml.name in
            ('handheld_core_hardware.xml', 'tablet_core_hardware.xml')
            for node in ET.parse(xml).getroot().iter('feature')
            if node.get('name', '').startswith(FEATURES)}


def hal_names(root: Path) -> set[str]:
    result = set()
    for partition in PARTITIONS:
        directory = root / partition / 'etc/vintf'
        for xml in (directory / 'manifest.xml', *sorted((directory / 'manifest').glob('*.xml'))):
            if xml.is_file():
                document = ET.parse(xml).getroot()
                if document.tag == 'manifest':
                    result.update(node.text.strip() for node in document.findall('hal/name')
                                  if node.text and node.text.strip() in HALS)
    return result


def sensor_modules(config: Path) -> set[str]:
    return {line.split('#', 1)[0].strip() for line in config.read_text(encoding='utf-8').splitlines()
            if line.split('#', 1)[0].strip()}


def module_path(root: Path, module: str) -> Path:
    path = PurePosixPath(module)
    if not path.is_absolute() or '..' in path.parts:
        raise ValueError(f'Invalid sensor HAL module path: {module}')
    if module.startswith('/system/vendor/'):
        return root / 'vendor' / module.removeprefix('/system/vendor/')
    if module.startswith('/vendor/'):
        return root / module.lstrip('/')
    if module.startswith('/system/'):
        return root / 'system/system' / module.removeprefix('/system/')
    raise ValueError(f'Unsupported sensor HAL module partition: {module}')


def verify(stock: Path, final: Path) -> dict:
    if not (stock / 'vendor/etc/vintf').is_dir() or not (final / 'vendor').is_dir():
        raise ValueError('r8s stock/final vendor inputs are missing')
    features = hardware_features(stock)
    missing = features - hardware_features(final)
    if missing:
        raise ValueError(f'Stock r8s hardware features missing from final tree: {sorted(missing)}')
    hals = hal_names(stock)
    missing = hals - hal_names(final)
    if missing:
        raise ValueError(f'Stock r8s HAL declarations missing from final tree: {sorted(missing)}')
    config = stock / 'vendor/etc/sensors/hals.conf'
    modules = set()
    if config.is_file():
        configured = final / 'vendor/etc/sensors/hals.conf'
        if not configured.is_file():
            raise ValueError('Final r8s sensor multi-HAL configuration is missing')
        modules = sensor_modules(config)
        missing = modules - sensor_modules(configured)
        if missing:
            raise ValueError(f'Stock sensor modules were dropped: {sorted(missing)}')
        for module in sorted(sensor_modules(configured)):
            path = module_path(final, module)
            expected = 2 if '/lib64/' in module else 1
            if not path.is_file():
                raise ValueError(f'Configured sensor HAL library is missing: {module}')
            with path.open('rb') as stream:
                header = stream.read(20)
            if (len(header) < 20 or header[:4] != b'\x7fELF' or header[4] != expected
                    or header[5] != 1 or int.from_bytes(header[18:20], 'little') != (183 if expected == 2 else 40)):
                raise ValueError(f'Configured sensor HAL has the wrong ELF ABI: {module}')
    if not features or not hals:
        raise ValueError('Stock hardware inventory is empty; refusing a vacuous validation')
    return {'stock_hardware_features_preserved': len(features),
            'stock_hal_names_preserved': len(hals), 'stock_sensor_modules_preserved': len(modules)}


if __name__ == '__main__':
    try:
        result = verify(Path(sys.argv[1]), Path(sys.argv[2]))
        print('r8s final hardware loader inputs: ' + str(result))
    except (OSError, ValueError, ET.ParseError, IndexError) as exc:
        print(f'r8s hardware input validation failed: {exc}', file=sys.stderr)
        raise SystemExit(1) from exc
