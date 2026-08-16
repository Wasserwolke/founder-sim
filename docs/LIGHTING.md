# Lighting System

## Ziel

Das Lighting-System ist ein wiederverwendbares Raum-Modul. Es soll Atmosphaere erzeugen, ohne die Spielobjekte fest an eine bestimmte Tageszeit oder ein bestimmtes Licht zu binden.

V1 etablierte die Grundschichten. V2 fuegt sichtbare Lichtwege und eine reagierende Aussenwelt hinzu. Spaetere Versionen erweitern das um echte `Light2D`-Emitter, Occluder, getrennte Exterior-Layer und optional Normal Maps.

## V2-Schichten

`RoomLightingRig` setzt sich aus folgenden visuellen Schichten zusammen:

- `AmbientShade`: kuehle Grundabdunklung fuer Abend/Nacht und schlechtes Wetter.
- `ExteriorResponse`: dunkelt nur den Fenster-/Aussenbereich zusaetzlich ab und faerbt ihn wetter-/tageszeitabhaengig.
- `Warmth`: warmer Golden-Hour-Ton bei Morgen- und Abendlicht.
- `WindowWash`: additive Fensterhelligkeit und weicher Halo am Fenster.
- `SunBeams`: mehrere gerichtete Lichtbahnen plus Wand- und Bodenflecken; Position und Richtung wandern mit der Tageszeit.
- `CityLights`: erste prozedurale Abend-/Nachtlichter im Fensterbereich als Prototyp, bis City-View und Room-Shell getrennt sind.
- `RoomLightWash`: warmer kuenstlicher Raumlicht-Prototyp.
- `Vignette`: sehr dezente Randabdunklung fuer Tiefe und Fokus.
- `DynamicLights`: reservierter Node fuer spaetere `Light2D`-Emitter von Items.

Uebergaenge werden weich interpoliert, statt Lichtzustand hart umzuschalten.

## Tagesbewegung des Sonnenlichts

Die V2-Sonnenbahnen sind bewusst geometrisch sichtbar. Sie sind kein physikalischer Raytracer, sondern ein Art-Directed-Prototyp fuer die spaetere Raumbeleuchtung:

- Sonnenposition wird aus der Uhrzeit abgeleitet.
- Lichtbahnen wandern horizontal durch den Raum und aendern dabei ihre Neigung.
- Morgens und abends sind direkte Lichtbahnen staerker sichtbar; mittags bleibt der Effekt dezenter.
- Bewoelkung und Regen reduzieren direktes Sonnenlicht stark.
- Wand- und Bodenlicht folgen derselben Sonnenposition, damit der Raum nicht nur global eingefaerbt wirkt.

Spaeter kann jeder Raum ein eigenes Lighting-Profil mit Fensterposition, Sonnenrichtung, Intensitaet und Masken bekommen.

## Aussenwelt / Fenster

Die aktuelle neutrale Room-Shell enthaelt die Stadt noch fest im PNG. V2 simuliert deshalb zusaetzlich:

- selektive Abdunklung nur innerhalb des Fensters,
- kalte Nacht-/Wetterfaerbung,
- prozedurale warme und kuehle Stadtlichter ab der Daemmerung.

Das ist ein Zwischenzustand. Das Ziel bleibt eine echte Trennung:

```text
Room Interior
├─ Window Mask
├─ Exterior / City View
├─ Weather Layer
└─ LightingRig
```

Dann koennen Himmel, Stadtlichter, Regen, Wolken und Innenraumlicht unabhaengig voneinander reagieren.

## Developer Atmosphere Controller

Im Debug-Build erscheint ein Live-Panel. `F10` blendet es ein oder aus.

Einstellbar:

- Uhrzeit 00:00–24:00
- Clear / Cloudy / Rain
- Raumlicht an/aus
- Raumlichtstaerke
- Sonnenstrahlen-Multiplikator
- Stadtlicht-Multiplikator
- animierter 24h-Zyklus
- Dauer des Test-Tages
- Reset auf simulierte GameState-Zeit

Zusaetzlich ist `RoomLightingRig` ein `@tool`-Script. In Godot kann der LightingRig-Node im lokalen Scene Tree ausgewaehlt und ueber die Gruppe `Editor Preview` direkt im Inspector getestet werden. Dort stehen ebenfalls Sun-Ray- und City-Light-Multiplikatoren zur Verfuegung.

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
- Placeable Objects werden so in den Scene Tree einsortiert, dass Atmosphere-Washes sie mit beeinflussen koennen; echte lokale Lichtquellen und Schatten laufen spaeter ueber `Light2D`/Occluder.

Damit kann derselbe Tisch bei Tageslicht, Nacht, Lampenlicht oder in einem anderen Raum glaubwuerdig reagieren.

## Asset-Regel

WORLD-Assets werden moeglichst neutral beleuchtet erstellt:

- keine starke fest eingebrannte Sonne
- keine harte Lichtfarbe, die nur zu einer Tageszeit passt
- transparenter Hintergrund fuer Einzelobjekte
- Material/Volumen sichtbar, aber Beleuchtung zurueckhaltend
- Emission (Monitor, LED, Lampe) als Zustand oder separater Layer

Die aktuelle Raum-Shell besitzt noch gebackene Bildinformationen. Sie bleibt fuer den Prototyp brauchbar. Nach dem Lighting-Tuning werden Innenraum und Fenster-/City-View getrennt, damit Wetter, Nachtlichter und Tageszeit unabhaengiger steuerbar sind.

## Wiederverwendung in weiteren Szenen

Jeder neue Raum kann dieselbe LightingRig-Szene instanzieren und ein eigenes Lighting-Profil bekommen. Auch Map-/Stadtansichten folgen demselben Grundprinzip: Environment + Atmosphaere + anklickbare Objekte. Der aktuelle Raum dient als Referenzraum, an dem diese Architektur zuerst vollstaendig ausgereift wird.
