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


def validate_desk_focus(scenes_data: dict, object_definitions: dict, errors: list[str]):
    office = (scenes_data.get("scenes") or {}).get("office") or {}
    cameras = office.get("cameras") or {}
    overview = cameras.get("overview") or {}
    desk = cameras.get("desk") or {}

    if desk and overview and desk.get("scale", 1) <= overview.get("scale", 1):
        errors.append("Scene office/desk: desk camera must zoom closer than overview")

    required_types = {
        "foundersim:monitor_left_starter",
        "foundersim:monitor_right_starter",
        "foundersim:notebook_starter_dark",
        "foundersim:keys_starter",
        "foundersim:phone_basic_black",
        "foundersim:coffee_starter_white",
        "foundersim:keyboard_starter_01",
        "foundersim:mouse_starter_black",
    }
    desk_instances = [
        placement
        for placement in office.get("instances") or []
        if "desk" in (placement.get("cameras") or [])
    ]
    desk_types = {placement.get("type_id") for placement in desk_instances}

    for type_id in sorted(required_types - desk_types):
        errors.append(f"Scene office/desk: required desk object missing: {type_id}")

    for placement in desk_instances:
        definition = object_definitions.get(placement.get("type_id")) or {}
        if definition.get("visual_mode") == "background_surface" and "h" not in placement:
            errors.append(
                f"Scene office/{placement.get('instance_id', '<missing>')}: "
                "background_surface requires an explicit height"
            )

    for type_id in sorted(required_types):
        definition = object_definitions.get(type_id) or {}
        if not definition.get("hint_key"):
            errors.append(f"Object {type_id}: desk objects require a hint_key")
        if definition.get("highlight") not in {"pixel_outline", "box_outline"}:
            errors.append(f"Object {type_id}: desk object highlight must be pixel_outline or box_outline")

    keyboard = object_definitions.get("foundersim:keyboard_starter_01") or {}
    if keyboard.get("asset_id") != "keyboard_starter_01" or keyboard.get("placeholder"):
        errors.append("Object foundersim:keyboard_starter_01: existing keyboard WORLD asset must be used")

    mouse = object_definitions.get("foundersim:mouse_starter_black") or {}
    if mouse.get("placeholder") is not True:
        errors.append("Object foundersim:mouse_starter_black: mouse remains a visible placeholder until a WORLD asset exists")

    left = object_definitions.get("foundersim:monitor_left_starter") or {}
    right = object_definitions.get("foundersim:monitor_right_starter") or {}
    if left.get("default_action") == right.get("default_action"):
        errors.append("Desk monitors must keep distinct operations and management actions")
    for type_id, definition in (("left", left), ("right", right)):
        if definition.get("visual_mode") != "background_surface":
            errors.append(f"Desk monitor {type_id}: use the visible environment screen as background_surface")
        if definition.get("asset_id") != "monitor_starter_dual":
            errors.append(f"Desk monitor {type_id}: keep monitor_starter_dual as the registered source asset")


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
        visual_mode = definition.get("visual_mode", "asset")
        if visual_mode not in {"asset", "background_surface"}:
            graph_errors.append(f"Object {type_id}: unsupported visual_mode {visual_mode!r}")
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

    validate_desk_focus(scenes_data, object_definitions, graph_errors)

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
