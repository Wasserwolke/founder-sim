# Changelog

## v0.12
- Atmosphere/Lighting auf einen Hybrid aus echten Godot-2D-Lichtern und art-directed Fensterprojektionen umgebaut
- `CanvasModulate`, `DirectionalLight2D` und ein fensternahes `PointLight2D` als echte Lichtgrundlage eingefuehrt
- Sonnenstrahlen neu gestaltet: wenige schmale, kontrastreiche Kerne, die erst unterhalb des Fensters in den Raum treten und mit der Tageszeit wandern
- staerkeren Wand-/Boden-Hotspot an dieselbe Sonnenrichtung gekoppelt; Clear/Cloudy/Rain beeinflusst das direkte Sonnenlicht
- ersten Atmosphaeren-Workspace mit vorhandenen Desk-, Dual-Monitor-, Keyboard- und Chair-WORLD-Assets in den Referenzraum gesetzt
- provisorische Tischlampe mit echtem warmem `PointLight2D` sowie zwei kuehle Monitor-Glow-Emitter hinzugefuegt
- `RoomLightEmitter2D` als generischen, automatisch registrierenden Lichtvertrag fuer spaetere Assets und Mods eingefuehrt
- ersten `LightOccluder2D` am Arbeitsplatz angelegt und Objektvertrag fuer receives-light / casts-shadow / emissive dokumentiert
- Developer Atmosphere Controller um Tischlampen- und Monitorlicht-Regler erweitert; Sun-Beams lassen sich fuer das Tuning bis 300% fahren
- Roadmap auf Atmosphere-first aktualisiert; echte Trennung von Interior und Exterior/City-View bleibt der naechste grosse Atmosphaeren-Meilenstein
- Godot-CI verschaerft: Scene-/Script-/Runtime-Fehler in den Godot-Logs lassen den Build jetzt scheitern, auch wenn Godot selbst Exitcode 0 liefert
- Projektversion auf 0.12.0 erhoeht

## v0.11
- LightingRig v2 um selektive Aussen-/Fensterabdunklung erweitert, damit Nacht und Wetter nicht nur als globaler Raumfilter wirken
- mehrere gerichtete Sonnenbahnen plus Wand- und Bodenlicht hinzugefuegt; Position und Neigung wandern mit der Tageszeit
- direkte Sonnenstrahlen reagieren auf Clear/Cloudy/Rain und werden bei Golden Hour deutlich sichtbarer
- erste prozedurale Stadtlichter im Fensterbereich hinzugefuegt, die mit der Daemmerung einblenden
- Developer Atmosphere Controller um Live-Regler fuer Sonnenstrahlen und Stadtlichter erweitert
- Editor-Preview des LightingRig um dieselben Detail-Multiplikatoren erweitert
- Lighting-Dokumentation auf V2 aktualisiert und Trennung von Interior/Exterior als naechsten Atmosphere-Meilenstein festgehalten
- Godot-Roadmap um Referenzraum-Strategie und expliziten Lighting-Vertrag fuer spaetere Placeable Objects erweitert
- Projektversion auf 0.11.0 erhoeht

## v0.10
- primitives `Darkness`-Overlay durch ein wiederverwendbares `RoomLightingRig` ersetzt
- LightingRig als eigene Godot-Szene mit Ambient-, Golden-Hour-, Fensterlicht-, Raumlicht- und Vignette-Layern aufgebaut
- Lichtwechsel werden weich animiert statt hart umgeschaltet
- Tageslicht reagiert auf simulierte Uhrzeit; erste Clear/Cloudy/Rain-Stimmungen vorbereitet
- `DynamicLights`-Root und `register_emitter()` als Hook fuer spaetere itemgebundene `Light2D`-Emitter eingefuehrt
- Developer Atmosphere Controller mit Live-Slidern fuer Zeit, Wetter, Raumlicht, Lichtstaerke und animierten 24h-Zyklus hinzugefuegt
- F10 blendet den Atmosphere Controller im Debug-Build ein/aus
- `RoomLightingRig` als `@tool` ausgelegt, damit Lichtwerte auch direkt im Godot-Inspector vorab betrachtet werden koennen
- Asset-/Lighting-Vertrag fuer neutrale WORLD-Assets, LightOccluder2D-Schatten und emissive Items dokumentiert
- Godot-Roadmap und gemeinsamer Szenenvertrag fuer Raeume, Shops, Lager und Map-Ansichten dokumentiert
- Projektversion auf 0.10.0 erhoeht

## v0.9
- aktive Entwicklung von der Browser-Runtime auf Godot 4 umgestellt
- `project.godot` im Repository-Root eingefuehrt, damit ein Clone direkt als Godot-Projekt geoeffnet werden kann
- neue Godot-Runtime unter `game/` mit Szenen, GDScript, Daten und Environment-Struktur angelegt
- bisherige Kernressourcen Geld, Einnahmen, Ausgaben, Energie, Fokus und Gesundheit in einen Godot-Autoload `GameState` uebertragen
- simulierte Uhrzeit und einfache tageszeitabhaengige Abdunklung Godot-nativ umgesetzt
- HUD als echte Godot-Control-Nodes umgesetzt
- neutrale 1672x941-Raum-Shell als neue modulare Environment-Basis vorgesehen
- robuste Fallback-Darstellung eingebaut, falls die externe Room-Shell-Grafik in einem Clone noch fehlt
- erste Raum-Hotspots fuer Tuer, Fenster, Wandregale, Buecherregal und freie Moebelflaeche angelegt
- Linux-Skripte fuer lokalen Godot-4.7.1-Setup ohne sudo und direkten Projektstart hinzugefuegt
- GitHub-Actions-Validierung um echten Godot-4.7.1-Headless-Import und Runtime-Smoke-Test erweitert
- Legacy-Web-Prototyp bleibt waehrend der Migration als Referenz und GitHub-Pages-Preview bestehen
- Legacy-Unterordner werden ueber `.gdignore` aus dem Godot-FileSystem-Dock ausgeblendet

## v0.8
- Desk-Focus von 1.62x auf 1.90x vergroessert und fuer eine engere, weiterhin weiche Kamerafahrt neu zentriert
- Desk-Focus auf acht klar benannte Interaktionsobjekte erweitert: zwei Monitore, Notizbuch, Schluessel, Telefon, Kaffeetasse, Tastatur und Maus
- vorhandenes `keyboard_starter_01` WORLD-Asset als Tastatur-Overlay eingebunden
- linke und rechte Monitorflaeche als getrennte Background-Surface-Objekte vorbereitet, ohne die im Environment sichtbaren Monitore zu ueberdecken
- linker Monitor fuehrt in den spaeteren Operativbereich, rechter Monitor in den spaeteren Managementbereich
- Maus als sichtbarer funktionaler Placeholder angelegt, bis ein passendes WORLD-Asset existiert
- Hover-Feedback zwischen Pixel-Outline und Box-Outline getrennt und Glow bewusst subtil gehalten
- Tooltips kompensieren den Kamera-Zoom, damit ihre Schriftgroesse im Desk-Focus stabil bleibt
- Runtime-Validator um verbindliche Desk-Focus-Vertraege fuer acht Objekte, Monitorrollen, Keyboard-Asset und Maus-Placeholder erweitert
- Build- und Manifest-Version auf 0.8.0 erhoeht

## v0.7.1
- Desk-Objektkoordinaten anhand des real gerenderten Zoom-Screenshots neu kalibriert
- beide Monitor-Trefferflaechen nach oben und horizontal auf die sichtbaren Monitorflaechen ausgerichtet
- Kaffee, Telefon, Schluessel und Notizbuch auf die Tischflaeche angehoben
- Build-Token erhoeht, damit GitHub Pages die korrigierten Scene-Daten ohne alten Browser-Cache laedt

## v0.7
- `overview` und `desk` als animierte Kamera-Presets desselben Buero-Environments eingefuehrt
- Hintergrund und Objekt-Layer in einen gemeinsamen `cameraStage` verschoben
- Objekttyp (`type_id`) und konkrete Instanz (`instance_id`) sauber getrennt
- Core-Objekt-IDs auf namespaced Strings wie `foundersim:coffee_starter_white` umgestellt
- alte unqualifizierte Core-IDs werden automatisch kompatibel aufgeloest
- sichtbare funktionale Placeholders fuer noch fehlende Objektvisuals eingefuehrt
- bestehende Atlas-Grafiken bleiben als automatischer WORLD-Fallback nutzbar
- vorhandene Furniture-WORLD/SPOT/ICON-Dateien in das Runtime-Manifest aufgenommen
- Runtime-Validator prueft Namespaces, Kamera-Presets, Instanz-IDs und Kamera-Sichtbarkeit

## v0.6.1
- Cache-Busting fuer Runtime-Module und Locale-Dateien
- sichtbarer Startup-/Runtime-Fehlerstatus statt schwarzer Fehlerflaeche
- GitHub Actions startet Founder Sim jetzt real in Headless Chrome vor dem Deploy

## v0.6
- frei schwebende Hotspots durch datengetriebene Objektinstanzen ersetzt
- `objects.json` + `ObjectRegistry` als wiederverwendbare Objekt-Schicht eingefuehrt
- `SceneRenderer` richtet Objektkoordinaten am tatsaechlich sichtbaren Environment-Bild aus
- Pixel-Outline + Tooltip fuer Hover und Keyboard-Fokus
- generische Inspect-Aktion statt eigener Handler pro Reinigungsgeraet
- ObjectRegistry in Mod API v1 aufgenommen

## v0.5.2
- bestaetigte Base-Assets direkt als Runtime-Environment verwendet
- Ressourceninitialisierung akzeptiert `initial` aus dem Datenschema
- prozeduralen Regen-Platzhalter fuer den ersten sichtbaren Meilenstein deaktiviert

## v0.5.1
- DOM-Vertrag zwischen HTML, CSS und Rendering-Code wieder vereinheitlicht
- Startfehler durch fehlendes `hotspotLayer` beseitigt
- HUD-Layout gegen Ueberlagerungen abgesichert

## v0.5
- erster visueller Desk/Storage/Map-Prototyp
- erster Asset-Batch integriert
- datengetriebene Hotspots und Scene-Konfiguration
- i18n- und Mod-API-Grundlage
