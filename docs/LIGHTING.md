# Founder Sim — Lighting / Atmosphere

## Visuelle Referenzen

Die Zielrichtung ist bewusst bildgetrieben, nicht effektgetrieben:

- `docs/reference/atmosphere_target_start.jpg` — Ziel fuer einen glaubwuerdigen, spielbaren Arbeitsplatz in der fruehen Firmenphase.
- `docs/reference/atmosphere_target_late.jpg` — Ziel fuer spaetere Nacht-/Premium-Atmosphaere, besonders Monitorlicht, lokale Lampe und Stadtwirkung.
- `docs/reference/sunlight_target.jpg` — Ziel fuer direktes Sonnenlicht im leeren Raum: breite, weiche, helle Fensterprojektion auf Wand/Boden statt weisser Neonlinien.

Die Referenzen sind **keine Runtime-Assets**. Sie liegen nur unter `docs/reference/`.

## V4: Clean light rebuild

V4 entfernt den misslungenen V3-Test-Workspace und alle sichtbaren Fake-Sun-Beam-Linien. Der leere Referenzraum ist wieder die einzige sichtbare Environment-Basis.

### Lichtsystem

- `CanvasModulate`: globale Tages-/Nachtbelichtung.
- `PointLight2D` `WindowBounceLight`: weiches Licht direkt um das Fenster und auf die angrenzende Wand.
- `PointLight2D` `SunProjectionLight`: breite zweigeteilte Fensterprojektion, deren Textur **zur Laufzeit erzeugt** wird. Es gibt dafuer kein dekoratives Sonnenstrahl-PNG und keinen weissen Linien-Shader.
- `PointLight2D` `RoomFillLight`: nur ein optionaler Developer-Fill zum Testen; standardmaessig aus.
- `ExteriorResponse`: nur eine fensterbegrenzte Abdunklung, weil die City-View noch im Room-PNG eingebrannt ist.
- `DynamicLights` / `DynamicOccluders`: Hooks fuer spaetere echte Objektlichter und Schatten.

Der Sonnenlicht-Node sitzt am Fenster. Seine Light2D-Textur wird mit `offset` nach unten auf Wand/Boden projiziert. Der Licht-Node selbst bleibt am Fenster, damit spaetere `LightOccluder2D`-Schatten von der richtigen Quelle berechnet werden koennen.

## Keine automatischen Moebel

Verbindliche Regel ab V4:

> Das Atmosphaeren-/Lighting-System fuegt niemals selbst Moebel, Geraete oder dekorative WORLD-Assets in einen Raum ein.

Neue sichtbare Objektassets werden erst nach expliziter Freigabe des konkreten Assets in die Szene gesetzt. Lighting darf dagegen bereits generische Schnittstellen fuer spaetere Emitter/Occluder vorbereiten.

## Objekt-Lichtvertrag

Spaetere Placeable Objects koennen unabhaengig deklarieren:

```text
receives_light: true/false
casts_shadow: true/false
emissive: true/false
emitter_category: monitor / desk_lamp / phone / ambient / ...
```

Technisch:

- normale Sprite-/Control-Visuals empfangen `Light2D`, sofern ihre Light-Mask passt,
- Schattenwerfer erhalten `LightOccluder2D` + `OccluderPolygon2D`,
- selbstleuchtende Objekte verwenden `RoomLightEmitter2D` oder einen kompatiblen `Light2D`-Emitter,
- `DynamicLights` und `DynamicOccluders` sind dafuer bereits im RoomLightingRig vorhanden.

## Developer Atmosphere Controller

`F10` blendet das Panel ein oder aus. V4 testet nur noch Werte, die im leeren Raum sinnvoll beurteilbar sind:

- Tageszeit,
- Wetter,
- optionaler Room Fill (Dev),
- Sonnenlichtstaerke,
- Fenster-Bounce,
- beschleunigter 24h-Zyklus.

Keine Lampen-/Monitor-Regler, solange solche Objekte nicht freigegeben und tatsaechlich im Raum vorhanden sind.

## Naechster Atmosphaeren-Meilenstein

Die City-View steckt weiterhin in `room_shell_neutral.png`. Fuer echte Nachtfenster, Himmel, Regen und Stadtlicht muss die Environment spaeter in Interior und Exterior getrennt werden. Bis dahin werden keine zufaelligen prozeduralen Stadtfenster ueber das bestehende Bild gelegt.
