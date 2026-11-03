#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Validate real host mounting before downloading Samsung firmware. No guest OS.
set -euo pipefail

as_root() {
    if [[ "$(id -u)" == 0 ]]; then "$@"; else sudo -n -- "$@"; fi
}

prepare_filesystems() {
    local release package
    release=$(uname -r)
    as_root modprobe fuse
    if ! as_root modprobe f2fs; then
        # New Ubuntu kernels may ship these modules in the unified package.
        # Never request an unavailable package or replace the running kernel.
        for package in "linux-modules-extra-$release" "linux-modules-$release"; do
            if apt-cache show "$package" >/dev/null 2>&1; then
                as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "$package"
                if as_root modprobe f2fs; then break; fi
            fi
        done
    fi
    if ! grep -qw f2fs /proc/filesystems; then
        echo "::error::Running host kernel $release cannot mount F2FS. Firmware extraction cannot continue." >&2
        return 1
    fi
    if ! test -c /dev/fuse; then
        echo "::error::FUSE is required by fuse.erofs for firmware extraction." >&2
        return 1
    fi
}

smoke_test() (
    local scratch mounted=false
    scratch=$(mktemp -d)
    cleanup() {
        if $mounted; then
            as_root umount "$scratch/mount" || return 1
        fi
        rm -f -- "$scratch/test.img"
        rmdir -- "$scratch/mount" "$scratch"
    }
    trap cleanup EXIT
    mkdir "$scratch/mount"
    truncate -s 256M "$scratch/test.img"
    mkfs.f2fs -f "$scratch/test.img"
    as_root mount -o loop,ro "$scratch/test.img" "$scratch/mount"
    mounted=true
    as_root umount "$scratch/mount"
    mounted=false
    echo "Host F2FS read-only image mount verified; FUSE available."
)

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    prepare_filesystems
    smoke_test
fi
