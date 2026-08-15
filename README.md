# Founder Sim

Realistischer Browsergame-Unternehmensgruendungssimulator.

Aktueller Stand: `v0.3 - Humble Beginnings UI Skeleton`

## Was bereits funktioniert
- Desk View als Hauptszene
- klickbare Hotspots
- Kaffee veraendert Zeit/Energie/Fokus/Gesundheit
- Wechsel Desk -> Map
- Wechsel Desk -> Storage
- Zurueck-Navigation
- Map-Hotspots als Platzhalter
- HUD fuer Geld, Einnahmen, Ausgaben, Zeit, Energie, Fokus, Gesundheit
- fehlende finale Assets haben automatische Platzhalter
- feste Asset-IDs und Dateipfade ueber `app/web/assets/manifest.json`
- Produktions-Sheet-Pipeline fuer WORLD / SPOT / ICON
- automatisches Trimmen und Zentrieren von Assets innerhalb ihrer Pixelbox

## Start

```bash
./scripts/start.sh
```

Dann:
`http://localhost:8080`

## Asset Workflow

Rohe Produktions-Sheets kommen nach:

`asset_sources/sheets/<category>/`

Beispiel:

`asset_sources/sheets/desk_objects/sheet_desk_objects_001_2048.png`

Finale Game-Assets liegen unter:

`app/web/assets/<category>/`

Vollstaendige Anleitung:

`docs/assets/UPLOAD_WORKFLOW.md`

2048x2048 Referenzraster neu erzeugen:

```bash
python3 -m pip install -r requirements.txt
python3 scripts/generate_asset_grid.py
```

Produktions-Sheet importieren:

```bash
python3 scripts/import_asset_sheet.py \
  --sheet asset_sources/sheets/desk_objects/sheet_desk_objects_001_2048.png \
  --category desk_objects \
  --ids coffee_starter_white,phone_basic_black,keys_starter,notebook_starter_dark
```

Die Gegenstaende duerfen innerhalb ihrer jeweiligen Pixelbox versetzt liegen. Der Importer trimmt den belegten Bereich und zentriert ihn automatisch in der Runtime-Datei.

## Namensprinzip

Jedes physische Asset besitzt eine stabile Asset-ID, z. B.:

`coffee_starter_white`

Daraus entstehen:
- `coffee_starter_white_world.png`
- `coffee_starter_white_spot.png`
- `coffee_starter_white_icon.png`

Die Dateinamen gelten als Vertrag zwischen Asset-Produktion und Spielcode. Neue Features nennen deshalb ihre benoetigten Asset-Dateinamen explizit.

## Git-Workflow

```bash
./scripts/changes.sh
git status
git diff
git log --oneline --decorate -10
```
