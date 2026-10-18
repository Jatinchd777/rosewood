#!/bin/bash
cache_dir="$HOME/.cache/awww/"

# if [ -n "$1" ]; then
#   wallpaper_path="$1"
# else
#   AWWW_VER=$(awww --version | awk '{print $2}')
#   current_monitor=$(hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name}')
#   cache_file="$cache_dir$AWWW_VER/$current_monitor"
#   if [ -f "$cache_file" ]; then
#     wallpaper_path=$(grep -aoP '/home/.*' "$cache_file" | head -n 1)
#   fi
# fi

wallpaper_path=$(cat ~/.cache/wallpaper_state.txt)

ln -sf "$wallpaper_path" "$HOME/.config/rofi/.current_wallpaper"

prime-run wallust run "$wallpaper_path" -q

#matugen_seed=$(grep '^color4=' ~/.cache/wal/colors.sh | cut -d'"' -f2)

#matugen color hex "$matugen_seed"
#matugen image "$wallpaper_path" -t scheme-tonal-spot

qs ipc call theme reload 2>/dev/null || true
