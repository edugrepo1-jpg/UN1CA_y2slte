#!/usr/bin/env bash
# GMKernel 4.19 Exynos990 already contains the Android 17 interfaces that
# upstream UN1CA's Extreme kernel patches add. Verify actual source behavior;
# do NOT reapply three Extreme-specific patches on top of this source.
set -euo pipefail
[[ "$#" -eq 1 && -d "$1" ]] || { echo "Usage: $0 GMKERNEL_SOURCE" >&2; exit 2; }
K="$1"

require() {
    local file="$1" pattern="$2"
    if ! grep -Fq -- "$pattern" "$K/$file"; then
        echo "GMKernel missing Android17 ABI in $file: $pattern" >&2
        exit 1
    fi
}

# Recursive memory.min/low cgroup2 semantics, including mount policy.
require include/linux/cgroup-defs.h 'CGRP_ROOT_MEMORY_RECURSIVE_PROT'
require kernel/cgroup/cgroup.c 'strcmp(token, "memory_recursiveprot")'
require kernel/cgroup/cgroup.c '"memory_recursiveprot'
require mm/memcontrol.c 'CGRP_ROOT_MEMORY_RECURSIVE_PROT'
require mm/memcontrol.c 'parent_effective - siblings_protected'
# cgroup.kill must be exposed and also close the fork race.
require include/linux/cgroup-defs.h 'CGRP_KILL'
require kernel/cgroup/cgroup.c 'static void __cgroup_kill'
require kernel/cgroup/cgroup.c 'cgroup_kill_write'
require kernel/cgroup/cgroup.c '"cgroup.kill"'
require kernel/cgroup/cgroup.c 'test_bit(CGRP_KILL'
# Android17 native zygote CAP bounding set ABI and SELinux names.
require include/uapi/linux/capability.h '#define CAP_PERFMON'
require include/uapi/linux/capability.h '#define CAP_BPF'
require include/uapi/linux/capability.h '#define CAP_CHECKPOINT_RESTORE'
require include/uapi/linux/capability.h 'CAP_LAST_CAP         CAP_CHECKPOINT_RESTORE'
require security/selinux/include/classmap.h '"perfmon", "bpf"'
require security/selinux/include/classmap.h '"checkpoint_restore"'
echo "GMKernel: Android 17 cgroup2 recursive protection, kill and capability ABIs present"
