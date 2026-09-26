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
    # 1. Hide active module directory and all recursive sub-paths from VFS lookups
    "$SUSFS_BIN" add_sus_path_loop "$MODDIR" 2>/dev/null || "$SUSFS_BIN" add_sus_path "$MODDIR" 2>/dev/null
    
    # Hide module config directory
    if [ -d "$MODULE_CONFIG" ]; then
        "$SUSFS_BIN" add_sus_path_loop "$MODULE_CONFIG" 2>/dev/null || "$SUSFS_BIN" add_sus_path "$MODULE_CONFIG" 2>/dev/null
    fi

    # 2. Hide mapped binary execution memory pages (proc/pid/maps, smaps)
    [ -f "$MODDIR/system/bin/encored" ] && "$SUSFS_BIN" add_sus_map "$MODDIR/system/bin/encored" 2>/dev/null
    [ -f "$MODDIR/system/bin/encore_profiler" ] && "$SUSFS_BIN" add_sus_map "$MODDIR/system/bin/encore_profiler" 2>/dev/null
    [ -f "$MODDIR/system/bin/encore_utility" ] && "$SUSFS_BIN" add_sus_map "$MODDIR/system/bin/encore_utility" 2>/dev/null
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
