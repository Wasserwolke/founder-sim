# Founder Sim

Realistischer, modularer Browsergame-Unternehmensgruendungssimulator.

Aktueller Stand: **v0.5 - erster visueller Humble-Beginnings-Prototyp**.

## Start
```bash
./scripts/start.sh
```
Dann `http://localhost:8080`.

## Jetzt testbar
- Starter-Schreibtisch bei Nacht/Regen
- klickbare Kaffee-, Telefon-, Schluessel-, Notizbuch- und Supplies-Hotspots
- Kaffee veraendert Zeit/Energie/Fokus/Gesundheit
- Wechsel Desk -> Storage Room
- Wechsel Desk -> City Map
- Kartenmarker fuer Zuhause, Fahrzeug, Lager, Kunde und Baumarkt
- erster Starter-Transporter als Asset
- HUD fuer Geld, Einnahmen, Ausgaben, Zeit, Energie, Fokus und Gesundheit
- Deutsch ueber `app/web/locales/de.json`
- Mod API v1
- datengetriebene Scenes, Ressourcen, Items und Assets

## Projektstruktur
Siehe `docs/PROJECT_STRUCTURE.md`.

Die wichtigsten Bereiche:
```text
app/core/        spaeterer Shared Kernel
app/modules/     Person, Founder, Company, CRM, Orders, Procurement,
                 Logistics, Finance, Invoices, Bureaucracy, HR
app/rules/       versionierte Deutschland-/Branchenregeln
app/web/         Browsergame
asset_sources/   Bildproduktion und Sheet-Metadaten
data/            spaetere persistente Daten/Migrationen
docs/            Architektur/Asset-/Modding-Dokumentation
scripts/         Entwicklungs- und Assetwerkzeuge
```

## Feature-first Regel
```text
Feature
 -> stabile item_id / asset_id
 -> Preis + Effekte im Catalog
 -> Translation Keys
 -> Scene/Mod-Schnittstelle
 -> Asset-Anforderung
 -> Bildgenerierung
 -> Runtime-Asset
```
Der Preis liegt nie im Bild.

## Asset-System
Der Spielcode referenziert stabile Asset-IDs ueber `app/web/assets/manifest.json`.

Runtime: `app/web/assets/`

Sheet-Zuordnung: `asset_sources/sheets/<category>/*.json`

Batch-Herkunft/Hashes: `asset_sources/incoming/batch_001/batch_001.json`

Der erste reale Bildbatch war 1254x1254 statt 2048x2048. Die tatsaechlichen Zellgrenzen sind in den Sidecars hinterlegt; der Importer kann deshalb trotzdem korrekt ausschneiden und zentrieren.

## Mehrsprachigkeit
Alle sichtbaren Texte liegen unter `app/web/locales/`. Deutsch ist aktuell die Standardsprache.

## Mods
Siehe `docs/MODDING.md`. `window.FounderSimModAPI` stellt Ressourcen, Catalog, Assets, Uebersetzungen und Events bereit.

## Dokumentation
- `ARCHITECTURE.md`
- `DESIGN.md`
- `docs/PROJECT_STRUCTURE.md`
- `docs/MODDING.md`
- `docs/assets/BATCH_001.md`
