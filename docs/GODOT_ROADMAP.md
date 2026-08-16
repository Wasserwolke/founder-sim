# Founder Sim — Godot Roadmap

## North star

Founder Sim wird ein modularer, datengetriebener Unternehmens- und Lebenssimulator. Der Spieler erlebt die Firma aus physischen Szenen heraus: Wohnung, Arbeitsplatz, Lager, Shop, Kundenorte, Stadtkarte und spaetere Bueros. Jede dieser Ansichten wird technisch als dieselbe Grundidee behandelt: eine Szene mit Environment, Atmosphere/Lighting, interaktiven Objekten, Kamera und optionalem HUD.

Dadurch entsteht ein wiederverwendbares Grundgeruest: Wenn ein Raum sauber funktioniert, koennen weitere Raeume und selbst eine Stadtkarte dieselben Vertraege fuer Licht, Interaktion, Kamera, Daten und Mods verwenden.

## Projektphasen

### Phase 1 — Godot-Fundament
- stabile Szenenstruktur und GameState
- skalierbares HUD
- Git/GitHub direkt aus Godot
- CI startet und prueft die echte Godot-Runtime

Status: grundsaetzlich funktionsfaehig.

### Phase 2 — Atmosphere + Lighting
- wiederverwendbares `RoomLightingRig`
- Tageszeit, Golden Hour, Nacht, Bewoelkung/Regen-Stimmung
- kuenstliches Raumlicht
- weiche animierte Uebergaenge
- Developer Atmosphere Controller fuer Live-Tuning
- gerichtete, wandernde Sonnenbahnen mit Wand-/Bodenlicht
- reagierender Fensterbereich und erste Stadtlichter
- Vorbereitung fuer Light2D-Emitter und LightOccluder2D an spaeteren Items

Status: V2 ab v0.11. Aktuell wird dieser Referenzraum atmosphaerisch kalibriert. Danach folgt die echte Trennung von Interior und Exterior/City-View.

### Phase 3 — Modulare Raumobjekte
- `PlaceableObject` / `InteractableObject` als gemeinsame Basis
- Schreibtisch, Stuhl, Monitore, Tastatur, Maus, Telefon, Tasse, Notizbuch, Schluessel
- Objekte im Godot-Editor sichtbar verschiebbar
- stabile namespaced IDs wie `foundersim:starter_desk`
- getrennte Daten, Visuals und Logik
- Lighting-Vertrag pro Objekt: Licht empfangen, Schatten werfen, selbst leuchten

### Phase 4 — Kamera und physische Bedienung
- Overview -> Desk Focus als echte Godot-Kamerafahrt
- linker Monitor = operativer Bereich
- rechter Monitor = Management/Finanzen
- physische Gegenstaende fuehren in Systeme, statt frei schwebender Menue-Hotspots

### Phase 5 — Erster kompletter Gameplay-Vertical-Slice
- Gruendung / Anmeldung
- erste Anschaffungen
- Kundengewinnung
- Angebot / Auftrag / Ausfuehrung
- Rechnung / Zahlung / Bewertung
- Zeit, Liquiditaet, Energie, Fokus und Gesundheit erzeugen echte Trade-offs

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
- Datenformate dokumentieren und validieren
- Mods duerfen Inhalte hinzufuegen, ohne Core-Dateien zu ersetzen

### Phase 8 — Breite und Polish
- weitere Branchen und Raeume
- groessere Bueros und Lager
- Fahrzeuge, Stadtorte, Wetter, Audio, Animationen
- Savegames, Balancing, Accessibility und Release-Pipeline

## Gemeinsamer Szenenvertrag

Jede groessere spielbare Ansicht soll langfristig dieselben Schichten besitzen:

```text
WorldView / Room
├─ Environment
├─ PlaceableObjects
├─ Atmosphere / LightingRig
├─ InteractionLayer
├─ CameraRig
└─ HUD / Context UI
```

Eine Stadtkarte ist damit kein Sonderfall. Sie ist eine andere `WorldView`, deren Environment eine Karte ist und deren interaktive Objekte Gebaeude, Marker und Wege sind.

## Referenzraum-Strategie

Der aktuelle Start-Raum ist unser Referenzraum. Neue Raumtechnik wird zuerst hier bis zu einem belastbaren Standard gebracht:

1. Environment und Skalierung.
2. Lighting/Atmosphere und Exterior-Reaktion.
3. Placeable Objects mit Licht-/Schattenvertrag.
4. Kamera und Interaktion.
5. HUD/Context UI.
6. Daten-/Mod-Schnittstellen.

Erst wenn dieser Vertrag sauber funktioniert, wird er auf Lager, Shop, Kundenorte und Map-Ansichten vervielfaeltigt. Dadurch vermeiden wir Sonderloesungen pro Raum.

## Asset-Workflow

Neue Assets werden nicht zuerst gemalt und danach irgendwie eingebaut. Der Workflow bleibt feature-first:

1. Spielbedarf und Funktion definieren.
2. Stabile `object_id`, `item_id` und `asset_id` festlegen.
3. Daten, Interaktion und benoetigte Zustaende definieren.
4. Asset Ticket erstellen.
5. Visual neutral beleuchtet generieren/zeichnen.
6. WORLD-Asset importieren und als Godot-Szene platzieren.
7. Lichtvertrag ergaenzen: Empfaengt Licht? Wirft Schatten? Leuchtet selbst?
8. Optional ICON / Shop Preview / weitere Zustaende erstellen.
9. CI und Runtime pruefen.
10. Im Godot-Editor feinpositionieren und committen.

### Asset Ticket — Standard

```text
Asset-ID: foundersim:...
Objekt-ID: foundersim:...
Typ: WORLD / ICON / PREVIEW
Zweck: ...
Perspektive: passend zur Zielszene
Hintergrund: transparent
Beleuchtung: neutral, moeglichst ohne fest eingebranntes Richtungslicht
Zustaende: ...
Interaktion: ...
Lighting: receives_light / casts_shadow / emissive
Godot-Zielordner: ...
Godot-Szene: ...
Bild-Prompt: ...
```

## Git/Godot-Workflow

```text
Aenderung durch ChatGPT
→ Commit auf GitHub/main
→ in Godot: Fetch + Pull
→ Szene/Script aktualisiert sich
→ lokal visuell pruefen / ggf. verschieben
→ Stage + Commit + Push direkt in Godot
→ ChatGPT arbeitet auf dem neuen main weiter
```

Vor Pull sollten lokale Aenderungen committed oder bewusst verworfen werden. Bei einer Godot-Meldung `changed on disk` gilt: Wenn die Datei lokal nicht bewusst bearbeitet wurde, `Reload from Disk`; sonst zuerst die lokale Aenderung sichern/committen. Groessere riskante Umbauten koennen spaeter auf Feature-Branches wandern; aktuell bleibt der schnelle gemeinsame `main`-Workflow fuer kleine, getestete Iterationen bestehen.
