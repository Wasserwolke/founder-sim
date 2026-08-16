# Modding

`window.FounderSimModAPI` ist API v1.

Mods koennen:
- Ressourcen lesen/aendern (`api.resources`)
- Catalog-Items registrieren/patchen (`api.catalog`)
- Objektdefinitionen registrieren/patchen (`api.objects`)
- Asset-Mappings ersetzen (`api.assets`)
- auf Events reagieren (`api.events`)
- eigene Uebersetzungen ueber Locale-Dateien laden

## Namespaced Objekt-IDs
Neue Mod-Objekte verwenden immer einen eigenen Namespace:

```text
mein_mod:industrial_vacuum_x2
mein_mod:coffee_machine_pro
```

Die ID ist ein String und nicht auf eine kleine Nummernmenge begrenzt. Auch sehr grosse Mods koennen deshalb tausende eigene Objekttypen registrieren, solange die Laufzeitdaten fuer den Browser praktisch handhabbar bleiben.

Beispiel:
```js
api.objects.register("mein_mod:industrial_vacuum_x2", {
  kind: "equipment",
  asset_id: "mein_mod:industrial_vacuum_x2",
  label_key: "mein_mod.vacuum.name",
  hint_key: "mein_mod.vacuum.hint",
  default_action: "inspect",
  highlight: "pixel_outline"
});
```

Core-Objekte verwenden den Namespace `foundersim:`:
```js
api.objects.patch("foundersim:vacuum_starter_basic", {
  hint_key: "mein_mod.vacuum_hint"
});
```

Alte unqualifizierte Core-IDs wie `vacuum_starter_basic` werden fuer Kompatibilitaet weiterhin automatisch auf `foundersim:vacuum_starter_basic` aufgeloest.

## Typ vs. Instanz
`api.objects` verwaltet wiederverwendbare Objekttypen. Eine konkrete Instanz besitzt eine eigene `instance_id` und verweist auf den Typ ueber `type_id`.

```text
type_id:     foundersim:coffee_starter_white
instance_id: foundersim:office.coffee.01
```

Mehrere Instanzen koennen denselben Typ und damit dasselbe Asset verwenden. Die PNG-Datei muss nicht pro Environment kopiert werden.

## Kamera und Environment
`overview` und `desk` sind Kamera-Presets desselben Environments. Mods sollen keine zweite Environment-Grafik anlegen, nur um einen Zoom zu simulieren.

## Datenorte
```text
app/web/data/resources.json       Ressourcenwerte
app/web/data/catalog/items.json   Preise/Effekte/Itemdaten
app/web/data/objects.json         Objekttypen
app/web/data/scenes.json          Environments, Kameras und Instanzen
app/web/assets/manifest.json      Asset-ID -> Runtime-Datei/Atlas
```

Hinweis: Mods laufen derzeit als vertrauenswuerdiger JavaScript-Code. Eine Sandbox fuer oeffentliche Fremdmods ist noch nicht Teil von API v1.
