export function createModAPI({resources, assets, catalog, objects, i18n}) {
  const events = new EventTarget();

  return Object.freeze({
    apiVersion: 1,
    resources,
    assets,
    catalog,
    objects,
    i18n,
    events: {
      on(name, handler) {
        const wrapped = event => handler(event.detail);
        events.addEventListener(name, wrapped);
        return () => events.removeEventListener(name, wrapped);
      },
      emit(name, detail = {}) {
        events.dispatchEvent(new CustomEvent(name, {detail}));
      }
    }
  });
}
