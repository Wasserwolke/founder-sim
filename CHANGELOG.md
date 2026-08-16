# Changelog

## v0.6.1
- buildweiten Cache-Token eingefuehrt, damit GitHub-Pages-HTML und JavaScript-Module nicht aus unterschiedlichen Versionen gemischt werden
- sichtbaren Startup-/Runtime-Status fuer Lade- und Fehlerfaelle hinzugefuegt
- Environment-Ladezustand explizit als Runtime-Status markiert
- Browser-Smoke-Test in GitHub Actions ergaenzt: echte JavaScript-Ausfuehrung, Environment-Decoding und erstes Objekt-Overlay muessen vor dem Deploy erfolgreich sein
- Daten-/Locale-Aufrufe fuer den aktuellen Build cache-sicher gemacht

## v0.6
- frei schwebende Hotspots durch datengetriebene Objektinstanzen ersetzt
- `objects.json` + `ObjectRegistry` als wiederverwendbare Objekt-Schicht eingefuehrt
- `SceneRenderer` richtet Objektkoordinaten am tatsaechlich sichtbaren Environment-Bild aus
- erste acht physische Objektarten als echte Overlays vorbereitet
- Pixel-Outline + Tooltip fuer Hover und Keyboard-Fokus
- generische Inspect-Aktion statt eigener Handler pro Reinigungsgeraet
- ObjectRegistry in Mod API v1 aufgenommen
- Runtime-Validator prueft jetzt Catalog -> Asset, Object -> Asset und Scene -> Object
- ungenutztes `scenes.js` sowie nicht mehr referenzierte Flat-PNG/WebP-Prototypen entfernt
- vorhandenes `state.js` wiederverwendet statt State-/Zeitlogik in `app.js` zu duplizieren

## v0.5.2
- bestaetigte Base-Assets direkt als Runtime-Environment verwendet
- Ressourceninitialisierung akzeptiert `initial` aus dem Datenschema
- prozeduralen Regen-Platzhalter fuer den ersten sichtbaren Meilenstein deaktiviert
- Asset-URLs/Atlas-Darstellung robuster gemacht
- Actions-Smoke-Test prueft die sichtbaren Base-Assets

## v0.5.1
- DOM-Vertrag zwischen HTML, CSS und Rendering-Code wieder vereinheitlicht
- Startfehler durch fehlendes `hotspotLayer` beseitigt und alte statische Hotspot-Struktur entfernt
- HUD-Layout gegen Ueberlagerungen und schmale Viewports abgesichert
- Runtime-Umgebungen auf die echten PNG-Prototyp-Assets umgestellt
- GitHub Actions prueft jetzt die erforderlichen DOM-Knoten vor dem Pages-Deployment

## v0.5
- erster visueller Desk/Storage/Map-Prototyp
- erster Asset-Batch integriert
- adaptive Produktions-Sheet-Metadaten fuer echte Zellgrenzen
- Runtime-Icon-Atlas fuer schnelle Browserdarstellung
- datengetriebene Hotspots und Scene-Konfiguration
- vollstaendige Repo-Grundstruktur fuer kuenftige Fachmodule
- bestehende i18n- und Mod-API-Grundlage beibehalten

## v0.4
- Mehrsprachigkeits-Grundlage
- Resource/Catalog/Asset Registries
- Mod API v1
