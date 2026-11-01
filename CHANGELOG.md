# Changelog

## 1.1.1
- Only one OS installed: boots it directly ("Press any key for the boot menu", 2 s) instead of showing a second menu. `autoSingle = false` in /boot/config.lua restores the old behaviour.

## 1.1.0
- New installer in the NyxOS style: splash, language menu (English, Francais, Espanol, Deutsch), option menus, progress bar.
- ASCII-only text everywhere (accents were garbled in the CC:Tweaked terminal).
- Automatic reboot at the end of the installation (any key = reboot now).
- `webinstall.lua` fixed: `lib/isolation.lua` was missing from the download list; installer now shared with the disk installer (`lib/setup.lua`).
- `--quiet` flag (used by the NyxOS installer): no menus, no reboot.
- `lang` saved in `/boot/config.lua`.
