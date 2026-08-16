# Founder Sim — Godot Roadmap

## North star

Founder Sim wird ein modularer, datengetriebener Unternehmens- und Lebenssimulator. Wohnung, Arbeitsplatz, Lager, Shop, Kundenorte, Stadtkarte und spaetere Bueros folgen demselben Szenenvertrag: Environment, Atmosphaere/Lighting, Objekte, Interaktion, Kamera und HUD. Wenn der Referenzraum sauber funktioniert, wird dieses Geruest auf weitere Raeume und Kartenansichten vervielfaeltigt.

## Projektphasen

### Phase 1 — Godot-Fundament
- Szenenstruktur und GameState
- skalierbares HUD
- Git/GitHub direkt aus Godot
- echte Godot-Runtime in CI

Status: funktionsfaehig.

### Phase 2 — Atmosphere + Lighting
- Tageszeit, Golden Hour, Nacht, Bewoelkung/Regen
- Developer Atmosphere Controller
- `CanvasModulate` fuer globale Belichtung
- `DirectionalLight2D` fuer Sonnenrichtung
- `PointLight2D` fuer Fenster- und lokale Objektlichter
- fenstergebundene, kontrastreiche Sun-Beam-Projektion
- City-Lights-Prototyp
- `LightOccluder2D`-Vertrag fuer Schatten
- Referenz-Workspace mit Monitor-Glow und Tischlampe

Status: **V3 ab v0.12**. Fokus bleibt Atmosphaere, bis der Referenzraum tagsueber und nachts ueberzeugend wirkt. Danach wird Interior und Exterior/City-View getrennt.

### Phase 3 — Modulare Raumobjekte
- `PlaceableObject` / `InteractableObject` als gemeinsame Basis
- Schreibtisch, Stuhl, Monitore, Tastatur, Maus, Telefon, Tasse, Notizbuch, Schluessel
- Objekte im Godot-Editor sichtbar verschiebbar
- stabile namespaced IDs wie `foundersim:starter_desk`
- getrennte Daten, Visuals und Logik
- Lichtvertrag: Licht empfangen, Schatten werfen, selbst leuchten

### Phase 4 — Kamera und physische Bedienung
- Overview -> Desk Focus als echte Godot-Kamerafahrt
- linker Monitor = operativer Bereich
- rechter Monitor = Management/Finanzen
- physische Gegenstaende fuehren in Systeme

### Phase 5 — Erster Gameplay-Vertical-Slice
- Gruendung / Anmeldung
- Anschaffungen
- Kundengewinnung
- Angebot / Auftrag / Ausfuehrung
- Rechnung / Zahlung / Bewertung
- Zeit, Liquiditaet, Energie, Fokus, Gesundheit

### Phase 6 — Tiefe Simulation
- Routine und Lernkurve
- Krankheit, Ueberlastung, Ausfaelle
- Forderungen, Kosten, Kredite, Zahlungsprobleme
- Reputation, Bewertungen, Personal und HR
- mehrere tragfaehige Wege statt eines optimalen Pfads

### Phase 7 — Modding API
- Content Packs mit Namespace
- registrierbare Items, Jobs, Events, Branchen, Raeume und Assets
- Signale/Events statt harter Abhaengigkeiten
- dokumentierte, validierte Datenformate
- Mods koennen Inhalte hinzufuegen, ohne Core-Dateien zu ersetzen

### Phase 8 — Breite und Polish
- weitere Branchen und Raeume
- groessere Bueros und Lager
- Fahrzeuge, Stadtorte, Wetter, Audio, Animationen
- Savegames, Balancing, Accessibility, Release-Pipeline

## Gemeinsamer Szenenvertrag

```text
WorldView / Room
├─ Environment / Interior
├─ Exterior / Window View
├─ PlaceableObjects
│  ├─ Visual
│  ├─ optional LightOccluder2D
│  └─ optional RoomLightEmitter2D
├─ Atmosphere / LightingRig
├─ InteractionLayer
├─ CameraRig
└─ HUD / Context UI
```

Eine Stadtkarte ist derselbe Vertrag mit anderem Environment: Gebaeude, Marker und Wege ersetzen Moebel.

## Referenzraum-Strategie

1. Atmosphaere und Licht bis zum glaubwuerdigen Tag-/Nachtbild bringen.
2. Interior und Exterior sauber trennen.
3. Placeable Objects mit Licht-/Schattenvertrag aufbauen.
4. Kamera und Interaktion.
5. HUD/Context UI.
6. Daten-/Mod-Schnittstellen.

Erst danach wird das Muster auf Lager, Shop, Kundenorte und Map-Ansichten vervielfaeltigt.

## Asset-Workflow

1. Spielbedarf/Funktion definieren.
2. `object_id`, `item_id`, `asset_id` festlegen.
3. Zustaende und Interaktion definieren.
4. Asset Ticket erstellen.
5. WORLD-Visual moeglichst neutral beleuchtet erstellen.
6. Godot-Szene anlegen und visuell platzieren.
7. Lichtvertrag angeben: `receives_light`, `casts_shadow`, `emissive`.
8. Occluder/Emitter bei Bedarf direkt in die Objekt-Szene legen.
9. ICON / Preview / weitere Zustaende ergaenzen.
10. CI pruefen, in Godot feinpositionieren, committen.

### Asset Ticket — Standard

```text
Asset-ID: foundersim:...
Objekt-ID: foundersim:...
Typ: WORLD / ICON / PREVIEW
Zweck: ...
Perspektive: passend zur Zielszene
Hintergrund: transparent
Beleuchtung: neutral
Zustaende: ...
Interaktion: ...
Lighting: receives_light / casts_shadow / emissive / emitter_category
Godot-Zielordner: ...
Godot-Szene: ...
Bild-Prompt: ...
```

## Git/Godot-Workflow

```text
Aenderung durch ChatGPT
→ Commit auf GitHub/main
→ in Godot: Fetch + Pull
→ bei unveraenderten lokalen Dateien: Reload from Disk
→ Szene visuell pruefen / verschieben
→ Stage + Commit + Push direkt in Godot
→ ChatGPT arbeitet auf dem neuen main weiter
```

Vor Pull lokale bewusste Aenderungen sichern. Automatisch erzeugte `.uid`-/Import-Metadaten erst beurteilen, bevor sie verworfen oder committed werden.
