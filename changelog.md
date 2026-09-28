## Zcore Tweaks 5.5.2

**Thanks for using Zcore Tweaks!**

Your continued support keeps this project going.

### Changelog

- Pure Snappy EAS Governor: Removed rigid `performance` governor lock and `cpufreq_max_perf` in game mode, allowing CPU to operate natively under dynamic `schedutil` (0.5ms ramp-up on load spikes while resting during VSync intervals)
- Adreno GPU Dynamic Scaling: Removed Level 0 hard lock (`min_pwrlevel=0`) and `force_clk_on=1` on Snapdragon, allowing GPU to clock gate and scale dynamically without burning 10W in 2D menus
- Xiaomi / POCO Touch Game Mode: Activated `/sys/class/touch/touch_dev/game_mode` for maximum 480Hz polling rate and low-latency touch response
