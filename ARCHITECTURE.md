# Founder Sim - Architektur v0.5

## Grundmodell
Founder Sim trennt vier Sphaeren:
1. Privatperson
2. Gruenderrolle
3. Unternehmen
4. Aussenwelt

Der sichtbare Prototyp startet bewusst kleiner: `Desk -> Storage -> Map`. Die Architektur bleibt bereits auf die spaeteren Unternehmenssysteme vorbereitet.

## Technische Schichten
```text
app/core          spaeterer stabiler Shared Kernel
app/modules       Fachmodule
app/rules         versionierte Regelpakete
app/web           Browsergame + Runtime
app/web/locales   alle spieler-sichtbaren Texte
app/web/data      Ressourcen-, Catalog- und Scene-Definitionen
app/web/mods      lokale Mods + Mod-Manifeste
app/web/assets    normalisierte Runtime-Assets
asset_sources     Produktions-Sheet-Metadaten + Herkunft
data              persistente Daten und Migrationen
docs              Architektur und Produktionsregeln
scripts           lokale Tools / Asset-Pipeline
```

## Datengetriebene UI
Der aktuelle Browser-Prototyp verwendet:
```text
scenes.json
  -> environment_asset + Hotspot-Definitionen
AssetRegistry
  -> stabile asset_id -> Runtime-Datei / Atlas-Crop
ResourceRegistry
  -> Werte + Grenzen + Mod-Zugriff
CatalogRegistry
  -> Items, Preise, Kaufstatus und Effekte
locales/de.json
  -> alle sichtbaren Texte
```

Dadurch muessen neue Gegenstaende, Preise oder Hotspots nicht quer durch HTML/CSS hart verdrahtet werden.

## Mod API
`window.FounderSimModAPI` ist die oeffentliche Schnittstelle. API v1 stellt Ressourcen, Assets, Catalog, Uebersetzungen und Events bereit. Mods deklarieren ihre benoetigte `api_version`; inkompatible Mods werden uebersprungen.

## Sprachen
Spieler-sichtbare Texte werden mit Translation Keys referenziert. Deutsch liegt in `app/web/locales/de.json`. Weitere Sprachen erhalten dieselbe Key-Struktur. Mods koennen eigene Locale-Dictionaries zur Laufzeit ergaenzen.

## Asset-Grundsatz
Asset-Produktion und Gameplay-Daten sind getrennt.
```text
Feature
 -> item_id / asset_id
 -> Catalog: Preis + Effekte
 -> Translation Keys
 -> Asset-Anforderung
 -> Sheet JSON: row -> asset_id + echte Zellgrenzen
 -> Bildgenerierung
 -> Import/Atlas
 -> Runtime-Dateien
 -> Scene / Shop / Inventar
```

WORLD, SPOT und ICON desselben Gegenstands behalten denselben stabilen Asset-ID-Stamm. Der Name eines Items wird nicht ins Produktionsbild eingebrannt. Ein JSON-Sidecar definiert die Zeilenzuordnung eindeutig.

Der erste reale Asset-Batch wurde nicht in 2048x2048, sondern 1254x1254 generiert. Das ist bewusst abgefangen: Sidecars speichern die tatsaechlichen Spalten-/Zeilengrenzen. Der Importer ist damit tolerant gegen solche Abweichungen und zentriert isolierte Assets automatisch.

## Erweiterungsprinzip
Fachmodule besitzen ihre Fachlogik. Langfristig kommunizieren sie ueber Commands/Events und registrierte Schnittstellen statt beliebige fremde Daten direkt zu veraendern. Rechts- und Steuerwerte gehoeren in versionierte Rule Packs, nicht in UI-Code.

## Spaeterer Shared Kernel
Geplant sind:
- Simulationsuhr und Kalender
- Scheduler fuer Termine/Fristen
- Event Bus
- reproduzierbarer Zufall (RNG Seed)
- Ressourcenprimitive
- Ledger/Buchungsprimitive
- Save/Load und Schema-Migrationen
