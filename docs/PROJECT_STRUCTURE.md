# Founder Sim - Projektstruktur

```text
founder-sim/
├── app/
│   ├── core/                         Shared-Kernel-Vertrag
│   ├── modules/
│   │   ├── person/
│   │   ├── founder/
│   │   ├── company/
│   │   ├── crm/
│   │   ├── orders/
│   │   ├── procurement/
│   │   ├── logistics/
│   │   ├── finance/
│   │   ├── invoices/
│   │   ├── bureaucracy/
│   │   └── hr/
│   ├── rules/                        Rechts-/Branchen-Rulepacks
│   └── web/
│       ├── index.html
│       ├── css/
│       ├── js/
│       │   ├── core/                 Resource/Asset/Catalog Registries
│       │   └── modding/
│       ├── data/
│       │   ├── resources.json
│       │   ├── scenes.json
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
│   ├── incoming/                     Herkunft/Batch-Metadaten
│   └── sheets/                       JSON-Sidecars pro Produktions-Sheet
├── data/migrations/                  spaetere Savegame/DB-Migrationen
├── docs/assets/
└── scripts/
```

## Abhaengigkeitsrichtung
`UI -> Registries/API -> Daten/Module`, niemals `UI -> hart codierte Spielwerte`.

## Erweiterungsregel
Neue Features werden zuerst als Daten/Code/ID definiert. Erst danach werden die benoetigten Assets generiert. Mods duerfen Ressourcen, Catalog-Eintraege, Assets und Uebersetzungen ueber die oeffentliche API erweitern.
