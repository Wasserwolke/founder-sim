#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Noch kein Git-Repository."
  exit 0
fi
echo "=== STATUS ==="
git status --short
echo
echo "=== DIFF ==="
git diff --stat
echo
echo "=== LAST COMMITS ==="
git log --oneline --decorate -10
