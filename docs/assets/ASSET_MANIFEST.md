# Asset Manifest v0.4 - Humble Beginnings

The machine-readable source of truth is `app/web/assets/manifest.json`.

Every runtime image has a stable `asset_id`. Physical assets normally use:

```text
<asset_id>_world.png
<asset_id>_spot.png
<asset_id>_icon.png
```

## Environments
- `desk_room_starter_night`
- `storage_room_starter`
- `city_map_starter`

## Desk Objects
- `coffee_starter_white`
- `phone_basic_black`
- `keys_starter`
- `notebook_starter_dark`

## Equipment
- `cleaning_caddy_starter`
- `vacuum_starter_basic`

## Vehicle
- `van_starter_white`

## Map Icons
- `map_home`
- `map_storage`
- `map_client`
- `map_hardware_store`

## UI
- `ui_money`
- `ui_income`
- `ui_expenses`
- `ui_time`
- `ui_energy`
- `ui_focus`
- `ui_health`
- `ui_back`
- `ui_close`

## Rule
The asset ID is the contract. File paths are resolved by the AssetRegistry. Gameplay data such as price and effects live in the catalog, not in this asset document and never in the PNG.
