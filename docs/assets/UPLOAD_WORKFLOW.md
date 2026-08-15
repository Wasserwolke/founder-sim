# Asset Upload Workflow

## Ziel
Ein neues Produktions-Sheet soll ohne manuelles Zuschneiden in Founder Sim nutzbar werden.

## 2048x2048 Object Sheet
Feste Geometrie:
- Gesamt: 2048 x 2048 px
- WORLD: x=0..895, Breite 896 px
- SPOT: x=896..1663, Breite 768 px
- ICON: x=1664..2047, Breite 384 px
- 4 Zeilen zu je 512 px

Die Position des Gegenstands innerhalb seiner Zelle ist nicht kritisch. Der Importer schneidet die feste Zelle aus, erkennt den belegten Bildbereich, trimmt ihn und zentriert ihn auf einer normierten transparenten Ausgabe.

Regeln fuer Produktions-Sheets:
- Gegenstand vollstaendig innerhalb seiner Zelle
- keine Texte, Nummern oder Deko innerhalb der eigentlichen Zelle
- Rasterlinien nur exakt an Zellgrenzen
- moeglichst einfarbiger oder transparenter Zellenhintergrund
- WORLD, SPOT und ICON einer Zeile zeigen dasselbe konkrete Design

## Ablage
Rohes Sheet:
`asset_sources/sheets/<category>/sheet_<category>_<batch>_2048.png`

Runtime-Ausgaben:
`app/web/assets/<category>/<asset_id>_world.png`
`app/web/assets/<category>/<asset_id>_spot.png`
`app/web/assets/<category>/<asset_id>_icon.png`

## Import
```bash
python3 scripts/import_asset_sheet.py \
  --sheet asset_sources/sheets/desk_objects/sheet_desk_objects_001_2048.png \
  --category desk_objects \
  --ids coffee_starter_white,phone_basic_black,keys_starter,notebook_starter_dark
```

Der Gegenstand darf innerhalb der Pixelbox versetzt sein. Der Importer normalisiert seine Position automatisch.

Komplette Environments werden separat behandelt und nicht mit dem 4-Zeilen-Object-Sheet importiert.
