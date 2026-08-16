#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WEB = ROOT / "app" / "web"


def load_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def check_file(missing: list[tuple[str, str, str]], asset_id: str, variant: str, relative_path: str):
    if not relative_path:
        return
    path = WEB / relative_path
    if not path.exists():
        missing.append((asset_id, variant, relative_path))


def main():
    manifest = load_json(WEB / "assets" / "manifest.json")
    catalog = load_json(WEB / "data" / "catalog" / "items.json")

    missing: list[tuple[str, str, str]] = []
    broken_catalog: list[tuple[str, str]] = []
    known_assets: set[str] = set()

    # v0.5 runtime manifest: full environment images.
    for asset_id, entry in sorted((manifest.get("environments") or {}).items()):
        known_assets.add(asset_id)
        for variant, relative_path in sorted(entry.items()):
            if isinstance(relative_path, str):
                check_file(missing, asset_id, variant, relative_path)

    # v0.5 runtime manifest: icons packed into a shared atlas.
    for asset_id, entry in sorted((manifest.get("prototype_icons") or {}).items()):
        known_assets.add(asset_id)
        atlas = entry.get("atlas")
        if atlas:
            check_file(missing, asset_id, "atlas", atlas)

        crop = entry.get("crop")
        atlas_size = entry.get("atlas_size")
        if not (isinstance(crop, list) and len(crop) == 4):
            raise SystemExit(f"Invalid crop metadata for asset: {asset_id}")
        if not (isinstance(atlas_size, list) and len(atlas_size) == 2):
            raise SystemExit(f"Invalid atlas_size metadata for asset: {asset_id}")

    # Forward-compatible/legacy manifest layout: assets -> files / atlas.
    for asset_id, entry in sorted((manifest.get("assets") or {}).items()):
        known_assets.add(asset_id)
        for variant, relative_path in sorted((entry.get("files") or {}).items()):
            check_file(missing, asset_id, variant, relative_path)
        atlas = entry.get("atlas")
        if atlas:
            check_file(missing, asset_id, "atlas", atlas)

    for item_id, item in sorted((catalog.get("items") or {}).items()):
        asset_id = item.get("asset_id")
        if asset_id and asset_id not in known_assets:
            broken_catalog.append((item_id, asset_id))

    print("=== Founder Sim Asset Status ===")
    print(f"Manifest assets: {len(known_assets)}")
    print(f"Catalog items:   {len(catalog.get('items', {}))}")
    print(f"Missing files:   {len(missing)}")
    print(f"Broken links:    {len(broken_catalog)}")

    if missing:
        print("\nMissing runtime files:")
        for asset_id, variant, relative_path in missing:
            print(f"  {asset_id:28} {variant:8} -> {relative_path}")

    if broken_catalog:
        print("\nCatalog items referencing unknown asset IDs:")
        for item_id, asset_id in broken_catalog:
            print(f"  {item_id} -> {asset_id}")

    raise SystemExit(1 if (missing or broken_catalog) else 0)


if __name__ == "__main__":
    main()
