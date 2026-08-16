export class ObjectRegistry {
  constructor(definitions = {}) {
    this.objects = new Map(Object.entries(definitions));
  }

  static async fromUrl(url) {
    const response = await fetch(url);
    if (!response.ok) throw new Error(`Object definitions not found: ${url}`);
    const data = await response.json();
    return new ObjectRegistry(data.objects || {});
  }

  get(id) {
    return this.objects.get(id);
  }

  all() {
    return Object.fromEntries(this.objects);
  }

  /** Merge a reusable object definition with one scene-specific placement. */
  resolve(instance) {
    const placement = typeof instance === "string" ? {object_id: instance} : instance;
    const objectId = placement.object_id;
    const definition = this.get(objectId);
    if (!definition) throw new Error(`Unknown scene object: ${objectId}`);
    return {id: objectId, ...definition, ...placement};
  }

  register(id, definition) {
    if (this.objects.has(id)) throw new Error(`Object already exists: ${id}`);
    this.objects.set(id, definition);
  }

  patch(id, patch) {
    const current = this.get(id);
    if (!current) throw new Error(`Unknown object: ${id}`);
    this.objects.set(id, {...current, ...patch});
  }
}
