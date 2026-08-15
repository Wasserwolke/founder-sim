# Founder Sim

Realistischer Browsergame-Unternehmensgruendungssimulator.

Aktueller Stand: `v0.4 - Foundation: Assets + i18n + Mod API`

## Aktueller Prototyp
- Desk View als Hauptszene
- klickbare Hotspots
- Kaffee veraendert Zeit/Energie/Fokus/Gesundheit
- Wechsel Desk -> Map
- Wechsel Desk -> Storage
- HUD fuer Geld, Einnahmen, Ausgaben, Zeit, Energie, Fokus, Gesundheit
- automatische Platzhalter fuer fehlende finale Assets

## Architektur-Grundlagen
- sichtbare Texte ueber `app/web/locales/de.json`
- stabile Asset-IDs ueber `app/web/assets/manifest.json`
- Itempreise und Gameplaywerte ueber `app/web/data/catalog/items.json`
- Ressourcen-Definitionen ueber `app/web/data/resources.json`
- oeffentliche Mod API v1 ueber `window.FounderSimModAPI`
- Mods unter `app/web/mods/`

## Start

```bash
./scripts/start.sh
```

Dann:
`http://localhost:8080`

## Asset Workflow

### Production Sheet
Rohe Sheets liegen unter:

`asset_sources/sheets/<category>/`

Ein Sheet besteht immer aus zwei zusammengehoerigen Dateien:

```text
sheet_desk_objects_001_2048.png
sheet_desk_objects_001_2048.json
```

Die JSON-Datei sagt eindeutig, welches Asset in welcher Zeile liegt. Der Name wird nicht in das Bild geschrieben.

Import:

```bash
python3 -m pip install -r requirements.txt
python3 scripts/import_asset_sheet.py \
  --sheet asset_sources/sheets/desk_objects/sheet_desk_objects_001_2048.png
```

Der Importer trimmt und zentriert das Artwork innerhalb jeder Pixelbox automatisch.

### Einzelne PNG-Dateien
Bereits getrennte WORLD/SPOT/ICON-Dateien duerfen direkt nach
`app/web/assets/<category>/` hochgeladen werden, sofern ihre Dateinamen exakt dem Asset-Manifest entsprechen.

### Asset Status

```bash
python3 scripts/asset_status.py
```

## Feature-first Regel
Neue kaufbare oder spielrelevante Dinge werden zuerst im Code definiert:

```text
Feature
 -> stabile item_id / asset_id
 -> Preis + Effekte im Catalog
 -> Asset-Manifest
 -> Sheet-Metadaten
 -> Bildgenerierung
 -> Import
 -> Runtime
```

Der Preis liegt nie im Bild. Beispiel:
`coffee_starter_white.price_cents` liegt in `app/web/data/catalog/items.json`.

## Sprachen
Deutsch ist die erste Sprache. Neue Sprachen werden als weitere JSON-Dateien unter `app/web/locales/` angelegt und behalten dieselben Keys.

## Mods
Siehe `docs/MODDING.md`.
Mods koennen ueber die API Ressourcen veraendern, Items registrieren/patchen, Assets ersetzen und eigene Uebersetzungen laden.

## Dokumentation
- `ARCHITECTURE.md`
- `DESIGN.md`
- `docs/MODDING.md`
- `docs/assets/UPLOAD_WORKFLOW.md`
- `docs/assets/SHEET_METADATA.md`

## Git-Workflow

```bash
./scripts/changes.sh
git status
git diff
git log --oneline --decorate -10
```
