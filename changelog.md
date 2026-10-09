## Zcore Tweaks 5.5.6

**Thanks for using Zcore Tweaks!**

Your continued support keeps this project going.

### Changelog

- Fix Overnight Screen-Off Battery Drain & Warmth (Doze Deep Suspend Fix):
  * Eliminated 500ms synchronous Binder IPC polling in daemon thread that generated 54,000+ wakeups overnight and prevented kernel AP deep suspend
  * Thread now enters deep futex sleep on `std::condition_variable` with zero CPU wakeups and zero Binder calls while screen is off, allowing the SoC to enter 100% deep sleep (Doze)
  * Increased screen-on polling interval from 500ms to 5s to eliminate unnecessary IPC load during daily interactive use
