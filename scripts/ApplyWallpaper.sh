#!/bin/bash
#
# Change the wallpaper: the transition starts immediately (shader, or awww as a
# fallback) and the palette is generated in the background. wallust can take a
# long time on a huge image, and the wallpaper must not wait for it.
#
#   ApplyWallpaper.sh <path> [duration] [transitionType] [resizeMode] [effect]
#
# `effect` is auto | contagion | outline | classic. The shader only knows how to
# cover/crop a screen, so any other resizeMode takes the classic path.

WALLPAPER_PATH="$1"
TRANSITION_DURATION="${2:-0.75}"
TRANSITION_TYPE="${3:-random}"
RESIZE_MODE="${4:-crop}"
TRANSITION_EFFECT="${5:-auto}"

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

case "$TRANSITION_EFFECT" in
    auto|contagion|outline|classic) ;;
    *) TRANSITION_EFFECT="auto" ;;
esac

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WALLFX="$SCRIPT_DIR/wallfx"
WALLUST_SCRIPT="$SCRIPT_DIR/WallustAwww.sh"

# Two selections in quick succession must not leave the desktop with one
# wallpaper and another's palette. Background helpers close fd 9 so they do not
# hold the lock after this script exits.
if exec 9>"${XDG_RUNTIME_DIR:-/tmp}/rosewood-wallpaper.lock" 2>/dev/null; then
    flock 9
fi

# The image awww is showing right now: the shader starts from it. If awww is
# showing a colour, or has no image, the shell cannot draw the change.
OLD_IMG="$(awww query 2>/dev/null | sed -n 's/.*currently displaying: image: //p' | head -n1)"

# Which wallpaper was requested last. Queued palette workers read it after
# taking the palette lock: an older worker that has been overtaken leaves
# without painting a stale palette over the new wallpaper.
REQUEST_FILE="${XDG_RUNTIME_DIR:-/tmp}/rosewood-wallpaper-request"
printf '%s' "$WALLPAPER_PATH" > "$REQUEST_FILE" 2>/dev/null || true

# Which transition this wallpaper gets. A wallpaper nobody has prepared yet
# may be cut out here (several seconds, announced by a notification); without
# the optional cut-out environment it returns a contagion map immediately.
eleccion=""
if [ "$TRANSITION_EFFECT" != "classic" ] && [ "$RESIZE_MODE" = "crop" ] && [ -x "$WALLFX" ]; then
    eleccion="$("$WALLFX" elige "$WALLPAPER_PATH" "$TRANSITION_EFFECT" 2>/dev/null 9>&-)"
fi

wallfx_ok=""
if [ -n "$OLD_IMG" ] && [ -f "$OLD_IMG" ] && [ -n "$eleccion" ]; then
    read -r wfx_kind wfx_map wfx_line <<<"$eleccion"
    case "$wfx_kind" in
        contagio|perfil)
            if [ -n "$wfx_map" ] && \
               [ "$(qs ipc call wallfx play "$OLD_IMG" "$WALLPAPER_PATH" "$wfx_kind" \
                    "$wfx_map" "${wfx_line:-$wfx_map}" 2>/dev/null)" = "ok" ]; then
                wallfx_ok=1
            fi
            ;;
    esac
fi

# Anything missing — no shell, no maps, awww showing a colour — falls back to
# the transition awww knows. The wallpaper must change even if the effect
# cannot be shown.
if [ -z "$wallfx_ok" ]; then
    awww img "$WALLPAPER_PATH" -t "$TRANSITION_TYPE" --resize "$RESIZE_MODE" \
        --transition-duration "$TRANSITION_DURATION" --transition-step 60 \
        --transition-fps 60 >/dev/null 2>&1 \
        || awww img "$WALLPAPER_PATH" >/dev/null 2>&1 \
        || true
fi

# The palette is slower than the wallpaper (wallust can chew on a 4K image for
# half a minute), so it runs in the background. Workers are serialized by their
# own lock, and one that has been overtaken by a newer pick exits without doing
# anything. fd 9 is closed: the wallpaper lock must not stay held while wallust
# works, or the next click would wait for it.
if [ -f "$WALLUST_SCRIPT" ]; then
    (
        exec 9>&-
        if exec 8>"${XDG_RUNTIME_DIR:-/tmp}/rosewood-wallust.lock" 2>/dev/null; then
            flock 8
        fi

        [ "$(cat "$REQUEST_FILE" 2>/dev/null)" = "$WALLPAPER_PATH" ] || exit 0

        nice -n 10 bash "$WALLUST_SCRIPT" "$WALLPAPER_PATH"
        pkill -USR1 kitty 2>/dev/null || true
        pkill -USR1 cava 2>/dev/null || true
    ) >/dev/null 2>&1 &
else
    echo "Warning: WallustAwww.sh not found; the palette may be stale" >&2
fi

# Keep the contagion pool full for the next change, without making anyone wait.
if [ -x "$WALLFX" ]; then
    nice -n 15 "$WALLFX" pool >/dev/null 2>&1 9>&- &
fi
