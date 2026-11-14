#!/bin/bash
# Rebuilds the compiled shaders Qt Quick loads at runtime.
#
# qsb comes from qt6-shadertools. It is not always in PATH: on Arch it lives in
# /usr/lib/qt6/bin, which is why this script looks there too.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [ -n "${QSB:-}" ]; then
    qsb_bin="$QSB"
elif command -v qsb >/dev/null 2>&1; then
    qsb_bin="$(command -v qsb)"
elif [ -x /usr/lib/qt6/bin/qsb ]; then
    qsb_bin=/usr/lib/qt6/bin/qsb
else
    echo "build-shaders: qsb not found (install qt6-shadertools)" >&2
    exit 1
fi

# The GLSL versions are the ones Qt 6 can consume on Linux. Keep the versioned
# output name: Qt caches compiled shaders by URL, so editing a shader in place
# can leave the old program in use until the cache is cleared.
"$qsb_bin" --glsl '100es,120,150,320es,330,440' \
    "$ROOT/shaders/wallfx.frag" \
    -o "$ROOT/shaders/wallfx.v1.frag.qsb"

echo "built shaders/wallfx.v1.frag.qsb"
