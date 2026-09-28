## Zcore Tweaks 5.5.3

**Thanks for using Zcore Tweaks!**

Your continued support keeps this project going.

### Changelog

- Evidence-Based Dual-Profile Architecture: Transformed Mode Performa into a cool, sustainable gaming profile and Mode Seimbang into an energy-efficient daily driver profile
- Pure Dynamic Schedutil in Game Mode: Completely removed rigid `performance` governor lock and `cpufreq_max_perf`, allowing CPU to scale dynamically under `schedutil` (0.5ms ramp-up on spikes, 10ms hold during frame gaps to eliminate frequency yo-yo and micro-stutter)
- Dynamic Adreno GPU Scaling: Unlocked GPU frequency scaling and removed Level 0 hard lock (`min_pwrlevel=0` and `force_clk_on=1`), eliminating 10W thermal runaway in 2D menus while sustaining peak clocks in 3D gaming
- Cool Gaming with Active Charging: Reduced SoC gaming power consumption to ~4.5W, allowing full fast charging while gaming without thermal throttling or battery discharge
- Daily Battery-Saving Mode: Tuned Mode Seimbang with conservative 2000us/2000us rate limits and relaxed EAS (85 95 migration) to maximize daily SOT and keep the device cool during casual use
