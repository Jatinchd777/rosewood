#!/bin/bash

settings_file="${HOME}/.config/quickshell/settings.json"
monitor=""

if command -v jq >/dev/null 2>&1 && [ -f "$settings_file" ]; then
    monitor="$(jq -r '.lock.monitor // empty' "$settings_file" 2>/dev/null)"
fi

if [ -z "$monitor" ] || [ "$monitor" = "null" ]; then
    monitor="eDP-1"
fi

bg="${XDG_RUNTIME_DIR}/quickshell-lock-bg.png"
mkdir -p "$(dirname "$bg")"
grim -o "$monitor" "$bg" 2>/dev/null || true
QS_LOCK_BG="$bg" qs -p "${HOME}/.config/quickshell/lockscreen/lockscreen.qml"
rm -f "$bg"
