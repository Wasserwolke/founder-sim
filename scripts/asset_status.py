#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WEB = ROOT / "app" / "web"


def load_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def check_file(missing: list[tuple[str, str, str]], asset_id: str, variant: str, relative_path: str):
    if relative_path and not (WEB / relative_path).exists():
        missing.append((asset_id, variant, relative_path))


def validate_placement(scene_id: str, placement: dict, errors: list[str]):
    object_id = placement.get("object_id", "<missing>")
    for field in ("x", "y", "w"):
        value = placement.get(field)
        if not isinstance(value, (int, float)):
            errors.append(f"{scene_id}/{object_id}: {field} must be numeric")
            continue
        if field in ("x", "y") and not 0 <= value <= 100:
            errors.append(f"{scene_id}/{object_id}: {field} must be between 0 and 100")
        if field == "w" and not 0 < value <= 100:
            errors.append(f"{scene_id}/{object_id}: w must be greater than 0 and at most 100")


def main():
    manifest = load_json(WEB / "assets" / "manifest.json")
    catalog = load_json(WEB / "data" / "catalog" / "items.json")
    objects_data = load_json(WEB / "data" / "objects.json")
    scenes_data = load_json(WEB / "data" / "scenes.json")

    missing: list[tuple[str, str, str]] = []
    broken_catalog: list[tuple[str, str]] = []
    broken_objects: list[tuple[str, str]] = []
    scene_errors: list[str] = []
    known_assets: set[str] = set()

    # Full environment images.
    for asset_id, entry in sorted((manifest.get("environments") or {}).items()):
        known_assets.add(asset_id)
        for variant, relative_path in sorted(entry.items()):
            if isinstance(relative_path, str):
                check_file(missing, asset_id, variant, relative_path)

    # Prototype object visuals packed into one shared atlas.
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

    # Forward-compatible manifest layout for standalone WORLD/SPOT/ICON files.
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

    object_definitions = objects_data.get("objects") or {}
    for object_id, definition in sorted(object_definitions.items()):
        asset_id = definition.get("asset_id")
        if not asset_id or asset_id not in known_assets:
            broken_objects.append((object_id, asset_id or "<missing>"))
        if not definition.get("default_action"):
            scene_errors.append(f"Object {object_id}: default_action is missing")
        if not definition.get("label_key"):
            scene_errors.append(f"Object {object_id}: label_key is missing")

    for scene_id, scene in sorted((scenes_data.get("scenes") or {}).items()):
        environment_asset = scene.get("environment_asset")
        if environment_asset not in known_assets:
            scene_errors.append(f"Scene {scene_id}: unknown environment {environment_asset}")
        if "hotspots" in scene:
            scene_errors.append(f"Scene {scene_id}: legacy hotspots are not allowed")

        for placement in scene.get("objects") or []:
            object_id = placement.get("object_id")
            if object_id not in object_definitions:
                scene_errors.append(f"Scene {scene_id}: unknown object {object_id}")
            validate_placement(scene_id, placement, scene_errors)

    print("=== Founder Sim Runtime Status ===")
    print(f"Manifest assets:  {len(known_assets)}")
    print(f"Catalog items:    {len(catalog.get('items', {}))}")
    print(f"Object types:     {len(object_definitions)}")
    print(f"Scenes:           {len(scenes_data.get('scenes', {}))}")
    print(f"Missing files:    {len(missing)}")
    print(f"Broken catalog:   {len(broken_catalog)}")
    print(f"Broken objects:   {len(broken_objects)}")
    print(f"Scene errors:     {len(scene_errors)}")

    if missing:
        print("\nMissing runtime files:")
        for asset_id, variant, relative_path in missing:
            print(f"  {asset_id:28} {variant:8} -> {relative_path}")

    if broken_catalog:
        print("\nCatalog items referencing unknown asset IDs:")
        for item_id, asset_id in broken_catalog:
            print(f"  {item_id} -> {asset_id}")

    if broken_objects:
        print("\nObjects referencing unknown asset IDs:")
        for object_id, asset_id in broken_objects:
            print(f"  {object_id} -> {asset_id}")

    if scene_errors:
        print("\nObject/scene graph errors:")
        for error in scene_errors:
            print(f"  {error}")

    raise SystemExit(1 if (missing or broken_catalog or broken_objects or scene_errors) else 0)


if __name__ == "__main__":
    main()
