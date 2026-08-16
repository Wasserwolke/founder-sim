export async function loadMods(api, registerTranslations) {
  try {
    const response = await fetch("mods/index.json");
    if (!response.ok) return [];

    const config = await response.json();
    const loaded = [];

    for (const path of config.mods || []) {
      const base = `mods/${path.replace(/\/$/, "")}`;
      const manifestResponse = await fetch(`${base}/manifest.json`);
      if (!manifestResponse.ok) continue;

      const manifest = await manifestResponse.json();
      if (manifest.api_version !== api.apiVersion) {
        console.warn(`Mod ${manifest.id || path} uebersprungen: API ${manifest.api_version}`);
        continue;
      }

      // Load optional translation dictionaries before activating the mod entry point.
      for (const [locale, file] of Object.entries(manifest.locales || {})) {
        const localeResponse = await fetch(`${base}/${file}`);
        if (localeResponse.ok) registerTranslations(locale, await localeResponse.json());
      }

      if (manifest.entry) {
        const mod = await import(`../../${base}/${manifest.entry}`);
        if (typeof mod.activate === "function") await mod.activate(api, manifest);
      }

      loaded.push(manifest.id || path);
    }

    return loaded;
  } catch (error) {
    console.warn("Mod loading skipped", error);
    return [];
  }
}
