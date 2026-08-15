#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WEB = ROOT / "app" / "web"


def load_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def main():
    manifest = load_json(WEB / "assets" / "manifest.json")
    catalog = load_json(WEB / "data" / "catalog" / "items.json")
    assets = manifest.get("assets", {})
    missing = []
    broken_catalog = []

    for asset_id, entry in sorted(assets.items()):
        for variant, relative_path in (entry.get("files") or {}).items():
            path = WEB / relative_path
            if not path.exists():
                missing.append((asset_id, variant, relative_path))

    for item_id, item in sorted((catalog.get("items") or {}).items()):
        asset_id = item.get("asset_id")
        if asset_id and asset_id not in assets:
            broken_catalog.append((item_id, asset_id))

    print("=== Founder Sim Asset Status ===")
    print(f"Manifest assets: {len(assets)}")
    print(f"Catalog items:   {len(catalog.get('items', {}))}")
    print(f"Missing files:   {len(missing)}")
    print(f"Broken links:    {len(broken_catalog)}")

    if missing:
        print("\nMissing runtime files:")
        for asset_id, variant, relative_path in missing:
            print(f"  {asset_id:28} {variant:6} -> {relative_path}")

    if broken_catalog:
        print("\nCatalog items referencing unknown asset IDs:")
        for item_id, asset_id in broken_catalog:
            print(f"  {item_id} -> {asset_id}")

    raise SystemExit(1 if broken_catalog else 0)


if __name__ == "__main__":
    main()
