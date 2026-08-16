export class ResourceRegistry {
  constructor(definitions = {}) {
    this.definitions = new Map();
    this.values = new Map();
    this.listeners = new Set();
    for (const [id, definition] of Object.entries(definitions)) this.define(id, definition);
  }

  static async fromUrl(url) {
    const response = await fetch(url);
    if (!response.ok) throw new Error(`Resource definitions not found: ${url}`);
    const data = await response.json();
    return new ResourceRegistry(data.resources || {});
  }

  /** Register a resource and initialize its runtime value from the data schema. */
  define(id, definition) {
    const normalized = {min: Number.NEGATIVE_INFINITY, max: Number.POSITIVE_INFINITY, modifiable: true, ...definition};
    this.definitions.set(id, normalized);

    if (!this.values.has(id)) {
      const initialValue = normalized.initial ?? normalized.default ?? 0;
      this.values.set(id, this.clamp(id, initialValue));
    }
  }

  patchDefinition(id, patch) {
    const current = this.getDefinition(id);
    if (!current) throw new Error(`Unknown resource: ${id}`);
    this.definitions.set(id, {...current, ...patch});
    this.set(id, this.get(id), "definition-patch");
  }

  getDefinition(id) { return this.definitions.get(id); }
  get(id) { return this.values.get(id); }

  clamp(id, value) {
    const definition = this.getDefinition(id) || {};
    return Math.max(definition.min ?? Number.NEGATIVE_INFINITY, Math.min(definition.max ?? Number.POSITIVE_INFINITY, value));
  }

  set(id, value, source = "game") {
    const definition = this.getDefinition(id);
    if (!definition) throw new Error(`Unknown resource: ${id}`);
    const oldValue = this.get(id);
    const newValue = this.clamp(id, Number(value));
    this.values.set(id, newValue);
    const event = {id, oldValue, newValue, delta: newValue - oldValue, source};
    for (const listener of this.listeners) listener(event);
    return newValue;
  }

  add(id, delta, source = "game") { return this.set(id, this.get(id) + Number(delta), source); }
  subscribe(listener) { this.listeners.add(listener); return () => this.listeners.delete(listener); }
  snapshot() { return Object.fromEntries(this.values); }
}
