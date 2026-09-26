## Encore Tweaks 5.3.1

**Thanks for using Encore Tweaks!**

Your continued support keeps this project going. If you enjoy the improvements and want to see more features in the future, [consider supporting the developer with a small donation](https://t.me/rem01schannel/670). Every bit helps!

### Changelog

- Implement complete SuSFS v2.3+ kernel stealth suite (add_sus_path_loop, add_sus_map, add_sus_mount, add_try_umount, hide_sus_mnts, enable_avc_log_spoofing, kstat full clone)
- Enable full ZeroMount VFS metamodule compatibility (remove legacy skip_mount & skip_mountify flags)
- Restructure system modifications and thermal profiles under system/ for seamless ZeroMount kernel redirection
- Ensure reliable daemon startup with absolute module path execution and PATH export

---

## Encore Tweaks 5.3.0

**Thanks for using Encore Tweaks!**

Your continued support keeps this project going. If you enjoy the improvements and want to see more features in the future, [consider supporting the developer with a small donation](https://t.me/rem01schannel/670). Every bit helps!

### Changelog

- Integrate unified high-performance thermal engine profiles for Snapdragon 8s Gen 3 (Peridot)
- Implement SuSFS v2.2+ kernel stealth cloaking (VFS path hiding & map masking)
- Add KernelSU/APatch mount namespace unmasking (`ksud kernel umount`)
- Add dynamic thermal-global-mode override and sysfs zone control
- Fix missing `<cstdarg>` include in `ShellUtility.hpp`
- Remove dead `cpu_governor` code remnants in Settings view

---

## Encore Tweaks 5.2.1

**Thanks for using Encore Tweaks!**

Your continued support keeps this project going. If you enjoy the improvements and want to see more features in the future, [consider supporting the developer with a small donation](https://t.me/rem01schannel/670). Every bit helps!

### Changelog

- Fix addon modules doesn't working when disable tweaks is enabled
- Fix DND mode did not reset after exiting the game
