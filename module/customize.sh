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

# shellcheck disable=SC1091,SC2034,SC2317
SKIPUNZIP=1
SOC=0

MODULE_CONFIG="/data/adb/.config/encore"

make_node() {
	[ ! -f "$2" ] && echo "$1" >"$2"
}

make_dir() {
	[ ! -d "$1" ] && mkdir -p "$1"
}

abort_unsupported_arch() {
	ui_print "*********************************************************"
	ui_print "! Unsupported Architecture: $ARCH"
	ui_print "! Your CPU architecture is not supported by Zcore Tweaks."
	abort "*********************************************************"
}

abort_corrupted() {
	ui_print "*********************************************************"
	ui_print "! Unable to extract verify.sh!"
	ui_print "! Installation aborted. The module may be corrupted."
	ui_print "! Please re-download and try again."
	abort "*********************************************************"
}

abort_gamelist_error() {
	ui_print "*********************************************************"
	ui_print "! Failed to initialize gamelist!"
	ui_print "! Installation aborted."
	abort "*********************************************************"
}

abort_android_version() {
	ui_print "*********************************************************"
	ui_print "! Your Android Version is not supported!"
	ui_print "! Please use Android 10 (Q) or higher."
	ui_print "! Installation aborted."
	abort "*********************************************************"
}

soc_recognition_extra() {
	[ -d /sys/class/kgsl/kgsl-3d0/devfreq ] && {
		SOC=2
		ui_print "- Implementing tweaks for Snapdragon"
		return 0
	}

	[ -d /sys/devices/platform/kgsl-2d0.0/kgsl ] && {
		SOC=2
		ui_print "- Implementing tweaks for Snapdragon"
		return 0
	}

	[ -d /sys/kernel/ged/hal ] && {
		SOC=1
		ui_print "- Implementing tweaks for MediaTek"
		return 0
	}

	[ -d /sys/kernel/tegra_gpu ] && {
		SOC=6
		ui_print "- Implementing tweaks for Nvidia Tegra"
		return 0
	}

	return 1
}

get_soc_getprop() {
	SOC_PROP="
ro.board.platform
ro.soc.model
ro.hardware
ro.chipname
ro.hardware.chipname
ro.vendor.soc.model.external_name
ro.vendor.qti.soc_name
ro.vendor.soc.model.part_name
ro.vendor.soc.model
"

	for prop in $SOC_PROP; do
		getprop "$prop"
	done
}

recognize_soc() {
	case "$1" in
	*mt* | *MT*) SOC=1 ;;
	*sm* | *qcom* | *SM* | *QCOM* | *Qualcomm*) SOC=2 ;;
	*exynos* | *Exynos* | *EXYNOS* | *universal* | *samsung* | *erd* | *s5e*) SOC=3 ;;
	*Unisoc* | *unisoc* | *ums* | *UNISOC* | *sp* | *SC*) SOC=4 ;;
	*gs* | *Tensor* | *tensor*) SOC=5 ;;
	*kirin*) SOC=7 ;;
	esac

	case "$SOC" in
	1) ui_print "- Implementing tweaks for MediaTek" ;;
	2) ui_print "- Implementing tweaks for Snapdragon" ;;
	3) ui_print "- Implementing tweaks for Exynos" ;;
	4) ui_print "- Implementing tweaks for Unisoc" ;;
	5) ui_print "- Implementing tweaks for Google Tensor" ;;
	6) ui_print "- Implementing tweaks for Nvidia Tegra" ;;
	7) ui_print "- Implementing tweaks for Kirin" ;;
	0) return 1 ;;
	esac
}

generate_gamelist() {
  make_dir "$MODULE_CONFIG"
  make_dir "/data/adb/.config/encore"
  extract "$ZIPFILE" 'gamelist.txt' "$TMPDIR"
  [ -x "$MODPATH/system/bin/zcored" ] && BIN_CMD="$MODPATH/system/bin/zcored" || BIN_CMD="$MODPATH/system/bin/encored"
  "$BIN_CMD" setup_gamelist "$TMPDIR/gamelist.txt"
  exit_code=$?

  # Sync generated gamelist.json across both directories
  if [ -f "/data/adb/.config/encore/gamelist.json" ]; then
    cp -f "/data/adb/.config/encore/gamelist.json" "$MODULE_CONFIG/gamelist.json" 2>/dev/null
  elif [ -f "$MODULE_CONFIG/gamelist.json" ]; then
    cp -f "$MODULE_CONFIG/gamelist.json" "/data/adb/.config/encore/gamelist.json" 2>/dev/null
  fi

  rm -f "$TMPDIR/gamelist.txt"
  [ ! -f "$MODULE_CONFIG/gamelist.json" ] && [ ! -f "/data/adb/.config/encore/gamelist.json" ] && abort_gamelist_error
}

# Check Android version
[ "$API" -lt 29 ] && abort_android_version

# Flashable integrity checkup
ui_print "- Extracting verify.sh"
unzip -o "$ZIPFILE" 'verify.sh' -d "$TMPDIR" >&2
[ ! -f "$TMPDIR/verify.sh" ] && abort_corrupted
source "$TMPDIR/verify.sh"

# Extract module files
ui_print "- Extracting module files"
extract "$ZIPFILE" 'module.prop' "$MODPATH"
extract "$ZIPFILE" 'banner.webp' "$MODPATH"
extract "$ZIPFILE" 'service.sh' "$MODPATH"
extract "$ZIPFILE" 'post-fs-data.sh' "$MODPATH"
extract "$ZIPFILE" 'uninstall.sh' "$MODPATH"
extract "$ZIPFILE" 'action.sh' "$MODPATH"
extract "$ZIPFILE" 'cleanup.sh' "$MODPATH"
extract "$ZIPFILE" 'binder_resolver.apk' "$MODPATH"
for script in zcore_profiler zcore_utility encore_profiler encore_utility; do
	if unzip -l "$ZIPFILE" 2>/dev/null | grep -q "system/bin/$script"; then
		extract "$ZIPFILE" "system/bin/$script" "$MODPATH"
	fi
done
cp "$MODPATH/module.prop" "$MODPATH/module.prop.orig"

# Target architecture
case $ARCH in
"arm64") ARCH_TMP="arm64-v8a" ;;
"arm") ARCH_TMP="armeabi-v7a" ;;
*) abort_unsupported_arch ;;
esac

# Extract executables
if unzip -l "$ZIPFILE" 2>/dev/null | grep -q "libs/$ARCH_TMP/zcored"; then
	extract "$ZIPFILE" "libs/$ARCH_TMP/zcored" "$TMPDIR"
	cp "$TMPDIR"/libs/"$ARCH_TMP"/* "$MODPATH/system/bin"
	ln -sf "$MODPATH/system/bin/zcored" "$MODPATH/system/bin/encored"
elif unzip -l "$ZIPFILE" 2>/dev/null | grep -q "libs/$ARCH_TMP/encored"; then
	extract "$ZIPFILE" "libs/$ARCH_TMP/encored" "$TMPDIR"
	cp "$TMPDIR"/libs/"$ARCH_TMP"/* "$MODPATH/system/bin"
	ln -sf "$MODPATH/system/bin/encored" "$MODPATH/system/bin/zcored"
fi
rm -rf "$TMPDIR/libs"

# Ensure mutual symlinks inside system/bin
[ -e "$MODPATH/system/bin/zcore_profiler" ] && [ ! -e "$MODPATH/system/bin/encore_profiler" ] && ln -sf "$MODPATH/system/bin/zcore_profiler" "$MODPATH/system/bin/encore_profiler"
[ -e "$MODPATH/system/bin/encore_profiler" ] && [ ! -e "$MODPATH/system/bin/zcore_profiler" ] && ln -sf "$MODPATH/system/bin/encore_profiler" "$MODPATH/system/bin/zcore_profiler"
[ -e "$MODPATH/system/bin/zcore_utility" ] && [ ! -e "$MODPATH/system/bin/encore_utility" ] && ln -sf "$MODPATH/system/bin/zcore_utility" "$MODPATH/system/bin/encore_utility"
[ -e "$MODPATH/system/bin/encore_utility" ] && [ ! -e "$MODPATH/system/bin/zcore_utility" ] && ln -sf "$MODPATH/system/bin/encore_utility" "$MODPATH/system/bin/zcore_utility"

# For KSU / APatch standalone WebUI
if [ "$KSU" = "true" ] || [ "$APATCH" = "true" ]; then
	rm "$MODPATH/action.sh"
fi

# Symlink ourselves on $PATH
manager_paths="/data/adb/ap/bin /data/adb/ksu/bin"
BIN_PATH="$MODPATH/system/bin"
for dir in $manager_paths; do
	[ -d "$dir" ] && {
		ui_print "- Creating symlink in $dir"
		for b in zcored zcore_profiler zcore_utility encored encore_profiler encore_utility; do
			[ -e "$BIN_PATH/$b" ] && ln -sf "$BIN_PATH/$b" "$dir/$b"
		done
	}
done

# Extract system, vendor, and odm partitions for ZeroMount VFS
for part in system vendor odm; do
	if unzip -l "$ZIPFILE" 2>/dev/null | grep -q "$part/"; then
		ui_print "- Extracting $part files for ZeroMount VFS"
		unzip -o "$ZIPFILE" "$part/*" -d "$MODPATH" -x "*.sha256" >&2
		set_perm_recursive "$MODPATH/$part" 0 0 0755 0644
	fi
done
# Extract webroot
ui_print "- Extracting webroot"
unzip -o "$ZIPFILE" "webroot/*" -d "$MODPATH" -x "*.sha256" >&2

# Mitigate root detection
[ -d /data/encore ] && rm -rf /data/encore
[ -d /data/zcore ] && rm -rf /data/zcore
[ -f /data/local/tmp/encore_logo.png ] && rm -f /data/local/tmp/encore_logo.png
rm -rf /data/adb/modules/encore 2>/dev/null || true

# Set configs
ui_print "- Zcore Tweaks configuration setup"
if [ -d "/data/adb/.config/encore" ] && [ ! -d "$MODULE_CONFIG" ]; then
	ui_print "- Migrating configuration from Encore"
	cp -r /data/adb/.config/encore "$MODULE_CONFIG"
fi
make_dir "$MODULE_CONFIG"
unzip -o "$ZIPFILE" "config/*" -d "$MODULE_CONFIG" -x "*.sha256" >&2
mv "$MODULE_CONFIG/config/"* "$MODULE_CONFIG/"
rm -rf "$MODULE_CONFIG/config"

# Permission settings
ui_print "- Permission setup"
set_perm_recursive "$MODPATH/system/bin" 0 0 0755 0755
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755 2>/dev/null

# Create symlinks so both encore and zcore paths resolve to the same location
make_dir "$MODULE_CONFIG"
make_dir "/data/adb/.config/zcore"
[ ! -L "/data/adb/.config/zcore" ] && ln -sf "/data/adb/.config/encore" "/data/adb/.config/zcore" 2>/dev/null || true

# Gamelist setup
need_generate=0
if [ ! -f "$MODULE_CONFIG/gamelist.json" ] && [ ! -f "/data/adb/.config/encore/gamelist.json" ]; then
  need_generate=1
else
  # Check if existing gamelist.json is empty "{}" or blank
  _raw=$(tr -d ' \n\r\t' < "$MODULE_CONFIG/gamelist.json" 2>/dev/null)
  [ -z "$_raw" ] && _raw=$(tr -d ' \n\r\t' < "/data/adb/.config/encore/gamelist.json" 2>/dev/null)
  if [ "$_raw" = "{}" ] || [ -z "$_raw" ]; then
    ui_print "- Empty gamelist detected, auto-populating installed games..."
    need_generate=1
  fi
fi

if [ $need_generate -eq 1 ]; then
  ui_print "- Generating Gamelist JSON from recommended games..."
  generate_gamelist
else
  ui_print "- Preserving existing user game configurations..."
  [ -f "/data/adb/.config/encore/gamelist.json" ] && [ ! -f "$MODULE_CONFIG/gamelist.json" ] && cp -f "/data/adb/.config/encore/gamelist.json" "$MODULE_CONFIG/gamelist.json"
  [ -f "$MODULE_CONFIG/gamelist.json" ] && [ ! -f "/data/adb/.config/encore/gamelist.json" ] && cp -f "$MODULE_CONFIG/gamelist.json" "/data/adb/.config/encore/gamelist.json"

  [ -x "$MODPATH/system/bin/zcored" ] && BIN_CMD="$MODPATH/system/bin/zcored" || BIN_CMD="$MODPATH/system/bin/encored"
  "$BIN_CMD" check_gamelist 2>/dev/null
fi

# SOC CODE:
# 1 = MediaTek
# 2 = Qualcomm Snapdragon
# 3 = Exynos
# 4 = Unisoc
# 5 = Google Tensor
# 6 = Nvidia Tegra
# 7 = Kirin

# Recognize Chipset
soc_recognition_extra
[ $SOC -eq 0 ] && recognize_soc "$(</proc/device-tree/model)"
[ $SOC -eq 0 ] && recognize_soc "$(get_soc_getprop)"
[ $SOC -eq 0 ] && recognize_soc "$(grep -E "Hardware|Processor" /proc/cpuinfo | uniq | cut -d ':' -f 2 | sed 's/^[ \t]*//')"
[ $SOC -eq 0 ] && recognize_soc "$(grep "model\sname" /proc/cpuinfo | uniq | cut -d ':' -f 2 | sed 's/^[ \t]*//')"
[ $SOC -eq 0 ] && {
	ui_print "! Unknown SoC, skipping some tweaks"
	ui_print "! If you think this is wrong, please report to maintainer"
}

echo $SOC >"$MODULE_CONFIG/soc_recognition"

# Easter Egg
case "$((RANDOM % 9 + 1))" in
1) ui_print "- Wooly's Fairy Tale" ;;
2) ui_print "- Sheep-counting Lullaby" ;;
3) ui_print "- Fog? The Black Shores!" ;;
4) ui_print "- Adventure? Let's go!" ;;
5) ui_print "- Hero Takes the Stage!" ;;
6) ui_print "- Woolies Save the World!" ;;
7) ui_print "- How much people will let you live for Encore?" ;;
8) ui_print "- Wen Donate?" ;;
9) ui_print "- Welcome to Encore Tweaks!" ;;
esac
