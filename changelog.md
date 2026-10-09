## Zcore Tweaks 5.5.7

**Thanks for using Zcore Tweaks!**

Your continued support keeps this project going.

### Changelog

- Zero-Stutter Extraction Shooter Optimization (Delta Force & Arena Breakout):
  * UFS 4.0 Parallel Multi-Queue Streaming: Increased `nr_requests` to 128 to prevent I/O queue wait stalls when dynamically streaming high-res compound meshes and textures
  * Anti-Direct Reclaim Cushion: Configured `watermark_scale_factor = 150` to expand the free memory buffer, ensuring sudden 80MB actor and skin memory allocations never freeze the render thread in direct reclaim
  * Sub-8.3ms Scheduler Preemption: Tightened CFS preemption granularity (`sched_wakeup_granularity_ns` & `sched_min_granularity_ns` = 0.5ms) during game mode so awakened rendering threads preempt immediately without waiting 1.5ms
  * Engine Whitelist Expansion: Added Audiokinetic Wwise spatial audio engine (`libAkSoundEngine.so`) and Tencent netcode foundation (`libINTLFoundation.so`) to `sched_lib_name` for top CPU priority
  * Network Burst Buffer Headroom: Expanded socket backlog to 5,000 and socket buffer limits to 8MB to prevent packet drops and latency spikes during sudden enemy encounters
