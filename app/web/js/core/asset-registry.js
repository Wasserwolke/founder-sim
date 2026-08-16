export class AssetRegistry {
  constructor(data = {}) {
    this.data = data;
  }

  static async fromUrl(url) {
    const response = await fetch(url);
    if (!response.ok) throw new Error(`Asset manifest not found: ${url}`);
    return new AssetRegistry(await response.json());
  }

  /** Find one asset entry in the supported manifest groups. */
  find(id) {
    return this.data.assets?.[id]
      ?? this.data.environments?.[id]
      ?? this.data.prototype_icons?.[id]
      ?? null;
  }

  /**
   * Resolve a stable asset ID. Standalone files always win; the prototype atlas
   * is an automatic fallback until a final WORLD asset is added to the manifest.
   */
  resolve(id, variant = "world") {
    if (!id) return null;

    const entry = this.data.assets?.[id] ?? this.data.environments?.[id];
    if (entry) {
      if (typeof entry === "string") return entry;
      if (entry.files?.[variant]) return entry.files[variant];
      if (entry[variant]) return entry[variant];
    }

    return this.data.prototype_icons?.[id] ?? null;
  }

  /** Patch an existing mapping without changing its stable asset ID. */
  patch(id, patch) {
    const entry = this.find(id);
    if (!entry || typeof entry !== "object") throw new Error(`Unknown asset: ${id}`);
    Object.assign(entry, patch);
  }
}
