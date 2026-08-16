# Godot + GitHub Workflow

## Einmalig auf Linux
1. Repository klonen.
2. Im Clone `./scripts/linux/setup_and_open.sh` ausfuehren. Das installiert Godot 4.7.1 Standard lokal unter `.tools/godot/`, falls noch kein Godot gefunden wird.
3. Das Projekt oeffnet sich direkt ueber `project.godot` im Repository-Root.
4. Optional das offizielle Godot Git Plugin aus dem Asset Store installieren.
5. In Godot: `Project -> Version Control -> Version Control Settings -> GitPlugin -> Connect to VCS`.

Founder Sim nutzt GDScript, daher ist die Standard-Ausgabe von Godot ausreichend.

## Alltag
- Projekt oeffnen: `./scripts/linux/open_godot.sh`
- Szenen, Nodes und GDScript direkt in Godot bearbeiten.
- Diffs, Stage/Unstage und Commits koennen ueber das VCS-Dock erfolgen.
- Pull/Push/Fetch sind im Git Plugin vorgesehen; fuer lange Netzwerkoperationen bleibt das Terminal ein sinnvoller Fallback.
- `.godot/`, Exporte und Builds werden nicht committet.

## Repository-Layout
`project.godot` und `game/` sind die Godot-Runtime. Die bisherige Web-Runtime unter `app/web/` bleibt waehrend der Migration als Referenz bestehen und wird von Godot ueber `.gdignore` ausgeblendet.

## Architekturregel
Die Environment-Grafik ist nur die Shell. Gameplay-Zustand, Licht, Objekte, UI und Interaktionen werden als separate Godot-Nodes/Resources gepflegt. Dadurch bleibt die Darstellung austauschbar, testbar und spaeter modding-faehig.
