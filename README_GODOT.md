# Founder Sim - Godot migration baseline

Dieser Stand verlagert die aktive Founder-Sim-Entwicklung nach Godot 4. Der bisherige Browser-Prototyp kann im Repository vorerst als Legacy-/Referenzstand liegen bleiben, waehrend die neue Runtime Godot-nativ aufgebaut wird.

## Architektur
- `project.godot` liegt im Repository-Root: ein Git-Clone kann direkt in Godot importiert werden.
- Die neutrale Raumgrafik ist eine feste Environment-Shell.
- Lichtstimmung, HUD, Interaktionen und spaetere Moebel liegen als separate Godot-Nodes bzw. GDScript darueber.
- Schreibtisch, Stuhl, Monitore, Lampen, Firmenausstattung und spaetere Upgrades werden nicht in den Hintergrund eingebrannt.
- Gameplay-Zustand liegt in Godot (`GameState`) und wird schrittweise aus dem Browser-Prototyp migriert.

## Linux: direkt starten

Wenn Godot noch nicht vorhanden ist, reicht fuer den ersten Start ein Befehl:

```bash
./scripts/linux/setup_and_open.sh
```

Das Skript installiert die gepinnte Standard-Version lokal unter `.tools/godot/` ohne sudo und startet anschliessend das Projekt. Spaeter reicht:

```bash
./scripts/linux/open_godot.sh
```

Alternativ `project.godot` im Godot Project Manager importieren.

Founder Sim verwendet GDScript. Die Standard-Ausgabe von Godot reicht; die .NET-Ausgabe wird fuer diesen Stand nicht benoetigt.

## Aktueller Godot-Stand
- neutrale Raum-Shell `game/assets/environments/room_shell_neutral.png`
- Referenz-Viewport 1672x941, passend zur Shell
- responsive Fenster-Skalierung mit beibehaltenem Seitenverhaeltnis
- GL Compatibility Renderer als konservativer Desktop-/Web-Baseline-Renderer
- Autoload `GameState`
- Ressourcen: Geld, Einnahmen, Ausgaben, Energie, Fokus, Gesundheit
- simulierte Uhrzeit
- einfache dynamische Dunkelheit anhand der Uhrzeit
- Godot-HUD als echte Control-Nodes
- erste Raum-Hotspots fuer Tuer, Fenster, Regale und freie Stellflaeche
- robuster Fallback, falls die externe Room-Shell-Datei fehlt

## Migration ab hier
1. Schreibtisch, Stuhl, Monitore, Tastatur und vorhandene Assets als einzelne Godot-Nodes migrieren.
2. Desk-Focus Godot-nativ als Kamera-/Viewport-Zustand aufbauen.
3. stabile `foundersim:`-Objekt-IDs und Interaktionsaktionen in Godot Resources uebernehmen.
4. Savegame, Ereignissystem, Zeitablauf und Simulation in Godot als autoritative Runtime aufbauen.
5. Browser-Runtime danach nur noch als eingefrorene Referenz behalten bzw. spaeter entfernen.
