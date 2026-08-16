# Founder Sim - Architektur v0.7

## Grundmodell
Founder Sim trennt vier Sphaeren:
1. Privatperson
2. Gruenderrolle
3. Unternehmen
4. Aussenwelt

Der sichtbare Prototyp startet bewusst kleiner: Buero -> Lager -> Karte. Innerhalb eines Environments werden Perspektiven als Kamerazustaende abgebildet, nicht als separate Hintergrundbilder.

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
```text
objects.json
  -> wiederverwendbare Objekttypen
scenes.json
  -> Environment + Kamera-Presets + konkrete Objektinstanzen
ObjectRegistry
  -> stabile namespaced type_id -> Objektdefinition
SceneRenderer
  -> Environment + Kameratransform + Instanz-Overlay + Tooltip + Highlight
AssetRegistry
  -> stabile asset_id -> WORLD/SPOT/ICON oder Atlas-Fallback
ResourceRegistry
  -> Werte + Grenzen + Mod-Zugriff
CatalogRegistry
  -> Items, Preise, Kaufstatus und Effekte
locales/de.json
  -> alle sichtbaren Texte
```

## Environment und Kamera
`overview` und `desk` sind Kamerazustaende desselben Buero-Environments.

```text
office
  environment_asset: desk_room_starter_night
  cameras:
    overview -> scale 1.0
    desk     -> animierter Zoom auf denselben Raum
```

`cameraStage` enthaelt Hintergrund und Objektinstanzen gemeinsam. Der komplette Stage wird transformiert. Deshalb bleiben visuelle Objekte, Klickflaechen und Tooltips am selben Bildpunkt und koennen beim Zoomen nicht gegeneinander verrutschen.

## Objekttyp und Objektinstanz
Ein Objekttyp beschreibt, was ein Gegenstand ist:
```text
type_id: foundersim:coffee_starter_white
asset_id: coffee_starter_white
catalog_id: coffee_starter_white
default_action: coffee
```

Eine Instanz beschreibt nur, wo dieses Objekt gerade existiert:
```text
instance_id: foundersim:office.coffee.01
type_id: foundersim:coffee_starter_white
x/y/w
camera visibility
```

Derselbe Typ kann beliebig viele Instanzen besitzen. Eine Kaffeetasse muss deshalb nicht fuer Buero und Lager dupliziert werden.

## ID-Regel fuer Mods
Oeffentliche Objekttyp-IDs sind Strings mit Namespace:
```text
foundersim:coffee_starter_white
my_cleaning_mod:industrial_vacuum_x2
another_pack:coffee_mug_0042
```

Es gibt keine kuenstliche numerische Obergrenze fuer Objekt-IDs. Praktische Grenzen entstehen nur aus Browser-Speicher und Performance.

Unqualifizierte alte Core-IDs werden von `ObjectRegistry` automatisch als `foundersim:<id>` aufgeloest, sofern die entsprechende Core-ID existiert. Dadurch ist keine spaetere Massenumbenennung alter Spielstaende oder Mods erforderlich.

## Asset-Fallback
Standalone WORLD-Dateien haben Vorrang. Solange sie fehlen, darf `AssetRegistry` automatisch den bestehenden Prototype-Atlas verwenden.

```text
finales WORLD vorhanden
  -> standalone PNG
sonst
  -> Prototype-Atlas
```

Dadurch koennen Platzhalter und Atlas-Grafiken heute funktionieren, waehrend spaetere finale PNGs ohne Aenderung an Scene-Koordinaten oder Objektlogik eingesteckt werden.

## Hover und Interaktion
Interaktion gehoert zur Objektinstanz. Physische Assets erhalten Pixel-Outline; fehlende oder absichtlich noch nicht produzierte Visuals erhalten einen sichtbaren funktionalen Placeholder mit Tooltip. Es existieren keine frei schwebenden separaten Hotspots.

## Mod API
`window.FounderSimModAPI` stellt Ressourcen, Assets, Catalog, Objects, Uebersetzungen und Events bereit. Neue Mod-Objekte muessen namespaced IDs verwenden.

## Asset-Grundsatz
Asset-Produktion und Gameplay-Daten bleiben getrennt:
```text
Feature
 -> catalog_id / asset_id / type_id
 -> Catalog: Preis + Effekte
 -> Object: Verhalten + Visual-Referenz
 -> Scene: Instanz + Position + Kamera-Sichtbarkeit
 -> Translation Keys
 -> Asset-Anforderung
 -> Bildgenerierung
 -> Runtime
```

WORLD, SPOT und ICON desselben Gegenstands behalten denselben stabilen Asset-ID-Stamm.

## Erweiterungsprinzip
Fachmodule besitzen ihre Fachlogik. Langfristig kommunizieren sie ueber Commands/Events und registrierte Schnittstellen. Rechts- und Steuerwerte gehoeren in versionierte Rule Packs, nicht in UI-Code.
