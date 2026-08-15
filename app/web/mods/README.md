# Founder Sim Mods

Enabled mods are listed in `mods/index.json`.

Example:

```text
mods/
  index.json
  my-balance-mod/
    manifest.json
    main.js
    locales/
      de.json
```

`manifest.json`:

```json
{
  "id": "my-balance-mod",
  "name": "My Balance Mod",
  "version": "1.0.0",
  "api_version": 1,
  "entry": "main.js",
  "locales": {"de": "locales/de.json"}
}
```

`main.js`:

```js
export function activate(api) {
  api.resources.patchDefinition("energy", {max: 120});
  api.resources.add("money", 500, "mod:my-balance-mod");
  api.catalog.patch("coffee_starter_white", {price_cents: 399});
}
```

The public mod surface is available as `window.FounderSimModAPI` after startup.
