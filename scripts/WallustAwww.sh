#!/bin/bash

wallpaper_path="${1:-$(cat "$HOME/.cache/wallpaper_state.txt")}"

ln -sf "$wallpaper_path" "$HOME/.config/rofi/.current_wallpaper"

# Matiz fork (https://github.com/Jatinchd777/Matiz) lives in ~/.local/bin.
# The official cargo build in ~/.cargo/bin shadows it in PATH and does not
# support the [semantics] palette used by this config.
wallust_bin="$HOME/.local/bin/wallust"
if [ ! -x "$wallust_bin" ]; then
    wallust_bin="$(command -v wallust || true)"
fi

if [ -n "$wallust_bin" ]; then
    "$wallust_bin" run "$wallpaper_path" -q
fi
