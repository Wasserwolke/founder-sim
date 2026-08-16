# Lighting System

## Ziel

Das Lighting-System ist ein wiederverwendbares Raum-Modul. Es soll Atmosphaere erzeugen, ohne die Spielobjekte fest an eine bestimmte Tageszeit oder ein bestimmtes Licht zu binden.

V1 arbeitet mit mehreren Canvas-Layern und Shader-Washes. Spaetere Versionen erweitern das um echte `Light2D`-Emitter, Occluder und optional Normal Maps.

## V1-Schichten

`RoomLightingRig` setzt sich aus folgenden visuellen Schichten zusammen:

- `AmbientShade`: kuehle Grundabdunklung fuer Abend/Nacht und schlechtes Wetter.
- `Warmth`: warmer Golden-Hour-Ton bei Morgen- und Abendlicht.
- `WindowWash`: additive Fensterhelligkeit und ein weicher Lichtwurf in den Raum.
- `RoomLightWash`: warmer kuenstlicher Raumlicht-Prototyp.
- `Vignette`: sehr dezente Randabdunklung fuer Tiefe und Fokus.
- `DynamicLights`: reservierter Node fuer spaetere `Light2D`-Emitter von Items.

Uebergaenge werden weich interpoliert, statt Lichtzustand hart umzuschalten.

## Developer Atmosphere Controller

Im Debug-Build erscheint ein Live-Panel. `F10` blendet es ein oder aus.

Einstellbar:

- Uhrzeit 00:00–24:00
- Clear / Cloudy / Rain
- Raumlicht an/aus
- Raumlichtstaerke
- animierter 24h-Zyklus
- Dauer des Test-Tages
- Reset auf simulierte GameState-Zeit

Zusaetzlich ist `RoomLightingRig` ein `@tool`-Script. In Godot kann der LightingRig-Node im lokalen Scene Tree ausgewaehlt und ueber die Gruppe `Editor Preview` direkt im Inspector getestet werden.

## Objekt-Lichtvertrag

Jedes spaetere platzierbare Objekt erhaelt explizite Lighting-Eigenschaften. Diese gehoeren zur Objektdefinition und nicht in das gerenderte Hintergrundbild.

Geplanter Vertrag:

```text
receives_light: true/false
casts_shadow: true/false
occluder_profile: optional
emissive: true/false
emitter_id: optional
light_color: optional
light_energy: optional
light_radius: optional
light_enabled_by_state: optional
light_mask: world/ui/special
```

Beispiele:

- Schreibtisch: `receives_light=true`, `casts_shadow=true` → unter/ hinter dem Tisch kann ein Occluder Schatten erzeugen.
- Monitor: empfaengt Raumlicht, kann bei eingeschaltetem Zustand einen eigenen schwachen Bildschirm-Emitter registrieren.
- RGB-Tastatur: emissive nur in einem eingeschalteten Zustand.
- Lampe: eigener `Light2D`-Emitter; Schalter/Item-State kontrolliert `enabled` und Energie.
- Papier/Notizbuch: empfaengt Licht, wirft nur einen kleinen Kontaktschatten.

`RoomLightingRig.register_emitter()` ist bereits als erster Hook vorhanden. Spaetere Item-Szenen koennen damit eigene `Light2D`-Nodes registrieren.

## Schatten

Schatten sollen nach Moeglichkeit aus Geometrie entstehen statt in WORLD-PNGs eingebrannt zu werden.

Fuer groessere Moebel:

- `LightOccluder2D` als Kind der Objekt-Szene.
- Occluder-Polygon folgt der relevanten Silhouette bzw. Standflaeche.
- Kontakt-/AO-Schatten duerfen als sehr dezente neutrale Asset-Komponente existieren, starke Richtungs-Schatten sollen vom Raumlicht kommen.

Damit kann derselbe Tisch bei Tageslicht, Nacht, Lampenlicht oder in einem anderen Raum glaubwuerdig reagieren.

## Asset-Regel

WORLD-Assets werden moeglichst neutral beleuchtet erstellt:

- keine starke fest eingebrannte Sonne
- keine harte Lichtfarbe, die nur zu einer Tageszeit passt
- transparenter Hintergrund fuer Einzelobjekte
- Material/Volumen sichtbar, aber Beleuchtung zurueckhaltend
- Emission (Monitor, LED, Lampe) als Zustand oder separater Layer

Die aktuelle Raum-Shell besitzt noch gebackene Bildinformationen. Sie bleibt fuer den V1-Prototyp brauchbar. Spaeter werden Innenraum und Fenster-/City-View getrennt, damit Wetter, Nachtlichter und Tageszeit unabhaengiger steuerbar sind.

## Wiederverwendung in weiteren Szenen

Jeder neue Raum kann dieselbe LightingRig-Szene instanzieren und spaeter ein eigenes Lighting-Profil bekommen. Auch Map-/Stadtansichten folgen demselben Grundprinzip: Environment + Atmosphaere + anklickbare Objekte.
