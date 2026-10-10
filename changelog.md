## Zcore Tweaks 5.5.8

**Thanks for using Zcore Tweaks!**

Your continued support keeps this project going.

### Changelog

- Ultra-Cool Daily Profile (Mode Seimbang):
  * CPU Energy Sweet-Spot Ceiling: Capped Cortex-X4 Prime Core to ~1.4 GHz and Cortex-A720 Big Cores to ~1.6 GHz during daily mode, cutting Prime core power draw by over 70% while keeping Little cores unconstrained and UI animations 100% fluid at 120Hz
  * Adreno GPU Daily Power Cap: Enforced Level 3 ceiling (~450 MHz) in daily mode to prevent GPU jumping to 900 MHz on short video UI blur transitions
  * Schedutil Touch Spike Filter: Set `up_rate_limit_us` to 2500us in daily mode to smooth out vertical swipe transitions without triggering frequency spikes
  * System-Background Isolation: Confined `system-background` tasks to Little cores alongside `background` tasks
