# Founder Sim — Godot Roadmap

## North star

Founder Sim wird ein modularer, datengetriebener Unternehmens- und Lebenssimulator. Wohnung, Arbeitsplatz, Lager, Shop, Kundenorte, Stadtkarte und spaetere Bueros folgen demselben Szenenvertrag: Environment, Atmosphaere/Lighting, Objekte, Interaktion, Kamera und HUD. Wenn der Referenzraum sauber funktioniert, wird dieses Geruest auf weitere Raeume und Kartenansichten vervielfaeltigt.

## Visuelle North-Star-Referenzen

- `docs/reference/atmosphere_target_start.jpg`
- `docs/reference/atmosphere_target_late.jpg`
- `docs/reference/sunlight_target.jpg`

Diese Dateien sind Designreferenzen und werden nie als Runtime-Environment benutzt.

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
- echtes `PointLight2D`-Fensterlicht und breite Sonnenprojektion
- keine gezeichneten Neon-Sun-Beams
- `DynamicLights` + `DynamicOccluders` fuer spaetere Objektlichter/Schatten
- Interior/Exterior-Trennung als naechster grosser Atmosphaeren-Schritt

Status: **V4 clean rebuild ab v0.13**. Der Referenzraum bleibt absichtlich leer, bis Licht und Aussenwirkung glaubwuerdig sind.

### Phase 3 — Modulare Raumobjekte
- `PlaceableObject` / `InteractableObject` als gemeinsame Basis
- Schreibtisch, Stuhl, Monitore, Tastatur, Maus, Telefon, Tasse, Notizbuch, Schluessel
- Objekte im Godot-Editor sichtbar verschiebbar
- stabile namespaced IDs wie `foundersim:starter_desk`
- getrennte Daten, Visuals und Logik
- Lichtvertrag: Licht empfangen, Schatten werfen, selbst leuchten

**Verbindlich:** Kein sichtbares Objektasset wird ohne vorherige Freigabe des konkreten Assets in eine Runtime-Szene eingefuegt.

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

1. Leeren Raum mit glaubwuerdigem Fenster-, Tages- und Nachtlicht fertigstellen.
2. Interior und Exterior sauber trennen.
3. Erst danach freigegebene Placeable Objects mit Licht-/Schattenvertrag aufbauen.
4. Kamera und Interaktion.
5. HUD/Context UI.
6. Daten-/Mod-Schnittstellen.

## Asset-Workflow

1. Spielbedarf/Funktion definieren.
2. `object_id`, `item_id`, `asset_id` festlegen.
3. Zustaende und Interaktion definieren.
4. Asset Ticket + Bildreferenz/Prompt vorlegen.
5. Asset explizit freigeben lassen.
6. WORLD-Visual moeglichst neutral beleuchtet erstellen/uebernehmen.
7. Godot-Szene anlegen und visuell platzieren.
8. Lichtvertrag angeben: `receives_light`, `casts_shadow`, `emissive`.
9. Occluder/Emitter bei Bedarf direkt in die Objekt-Szene legen.
10. ICON / Preview / weitere Zustaende ergaenzen.
11. CI pruefen, in Godot feinpositionieren, committen.

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
Freigabe: AUSSTEHEND / FREIGEGEBEN
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
