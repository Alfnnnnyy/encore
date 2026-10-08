## Zcore Tweaks 5.5.4

**Thanks for using Zcore Tweaks!**

Your continued support keeps this project going.

### Changelog

- Cool & Efficient Daily Mode (Mode Seimbang):
  * Confined background tasks strictly to Little cores (`/dev/cpuset/background/cpus` = Core 0-2) to allow Cortex-X4 Prime Core and Cortex-A720 Big Cores to enter deep sleep during idle
  * Restored Linux default `sched_migration_cost_ns` (500us) and `sched_nr_migrate` (8) to eliminate inter-cluster task bouncing and cache thrashing during daily use
  * Removed kernel thermal zone disabling in `service.sh`, restoring proper PMIC, modem, and display adaptive refresh rate idle power-saving states
  * Optimized daily Schedutil rate limits: 1000us up-rate for buttery 120Hz touch animations and 2000us down-rate for instantaneous frequency drop when idle
- Fix Duplicate Module Card in KernelSU / APatch / Magisk:
  * Eliminated legacy `/data/adb/modules/encore` symlink creation in `customize.sh` and `service.sh`
  * Added proactive cleanup for residual encore module directories across `customize.sh`, `post-fs-data.sh`, `service.sh`, and `uninstall.sh`
