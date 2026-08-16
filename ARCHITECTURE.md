# Founder Sim - Architektur v0.6

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
app/web/data      Ressourcen-, Catalog-, Object- und Scene-Definitionen
app/web/mods      lokale Mods + Mod-Manifeste
app/web/assets    normalisierte Runtime-Assets
asset_sources     Produktions-Sheet-Metadaten + Herkunft
data              persistente Daten und Migrationen
docs              Architektur und Produktionsregeln
scripts           wenige allgemeine Entwicklungs-/Assetwerkzeuge
```

## Datengetriebene Runtime
Der Browser-Prototyp verwendet:
```text
objects.json
  -> wiederverwendbare Objektdefinition: Asset, Label, Default-Aktion, Hover-Stil
scenes.json
  -> environment_asset + Platzierung von Objektinstanzen
ObjectRegistry
  -> stabile object_id -> Objektdefinition / Mod-Schnittstelle
SceneRenderer
  -> Environment + objektgebundene Interaktion + Tooltip + Highlight
AssetRegistry
  -> stabile asset_id -> Runtime-Datei / Atlas-Crop
ResourceRegistry
  -> Werte + Grenzen + Mod-Zugriff
CatalogRegistry
  -> Items, Preise, Kaufstatus und Effekte
locales/de.json
  -> alle sichtbaren Texte
```

## Objekt-Overlay-Modell
Interaktive Gegenstaende sind keine frei schwebenden Hotspots mehr. Eine Objektinstanz besteht aus:
```text
object_id
+ x/y/w in Prozent des Originalbildes
+ optionale Scene-Overrides (z. B. andere Aktion)
```

Die Objektdefinition liegt nur einmal in `objects.json`. `SceneRenderer` richtet `objectLayer` exakt am sichtbaren Environment-Bild aus. Dadurch bleiben Positionen bei anderem Browserformat, Aufloesung oder Letterboxing stabil.

Die ersten echten Objekt-Overlays sind:
- Kaffeetasse
- Telefon
- Autoschluessel
- Notizbuch
- Reinigungskiste
- Staubsauger
- Putzeimer
- Wischmopp

Bis transparente WORLD-PNGs vorliegen, werden diese Objektinstanzen aus dem vorhandenen Prototype-Atlas gerendert. Der Austausch gegen spaetere WORLD-Assets benoetigt keine Aenderung an den Scene-Platzierungen.

## Hover und Interaktion
Ein Objekt besitzt Visual und Interaktion gemeinsam. Hover/Keyboard-Fokus hebt die nichttransparenten Pixel des Objektvisuals hervor und zeigt einen Tooltip mit Objektname und Aktion. Der Klick wird ueber `data-object-id` + `data-action` an die zentrale Action-Routing-Logik weitergegeben.

## Mod API
`window.FounderSimModAPI` ist die oeffentliche Schnittstelle. API v1 stellt Ressourcen, Assets, Catalog, **Objects**, Uebersetzungen und Events bereit. Mods koennen damit neue Objektdefinitionen registrieren oder vorhandene patchen, ohne Scene-Rendering-Code zu veraendern.

## Sprachen
Spieler-sichtbare Texte werden mit Translation Keys referenziert. Deutsch liegt in `app/web/locales/de.json`. Weitere Sprachen erhalten dieselbe Key-Struktur. Mods koennen eigene Locale-Dictionaries zur Laufzeit ergaenzen.

## Asset-Grundsatz
Asset-Produktion und Gameplay-Daten sind getrennt.
```text
Feature
 -> item_id / asset_id / object_id
 -> Catalog: Preis + Effekte
 -> Object: Visual + Interaktion
 -> Scene: konkrete Platzierung
 -> Translation Keys
 -> Asset-Anforderung
 -> Bildgenerierung
 -> Import/Atlas oder WORLD/SPOT/ICON
 -> Runtime
```

WORLD, SPOT und ICON desselben Gegenstands behalten denselben stabilen Asset-ID-Stamm. Der Name eines Items wird nicht ins Produktionsbild eingebrannt. Ein JSON-Sidecar definiert die Zeilenzuordnung eindeutig.

Der erste reale Asset-Batch wurde nicht in 2048x2048, sondern 1254x1254 generiert. Sidecars speichern deshalb die tatsaechlichen Spalten-/Zeilengrenzen. Der Importer ist tolerant gegen solche Abweichungen und zentriert isolierte Assets automatisch.

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
