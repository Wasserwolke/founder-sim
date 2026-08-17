# Room Shell Geometry Reference

Quelle: `game/assets/environments/room_shell_neutral.png`

Referenzaufloesung: **1672 x 941 px**. Alle Koordinaten in diesem Dokument beziehen sich direkt auf diese Pixelkoordinaten und dienen der 2D-Lichtprojektion. Sichtbare Objektgrafiken werden dadurch nicht veraendert.

## Grundregel

**Gameplay-Hotspots sind niemals Render-Geometrie.** Die anklickbaren Flaechen `Door`, `LeftShelves`, `Window`, `Bookcase`, `Floor` dienen nur der Interaktion. Licht-Receiver werden ausschliesslich anhand der tatsaechlich sichtbaren Pixelkonturen von `room_shell_neutral.png` definiert.

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

Diese planare Flaeche bekommt weiterhin einen eigenen Hoehen-Receiver.

### Sofa links und gruener Polster

Die sichtbare Couch ist perspektivisch gekippt und besteht aus mehreren gekruemmten beziehungsweise unterschiedlich orientierten Flaechen. Der gruene Polster liegt nochmals auf einer anderen Hoehe und Neigung.

Fruehere Versuche mit separaten flachen Receiver-Polygonen erzeugten kleine unplausible Licht-/Schattenkanten. Deshalb bekommen Sofa und Polster im **finalen 2D-Pass keinen eigenen direkten Sonnen-Receiver mehr**. Sie erhalten weiterhin Ambient-/Fenster-Bounce-Licht. Damit wird kein falsches 2D-Schattenmodell vorgetaeuscht.

Die grobe sichtbare Silhouette bleibt als Referenz fuer den spaeteren 3D-Umbau relevant, wird aber nicht mehr fuer direkte 2D-Projektion verwendet.

### Couchtisch vorne links

Sichtbare Tischplatte:

`[(24,817), (441,817), (363,941), (0,941)]`

Die hintere Tischkante liegt bei etwa `y = 817`. Der Boden-Receiver endet vor dieser Flaeche; die Tischplatte bekommt einen eigenen Hoehen-Receiver.

### Buecherregal rechts

Die fruehere grosse rechteckige Flaeche entsprach optisch zu stark dem Gameplay-Hotspot und nicht der tatsaechlichen Deckflaeche. Fuer den finalen 2D-Pass wird nur die **sichtbare obere Deckflaeche** verwendet:

`[(1405,409), (1546,409), (1672,446), (1672,466), (1405,431)]`

Der sichtbare obere Rueck-/Randverlauf beginnt bei etwa `(1405,409)`, die vordere linke Kante endet bei etwa `(1405,431)`, und die perspektivische Vorderkante laeuft bis zum rechten Bildrand um `y = 466`. Die darunterliegende Regalfront bekommt keinen eigenen direkten Receiver.

## Boden-/Wandflaechen

Die Grundprojektion wird um eingebrannte Moebel herum in mehrere Receiver geteilt. Ziel ist, dass kein Bodenlicht einfach ueber eine bereits gerenderte Moebelflaeche gemalt wird.

Der Couchbereich links und das rechte Regal werden von den Bodenflaechen ausgespart. Direkte Sonne auf eindeutig planaren Oberflaechen wird separat gezeichnet; komplexe gekruemmte Objekte bleiben beim finalen 2D-Stand beim allgemeinen Fenster-/Ambientlicht.

Die Werte leben in `game/scripts/room/sunlight_projection.gd`. Dieses Dokument ist die visuelle Referenz und soll bei einer Aenderung der Room-Shell gemeinsam mit dem Script aktualisiert werden.

## Regel fuer spaetere Assets / 3D

Diese Sonderkoordinaten gelten nur fuer die fest in `room_shell_neutral.png` eingebrannten Gegenstaende. Sie sind bewusst der Endpunkt des 2D-Prototyps.

Neue freigegebene Assets sollen nicht weitere feste Sonderpolygone erzeugen. Fuer den geplanten 3D-Vergleich sollen Moebel echte Mesh-/Collider-/Shadow-Geometrie mitbringen, waehrend die Kamera weiterhin eine feste, spielerisch nahezu 2D-artige Raumansicht liefern kann.
