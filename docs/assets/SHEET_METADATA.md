# Asset Sheet Metadata

## Important rule
The image itself does NOT carry the asset name.

Founder Sim maps rows to game objects through a JSON sidecar with the same filename stem as the PNG.

Example pair:

```text
sheet_desk_objects_001_2048.png
sheet_desk_objects_001_2048.json
```

Example metadata:

```json
{
  "schema_version": 1,
  "sheet": "sheet_desk_objects_001_2048.png",
  "category": "desk_objects",
  "rows": [
    {"row": 1, "asset_id": "coffee_starter_white"},
    {"row": 2, "asset_id": "phone_basic_black"},
    {"row": 3, "asset_id": "keys_starter"},
    {"row": 4, "asset_id": "notebook_starter_dark"}
  ]
}
```

This is deliberately more reliable than printing names inside the production image. Text in the image could be misread by an image model and would also interfere with automatic trimming.

## Two supported asset workflows

### A. Production sheet
1. Feature/item receives a stable asset ID first.
2. A sidecar JSON defines which row belongs to which asset ID.
3. The asset chat generates the 2048x2048 PNG according to that row order.
4. Upload the PNG next to the JSON.
5. Run `scripts/import_asset_sheet.py --sheet <file>`.
6. The importer creates `<asset_id>_world.png`, `<asset_id>_spot.png`, `<asset_id>_icon.png`.

### B. Direct individual PNGs
If WORLD/SPOT/ICON already exist separately, place them directly in:

```text
app/web/assets/<category>/
```

They must use the exact stable naming convention:

```text
<asset_id>_world.png
<asset_id>_spot.png
<asset_id>_icon.png
```

No production-sheet import is needed in that case.

## Feature-first rule
Gameplay content is defined BEFORE final artwork:

```text
Feature request
 -> stable item ID
 -> price/effects/content definition
 -> asset manifest entry
 -> sheet sidecar/spec
 -> artwork generation
 -> import/validation
 -> feature uses final art
```

Prices and gameplay effects never live in the PNG file.
