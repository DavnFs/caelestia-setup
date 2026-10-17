# caelestia-setup

My personal setup of the [Caelestia shell](https://github.com/caelestia-dots/shell) for Hyprland: a horizontal top bar, a cleaner workspace widget, a centred clock, battery info, a better per-app audio page, clickable notifications and a macOS-style lock screen.

`shell/` is based on [caelestia-dots/shell PR #2076](https://github.com/caelestia-dots/shell/pull/2076) ("support all four screen edges") by [@alper-han](https://github.com/alper-han), with my changes on top. All credit for Caelestia goes to its authors. Licensed GPL-3.0 like the original.

## What's changed

**Top bar**
- Clock is centred; the active window title sits on the left in smaller text and is cut off at a quarter of the bar width so it never pushes the clock.
- The centring logic now centres whichever entry comes right after the first `spacer` in `bar.entries`, so the order in `shell.json` decides what's in the middle.
- Battery shows percentage next to the icon, plus live power draw while on battery (e.g. `92% · 4.7W`).
- Bar is 50 px tall instead of 56 (`config/shell-tokens.json`).

**Workspaces**
- Numbers instead of random shapes, with up to 3 app icons per workspace.
- The active-workspace pill no longer clips the last app icon, and icons shrink to fit their slot instead of overlapping.

**Hyprland Lua config + noctalia-qs fix**
- `noctalia-qs` (a Quickshell fork) has no `Hyprland.usingLua`, so the shell sent old-style dispatch commands that a Lua Hyprland config rejects. `services/Hypr.qml` now falls back to Lua. This fixes clicking and scrolling workspaces on the bar, idle screen-off, and the window-info buttons.
- If you use upstream Quickshell or a classic `hyprland.conf`, remove the `?? true` fallback in `services/Hypr.qml`.

**Settings → Audio → App volumes**
- Separate "Playing" and "Recording" sections.
- Click an app's icon to mute it.
- Per-app output/input device picker (moves the stream with `pw-metadata`).

**Notifications**
- Clicking a notification opens it: runs the app's default action if it's still live, otherwise focuses the app's window, or launches the app. Then closes the panel.
- New **Notifications** tab in the dashboard (the same list as the sidebar).

**Lock screen (macOS style)**
- Date and big clock at the top in frosted glass (the background shows through, blurred), battery in the corner.
- Frosted-glass now-playing widget (artwork, title, artist, progress, controls) while a player has a track loaded.
- "Enter Password" hint at the bottom; the password field fades in when you start typing and the wallpaper blurs. Fingerprint/face messages still work.
- **Settings → Lock screen**: background (desktop wallpaper, an image, or a looping video as a live wallpaper, optionally only while charging) and a now-playing toggle. Saved in `~/.config/caelestia/lock.json`.
- Files: `modules/lock/Minimal.qml`, `modules/lock/NowPlaying.qml`, `modules/lock/LockSurface.qml`, `services/LockSettings.qml`, `modules/nexus/pages/LockScreenPage.qml`.

**Boot login screen (SDDM)**
- `sddm/Main.qml` restyles the [caelestia SDDM theme](https://github.com/ItsABigIgloo/caelestia-sddm) to match the lock screen: frosted date and clock in Rubik, "Enter Password" that turns into a password field as you type, restart/power buttons in the corner.
- Install: `sudo sddm/install.sh` (backs up the theme's `Main.qml`, then syncs your wallpaper and colours). Re-run after the theme package updates.

**Hyprland special workspaces**
- `config/cli.json` swaps Spotify for [Sidra](https://github.com/wimpysworld/sidra) (Apple Music) on the music workspace (Super + M).

## Files

```
shell/                 the patched shell (goes in ~/.config/quickshell/caelestia)
config/shell.json      bar layout, workspaces, labels  (goes in ~/.config/caelestia/)
config/shell-tokens.json  bar height                   (goes in ~/.config/caelestia/)
config/cli.json        special workspace apps (Sidra)  (goes in ~/.config/caelestia/)
sddm/                  boot login screen layout + install script
```

## Install

This repo has only the QML. It needs Caelestia's compiled plugins from a build of PR #2076.

1. Build PR #2076 (see the upstream README for build steps) or install `caelestia-shell` and build the PR's plugins.
2. Edit the first two lines of `shell/shell.qml` so `QML_IMPORT_PATH` and `CAELESTIA_LIB_DIR` point to your build's `qml` and `lib` folders.
3. Link or copy `shell/` to `~/.config/quickshell/caelestia` and the files in `config/` to `~/.config/caelestia/`.
4. Restart: `caelestia shell -k; caelestia shell -d`

## Known limits

- With `noctalia-qs`, the shell's own audio visualiser may appear under "Recording" in App volumes (the fork doesn't expose stream process info).
- The title width cap is a fixed quarter of the bar, not calculated from free space.
