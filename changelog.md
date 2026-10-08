## Zcore Tweaks 5.5.5

**Thanks for using Zcore Tweaks!**

Your continued support keeps this project going.

### Changelog

- Sustained 120 FPS Gaming Optimization (Zero Frame-Drop Decay):
  * Adreno 735 GPU Floor: Enforced Level 3/4 floor (~500 MHz) in game mode to eliminate the 8.3ms VSync deadline miss caused by ramping from 200 MHz, while still allowing dynamic scale up to Level 0 (900+ MHz)
  * CPU Mid-Frequency Floor: Enforced `cpu_midfreq` (~1.2 - 1.5 GHz) in game mode to prevent CPU dropping into the 300 MHz basement between draw calls
  * 20ms Frame-Hold Window: Increased `down_rate_limit_us` to 20,000us in game mode to hold CPU frequency stable across multiple 120Hz frames (16.6ms), eliminating intra-frame clock oscillations
  * Memory Bus Pacing: Switched DDR, LLCC, and L3 latency boost to `devfreq_mid_perf`, providing stable memory throughput while preventing DDR thermal saturation during prolonged sessions
  * Removed `step_wise` thermal governor loop from `perfcommon()`, eliminating progressive CPU/GPU frequency step-down throttling over time
