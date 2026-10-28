#!/bin/bash

dir="${1:-$HOME/Pictures/wallpapers}"

if [ ! -d "$dir" ]; then
    exit 0
fi

ls "$dir"
