#!/system/bin/sh
#
# Copyright (C) 2024-2026 Rem01Gaming
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

MODDIR=${0%/*}
MODULE_CONFIG="/data/adb/.config/encore"

# === SUSFS Kernel Cloaking (Additive & Anti-Detection) ===
SUSFS_BIN=""
for _candidate in /data/adb/ksu/bin/ksu_susfs /system/bin/susfs /data/adb/bin/ksu_susfs /data/adb/ap/bin/ksu_susfs; do
    if [ -x "$_candidate" ]; then
        SUSFS_BIN="$_candidate"
        break
    fi
done

if [ -z "$SUSFS_BIN" ] && command -v ksu_susfs >/dev/null 2>&1; then
    SUSFS_BIN="ksu_susfs"
elif [ -z "$SUSFS_BIN" ] && command -v susfs >/dev/null 2>&1; then
    SUSFS_BIN="susfs"
fi

if [ -n "$SUSFS_BIN" ]; then
    # 1. VFS Path Cloaking (add_sus_path & add_sus_path_loop -> return ENOENT)
    "$SUSFS_BIN" add_sus_path_loop "$MODDIR" 2>/dev/null || "$SUSFS_BIN" add_sus_path "$MODDIR" 2>/dev/null
    if [ -d "$MODULE_CONFIG" ]; then
        "$SUSFS_BIN" add_sus_path_loop "$MODULE_CONFIG" 2>/dev/null || "$SUSFS_BIN" add_sus_path "$MODULE_CONFIG" 2>/dev/null
    fi
    [ -f "/data/adb/service.d/.encore_cleanup.sh" ] && "$SUSFS_BIN" add_sus_path "/data/adb/service.d/.encore_cleanup.sh" 2>/dev/null
    [ -d "/data/encore" ] && "$SUSFS_BIN" add_sus_path_loop "/data/encore" 2>/dev/null

    # 2. Memory Maps Masking (add_sus_map -> scrub from /proc/[pid]/maps, smaps)
    for _bin in "$MODDIR/system/bin/encored" \
                "$MODDIR/system/bin/encore_profiler" \
                "$MODDIR/system/bin/encore_utility" \
                "/data/adb/ksu/bin/encored" \
                "/data/adb/ksu/bin/encore_profiler" \
                "/data/adb/ksu/bin/encore_utility" \
                "/data/adb/ap/bin/encored" \
                "/data/adb/ap/bin/encore_profiler" \
                "/data/adb/ap/bin/encore_utility"; do
        [ -e "$_bin" ] && "$SUSFS_BIN" add_sus_map "$_bin" 2>/dev/null
    done

    # 3. Mount Table Filtering (hide_sus_mnts & add_sus_mount)
    "$SUSFS_BIN" add_sus_mount "$MODDIR" 2>/dev/null
    "$SUSFS_BIN" add_try_umount "$MODDIR" 2>/dev/null
    "$SUSFS_BIN" hide_sus_mnts_for_non_su_procs 1 2>/dev/null

    # 4. Kernel Log & AVC Audit Spoofing
    "$SUSFS_BIN" enable_log 0 2>/dev/null
    "$SUSFS_BIN" enable_avc_log_spoofing 1 2>/dev/null

    # 5. Kstat Inode Spoofing (clone genuine system inode metadata)
    for _f in "$MODDIR/system/bin/"*; do
        [ -f "$_f" ] && "$SUSFS_BIN" update_sus_kstat_full_clone "$_f" 2>/dev/null
    done
fi

# 3. ZeroMount & Mount Isolation Handling
if [ -e "/dev/zeromount" ]; then
    # ZeroMount VFS active - Zero mount points created
    :
else
    # Fallback for standard KernelSU/APatch mount
    if command -v ksud >/dev/null 2>&1; then
        ksud kernel umount add 'encore' 2>/dev/null || true
    fi
    [ -n "$SUSFS_BIN" ] && "$SUSFS_BIN" add_try_umount "$MODDIR" 2>/dev/null || true
fi
