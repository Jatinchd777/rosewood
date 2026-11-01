#!/bin/bash

WALLPAPER_PATH="$1"
TRANSITION_DURATION="${2:-0.75}"
TRANSITION_TYPE="${3:-random}"
RESIZE_MODE="${4:-crop}"

if [ -z "$WALLPAPER_PATH" ]; then
    exit 1
fi

case "$TRANSITION_TYPE" in
    random|fade|wipe|grow|wave) ;;
    *) TRANSITION_TYPE="random" ;;
esac

case "$RESIZE_MODE" in
    crop|fit|stretch|no) ;;
    *) RESIZE_MODE="crop" ;;
esac

# Start the wallpaper transition immediately. The color extraction below only
# needs the image file, so it can run concurrently instead of waiting for the
# transition to finish.
awww img "$WALLPAPER_PATH" -t "$TRANSITION_TYPE" --resize "$RESIZE_MODE" --transition-duration "$TRANSITION_DURATION" --transition-step 60 --transition-fps 60 &
awww_pid=$!

SCRIPT_PATH="$(dirname "$0")/WallustAwww.sh"
if [ -f "$SCRIPT_PATH" ]; then
    bash "$SCRIPT_PATH" "$WALLPAPER_PATH"
else
    echo "Error: WallustAwww.sh not found!" >&2
    wait "$awww_pid" 2>/dev/null || true
    exit 1
fi

pkill -USR1 kitty 2>/dev/null || true
pkill -USR1 cava 2>/dev/null || true

wait "$awww_pid" 2>/dev/null || true
