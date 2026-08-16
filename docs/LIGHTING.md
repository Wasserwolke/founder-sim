# Founder Sim — Lighting / Atmosphere

## Ziel

Der Referenzraum soll Licht sichtbar und raeumlich glaubwuerdig vermitteln. Farbe und Helligkeit allein reichen nicht: Fenster, direkte Sonnenbahnen, lokale Lampen, Monitorlicht und spaetere Schatten muessen als getrennte Systeme reagieren.

## V3: Hybrid aus Godot-2D-Licht und art-directed Atmosphaere

V3 verwendet erstmals Godots echte 2D-Lichtbausteine als Fundament und behaelt Shader nur dort, wo die frontale 2D-Illustration eine bewusst gestaltete Projektion braucht.

### Echte Godot-Lichtbausteine

- `CanvasModulate`: Grundbelichtung und Farbtemperatur des gesamten Raum-Canvas.
- `DirectionalLight2D`: Sonnenrichtung und allgemeines direktes Sonnenlicht; bereits shadow-ready fuer spaetere Occluder.
- `PointLight2D` am Fenster: lokales Fenster-/Key-Light, das echte `Light2D`-Empfaenger beeinflusst.
- `PointLight2D` an Objekten: Tischlampe, Monitore und spaetere emissive Gegenstaende.
- `LightOccluder2D`: Schattenvertrag fuer Moebel und Architektur.

### Art-directed Fensterprojektion

Die aktuelle Room-Shell ist eine frontale Einzelgrafik. Ein rein physikalisches 2D-Licht kann deshalb die Perspektive eines durch ein Wandfenster fallenden Sonnenstrahls nicht vollstaendig ableiten. `SunBeams` bleibt deshalb vorerst ein Shader-Layer, ist ab V3 aber strikt am unteren Fensteraustritt verankert:

- drei schmale helle Kerne mit weichem Halo,
- ca. wenige Pixel sichtbarer Kern bei Referenzaufloesung,
- keine Lichtbahnen oberhalb bzw. links/rechts frei durch Waende,
- Strahlen bewegen sich mit dem Sonnenstand,
- ein deutlicher Boden-Hotspot folgt derselben Richtung,
- Clear/Cloudy/Rain beeinflusst die Intensitaet.

Der Shader ist damit eine Projektion des echten Sonnenzustands, kein unabhaengiger Fake-Filter.

## Referenz-Workspace

V3 fuegt einen ersten Atmosphaeren-Workspace in den Raum ein. Er dient noch nicht als Gameplay-Objektsystem, sondern als Licht-Testbett:

- bestehendes Starter-Desk-WORLD-Asset,
- Dual-Monitor-WORLD-Asset,
- Keyboard und Chair,
- eingeschaltete Monitor-Glow-Emitter,
- provisorische Tischlampe mit echtem `PointLight2D`,
- erster `LightOccluder2D` fuer die Schreibtischzone.

Damit kann Licht ab jetzt an realen Gegenstaenden beurteilt werden statt nur in einem leeren Raum.

## Objekt-Lichtvertrag

Jedes spaetere Placeable Object kann unabhaengig diese Faehigkeiten besitzen:

```text
receives_light: true/false
casts_shadow: true/false
emissive: true/false
emitter_category: monitor / desk_lamp / phone / ambient / ...
```

Technisch:

- normale Sprite-/Control-Visuals empfangen `Light2D`, sofern ihre Light-Mask passt,
- Schattenwerfer erhalten `LightOccluder2D` + `OccluderPolygon2D`,
- selbstleuchtende Objekte verwenden `RoomLightEmitter2D` mit einem `Light2D`-Kind,
- Emitter registrieren sich automatisch beim `RoomLightingRig`,
- Kategorien koennen zentral aktiviert und in der Staerke skaliert werden.

Damit kann spaeter ein Mod-Objekt dieselbe Lichtlogik nutzen, ohne das LightingRig umzuschreiben.

## Developer Atmosphere Controller

`F10` blendet das Panel ein oder aus. V3 kann live testen:

- Tageszeit,
- Wetter,
- globalen Room Fill,
- Sun Beams bis 300%,
- City Lights,
- Tischlampe an/aus + Staerke,
- Monitor Glow an/aus + Staerke,
- beschleunigten 24h-Zyklus.

Empfohlene Referenzpunkte:

- 07:00 Clear: harte Morgenstrahlen und warmer Boden-Hotspot,
- 12:30 Clear: helles Fenster, deutlich weniger dramatische Beams,
- 18:00 Clear: flache warme Abendstrahlen,
- 22:30 Clear: Stadtlichter, Monitorlicht und Tischlampe dominieren,
- Rain: direkte Sonne stark reduziert, lokale Lichtquellen gewinnen an Bedeutung.

## Naechste Atmosphaerenstufe

Die aktuelle City-View steckt noch fest in `room_shell_neutral.png`. Der naechste grosse Atmosphaeren-Meilenstein ist deshalb die Trennung in:

```text
Room Interior
├─ Window opening / mask
├─ Exterior / City View
├─ Weather layer
├─ Placeable Objects
└─ LightingRig
```

Danach koennen Himmel, Wolken, Regen und Stadtlichter unabhaengig vom Innenraum animiert werden.
