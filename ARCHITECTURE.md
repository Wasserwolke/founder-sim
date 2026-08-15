# Founder Sim - Architektur v0.4

## Grundmodell
Founder Sim trennt vier Sphaeren:
1. Privatperson
2. Gruenderrolle
3. Unternehmen
4. Aussenwelt

Der sichtbare Prototyp startet bewusst kleiner: `Desk -> Storage -> Map`.

## Technische Schichten
```text
app/core          spaeterer stabiler Shared Kernel
app/modules       Fachmodule
app/rules         versionierte Regelpakete
app/web           Browsergame + Runtime
app/web/locales   alle spieler-sichtbaren Texte
app/web/data      Ressourcen- und Contentdefinitionen
app/web/mods      lokale Mods + Mod-Manifeste
app/web/assets    normalisierte Runtime-Assets
asset_sources     rohe Produktions-Sheets + Sheet-Metadaten
data              persistente Daten und Migrationen
docs              Architektur und Produktionsregeln
scripts           lokale Tools / Asset-Pipeline
```

## Registries statt harter Kopplung
Der Browser-Prototyp verwendet drei zentrale Registries:

```text
ResourceRegistry  Werte + Grenzen + Mod-Zugriff
AssetRegistry     stabile asset_id -> Runtime-Dateien
CatalogRegistry   Items, Preise, Kaufstatus und Effekte
```

Dadurch referenziert Fachcode stabile IDs statt Dateipfade oder hart codierte Preise.

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
 -> Asset Manifest
 -> Sheet JSON: row -> asset_id
 -> Asset-Chat erzeugt PNG
 -> Importer trimmt + zentriert
 -> Runtime-Dateien
 -> Spiel
```

WORLD, SPOT und ICON desselben Gegenstands behalten denselben stabilen Asset-ID-Stamm.

Der Name eines Items wird nicht in das Produktionsbild eingebrannt. Ein JSON-Sidecar definiert die Zeilenzuordnung eindeutig. Dadurch ist die Position des Gegenstands innerhalb seiner Zelle frei, waehrend die Identitaet maschinenlesbar bleibt.

## Zwei Asset-Wege
1. Produktions-Sheet + JSON-Sidecar -> automatischer Import.
2. Bereits getrennte PNGs direkt unter `app/web/assets/<category>/` mit exakten Manifest-Dateinamen.

## Spaeter
Der Shared Kernel soll Simulationsuhr, Scheduler, Event Bus, reproduzierbaren Zufall und Ledger-Primitiven enthalten. Fachmodule kommunizieren ueber Commands/Events und registrierte Schnittstellen statt beliebige fremde Daten direkt zu veraendern.
