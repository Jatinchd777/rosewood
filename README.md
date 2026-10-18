<div align="center">

# rosewood

_a warm, dark, pill-shaped desktop shell built on Quickshell & Hyprland._

<br>

<a href="LICENSE"><img alt="license" src="https://img.shields.io/github/license/Jatinchd777/rosewood?color=1C1917&style=for-the-badge&labelColor=FAFAFA"></a>
<a href="https://quickshell.org"><img alt="quickshell" src="https://img.shields.io/badge/built%20with-Quickshell-1C1917?style=for-the-badge&labelColor=FAFAFA"></a>
<img alt="platform" src="https://img.shields.io/badge/platform-Linux%20%2F%20Hyprland-1C1917?style=for-the-badge&labelColor=FAFAFA">

<br>

<a href="#features">Features</a>
&middot;
<a href="#installation">Installation</a>
&middot;
<a href="#usage">Usage</a>
&middot;
<a href="#keybinds">Keybinds</a>
&middot;
<a href="#theming">Theming</a>
&middot;
<a href="#structure">Structure</a>
&middot;
<a href="#troubleshooting">Troubleshooting</a>

</div>

---

Everything in rosewood lives in a single floating **pill** at the top of the screen. It idles as a clock, morphs to show volume / brightness / workspaces when they change, turns into toasts for notifications, and expands — on hover — into a full **hover dashboard** with a clock, media player, quick settings and notification history. A matching **session lock** (PAM, wallpaper-woven) and a **2-column app launcher** with calculator and shell modes round it out, all tinted from your wallpaper through wallust.

## Features

### The pill
- **One widget, many faces** — a state machine morphs a single pill between clock, volume, brightness, workspace, notifications, power, wallpaper, clipboard and launcher with animated width/height/radius transitions.
- **Hover to expand** — parking the cursor on the pill opens the hover dashboard instead of switching states; modal views always take priority.
- **Transient states** — volume/brightness/workspaces show themselves for 1s after a change, notification toasts for 3s, then fall back to the clock.

### Hover dashboard
- **Clock tab** — big clock and date, weather from wttr.in, CPU and RAM load, ping to `1.1.1.1`, battery (UPower), Wi-Fi network, `user@host`, and clickable workspace dots. Double-click (or right-click) the clock for a full **month calendar** with today highlighted.
- **Media tab** — MPRIS players with blurred artwork backdrop, marquee title, seekable progress bar, play/pause/next/prev, shuffle and loop toggles, volume by scrolling on the artwork, and multi-player switching.
- **Settings tab** — a grid of one-tap toggles: **Bluetooth**, **Network** (both open expanded device menus), **Night Light** (hyprsunset), **Awake** (systemd-inhibit), **Aeroplane** (rfkill), **Power Profile** (powerprofilesctl), **Microphone** (pamixer), **Screenshot**, **Screen Record** (gpu-screen-recorder, with a pulsing red dot), plus drag-to-set **volume** and **brightness** sliders.
- **Notifications tab** — scrollback history with expand/collapse cards, urgency colours, per-item and clear-all dismissal.

### App launcher
- Searches every `.desktop` entry on the system (parsed straight from `/usr/share/applications`).
- `=2+2` turns it into a **calculator**, `:htop` turns it into a **bash prompt** — Enter runs it raw.
- Grid navigation with arrows or `hjkl`, launches through `hyprctl dispatch` so apps inherit your Hyprland environment.

### Clipboard
- Watches `wl-paste` for text *and* images, keeps the last 20 entries, re-copies with Enter, deletes per item, and can clear the system clipboard too.

### Lockscreen
- True Wayland session lock (`WlSessionLock`) with a **PAM** password prompt (include-free `pam_unix` config).
- Freezes the screen with `grim`, then fades a blurred, vignetted copy of your wallpaper over it.
- Animated idle → auth flow: *"PRESS ANY KEY TO UNLOCK"*, dots while PAM checks, red *"Incorrect password"* on failure, and `lockscreen_preview.qml` for testing without locking yourself out.

### Theming
- **Wallust** (Material You palette) regenerates the shell live: change wallpaper → palette rewrite → shell recolours itself in place via the hot-reload engine, no restart.
- The wallpaper picker (grid + fuzzy search over `~/Pictures/wallpapers`) applies wallpapers through [awww](https://codeberg.org/LGFae/awww) with a random transition, reruns wallust, and pings kitty + cava to retheme.
- Every widget reads semantic Material tokens (`primary`, `surface_container`, `error`, …), so all screens — bar, dashboard, launcher, lock — change clothes together.

## Showcase

| Hover dashboard | App launcher |
| :---: | :---: |
| ![dashboard](assets/dashboard.png) | ![launcher](assets/launcher.png) |

| Media + settings | Lock screen |
| :---: | :---: |
| ![media](assets/media.gif) | ![lockscreen](assets/lockscreen.png) |

## Requirements

| Dependency | Used for |
| --- | --- |
| [quickshell](https://quickshell.org) (`qs`) | The shell itself |
| [Hyprland](https://hyprland.org) (`hyprctl`) | Workspaces, app launching, `hyprsunset` night light |
| [awww](https://codeberg.org/LGFae/awww) | Animated wallpaper transitions |
| [wallust](https://codeberg.org/explosion-mental/wallust) | Material You palette generation |
| `brightnessctl` | Brightness slider |
| `pamixer` | Microphone mute toggle |
| `wl-clipboard` (`wl-paste` / `wl-copy`) | Clipboard history |
| `gpu-screen-recorder` | Screen recording toggle |
| `grim` | Lock screen background capture |
| `rfkill` | Aeroplane mode toggle |
| `power-profiles-daemon` (`powerprofilesctl`) | Power profile toggle |
| `systemd-inhibit` | Keep-awake toggle |
| `curl`, `ping`, `procps` (`top`, `free`), `coreutils` | Weather, latency, CPU/RAM, hostname |
| **JetBrainsMono Nerd Font** | Every glyph and icon in the UI |
| PipeWire + an MPRIS player | Audio and the media tab |

Optional, if you have them lying around in your Hyprland config:

- `~/.config/hypr/scripts/ScreenShot.sh` — used by the Screenshot toggle (`--area` / `--now`)
- `~/.config/hypr/scripts/Sounds.sh --volume` — volume feedback sound

## Installation

> rosewood expects to live at `~/.config/quickshell` — several scripts reference that path directly.

```sh
git clone https://github.com/Jatinchd777/rosewood.git ~/.config/quickshell
```

Install the dependencies above, then point the hardcoded paths in the repo at your own home directory:

```sh
cd ~/.config/quickshell
grep -rl "lilarchie" --include='*.qml' --include='*.js' --include='*.sh' . \
  | xargs sed -i "s|/home/lilarchie|$HOME|g"
```

A few things you'll likely want to adjust first:

| What | Where |
| --- | --- |
| Weather location (defaults to `Chandigarh`) | `ui/HoverDashboard/components/WeatherWidget.qml`, `.../Slides/ClockSlide/ClockSlide.qml` |
| Wallpaper directory (`~/Pictures/wallpapers`) | `scripts/ListWallpapers.sh`, `ui/global/WallpaperPicker.qml` |
| Screen recordings directory (`~/Videos`) | `.../SettingsSlide/ScreenRecord/ScreenRecordToggle.qml` |
| Monitor name used for lock screenshot (`eDP-1`) | `lockscreen/lock.sh` |
| `prime-run` prefix in the theming script (NVIDIA only) | `scripts/WallustAwww.sh` |
| Palette output: wallust must write `core/Logic/WallustColors.js` | your `~/.config/wallust/wallust.toml` |

Start it:

```sh
qs -p ~/.config/quickshell        # or ./scripts/reload.sh to restart
```

Autostart it with Hyprland:

```
exec-once = qs -p ~/.config/quickshell
```

Lock your session with:

```sh
~/.config/quickshell/lockscreen/lock.sh
```

## Usage

| Action | How |
| --- | --- |
| Open the dashboard | Hover the pill |
| Switch dashboard tabs | Click the icons at the top (clock · media · settings · notifications) |
| Calendar | Double-click or right-click the clock |
| Expanded Wi-Fi / Bluetooth menus | Right-click or double-click those toggles |
| Seek / volume | Click the progress bar · scroll on the album art |
| Switch workspaces | Click a workspace dot |
| Copy a clipboard entry | Click it (or select + Enter) |
| Delete a clipboard entry | Click the ✕ on the card |

rosewood exposes two IPC channels, handy for keybinds:

```sh
qs ipc call pill setState appLauncher   # any state: clock volume brightness workspace
                                        # notifications powermenu wallpaper clipboard appLauncher
qs ipc call theme reload                # re-read the palette after regenerating it
```

Example Hyprland binds:

```
bind = SUPER, R,      exec, qs ipc call pill setState appLauncher
bind = SUPER, V,      exec, qs ipc call pill setState clipboard
bind = SUPER, W,      exec, qs ipc call pill setState wallpaper
bind = SUPER SHIFT, P, exec, qs ipc call pill setState powermenu
bind = SUPER, L,      exec, ~/.config/quickshell/lockscreen/lock.sh
```

## Keybinds

All dashboard views are keyboard-first:

| Context | Keys | Action |
| --- | --- | --- |
| Launcher | `/` | Focus search |
| Launcher | `=` … | Calculator mode (`=12*4`) |
| Launcher | `:` … | Bash mode — Enter runs the command |
| Launcher | `hjkl` / arrows | Move through the grid |
| Launcher | `Enter` | Launch selected app |
| Launcher | `Esc` | Clear search, then back to clock |
| Wallpaper | `/` | Search wallpapers |
| Wallpaper | `hjkl` / arrows | Move through the grid |
| Wallpaper | `Enter` | Apply wallpaper (awww + wallust) |
| Clipboard | `j` / `k`, `↑` / `↓` | Navigate history |
| Clipboard | `Enter` | Copy selection to the system clipboard |
| Power menu | `h` / `l`, `←` / `→` | Choose power · reboot · suspend · lock |
| Power menu | `Enter` / `Space` | Execute |
| Everywhere | `Esc` | Back to the clock |

## Theming

The colour pipeline is wallpaper → **wallust** → JavaScript palette → **live** shell:

```
wallpaper ──▶ scripts/ApplyWallpaper.sh ──▶ awww (set wallpaper)
                     │
                     ▼
             scripts/WallustAwww.sh ──▶ wallust run  ──▶ core/Logic/WallustColors.js
                     │
                     ▼
             qs ipc call theme reload ──▶ WallustHotReload ──▶ every widget
```

- `core/Logic/WallustColors.js` is generated — edit your wallust config, not this file.
- `core/Logic/ThemeColors.js` is a matugen-generated palette kept around as an alternative source; the shell reads the wallust one.
- The current wallpaper path is remembered between sessions in `~/.cache/wallpaper_state.txt`, so the lock screen and theme engine can draw the same image after a reboot.

## Structure

```
rosewood/
├── shell.qml                    # entry point — pill state, audio, main panel
├── core/
│   ├── Logic/                   # theme engine, palette hot-reload, system actions
│   ├── Managers/                # audio · brightness · workspace · power · IPC
│   └── Shortcuts/               # per-view keyboard handling
├── ui/
│   ├── panels/                  # MainPanel (the pill) · HoverDashboard
│   ├── global/                  # clock · bars · power menu · notifications
│   │                            # wallpaper picker · clipboard · app launcher
│   └── HoverDashboard/          # dashboard tabs and widgets
├── lockscreen/                  # PAM session lock + preview window
└── scripts/                     # wallpaper, theming, recording helpers
```

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| Nothing appears | Check the `qs` logs — usually a missing dependency or another `qs` instance already running (`scripts/reload.sh` kills the old one). |
| Colours are stale after a wallpaper change | `qs ipc call theme reload`; if that fails, wallust didn't write `core/Logic/WallustColors.js`. |
| Icons render as boxes | Install **JetBrainsMono Nerd Font**. |
| Volume slider works, brightness doesn't | `brightnessctl` needs `video` group membership (or a udev rule). |
| Lock screen is plain black | `grim` missing, or the monitor name in `lockscreen/lock.sh` isn't yours — check `hyprctl monitors`. |
| No notification toasts | Another daemon (dunst, mako, …) owns the notification bus — stop it. |
| Weather stuck at `--°C` | `curl` can't reach wttr.in, or the location string needs changing. |
| Record toggle does nothing | `gpu-screen-recorder` isn't installed. |

## Roadmap

- [ ] Move hardcoded paths, weather location and directories into a single config file
- [ ] Multi-monitor bar (the lock screen already spawns one surface per screen)
- [ ] Replace the fixed 1–10 workspace dots with a dynamic count
- [ ] Ship example wallust config in-repo for one-command setup
- [ ] Packaging: Nix flake / AUR PKGBUILD

## Credits

- [Quickshell](https://quickshell.org) — the framework that makes all of this possible
- [Nerd Fonts](https://www.nerdfonts.com) for the icon glyphs, [wttr.in](https://wttr.in) for weather
- Inspired by every rice that came before — go make something warm.

<div align="center">

MIT © [Jatin](https://github.com/Jatinchd777)

</div>
