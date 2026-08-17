# Founder Sim — Lighting / Atmosphere

## Visuelle Referenzen

Die Zielrichtung ist bewusst bildgetrieben, nicht effektgetrieben:

- `docs/reference/atmosphere_target_start.jpg` — Ziel fuer einen glaubwuerdigen, spielbaren Arbeitsplatz in der fruehen Firmenphase.
- `docs/reference/atmosphere_target_late.jpg` — Ziel fuer spaetere Nacht-/Premium-Atmosphaere, besonders Monitorlicht, lokale Lampe und Stadtwirkung.
- `docs/reference/sunlight_target.jpg` — Ziel fuer direktes Sonnenlicht im leeren Raum: breite, weiche, helle Fensterprojektion auf Wand/Boden statt weisser Neonlinien.

Die Referenzen sind **keine Runtime-Assets**. Sie liegen nur unter `docs/reference/`.

## V4: Clean light rebuild

V4 entfernt den misslungenen V3-Test-Workspace und alle sichtbaren Fake-Sun-Beam-Linien. Der leere Referenzraum ist wieder die einzige sichtbare Environment-Basis.

### Grundsystem

- `CanvasModulate`: globale Tages-/Nachtbelichtung.
- `PointLight2D` `WindowBounceLight`: weiches indirektes Licht direkt um das Fenster.
- `SunlightProjection2D`: direkte Sonnenprojektion durch die reale Fensterapertur.
- `PointLight2D` `RoomFillLight`: optionales Developer-Fill; standardmaessig aus.
- `ExteriorResponse`: fensterbegrenzte Abdunklung, solange die City-View noch im Room-PNG eingebrannt ist.
- `DynamicLights` / `DynamicOccluders`: Hooks fuer spaetere freigegebene Objektlichter und Schatten.

## V4.2: Zwei feste Glas-Aperturen, paralleler Sonneneinfall

Direkte Sonne wird nicht mehr als radiale `PointLight2D`-Quelle behandelt. Das war geometrisch falsch fuer Sonnenlicht und erzeugte den Eindruck einer Lichtquelle aus der Kamerarichtung.

Ab V4.2 gelten vier feste Punkte an der unteren sichtbaren Glaskante:

- linke Scheibe: `left_glass_start` -> `left_glass_end`
- rechte Scheibe: `right_glass_start` -> `right_glass_end`

Diese vier Punkte bleiben ueber den gesamten Tag unveraendert. Nur die Projektion hinter der Apertur veraendert sich.

Regeln:

- Licht beginnt ausschliesslich an der unteren Glaskante, nicht am Holz-/Aussenrahmen.
- Jede Scheibe erzeugt ihre eigene parallele Projektion.
- Der Mittelsteg ist die echte Luecke zwischen den beiden Projektionen und bleibt dadurch deutlich als Schatten lesbar.
- Die Aussenkanten bleiben an den Glasgrenzen fest; es gibt keinen radialen Faecher vom Fenstermittelpunkt.
- Niedrige Sonne -> lange Projektion weit in den Raum.
- Hohe Sonne -> kurze Projektion nah am Fenster.
- Die seitliche Tagesbewegung ist bewusst klein; Hauptanimation ist die Projektionslaenge durch die Sonnenhoehe.
- Dawn/Dusk werden waermer, Cloudy/Rain reduzieren die direkte Sonne.

`SunlightProjection2D` zeichnet die beiden Projektionen additiv mit einem hellen Kern und weicher werdenden Kanten erst **nach** der Fensterapertur. Die Startkante selbst wird nicht verbreitert; dadurch kann direktes Sonnenlicht optisch nicht neben dem Glas durch die Wand treten.

Das Window-Bounce-Licht bleibt davon getrennt. Es darf die Wand um das Fenster weich aufhellen, stellt aber kein direktes Sonnenlicht dar.

## Keine automatischen Moebel

Verbindliche Regel:

> Das Atmosphaeren-/Lighting-System fuegt niemals selbst Moebel, Geraete oder dekorative WORLD-Assets in einen Raum ein.

Neue sichtbare Objektassets werden erst nach expliziter Freigabe des konkreten Assets in die Szene gesetzt. Lighting darf generische Schnittstellen fuer spaetere Emitter/Occluder vorbereiten.

## Objekt-Lichtvertrag

Spaetere Placeable Objects koennen unabhaengig deklarieren:

```text
receives_light: true/false
casts_shadow: true/false
emissive: true/false
emitter_category: monitor / desk_lamp / phone / ambient / ...
```

Technisch:

- normale Sprite-/Control-Visuals koennen Licht empfangen,
- Schattenwerfer erhalten `LightOccluder2D` + `OccluderPolygon2D`,
- selbstleuchtende Objekte verwenden `RoomLightEmitter2D` oder einen kompatiblen `Light2D`-Emitter,
- `DynamicLights` und `DynamicOccluders` sind dafuer bereits im RoomLightingRig vorhanden,
- direkte Sonnenprojektion bleibt eine separate Fensterprojektion; bevor freigegebene Objekte hinzukommen, wird deren Occlusion gegen diese Projektion als eigener Schritt integriert.

## Developer Atmosphere Controller

`F10` blendet das Panel ein oder aus. Im leeren Raum relevant:

- Tageszeit,
- Wetter,
- optionaler Room Fill (Dev),
- Sonnenlichtstaerke,
- Fenster-Bounce,
- beschleunigter 24h-Zyklus.

## Naechster Atmosphaeren-Meilenstein

Die City-View steckt weiterhin in `room_shell_neutral.png`. Fuer echte Nachtfenster, Himmel, Regen und Stadtlicht muss die Environment spaeter in Interior und Exterior getrennt werden.
