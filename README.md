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
- feste Asset-IDs und Dateipfade
- Produktions-Sheet-Pipeline fuer WORLD / SPOT / ICON

## Start

```bash
./scripts/start.sh
```

Dann:
`http://localhost:8080`

## Asset Workflow

Finale Game-Assets:
`app/web/assets/`

Rohe Produktions-Sheets:
`asset_sources/incoming/`

Sheet-Spezifikationen:
`asset_sources/pack_specs/`

Vollstaendige Anleitung:
`docs/assets/ASSET_PIPELINE.md`

Asset-Status:
```bash
python3 scripts/asset_status.py
```

Produktions-Sheet schneiden:
```bash
python3 -m pip install -r requirements-tools.txt
python3 scripts/slice_asset_sheet.py asset_sources/pack_specs/pack_desk_objects_01.json
```

## Namensprinzip

Jedes Asset besitzt eine stabile Asset-ID, z. B.:
`coffee_starter_white`

Daraus:
- `coffee_starter_white_world.png`
- `coffee_starter_white_spot.png`
- `coffee_starter_white_icon.png`

Der Code referenziert diese festen IDs/Pfade ueber `app/web/assets/manifest.json`.

## Git-Workflow

```bash
./scripts/changes.sh
git status
git diff
git log --oneline --decorate -10
```
