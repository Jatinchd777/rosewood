#!/bin/bash

WALLPAPER_PATH="$1"

if [ -z "$WALLPAPER_PATH" ]; then
    exit 1
fi

# EFFECTS=("left" "right" "wipe" "center" "outer" "grow")
# RANDOM_EFFECT=${EFFECTS[$RANDOM % ${#EFFECTS[@]}]}

awww img "$WALLPAPER_PATH" -t "random" --transition-duration 2.5  --transition-step 60 --transition-fps 60

SCRIPT_PATH="/home/lilarchie/.config/quickshell/scripts/WallustAwww.sh"
if [ -f "$SCRIPT_PATH" ]; then
    bash "$SCRIPT_PATH" "$WALLPAPER_PATH"
else
    echo "Error: WallustAwww.sh not found!"
    exit 1
fi

pkill -USR1 kitty
pkill -USR1 cava
