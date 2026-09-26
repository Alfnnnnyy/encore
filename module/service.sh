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

MODDIR=$(dirname "$0")
export PATH="$MODDIR/system/bin:/data/adb/ksu/bin:/data/adb/ap/bin:$PATH"

MODULE_CONFIG="/data/adb/.config/encore"
CLEANUP_SCRIPT="/data/adb/service.d/.encore_cleanup.sh"
CPUFREQ="/sys/devices/system/cpu/cpu0/cpufreq"

# Restore original module.prop
[ -f "$MODDIR/module.prop.orig" ] && {
  cp "$MODDIR/module.prop.orig" "$MODDIR/module.prop"
}

# Clear old logs
rm -f "$MODULE_CONFIG/encore.log" "$MODULE_CONFIG/sysmon.log"

# Parse Governor to use
chmod 644 "$CPUFREQ/scaling_governor"
default_gov=$(cat "$CPUFREQ/scaling_governor")
echo "$default_gov" >$MODULE_CONFIG/default_cpu_gov

# Create cleanup script
[ ! -f "$CLEANUP_SCRIPT" ] && {
  mkdir -p "$(dirname $CLEANUP_SCRIPT)"
  cp "$MODDIR/cleanup.sh" "$CLEANUP_SCRIPT"
  chmod +x "$CLEANUP_SCRIPT"
}

# Wait until boot completed
while [ -z "$(getprop sys.boot_completed)" ]; do
	sleep 40
done

# Handle case when 'default_gov' is performance
default_gov_preferred_array="
scx
schedhorizon
walt
sched_pixel
sugov_ext
uag
schedplus
energy_step
schedutil
interactive
conservative
powersave
"

if [ "$default_gov" == "performance" ]; then
	for gov in $default_gov_preferred_array; do
		grep -q "$gov" "$CPUFREQ/scaling_available_governors" && {
			echo "$gov" >$MODULE_CONFIG/default_cpu_gov
			default_gov="$gov"
			break
		}
	done
fi

# Revert to normal CPU governor
echo "$default_gov" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Mitigate buggy thermal throttling on post-startup
# in old MediaTek devices.
ENABLE_PPM="/proc/ppm/enabled"
if [ -f "$ENABLE_PPM" ]; then
	echo 0 >"$ENABLE_PPM"
	sleep 1
	echo 1 >"$ENABLE_PPM"
fi

# Apply thermal optimizations
if [ -d /data/vendor/thermal ]; then
	echo '1' > /data/vendor/thermal/thermal-global-mode 2>/dev/null
	chmod 644 /data/vendor/thermal/thermal-global-mode 2>/dev/null
fi
resetprop -n persist.vendor.thermal.enable 0 2>/dev/null
resetprop -n vendor.thermal.enable 0 2>/dev/null
for zone in /sys/class/thermal/thermal_zone*/mode; do
	echo "disabled" > "$zone" 2>/dev/null || true
done

# ZeroMount & SUSFS cloaking check
if [ ! -e "/dev/zeromount" ] && command -v ksud >/dev/null 2>&1; then
	ksud kernel umount add 'encore' 2>/dev/null || true
fi

for _sus in /data/adb/ksu/bin/ksu_susfs /system/bin/susfs /data/adb/bin/ksu_susfs /data/adb/ap/bin/ksu_susfs; do
	if [ -x "$_sus" ]; then
		"$_sus" add_sus_path_loop "$MODULE_CONFIG" 2>/dev/null || "$_sus" add_sus_path "$MODULE_CONFIG" 2>/dev/null
		[ -f "$MODDIR/system/bin/encored" ] && "$_sus" add_sus_map "$MODDIR/system/bin/encored" 2>/dev/null
		break
	fi
done

# Start Encore Daemon using absolute path
if [ -x "$MODDIR/system/bin/encored" ]; then
	"$MODDIR/system/bin/encored" daemon &
else
	encored daemon &
fi
