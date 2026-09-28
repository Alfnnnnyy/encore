## Zcore Tweaks 5.5.0

**Thanks for using Zcore Tweaks!**

Your continued support keeps this project going.

### Changelog

- Fix bypass charging deactivation: explicitly restore unthrottled charging when games with bypass disabled enter foreground
- Cleanly manage active_game_bypass lockfile during game lifecycle transitions
- Ensure normal 4.25A fast charging is actively enforced when bypass charging toggle is turned off
