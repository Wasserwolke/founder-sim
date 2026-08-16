export class ObjectRegistry {
  constructor(definitions = {}, defaultNamespace = "foundersim") {
    this.objects = new Map(Object.entries(definitions));
    this.defaultNamespace = defaultNamespace;
  }

  static async fromUrl(url) {
    const response = await fetch(url);
    if (!response.ok) throw new Error(`Object definitions not found: ${url}`);
    const data = await response.json();
    return new ObjectRegistry(data.objects || {}, data.default_namespace || "foundersim");
  }

  /** Resolve old unqualified core IDs without forcing a future mass rename. */
  normalizeId(id) {
    if (!id || typeof id !== "string") return id;
    if (id.includes(":")) return id;
    const qualified = `${this.defaultNamespace}:${id}`;
    return this.objects.has(qualified) ? qualified : id;
  }

  get(id) {
    return this.objects.get(this.normalizeId(id));
  }

  all() {
    return Object.fromEntries(this.objects);
  }

  /** Merge a reusable object type with one independently named world instance. */
  resolve(instance) {
    const placement = typeof instance === "string" ? {type_id: instance} : instance;
    const requestedTypeId = placement.type_id ?? placement.object_id;
    const typeId = this.normalizeId(requestedTypeId);
    const definition = this.get(typeId);
    if (!definition) throw new Error(`Unknown object type: ${requestedTypeId}`);

    return {
      ...definition,
      ...placement,
      type_id: typeId,
      instance_id: placement.instance_id ?? `${typeId}@anonymous`
    };
  }

  /** Mods must use namespaced IDs, e.g. mymod:industrial_vacuum. */
  register(id, definition) {
    if (!id?.includes(":")) throw new Error(`Mod object IDs must be namespaced: ${id}`);
    if (this.objects.has(id)) throw new Error(`Object already exists: ${id}`);
    this.objects.set(id, definition);
  }

  patch(id, patch) {
    const normalized = this.normalizeId(id);
    const current = this.get(normalized);
    if (!current) throw new Error(`Unknown object: ${id}`);
    this.objects.set(normalized, {...current, ...patch});
  }
}
