export class CatalogRegistry {
  constructor(items = {}) { this.items = new Map(Object.entries(items)); }

  static async fromUrl(url) {
    const response = await fetch(url);
    if (!response.ok) throw new Error(`Catalog not found: ${url}`);
    const data = await response.json();
    return new CatalogRegistry(data.items || {});
  }

  get(id) { return this.items.get(id); }
  all() { return Object.fromEntries(this.items); }

  register(id, item) {
    if (this.items.has(id)) throw new Error(`Item already exists: ${id}`);
    this.items.set(id, item);
  }

  patch(id, patch) {
    const current = this.get(id);
    if (!current) throw new Error(`Unknown item: ${id}`);
    this.items.set(id, {...current, ...patch, effects: {...(current.effects || {}), ...(patch.effects || {})}});
  }
}
