#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if [[ ! -x "$ROOT/.tools/godot/godot" ]] && ! command -v godot >/dev/null 2>&1 && ! command -v godot4 >/dev/null 2>&1; then
    "$ROOT/scripts/linux/install_godot.sh"
fi

exec "$ROOT/scripts/linux/open_godot.sh"
