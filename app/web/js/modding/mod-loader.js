export async function loadMods(api, registerTranslations) {
  const response = await fetch("mods/index.json");
  if (!response.ok) return [];
  const config = await response.json();
  const loaded = [];

  for (const modPath of config.mods || []) {
    const base = `mods/${modPath.replace(/\/$/, "")}`;
    const manifestResponse = await fetch(`${base}/manifest.json`);
    if (!manifestResponse.ok) {
      console.warn(`Skipping mod without manifest: ${modPath}`);
      continue;
    }
    const manifest = await manifestResponse.json();
    if (manifest.api_version !== 1) {
      console.warn(`Skipping incompatible mod ${manifest.id}: API ${manifest.api_version}`);
      continue;
    }

    for (const [locale, file] of Object.entries(manifest.locales || {})) {
      const localeResponse = await fetch(`${base}/${file}`);
      if (localeResponse.ok) registerTranslations(locale, await localeResponse.json());
    }

    if (manifest.entry) {
      const module = await import(`../../${base}/${manifest.entry}`);
      if (typeof module.activate === "function") await module.activate(api, manifest);
    }
    loaded.push(manifest.id);
  }

  return loaded;
}
