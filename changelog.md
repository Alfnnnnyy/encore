## Zcore Tweaks 5.4.8

**Thanks for using Zcore Tweaks!**

Your continued support keeps this project going.

### Changelog

- Optimize memory pipeline: remove drop_caches from game entry to preserve warm shader and texture caches
- Tune virtual memory writeback: set dirty_background_ratio=5 and dirty_ratio=15 to prevent I/O pause freezes
- Set watermark_boost_factor=0 to eliminate aggressive kswapd memory reclaim storms
- Implement dynamic CPUSet isolation: restrict background tasks to efficiency cluster during games, keeping big/prime cores 100% dedicated to gaming
- Enable uclamp.latency_sensitive=1 and uclamp.min=20 for top-app to ensure zero-lag scheduler response
