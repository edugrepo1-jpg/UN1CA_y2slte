#!/usr/bin/env python3
"""Check r8s ChargeMax wiring and units; this cannot certify physical charging."""
from pathlib import Path
import argparse
import json
import re
import shutil
import subprocess
import tempfile


def function(text, name):
    match = re.search(r'\b(?:bool|int)\s+' + re.escape(name) + r'\([^)]*\)\s*\{', text)
    if not match:
        raise ValueError('Missing ChargeMax helper ' + name)
    start, end, depth = match.start(), match.end(), 1
    while depth:
        if text[end] == '{':
            depth += 1
        elif text[end] == '}':
            depth -= 1
        end += 1
    return text[start:end]


def inspect(root, require_cc=False):
    battery = (root / 'drivers/battery_v2/sec_battery.c').read_text()
    sysfs = (root / 'drivers/battery_v2/sec_battery_sysfs.c').read_text()
    enums = (root / 'drivers/battery_v2/include/sec_battery_sysfs.h').read_text()
    common = (root / 'drivers/battery_v2/include/sec_charging_common.h').read_text()
    dts = (root / 'arch/arm64/boot/dts/samsung/battery_data_r8_common.dtsi').read_text()
    config = (root / 'arch/arm64/configs/exynos9830_defconfig').read_text()
    probe = battery.split('static int sec_battery_probe(', 1)[1]
    if 'battery->charge_max_mode = true;' not in probe:
        raise ValueError('ChargeMax must initialize ON in the battery probe')
    for option in ('BATTERY_SAMSUNG', 'BATTERY_SAMSUNG_V2', 'BATTERY_SWELLING', 'DIRECT_CHARGING', 'STEP_CHARGING'):
        if 'CONFIG_' + option + '=y' not in config:
            raise ValueError('Required charging/protection option missing: ' + option)
    enum_body = next(m[1] for m in re.finditer(r'enum\s*\{([^}]+)\}', enums, re.S) if 'CHARGE_MAX_MODE' in m[1])
    enum_body = re.sub(r'/\*.*?\*/|//[^\n]*', '', enum_body, flags=re.S)
    entries = [x.strip().split('=')[0].strip() for x in enum_body.split(',') if x.strip()]
    attrs = re.search(r'sec_battery_attrs\[\]\s*=\s*\{(.*?)\n\};', sysfs, re.S)[1]
    names = re.findall(r'SEC_BATTERY_ATTR\((\w+)\)', attrs)
    if entries.index('CHARGE_MAX_MODE') != names.index('charge_max_mode'):
        raise ValueError('ChargeMax sysfs enum and attribute indexes disagree')
    values = {}
    for name, raw in re.findall(r'((?:battery|charger),[\w_]+)\s*=\s*<([^>]+)>', dts):
        if all(re.fullmatch(r'-?(?:0[xX][0-9a-fA-F]+|[0-9]+)', token) for token in raw.split()):
            values[name] = [int(x, 0) for x in raw.split()]
    pairs = [('battery,chg_high_temp', 'battery,chg_high_temp_recovery'),
             ('battery,dchg_high_temp', 'battery,dchg_high_temp_recovery'),
             ('battery,dchg_high_batt_temp', 'battery,dchg_high_batt_temp_recovery'),
             ('battery,mix_high_temp', 'battery,mix_high_temp_recovery'),
             ('battery,swelling_high_temp_block', 'battery,swelling_high_temp_recov')]
    for high, recovery in pairs:
        if len(values[high]) != len(values[recovery]):
            raise ValueError('Thermal table lengths differ: ' + high)
        for h, r in zip(values[high], values[recovery]):
            if (h, r) != (1000, 1000) and not h > r:
                raise ValueError('Invalid thermal hysteresis: ' + high)
    if values['battery,chg_float_voltage'][0] > 4380:
        raise ValueError('Battery voltage exceeds the reviewed r8s 4380 mV target')
    for name in ('battery,dchg_input_limit_current', 'battery,dchg_charging_limit_current',
                 'battery,siop_apdo_charging_limit_current'):
        if values[name][0] <= 0 or values[name][0] > values['battery,max_input_current' if 'input' in name else 'battery,max_charging_current'][0]:
            raise ValueError('Charging limiter is outside its declared current range: ' + name)

    helpers = '\n'.join(function(battery, name) for name in ('sec_bat_charge_max_mode_active', 'sec_bat_effective_charge_siop'))
    cable_enum = next(m[0] for m in re.finditer(r'enum\s+\w*\s*\{[^}]+\}', common, re.S) if 'SEC_BATTERY_CABLE_NONE' in m[0])
    macros = {}
    lines = iter(common.splitlines())
    for line in lines:
        if not line.startswith('#define is_'):
            continue
        block = [line]
        while block[-1].rstrip().endswith('\\'):
            block.append(next(lines))
        macros[re.match(r'#define (\w+)', line)[1]] = '\n'.join(block)
    selected, pending = {}, ['is_wired_type', 'is_wireless_type']
    while pending:
        name = pending.pop()
        if name in selected:
            continue
        selected[name] = macros[name]
        pending.extend(n for n in re.findall(r'\b(is_\w+)\(', macros[name]) if n != name)
    # Some cable IDs, notably HV_WIRELESS_ETX=100, are object macros outside
    # the contiguous enum. Retain their exact definitions in the host harness.
    cable_defines = '\n'.join(re.findall(r'^#define\s+SEC_BATTERY_CABLE_\w+\s+[^\n]+', common, re.M))
    compiler = shutil.which('cc') or shutil.which('clang') or shutil.which('gcc')
    cases = None
    if compiler:
        code = ('#include <assert.h>\n#include <stdbool.h>\n#include <stdio.h>\n' + cable_defines + '\n' + cable_enum + ';\n' +
                '\n'.join(selected.values()) + '\nstruct sec_battery_info {bool charge_max_mode,charging_enabled,store_mode;int cable_type,siop_level;};\n' + helpers + r'''
int main(void) { int cases=0;
for(int mode=0;mode<2;mode++)for(int on=0;on<2;on++)for(int store=0;store<2;store++)
for(int cable=0;cable<=SEC_BATTERY_CABLE_HV_WIRELESS_ETX;cable++)for(int raw=0;raw<=100;raw++) {
if(cable>=SEC_BATTERY_CABLE_MAX&&cable!=SEC_BATTERY_CABLE_HV_WIRELESS_ETX)continue;
struct sec_battery_info b={mode,on,store,cable,raw};
bool expected=mode&&on&&!store&&is_wired_type(cable);
assert(sec_bat_charge_max_mode_active(&b)==expected);
assert(sec_bat_effective_charge_siop(&b)==(expected?100:raw));
assert(b.siop_level==raw);cases++;
}printf("%d\n",cases);return 0;}
''')
        with tempfile.TemporaryDirectory() as temp:
            source, binary = Path(temp) / 'contract.c', Path(temp) / 'contract'
            source.write_text(code)
            subprocess.run([compiler, '-std=c11', '-Wall', '-Werror', str(source), '-o', str(binary)], check=True)
            cases = int(subprocess.check_output([str(binary)], text=True).strip())
    elif require_cc:
        raise ValueError('A native host C compiler is required for the actual ChargeMax helper contract')
    report = {'charge_max_default_on': True, 'sysfs_index': names.index('charge_max_mode'),
              'native_helper_cases': cases, 'charging_configuration': {k: values[k] for k in values if k in {
                  'battery,dchg_input_limit_current', 'battery,dchg_charging_limit_current',
                  'battery,siop_apdo_charging_limit_current', 'battery,chg_float_voltage',
                  'battery,dc_step_chg_val_iout'}},
              'thermal_hysteresis_valid': True,
              'scope': 'Source/configuration and native helper contracts, not physical electrical or battery safety validation'}
    print(json.dumps(report, indent=2))
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('kernel', type=Path)
    parser.add_argument('--require-cc', action='store_true')
    args = parser.parse_args()
    inspect(args.kernel.resolve(), args.require_cc)
