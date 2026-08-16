# Founder Sim - Projektstruktur

```text
founder-sim/
├── app/
│   ├── core/                         spaeterer Shared Kernel
│   ├── modules/                      fachlich auffindbare Unternehmensmodule
│   ├── rules/                        Rechts-/Branchen-Rulepacks
│   └── web/
│       ├── index.html
│       ├── css/
│       ├── js/
│       │   ├── core/                 Resource/Asset/Catalog/Object Registries
│       │   ├── ui/                   SceneRenderer und spaetere UI-Komponenten
│       │   └── modding/
│       ├── data/
│       │   ├── resources.json
│       │   ├── objects.json          wiederverwendbare Objektdefinitionen
│       │   ├── scenes.json           Environment + Objektplatzierungen
│       │   └── catalog/items.json
│       ├── locales/                  alle sichtbaren Texte
│       ├── mods/                     installierte Mods
│       └── assets/
│           ├── manifest.json
│           ├── environments/
│           ├── atlases/
│           ├── furniture/
│           ├── consumables/
│           ├── desk_objects/
│           ├── equipment/
│           ├── vehicles/
│           ├── map/
│           ├── ui/
│           └── fx/
├── asset_sources/
│   ├── incoming/                     temporaere Rohimporte
│   └── sheets/                       JSON-Sidecars pro Produktions-Sheet
├── data/migrations/                  spaetere Savegame/DB-Migrationen
├── docs/
└── scripts/                          wenige allgemeine Werkzeuge
```

## Abhaengigkeitsrichtung
```text
Scene JSON -> ObjectRegistry -> AssetRegistry
                       \-> Action Router
UI/Renderer -> Registries/API -> Daten/Module
```

Die Scene kennt nur `object_id` und Platzierung. Die wiederverwendbare Bedeutung eines Objekts liegt in `objects.json`. Dadurch wird keine Interaktionslogik pro Szene dupliziert.

## Erweiterungsregel
Neue Features werden zuerst als stabile IDs/Daten/Code definiert. Erst danach werden benoetigte Assets generiert. Mods duerfen Ressourcen, Catalog-Eintraege, Objects, Assets und Uebersetzungen ueber die oeffentliche API erweitern.
