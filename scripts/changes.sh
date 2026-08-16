#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Noch kein Git-Repository."
  exit 0
fi

echo "=== UNCOMMITTED ==="
git status --short

echo
echo "=== UNCOMMITTED DIFF ==="
git diff --stat

echo
echo "=== LATEST COMMIT REPORT ==="
if git rev-parse HEAD^ >/dev/null 2>&1; then
  python3 scripts/change_report.py --base HEAD^ --head HEAD
else
  echo "Noch kein vorheriger Commit fuer einen Vergleich vorhanden."
fi

echo "=== LAST COMMITS ==="
git log --oneline --decorate -10
