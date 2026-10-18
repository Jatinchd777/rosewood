#!/bin/bash

pkill qs

qs -p "$HOME/.config/quickshell" &
