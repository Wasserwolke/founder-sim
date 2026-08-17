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
- `PointLight2D` `WindowSunGlowLight`: direktes, sonnengekoppeltes Aufhellen von Glas, Rahmen und unmittelbarer Fensterumgebung.
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
- Dawn/Dusk werden waermer, Cloudy/Rain reduzieren die direkte Sonne.

`SunlightProjection2D` zeichnet die beiden Projektionen additiv mit einem hellen Kern und weicher werdenden Kanten erst **nach** der Fensterapertur. Die Startkante selbst wird nicht verbreitert; dadurch kann direktes Sonnenlicht optisch nicht neben dem Glas durch die Wand treten.

Das Window-Bounce-Licht bleibt davon getrennt. Es darf die Wand um das Fenster weich aufhellen, stellt aber kein direktes Sonnenlicht dar.

## V4.3: Animationsstabile Geometrie + Fensterbelichtung

Die beschleunigte 24h-Animation darf die Sonnenprojektion nicht hinter der simulierten Uhrzeit herziehen. Deshalb werden Richtung und Projektionslaenge der direkten Sonne pro Frame exakt aus der aktuellen Uhrzeit berechnet und ohne zusaetzliche Geometrie-Easing-Stufe angewendet. So entspricht dieselbe Uhrzeit bei manueller Einstellung und bei laufender Animation derselben Lichtposition.

Direkte Sonne wirkt ausserdem nicht mehr nur als Boden-/Wandprojektion. `WindowSunGlowLight` ist ein echtes `PointLight2D`, das mit derselben Sonnenstaerke, Wetterlage und Farbtemperatur arbeitet und dadurch Glas, Rahmen und den unmittelbaren Fensterbereich heller erscheinen laesst.

## V4.4: Pixelkalibrierte Apertur, Ost-West-Bewegung und Hoehen-Receiver

Die Apertur wurde nicht mehr visuell geschaetzt, sondern direkt am exakten Runtime-Asset `room_shell_neutral.png` (1672 x 941) analysiert. Die Repository-Datei und die zur Analyse verwendete Originaldatei besitzen denselben Git-Blob-SHA.

Pixelkalibrierung der unteren sichtbaren Glaskante:

```text
linke Scheibe:  (525, 431) -> (821, 431)
rechte Scheibe: (839, 431) -> (1126, 431)
```

`y = 431` ist die letzte sichtbare Glaszeile; `y = 432` gehoert bereits zum dunklen unteren Rahmen. Direkte Sonne beginnt deshalb exakt an `y = 431`.

Die horizontale Tagesbewegung ist jetzt bewusst umgedreht:

- morgens / Osten: Projektion laeuft nach rechts in den Raum,
- mittags: Projektion liegt nahezu zentral und wird kuerzer/steiler,
- abends / Westen: Projektion laeuft nach links in den Raum.

Bei niedriger Sonne wird die Projektion deutlich laenger und flacher als zuvor. Dadurch kann spaetes Licht bis in den Vordergrund und auf die bereits im Background vorhandenen Moebel reichen.

### Baked receiver surfaces

Da Sofa, Couchtisch, kleines Seitenmoebel und rechtes Buecherregal bereits fest in `room_shell_neutral.png` enthalten sind, koennen sie in 2D nicht automatisch eine echte Hoehe besitzen. V4.4 hinterlegt deshalb ausschliesslich fuer diese bereits vorhandenen Bildobjekte Receiver-Polygone. Es werden **keine neuen sichtbaren Assets** hinzugefuegt.

Jede Receiver-Flaeche verwendet dieselbe Sonnenrichtung, aber eine eigene kuerzere Projektionsdistanz. Dadurch trifft derselbe Strahl eine erhoehte Moebelflaeche frueher als den Boden. Der Boden-Lichtkeil wird gleichzeitig in den entsprechenden Moebelbereichen ausgespart, damit die Hoehenprojektion nicht einfach ueber einer falschen Bodenprojektion liegt.

Die Receiver sind im Inspector editierbar und koennen mit `Debug Draw Receivers` sichtbar gemacht werden. Das ist die bewusst letzte auf den aktuellen fest gerenderten 2D-Raum zugeschnittene Perspektivkorrektur; fuer frei platzierbare spaetere Objekte bleibt `DynamicLights` / `DynamicOccluders` die allgemeine Schnittstelle.

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

V4.4 ist der Abschlussversuch fuer die aktuell fest gerenderte 2D-Raumprojektion. Nach visueller Bewertung wird entschieden, ob die weitere Raumarchitektur 2D bleibt oder auf eine 3D-Szene mit weiterhin fixer/frontaler Kamera umgestellt wird. Eine 3D-Umstellung wuerde insbesondere Sonnenrichtung, Oberflaechenhoehen, Schattenwurf und neu platzierbare Moebel systemisch statt ueber gebackene Receiver loesen.

Die City-View steckt weiterhin in `room_shell_neutral.png`. Fuer echte Nachtfenster, Himmel, Regen und Stadtlicht muss die Environment bei einem Verbleib in 2D spaeter in Interior und Exterior getrennt werden.
