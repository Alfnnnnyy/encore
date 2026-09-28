## Zcore Tweaks 5.4.9

**Thanks for using Zcore Tweaks!**

Your continued support keeps this project going.

### Changelog

- Overhaul Bypass Charging into Smart Float Charging mode (eliminates battery drain and tekor)
- Keep wall adapter input unthrottled (level 0) so motherboard and SoC are powered fully from cable
- Throttle battery charge current to 1.2A to eliminate charging heat without causing battery drop
- Prevent PMIC freeze by removing unnecessary input_suspend manipulation
