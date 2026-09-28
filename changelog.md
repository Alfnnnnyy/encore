## Zcore Tweaks 5.5.1

**Thanks for using Zcore Tweaks!**

Your continued support keeps this project going.

### Changelog

- Complete removal of pseudo bypass charging across backend scripts, daemon, and WebUI (eliminates battery drain and unstable PMIC states on single-buck converter hardware)
- Responsive EAS scheduling: optimized sched_upmigrate and sched_initial_task_util to instantly promote game threads to Big and Prime cores
- Snappy CPU governor rate limits: tuned schedutil up_rate_limit_us to 500us and down_rate_limit_us to 4000us for rapid frequency scaling without thermal lockup
- Adreno GPU frame pacing guard: 80ms idle_timer prevents premature GPU downclocking across VSync intervals
- Network packet latency fix: keep system-background CPUSet unthrottled and enable TCP timestamps with ECN negotiation to eliminate mobile gaming ping spikes
- Extended sched_lib_name game engine registry: added Unreal Engine, Tencent TDataMaster, GCloud, and modern engine libraries
