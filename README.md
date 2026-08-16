# Founder Sim

Realistischer, modularer Browsergame-Unternehmensgruendungssimulator.

Aktueller Stand: **v0.6 - erster objektbasierter Humble-Beginnings-Prototyp**.

## Direkt spielen
https://wasserwolke.github.io/founder-sim/

## Lokal starten
```bash
./scripts/start.sh
```
Dann `http://localhost:8080`.

## Jetzt testbar
- Starter-Schreibtisch, Lager und Stadtkarte
- Objekt-Overlay-System statt frei schwebender Hotspots
- acht erste physische Objektarten: Kaffee, Telefon, Schluessel, Notizbuch, Reinigungskiste, Staubsauger, Putzeimer, Wischmopp
- Hover/Keyboard-Fokus hebt Objektpixel hervor und zeigt Name + Aktion
- Objektpositionen bleiben an der sichtbaren Environment-Grafik verankert, auch bei anderem Browserformat
- Kaffee veraendert Zeit/Energie/Fokus/Gesundheit
- Wechsel Desk -> Storage -> Map
- Kartenmarker fuer Zuhause, Fahrzeug, Lager, Kunde und Baumarkt
- HUD fuer Geld, Einnahmen, Ausgaben, Zeit, Energie, Fokus und Gesundheit
- Deutsch ueber `app/web/locales/de.json`
- Mod API v1 inkl. ObjectRegistry

## Wichtige Datenwege
```text
app/web/data/objects.json       Was ist ein Objekt?
app/web/data/scenes.json        Wo steht es in einer Szene?
app/web/assets/manifest.json    Welches Bild gehoert zur asset_id?
app/web/data/catalog/items.json Preis / Effekte / Itemdaten
app/web/locales/de.json         Sichtbare Texte
```

Damit muss ein spaeteres WORLD-PNG nur im Asset-System ausgetauscht werden; die Scene-Position und Interaktion bleiben erhalten.

## Projektstruktur
Siehe `docs/PROJECT_STRUCTURE.md` und `ARCHITECTURE.md`.

## Feature-first Regel
```text
Feature
 -> stabile item_id / asset_id / object_id
 -> Preis + Effekte im Catalog
 -> Objektdefinition
 -> Scene-Platzierung
 -> Translation Keys
 -> Asset-Anforderung
 -> Bildgenerierung
 -> Runtime-Asset
```
Der Preis liegt nie im Bild.

## Asset-System
Runtime-Assets liegen unter `app/web/assets/`. Produktions-Sheets und ihre eindeutigen Zuordnungen liegen unter `asset_sources/sheets/`. `scripts/import_asset_sheet.py` kann daraus spaeter eigenstaendige WORLD/SPOT/ICON-Dateien erzeugen.

## Mehrsprachigkeit
Alle sichtbaren Texte liegen unter `app/web/locales/`. Deutsch ist aktuell die Standardsprache.

## Mods
Siehe `docs/MODDING.md`. `window.FounderSimModAPI` stellt Ressourcen, Catalog, Objects, Assets, Uebersetzungen und Events bereit.

## Entwicklung
GitHub Actions validiert Python, JSON, JavaScript, DOM-Vertrag, Asset-/Catalog-/Object-/Scene-Verknuepfungen und die wichtigsten Runtime-Dateien. Nur ein erfolgreicher Build wird auf GitHub Pages deployed.
