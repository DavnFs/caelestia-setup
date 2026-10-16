# caelestia-setup

My personal setup of the [Caelestia shell](https://github.com/caelestia-dots/shell) for Hyprland: a horizontal top bar, a cleaner workspace widget, a centred clock, battery info, and a better per-app audio page.

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

## Files

```
shell/                 the patched shell (goes in ~/.config/quickshell/caelestia)
config/shell.json      bar layout, workspaces, labels  (goes in ~/.config/caelestia/)
config/shell-tokens.json  bar height                   (goes in ~/.config/caelestia/)
```

## Install

This repo has only the QML. It needs Caelestia's compiled plugins from a build of PR #2076.

1. Build PR #2076 (see the upstream README for build steps) or install `caelestia-shell` and build the PR's plugins.
2. Edit the first two lines of `shell/shell.qml` so `QML_IMPORT_PATH` and `CAELESTIA_LIB_DIR` point to your build's `qml` and `lib` folders.
3. Link or copy `shell/` to `~/.config/quickshell/caelestia` and the two files in `config/` to `~/.config/caelestia/`.
4. Restart: `caelestia shell -k; caelestia shell -d`

## Known limits

- With `noctalia-qs`, the shell's own audio visualiser may appear under "Recording" in App volumes (the fork doesn't expose stream process info).
- The title width cap is a fixed quarter of the bar, not calculated from free space.
