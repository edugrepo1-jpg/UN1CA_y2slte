# SPDX-License-Identifier: GPL-3.0-or-later
# Only loaded for SM-G780F / r8s. Other Exynos 990 targets retain Extreme Kernel.
#
# Full, user-owned GM kernel branch derived from r8s-chargemax-current-thermal-20261031.
# Includes our Charge Max V3 default ON, higher r8s charging current and thermal
# thresholds, r8s DT revisions, EA8079 96 Hz and the Clang bootstrap repair.
# IMPORTANT: threshold increases require physical thermal/charging validation.
R8S_GM_KERNEL_REPO="https://github.com/edugrepo1-jpg/android_kernel_samsung_exynos990.git"
R8S_GM_KERNEL_BRANCH="r8s-unica-full-20261101"
R8S_GM_KERNEL_SHA="fa5d1658e79b441e42073f874a6f81aee0b65459"

R8S_BUILD_OWN_KERNEL()
{
    local source_dir="$OUT_DIR/kernel_tmp-exynos990-gm-r8s"
    local build_boot build_dtbo current_origin
    local built_bytes dtbo_bytes cache_key cache_file
    local current_dir

    [[ "$TARGET_CODENAME" == "r8s" ]] || ABORT "GM kernel is restricted to r8s"
    [[ "$TARGET_BOOT_PARTITION_SIZE" == "61865984" ]] || \
        ABORT "SM-G780F requires exactly 61865984 bytes of boot partition"
    [[ "$TARGET_DTBO_PARTITION_SIZE" =~ ^[0-9]+$ ]] || \
        ABORT "Missing numeric TARGET_DTBO_PARTITION_SIZE"

    mkdir -p "$OUT_DIR"
    if [[ -e "$source_dir" && ! -d "$source_dir/.git" ]]; then
        ABORT "Refusing to reuse a non-Git kernel directory: $source_dir"
    fi

    if [[ ! -d "$source_dir/.git" ]]; then
        LOG "- Cloning our r8s kernel fork, not Extreme Kernel"
        git clone --single-branch --branch "$R8S_GM_KERNEL_BRANCH" \
            "$R8S_GM_KERNEL_REPO" "$source_dir" || return 1
    fi

    current_origin="$(git -C "$source_dir" remote get-url origin)" || return 1
    if [[ "$current_origin" != "$R8S_GM_KERNEL_REPO" ]]; then
        ABORT "Unexpected kernel origin: $current_origin"
    fi

    # Never reset a kernel working tree or silently accept new upstream commits.
    git -C "$source_dir" diff --quiet || ABORT "Local kernel edits exist; review them before continuing"
    git -C "$source_dir" diff --cached --quiet || ABORT "Staged kernel edits exist"
    git -C "$source_dir" fetch --no-tags origin "$R8S_GM_KERNEL_BRANCH" || return 1
    if [[ "$(git -C "$source_dir" rev-parse FETCH_HEAD)" != "$R8S_GM_KERNEL_SHA" ]]; then
        ABORT "Kernel fork branch moved; review changes and update the SHA pin explicitly"
    fi
    git -C "$source_dir" checkout --detach "$R8S_GM_KERNEL_SHA" || return 1
    git -C "$source_dir" submodule sync --recursive || return 1
    git -C "$source_dir" submodule update --init --recursive || return 1
    [[ -d "$source_dir/KernelSU-Next/kernel" ]] || \
        ABORT "Required KernelSU Next Legacy submodule not available"

    cache_file="$source_dir/.gm-r8s-unica-kernel-cache"
    cache_key="$R8S_GM_KERNEL_SHA:$(git -C "$source_dir" submodule status --recursive | sha256sum | cut -d ' ' -f 1):model=r8s,ksu=y,recovery=n"
    build_boot="$source_dir/build/out/r8s/boot.img"
    build_dtbo="$source_dir/build/out/r8s/dtbo.img"

    if [[ -f "$cache_file" && -f "$build_boot" && -f "$build_dtbo" \
       && "$(cat "$cache_file")" == "$cache_key" ]]; then
        LOG "- Reusing verified GM r8s kernel build"
    else
        LOG "- Compiling our GM kernel for r8s with KernelSU Next Legacy"
        current_dir="$PWD"
        cd "$source_dir" || return 1
        ./build.sh -m r8s -k y -r n
        local build_status=$?
        cd "$current_dir" || return 1
        [[ "$build_status" == "0" ]] || ABORT "GM r8s kernel build failed ($build_status)"
    fi

    [[ -s "$build_boot" && -s "$build_dtbo" ]] || ABORT "Missing GM kernel boot.img or dtbo.img"
    built_bytes="$(stat -c%s "$build_boot")" || return 1
    dtbo_bytes="$(stat -c%s "$build_dtbo")" || return 1
    (( built_bytes <= TARGET_BOOT_PARTITION_SIZE )) || \
        ABORT "GM boot.img exceeds the 59-MiB SM-G780F partition"
    (( dtbo_bytes <= TARGET_DTBO_PARTITION_SIZE )) || \
        ABORT "GM dtbo.img exceeds its destination partition"

    # Fail on wrong image formats or wrong r8s DTBO selector revisions.
    python3 - "$build_boot" "$build_dtbo" <<'PY'
import pathlib
import struct
import sys

boot, dtbo = map(pathlib.Path, sys.argv[1:])
if boot.open("rb").read(8) != b"ANDROID!":
    raise SystemExit("Invalid Android boot image magic")
with dtbo.open("rb") as fh:
    header = fh.read(32)
    if len(header) != 32:
        raise SystemExit("Truncated Android DTBO table header")
    magic, total, hdr_size, entry_size, count, offset, page_size, version = struct.unpack(">8I", header)
    if magic != 0xD7B7AB1E or total > dtbo.stat().st_size:
        raise SystemExit("Invalid DTBO image header")
    if hdr_size < 32 or entry_size < 32 or count != 3 or offset < hdr_size:
        raise SystemExit("Unexpected r8s DTBO geometry")
    if offset + count * entry_size > total:
        raise SystemExit("DTBO entries extend beyond image")
    revisions = []
    for idx in range(count):
        fh.seek(offset + idx * entry_size)
        entry = fh.read(32)
        if len(entry) != 32:
            raise SystemExit("Truncated DTBO entry")
        dt_size, dt_offset, dt_id, rev, c0, c1, c2, c3 = struct.unpack(">8I", entry)
        if dt_size == 0 or dt_offset + dt_size > total:
            raise SystemExit("Invalid embedded DTB bounds")
        revisions.append((c0, c1))
    expected = [(0, 1), (2, 4), (5, 255)]
    if revisions != expected:
        raise SystemExit(f"Wrong SM-G780F DTBO selectors: {revisions!r} != {expected!r}")
print("GM r8s boot magic, DTBO table and stock revision selectors OK")
PY
    [[ "$?" == "0" ]] || ABORT "GM kernel image geometry/DTBO validation failed"

    printf '%s' "$cache_key" > "$cache_file"
    mkdir -p "$WORK_DIR/kernel"
    cp -f "$build_boot" "$WORK_DIR/kernel/boot.img" || return 1
    cp -f "$build_dtbo" "$WORK_DIR/kernel/dtbo.img" || return 1
    # r8s has no LTE sibling DTBO artifact.
    rm -f "$WORK_DIR/kernel/dtbo_lte.img"
    LOG "- Using GM r8s kernel $R8S_GM_KERNEL_SHA; Charge Max V3 is enabled by default in the pinned GM kernel"
}
R8S_BUILD_OWN_KERNEL
