export class AssetRegistry {
  constructor(entries = {}) {
    this.entries = new Map(Object.entries(entries));
  }

  static async fromUrl(url) {
    const response = await fetch(url);
    if (!response.ok) throw new Error(`Asset manifest not found: ${url}`);
    const data = await response.json();
    return new AssetRegistry(data.assets || {});
  }

  get(id) { return this.entries.get(id); }

  resolve(id, variant = "world") {
    const entry = this.get(id);
    if (!entry) return null;
    return entry.files?.[variant] ?? null;
  }

  register(id, entry) {
    if (this.entries.has(id)) throw new Error(`Asset already exists: ${id}`);
    this.entries.set(id, entry);
  }

  patch(id, patch) {
    const current = this.get(id);
    if (!current) throw new Error(`Unknown asset: ${id}`);
    this.entries.set(id, {
      ...current,
      ...patch,
      files: {...(current.files || {}), ...(patch.files || {})}
    });
  }

  all() { return Object.fromEntries(this.entries); }
}
