# Modding Architecture

## Goal
Founder Sim is designed so mods can alter resources, add/patch catalog items, replace asset mappings and add translations without editing core files.

## Public API v1
Available after startup as `window.FounderSimModAPI`.

```text
api.resources   ResourceRegistry
api.assets      AssetRegistry
api.catalog     CatalogRegistry
api.i18n        translation functions
api.events      small event interface
```

### Resources
Mods can:
- read values with `get(id)`
- change values with `set(id, value, source)`
- add/subtract with `add(id, delta, source)`
- change limits/metadata with `patchDefinition(id, patch)`
- subscribe to resource changes

Core resource definitions live in `app/web/data/resources.json`.

### Catalog
Item gameplay data lives in `app/web/data/catalog/items.json`.
This is where price, purchase state and gameplay effects belong. Artwork does not define gameplay values.

Mods can register new items or patch existing items through `api.catalog`.

### Assets
Stable asset IDs are resolved through `app/web/assets/manifest.json`.
Mods can register or patch asset entries through `api.assets`.

### Languages
Core language files live in `app/web/locales/`.
Mods may ship additional locale dictionaries and declare them in their `manifest.json`.

## Compatibility
Mods declare `api_version`. The current public API is version 1. Incompatible mods are skipped rather than silently loaded.

## Security model
The current mod system is a trusted-code model. A JavaScript mod entry is imported and executed in the game page context. Only install mods you trust. A permission/sandbox model can be added later if public third-party distribution becomes a goal.
