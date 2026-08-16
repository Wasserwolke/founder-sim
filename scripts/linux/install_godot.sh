#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VERSION="${GODOT_VERSION:-4.7.1}"
TOOLS_DIR="$ROOT/.tools/godot"
ARCH="$(uname -m)"

case "$ARCH" in
    x86_64|amd64)
        PLATFORM="linux.64"
        SLUG="linux.x86_64.zip"
        ;;
    aarch64|arm64)
        PLATFORM="linux.arm64"
        SLUG="linux.arm64.zip"
        ;;
    *)
        echo "Unsupported Linux architecture for automatic Godot setup: $ARCH" >&2
        exit 1
        ;;
esac

if [[ -x "$TOOLS_DIR/godot" ]]; then
    echo "Godot is already installed for this repository: $TOOLS_DIR/godot"
    "$TOOLS_DIR/godot" --version
    exit 0
fi

command -v unzip >/dev/null 2>&1 || {
    echo "Missing dependency: unzip" >&2
    exit 1
}

mkdir -p "$TOOLS_DIR"
ZIP="$TOOLS_DIR/godot.zip"
URL="https://downloads.godotengine.org/?flavor=stable&platform=${PLATFORM}&slug=${SLUG}&version=${VERSION}"

echo "Downloading Godot ${VERSION} Standard from the official Godot download service ..."
if command -v curl >/dev/null 2>&1; then
    curl -L --fail --show-error --progress-bar "$URL" -o "$ZIP"
elif command -v wget >/dev/null 2>&1; then
    wget -O "$ZIP" "$URL"
else
    echo "Install curl or wget, then run this script again." >&2
    exit 1
fi

unzip -q -o "$ZIP" -d "$TOOLS_DIR"
rm -f "$ZIP"

ENGINE_BIN="$(find "$TOOLS_DIR" -maxdepth 1 -type f -name 'Godot_*' -print | sort -V | tail -n 1)"
if [[ -z "$ENGINE_BIN" ]]; then
    echo "Godot archive did not contain the expected executable." >&2
    exit 1
fi

chmod +x "$ENGINE_BIN"
ln -sfn "$(basename "$ENGINE_BIN")" "$TOOLS_DIR/godot"

echo "Installed: $TOOLS_DIR/godot"
"$TOOLS_DIR/godot" --version
