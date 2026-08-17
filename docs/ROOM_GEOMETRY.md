# Room Shell Geometry Reference

Quelle: `game/assets/environments/room_shell_neutral.png`

Referenzaufloesung: **1672 x 941 px**. Alle Koordinaten in diesem Dokument beziehen sich direkt auf diese Pixelkoordinaten und dienen der 2D-Lichtprojektion. Sichtbare Objektgrafiken werden dadurch nicht veraendert.

## Fenster

Unterste sichtbare Glaszeile: `y = 431`. Ab `y = 432` beginnt der dunkle untere Rahmen.

- Linke Scheibe, untere Eintrittskante: `(525, 431) -> (821, 431)`
- Rechte Scheibe, untere Eintrittskante: `(839, 431) -> (1126, 431)`
- Oberkante der fuer Glare verwendeten Glasflaeche: `y = 47`

Die direkte Sonne startet ausschliesslich an diesen beiden unteren Glaskanten. Der Mittelsteg zwischen `x = 821` und `x = 839` bleibt lichtundurchlaessig.

## Bereits eingebrannte Moebel - relevante Lichtflaechen

### Kleines Seitenregal links

Obere sichtbare Deckflaeche:

`[(205,491), (350,491), (384,470), (239,470)]`

Die Projektion auf dieser hohen Flaeche verwendet einen kuerzeren Strahlweg als der Boden.

### Sofa links

Rechte Arm-/Sitzflaeche, die direktes Licht aufnehmen kann:

`[(176,636), (276,636), (278,804), (241,820), (192,844), (154,865), (154,813), (204,781), (219,742), (217,704)]`

### Gruenes Sofakissen

Sichtbare Kissenflaeche:

`[(35,632), (219,615), (302,691), (236,756), (114,780), (33,716)]`

### Couchtisch vorne links

Sichtbare Tischplatte:

`[(24,817), (441,817), (363,941), (0,941)]`

Wichtig: Die hintere Tischkante liegt bei etwa `y = 817`. Fruehere Receiver bei `y ~= 849` erzeugten einen sichtbar falschen Lichtabschnitt.

### Buecherregal rechts

Obere sichtbare Deckflaeche:

`[(1405,409), (1530,409), (1672,447), (1672,491), (1520,475), (1405,432)]`

Nur die obere Flaeche bekommt aktuell einen eigenen Hoehen-Receiver. Dadurch verschwindet der zuvor sichtbare kuenstliche horizontale Abschluss weiter unten am Regal.

## Boden-/Wandflaechen

Die Grundprojektion wird um eingebrannte Moebel herum in mehrere Receiver geteilt. Ziel ist, dass kein Bodenlicht einfach ueber eine bereits gerenderte Moebelflaeche gemalt wird.

Die pixelgenauen Werte leben aktuell in `game/scripts/room/sunlight_projection.gd`. Dieses Dokument ist die visuelle Referenz und soll bei einer Aenderung der Room-Shell gemeinsam mit dem Script aktualisiert werden.

## Regel fuer spaetere Assets

Diese Koordinaten gelten nur fuer die fest in `room_shell_neutral.png` eingebrannten Gegenstaende. Neue freigegebene Assets sollen ihre eigene Geometrie beziehungsweise in einer spaeteren 3D-Variante echte Mesh-/Collider-/Shadow-Geometrie mitbringen, statt weitere feste Sonderkoordinaten in diese Datei zu bekommen.
