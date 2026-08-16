# Modding

`window.FounderSimModAPI` ist API v1.

Mods koennen:
- Ressourcen lesen/aendern (`api.resources`)
- Catalog-Items registrieren/patchen (`api.catalog`)
- Objektdefinitionen registrieren/patchen (`api.objects`)
- Asset-Mappings ersetzen (`api.assets`)
- auf Events reagieren (`api.events`)
- eigene Uebersetzungen ueber Locale-Dateien laden

## Objektmodell
`api.objects` arbeitet mit denselben wiederverwendbaren Definitionen wie `app/web/data/objects.json`.

Beispiel:
```js
api.objects.patch("vacuum_starter_basic", {
  hint_key: "my_mod.vacuum_hint"
});
```

Die konkrete Position eines Objekts ist Scene-Datenzustand und bleibt in `app/web/data/scenes.json`. Ein Mod soll deshalb bevorzugt Objektverhalten oder Visuals erweitern, statt Pixelpositionen quer durch Rendering-Code zu patchen.

## Datenorte
```text
app/web/data/resources.json       Ressourcenwerte
app/web/data/catalog/items.json   Preise/Effekte/Itemdaten
app/web/data/objects.json         Objektvisual + Default-Interaktion
app/web/data/scenes.json          konkrete Objektplatzierungen
app/web/assets/manifest.json      Asset-ID -> Runtime-Datei/Atlas
```

Hinweis: Mods laufen derzeit als vertrauenswuerdiger JavaScript-Code. Eine Sandbox fuer oeffentliche Fremdmods ist noch nicht Teil von API v1.
