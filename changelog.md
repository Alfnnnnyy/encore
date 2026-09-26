## Zcore Tweaks 5.4.4

**Thanks for using Zcore Tweaks!**

Your continued support keeps this project going.

### Changelog

- Bypass ZeroMount has_manual_mounts scanner check in post-fs-data.sh and service.sh so ZeroMount mounts the module at boot
- Move vendor files to canonical vendor/ partition directory for ZeroMount VFS compatibility
- Maintain odm/ partition directly at module root matching ZeroMount partition architecture
- Auto-initialize clean gamelist.json in Main.cpp to permanently eliminate daemon crash
- Pre-package valid default gamelist.json inside module config directory

---

## Zcore Tweaks 5.4.3

**Thanks for using Zcore Tweaks!**

Your continued support keeps this project going.

### Changelog

- Automate GitHub Release creation and asset upload directly in GitHub Actions CI/CD workflow
- Flashable zip packages are now automatically attached to GitHub Releases on every build
- Dynamic update.json and release assets are always in sync

---

## Zcore Tweaks 5.4.2

**Thanks for using Zcore Tweaks!**

Your continued support keeps this project going.

### Changelog

- Fix ZeroMount partition mapping by placing odm directly under module root (per ZeroMount VFS specification)
- Fix native C++ daemon config path fallback to prevent "gamelist.json is missing" crashes
- Ensure dual-directory synchronization between /data/adb/.config/zcore and /data/adb/.config/encore
- Fully resolve ZeroMount VFS hot-loading and prevent automatic unloads

---

## Zcore Tweaks 5.4.1

**Thanks for using Zcore Tweaks!**

Your continued support keeps this project going.

### Changelog

- Add Bypass Charging toggle in GameSettings with strict hardware support validation
- Implement Qualcomm PMIC Glink bypass power routing (charge_control_limit, constant_charge_current, input_suspend)
- Automatically disable toggle when hardware nodes are missing (safe on unsupported devices)
- Auto-engage bypass charging during game sessions and auto-restore normal charging on game exit
- Add CLI controls in encore_utility: is_bypass_supported, get_bypass_status, set_bypass_charging
- Add localized string translations across all 11 supported languages

---

## Zcore Tweaks 5.4.0

**Thanks for using Zcore Tweaks!**

Your continued support keeps this project going.

### Changelog

- Rebranded project identity to Zcore Tweaks (Author: Alfnnnnyy, base by Rem01Gaming)
- Dynamic update.json automation on GitHub Actions with live update URL to Alfnnnnyy/encore
- ZeroMount VFS metamodule full compatibility (eliminated skip_mount & skip_mountify flags)
- Full SuSFS v2.3+ kernel stealth suite (add_sus_path_loop, add_sus_map, add_sus_mount, add_try_umount, hide_sus_mnts, enable_avc_log_spoofing, kstat full clone)
- Restructured thermal engine profiles under system/ for seamless ZeroMount kernel VFS redirection
- Updated WebUI branding and localized string translations across all 11 supported languages

---

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
