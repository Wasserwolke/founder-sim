# Founder Sim

Realistischer, modularer Unternehmensgruendungssimulator.

Aktueller Entwicklungsstand: **v0.9 - Godot-Migration gestartet**. Die aktive Runtime wird ab jetzt Godot-nativ aufgebaut. Der bisherige Browser-Prototyp bleibt waehrend der Migration als Legacy-/Referenzstand erhalten.

## Godot auf Linux - ein Befehl

```bash
git clone https://github.com/Wasserwolke/founder-sim.git
cd founder-sim
./scripts/linux/setup_and_open.sh
```

`setup_and_open.sh` installiert bei Bedarf die gepinnte Godot-Standardversion lokal unter `.tools/godot/` ohne sudo und oeffnet direkt das Projekt im Repository-Root. Danach reicht normalerweise:

```bash
./scripts/linux/open_godot.sh
```

Founder Sim verwendet GDScript; eine .NET-/C#-Installation ist fuer diesen Stand nicht erforderlich.

## Neue Godot-Runtime

- `project.godot` direkt im Repository-Root
- `game/` als neue aktive Runtime
- neutrale Raum-Shell als wiederverwendbares Environment
- Licht, HUD, Interaktionen und spaetere Moebel als getrennte Godot-Nodes
- Autoload `GameState` fuer Geld, Einnahmen, Ausgaben, Energie, Fokus, Gesundheit und simulierte Zeit
- dynamische Dunkelheit anhand der Tageszeit
- erste Raum-Hotspots fuer Tuer, Fenster, Regale und freie Stellflaeche
- CI startet und prueft die Godot-Runtime headless mit Godot 4.7.1

Die vollstaendige neutrale 1672x941-Raumgrafik wird als `game/assets/environments/room_shell_neutral.png` verwendet. Das separate Godot-Projektpaket enthaelt sie bereits. Ohne diese Datei startet die Runtime bewusst mit einem neutralen Fallback und deaktivierten Raum-Hotspots.

Weitere Details: `README_GODOT.md` und `docs/GODOT_WORKFLOW.md`.

## Git direkt in Godot

Das offizielle Godot Git Plugin kann im Editor als VCS-Backend verbunden werden. Damit sind Diffs, Stage/Unstage und Commits direkt im Godot-Workflow moeglich; Pull/Push/Fetch werden ebenfalls unterstuetzt. Das normale Terminal-Git bleibt fuer grosse Netzwerkoperationen als Fallback sinnvoll.

## Legacy-Web-Prototyp

Der bisherige Stand unter `app/web/` bleibt vorerst unveraendert als Referenz bestehen und wird weiterhin unter

https://wasserwolke.github.io/founder-sim/

bereitgestellt. Godot blendet die Legacy-Verzeichnisse ueber `.gdignore` aus, damit der FileSystem-Dock auf die neue Runtime fokussiert bleibt.

Der Legacy-Stand v0.8 enthaelt unter anderem den Desk-Focus mit acht Interaktionsobjekten, Lager, Karte, HUD, datengetriebene ObjectRegistry und Mod API v1. Diese Systeme werden schrittweise Godot-nativ uebernommen und danach nicht mehr parallel weiterentwickelt.

## Architekturregel ab v0.9

```text
Environment-Shell
  + Godot Scene/Nodes
  + stabile foundersim:-IDs
  + Gameplay-State / Events
  + UI / Licht / Kamera
  + austauschbare Assets
```

Spielregeln, Preise, Besitz, Zustand und Effekte gehoeren in Daten/Code. Grafiken bleiben Darstellung und werden nicht zur Quelle fuer Gameplay-Zustand.
