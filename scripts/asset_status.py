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
    instance_id = placement.get("instance_id", "<missing>")
    for field in ("x", "y", "w"):
        value = placement.get(field)
        if not isinstance(value, (int, float)):
            errors.append(f"{scene_id}/{instance_id}: {field} must be numeric")
            continue
        if field in ("x", "y") and not 0 <= value <= 100:
            errors.append(f"{scene_id}/{instance_id}: {field} must be between 0 and 100")
        if field == "w" and not 0 < value <= 100:
            errors.append(f"{scene_id}/{instance_id}: w must be greater than 0 and at most 100")

    if "h" in placement:
        value = placement["h"]
        if not isinstance(value, (int, float)) or not 0 < value <= 100:
            errors.append(f"{scene_id}/{instance_id}: h must be numeric, greater than 0 and at most 100")


def main():
    manifest = load_json(WEB / "assets" / "manifest.json")
    catalog = load_json(WEB / "data" / "catalog" / "items.json")
    objects_data = load_json(WEB / "data" / "objects.json")
    scenes_data = load_json(WEB / "data" / "scenes.json")

    missing: list[tuple[str, str, str]] = []
    broken_catalog: list[tuple[str, str]] = []
    broken_objects: list[tuple[str, str]] = []
    graph_errors: list[str] = []
    known_assets: set[str] = set()

    for asset_id, entry in sorted((manifest.get("environments") or {}).items()):
        known_assets.add(asset_id)
        for variant, relative_path in sorted(entry.items()):
            if isinstance(relative_path, str):
                check_file(missing, asset_id, variant, relative_path)

    for asset_id, entry in sorted((manifest.get("prototype_icons") or {}).items()):
        known_assets.add(asset_id)
        atlas = entry.get("atlas")
        if atlas:
            check_file(missing, asset_id, "atlas", atlas)
        crop = entry.get("crop")
        atlas_size = entry.get("atlas_size")
        if not (isinstance(crop, list) and len(crop) == 4):
            graph_errors.append(f"Asset {asset_id}: invalid crop metadata")
        if not (isinstance(atlas_size, list) and len(atlas_size) == 2):
            graph_errors.append(f"Asset {asset_id}: invalid atlas_size metadata")

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
    for type_id, definition in sorted(object_definitions.items()):
        if ":" not in type_id:
            graph_errors.append(f"Object type {type_id}: public IDs must be namespaced")

        asset_id = definition.get("asset_id")
        is_placeholder = bool(definition.get("placeholder"))
        if asset_id and asset_id not in known_assets:
            broken_objects.append((type_id, asset_id))
        if not asset_id and not is_placeholder:
            broken_objects.append((type_id, "<missing>"))
        if not definition.get("default_action"):
            graph_errors.append(f"Object {type_id}: default_action is missing")
        if not definition.get("label_key"):
            graph_errors.append(f"Object {type_id}: label_key is missing")

    for scene_id, scene in sorted((scenes_data.get("scenes") or {}).items()):
        environment_asset = scene.get("environment_asset")
        if environment_asset not in known_assets:
            graph_errors.append(f"Scene {scene_id}: unknown environment {environment_asset}")

        for legacy_key in ("hotspots", "objects"):
            if legacy_key in scene:
                graph_errors.append(f"Scene {scene_id}: legacy {legacy_key} are not allowed; use instances")

        cameras = scene.get("cameras") or {}
        initial_camera = scene.get("initial_camera")
        if not cameras:
            graph_errors.append(f"Scene {scene_id}: at least one camera preset is required")
        if initial_camera not in cameras:
            graph_errors.append(f"Scene {scene_id}: initial_camera {initial_camera!r} does not exist")

        for camera_id, camera in cameras.items():
            scale = camera.get("scale", 1)
            if not isinstance(scale, (int, float)) or scale <= 0:
                graph_errors.append(f"Scene {scene_id}/{camera_id}: scale must be greater than 0")
            for field in ("x", "y", "duration_ms"):
                if field in camera and not isinstance(camera[field], (int, float)):
                    graph_errors.append(f"Scene {scene_id}/{camera_id}: {field} must be numeric")

        seen_instances: set[str] = set()
        for placement in scene.get("instances") or []:
            instance_id = placement.get("instance_id")
            type_id = placement.get("type_id")

            if not instance_id:
                graph_errors.append(f"Scene {scene_id}: instance_id is required")
            elif instance_id in seen_instances:
                graph_errors.append(f"Scene {scene_id}: duplicate instance_id {instance_id}")
            else:
                seen_instances.add(instance_id)

            if type_id not in object_definitions:
                graph_errors.append(f"Scene {scene_id}: unknown object type {type_id}")

            for camera_id in placement.get("cameras") or []:
                if camera_id not in cameras:
                    graph_errors.append(f"Scene {scene_id}/{instance_id}: unknown camera {camera_id}")

            validate_placement(scene_id, placement, graph_errors)

    print("=== Founder Sim Runtime Status ===")
    print(f"Manifest assets:  {len(known_assets)}")
    print(f"Catalog items:    {len(catalog.get('items', {}))}")
    print(f"Object types:     {len(object_definitions)}")
    print(f"Scenes:           {len(scenes_data.get('scenes', {}))}")
    print(f"Missing files:    {len(missing)}")
    print(f"Broken catalog:   {len(broken_catalog)}")
    print(f"Broken objects:   {len(broken_objects)}")
    print(f"Graph errors:     {len(graph_errors)}")

    if missing:
        print("\nMissing runtime files:")
        for asset_id, variant, relative_path in missing:
            print(f"  {asset_id:32} {variant:8} -> {relative_path}")

    if broken_catalog:
        print("\nCatalog items referencing unknown asset IDs:")
        for item_id, asset_id in broken_catalog:
            print(f"  {item_id} -> {asset_id}")

    if broken_objects:
        print("\nObjects referencing unknown asset IDs:")
        for type_id, asset_id in broken_objects:
            print(f"  {type_id} -> {asset_id}")

    if graph_errors:
        print("\nObject/scene/camera graph errors:")
        for error in graph_errors:
            print(f"  {error}")

    raise SystemExit(1 if (missing or broken_catalog or broken_objects or graph_errors) else 0)


if __name__ == "__main__":
    main()
