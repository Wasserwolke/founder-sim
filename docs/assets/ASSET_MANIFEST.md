# Asset Manifest v0.7 - Humble Beginnings

Die maschinenlesbare Quelle ist `app/web/assets/manifest.json`.

Physische Assets verwenden normalerweise:
```text
<asset_id>_world.png
<asset_id>_spot.png
<asset_id>_icon.png
```

Der Dateiname traegt die Variante; dafuer wird kein eigener Unterordner pro Gegenstand angelegt.

## Bereits vorhandene Runtime-Assets
Environments:
- `desk_room_starter_night`
- `storage_room_starter`
- `city_map_starter`

Standalone Furniture:
- `chair_starter_01`
- `desk_starter_01`
- `keyboard_starter_01`
- `monitor_starter_dual`

Prototype-Atlas/Fallback:
- `coffee_starter_white`
- `phone_basic_black`
- `keys_starter`
- `notebook_starter_dark`
- `cleaning_caddy_starter`
- `vacuum_starter_basic`
- `bucket_blue_basic`
- `mop_basic_01`
- `van_starter_white`
- `map_home`
- `map_storage`
- `map_client`
- `map_hardware_store`

## Gewuenschte spaetere WORLD-Dateien
Diese Dateien sind fuer die neue Objektlogik nicht blockierend. Bis sie existieren, wird der Atlas oder ein sichtbarer Placeholder verwendet.

```text
assets/objects/common/coffee_starter_white_world.png
assets/objects/common/phone_basic_black_world.png
assets/objects/common/keys_starter_world.png
assets/objects/common/notebook_starter_dark_world.png

assets/objects/office/monitor_left_starter_world.png
assets/objects/office/monitor_right_starter_world.png

assets/objects/equipment/cleaning_caddy_starter_world.png
assets/objects/equipment/vacuum_starter_basic_world.png
assets/objects/equipment/bucket_blue_basic_world.png
assets/objects/equipment/mop_basic_01_world.png
```

Portable Gegenstaende werden nur einmal gespeichert. Wenn dieselbe Kaffeetasse spaeter im Lager statt im Buero steht, verweist die neue Instanz weiterhin auf dasselbe Asset.

## Regel
Die Asset-ID ist der Vertrag. Preise, Effekte, Besitz und Position stehen nicht im PNG. Die ObjectRegistry verwaltet den Typ; `scenes.json` verwaltet konkrete Instanzen und Kamera-Sichtbarkeit.
