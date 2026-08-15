#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT/app/web"
echo "Founder Sim v0.3"
echo "Open: http://localhost:8080"
python3 -m http.server 8080
