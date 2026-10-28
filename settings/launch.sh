#!/bin/bash

config="${HOME}/.config/quickshell/settings/settings.qml"
title="Rosewood Settings"
place="${HOME}/.config/quickshell/settings/place.sh"

# Reopen the running instance instead of starting a duplicate.
if qs ipc -p "$config" call settings open >/dev/null 2>&1; then
    bash "$place"
    exit 0
fi

qs -n -d -p "$config" || exit 1

# Wait for the window to be mapped (up to 5 seconds), then place it.
for _ in $(seq 1 50); do
    if hyprctl clients -j 2>/dev/null | jq -e --arg title "$title" 'any(.[]; .title == $title)' >/dev/null 2>&1; then
        break
    fi
    sleep 0.1
done

bash "$place"
