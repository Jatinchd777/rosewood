#!/bin/bash

# Wayland clients cannot float or position themselves. Ask Hyprland to apply
# the intended settings-window geometry and raise the window.
hyprctl dispatch 'hl.dsp.window.float({ action = "set", window = "title:Rosewood Settings" })' >/dev/null 2>&1
hyprctl dispatch 'hl.dsp.window.resize({ x = 1020, y = 720, exact = true, window = "title:Rosewood Settings" })' >/dev/null 2>&1
hyprctl dispatch 'hl.dsp.window.center({ window = "title:Rosewood Settings" })' >/dev/null 2>&1
hyprctl dispatch 'hl.dsp.focus({ window = "title:Rosewood Settings" })' >/dev/null 2>&1
