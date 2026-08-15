# Asset Upload Workflow

## Core idea
The production PNG contains artwork only. Asset identity comes from a JSON sidecar with the same filename stem.

Example:

```text
asset_sources/sheets/desk_objects/
  sheet_desk_objects_001_2048.png
  sheet_desk_objects_001_2048.json
```

The JSON file defines which row belongs to which stable asset ID.

## 2048x2048 Object Sheet
Fixed geometry:
- total: 2048 x 2048 px
- WORLD: x=0..895, width 896 px
- SPOT: x=896..1663, width 768 px
- ICON: x=1664..2047, width 384 px
- four rows, 512 px each

The artwork may sit anywhere inside its cell as long as it remains completely inside the cell. The importer crops the fixed cell, detects the occupied region, trims it and centers it on a normalized transparent output canvas.

## Import a sheet
With the sidecar JSON present, only the PNG path is needed:

```bash
python3 scripts/import_asset_sheet.py \
  --sheet asset_sources/sheets/desk_objects/sheet_desk_objects_001_2048.png
```

The importer automatically creates:

```text
app/web/assets/<category>/<asset_id>_world.png
app/web/assets/<category>/<asset_id>_spot.png
app/web/assets/<category>/<asset_id>_icon.png
```

## Direct PNG workflow
Already-separated images can be uploaded directly to `app/web/assets/<category>/` using the exact stable names from the manifest. No sheet import is required.

## Important
Do not write asset names inside the production cells. Names are metadata, not artwork. This avoids image-model text errors and prevents labels from being mistaken for part of the object during automatic trimming.

See also:
- `docs/assets/SHEET_METADATA.md`
- `app/web/assets/manifest.json`
- `app/web/data/catalog/items.json`
