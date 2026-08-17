# Founder Sim 2.5D / 3D Lighting Prototype

## Ziel

Dieser Prototyp prueft bewusst nur die technische Kernfrage: Kann Founder Sim wie ein fast flaches 2D-Bild wirken, waehrend Raumtiefe, Fenster, Moebel, Sonnenlicht und lokale Lichtquellen echte 3D-Geometrie benutzen?

Die bestehende 2D-Runtime bleibt unangetastet. Der Prototyp liegt separat unter `game/scenes/prototypes/room_25d_prototype.tscn`.

## Aufruf

Im Debug-Build schaltet `F9` global zwischen `main.tscn` und dem 2.5D-Prototyp um. Im Prototyp fuehrt `Esc` ebenfalls zurueck zur Hauptszene.

Weitere Testtasten:

- `1` Morgen (07:00)
- `2` Mittag (12:30)
- `3` Abend (18:12)
- `4` Nacht (22:00)
- `Space` 24h-Animation an/aus

Zeit und Sonnenstaerke sind zusaetzlich direkt im eingeblendeten Testpanel regelbar.

## Technische Architektur

- echte `MeshInstance3D`-Raumgeometrie
- echtes Fenster als Oeffnung in der Rueckwand, nicht als Lichtmaske
- echter Mittelsteg und Fensterrahmen, die Schatten werfen
- feste orthografische `Camera3D`, damit Entfernung die Objektgroesse nicht perspektivisch veraendert
- `DirectionalLight3D` fuer parallele Sonnenstrahlen
- `SpotLight3D` als warme Tischlampen-Probe
- `OmniLight3D` als schwacher Monitor-Glow
- `SubViewport` mit 836 x 470 interner Aufloesung und Nearest-Scaling als erster Pixel-/2.5D-Presentation-Test
- vorhandener `GL Compatibility`-Renderer bleibt vorerst erhalten, damit der Test auf dem aktuellen Linux-Setup keine Renderer-Migration erzwingt

## Wichtige Grenze

Die sichtbaren Moebel sind ausschliesslich grobe primitive Testgeometrie. Sie sind keine freigegebenen Founder-Sim-Assets und sollen nur zeigen, wie Licht und Schatten auf echte Hoehe und Tiefe reagieren. Falls die 3D-/2.5D-Richtung ueberzeugt, werden Raum- und Asset-Pipeline danach bewusst neu geplant.

## Entscheidung nach dem Test

Der Prototyp soll vor allem vier Fragen beantworten:

1. Fuehlt sich die orthografische Kamera weiterhin wie ein 2D-Bild an?
2. Wirkt das Sonnenlicht durch das echte Fenster sofort plausibler als die handkalibrierte 2D-Projektion?
3. Reagieren Tisch, Sofa, Monitor und lokale Lampe auf Licht/Schatten so, dass neue Assets spaeter weniger Sonderlogik benoetigen?
4. Ist die niedrig aufgeloeste 3D-Darstellung eine brauchbare Basis fuer den gewuenschten Pixel-Art-/2.5D-Look?

Wenn die Antwort grundsaetzlich nein ist, wird dieser Prototyp verworfen und die Architektur von null neu aufgebaut. Er ist absichtlich isoliert und veraendert die bestehende 2D-Szene nicht.
