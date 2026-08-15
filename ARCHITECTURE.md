# Founder Sim - Architektur v0.3

## Grundmodell

Founder Sim trennt vier Sphaeren:

1. Privatperson
2. Gruenderrolle
3. Unternehmen
4. Aussenwelt

Der sichtbare Prototyp startet bewusst kleiner: `Desk -> Storage -> Map`.

## Technische Schichten

```text
app/core       stabiler Shared Kernel
app/modules    spaetere Fachmodule
app/rules      versionierte Regelpakete
app/web        Browsergame, UI und Runtime-Assets
data            persistente Daten und Migrationen
docs            Architektur, Design und Asset-Pipeline
scripts         lokale Werkzeuge und Asset-Verarbeitung
```

## Asset-Grundsatz

Der Code referenziert keine frei erfundenen Bildpfade. Alle Runtime-Assets werden zentral ueber `app/web/assets/manifest.json` benannt.

Asset-Produktion und Spielcode bleiben getrennt:

```text
Asset-Chat -> Produktions-Sheet -> _incoming -> Asset-Processor -> normalisierte Runtime-Dateien -> manifest.json -> Spiel
```

WORLD, SPOT und ICON desselben Gegenstands behalten denselben stabilen Asset-ID-Stamm.

## Spaeter

Der Shared Kernel soll Simulationsuhr, Scheduler, Event Bus, reproduzierbaren Zufall, Ressourcen und Ledger-Primitiven enthalten. Fachmodule kommunizieren ueber Commands und Events statt direkt beliebige fremde Tabellen zu veraendern.
