#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if [[ -n "${GODOT_BIN:-}" && -x "$GODOT_BIN" ]]; then
    ENGINE="$GODOT_BIN"
elif [[ -x "$ROOT/.tools/godot/godot" ]]; then
    ENGINE="$ROOT/.tools/godot/godot"
elif command -v godot >/dev/null 2>&1; then
    ENGINE="$(command -v godot)"
elif command -v godot4 >/dev/null 2>&1; then
    ENGINE="$(command -v godot4)"
else
    cat >&2 <<'MSG'
Godot wurde nicht gefunden.
Einmalig ohne sudo installieren:
  ./scripts/linux/install_godot.sh
Danach:
  ./scripts/linux/open_godot.sh
MSG
    exit 1
fi

exec "$ENGINE" --editor --path "$ROOT"
