# Founder Sim
Aktueller Stand: **v0.5 - erster visueller Humble-Beginnings-Prototyp**.

## Start
```bash
./scripts/start.sh
```
Dann `http://localhost:8080`.

## Bereits testbar
- Starter-Schreibtisch bei Nacht/Regen
- Kaffee, Telefon, Schluessel, Notizbuch und Supplies als klickbare Hotspots
- Kaffee verbraucht Zeit und veraendert Energie/Fokus/Gesundheit
- Wechsel Desk -> Storage Room
- Wechsel Desk -> City Map
- Kartenmarker: Zuhause, Fahrzeug, Lager, Kunde, Baumarkt
- erstes Fahrzeug-Asset im Runtime-Atlas
- HUD fuer Geld, Einnahmen, Ausgaben, Zeit, Energie, Fokus und Gesundheit
- Deutsch ueber `app/web/locales/de.json`
- Mod API v1
- datengetriebene Scene- und Asset-Konfiguration

## Projektprinzip
```text
Feature
 -> stabile IDs / Daten / Preis / Effekte
 -> Uebersetzung
 -> Asset-Anforderung
 -> Bildgenerierung
 -> Runtime-Asset
 -> Scene / Shop / Inventar
```

## Assets
Der Spielcode referenziert stabile Asset-IDs ueber `app/web/assets/manifest.json`.

- Runtime-Assets: `app/web/assets/`
- Produktions-Sheet-Metadaten: `asset_sources/sheets/<category>/`
- Batch-Herkunft/Hashes: `asset_sources/incoming/batch_001/batch_001.json`
- Importer: `scripts/import_asset_sheet.py`

Fuer den Prototypen werden die kleinen Objekt-Icons aus einem Atlas geladen. Die originalen grossen Produktionsbilder bleiben ueber ihre Batch-Metadaten eindeutig nachvollziehbar und koennen spaeter erneut importiert/ersetzt werden.

## Architektur
Siehe `ARCHITECTURE.md`, `DESIGN.md`, `docs/PROJECT_STRUCTURE.md`, `docs/MODDING.md` und `docs/assets/BATCH_001.md`.
