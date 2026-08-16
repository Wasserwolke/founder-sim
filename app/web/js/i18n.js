let dict = {};

/** Merge nested translation dictionaries without replacing unrelated sibling keys. */
function mergeDeep(target, source) {
  for (const [key, value] of Object.entries(source || {})) {
    if (value && typeof value === "object" && !Array.isArray(value)) {
      if (!target[key] || typeof target[key] !== "object") target[key] = {};
      mergeDeep(target[key], value);
    } else {
      target[key] = value;
    }
  }
  return target;
}

export async function loadLocale(code = "de") {
  const response = await fetch(`locales/${code}.json`);
  if (!response.ok) throw new Error(`Locale ${code} konnte nicht geladen werden`);
  dict = await response.json();
  return dict;
}

/** Add mod translations only to the currently active locale. */
export function registerTranslations(locale, data) {
  const active = dict?.meta?.code || "de";
  if (locale === active) mergeDeep(dict, data);
}

export function t(key, fallback = key) {
  let value = dict;
  for (const part of key.split(".")) value = value?.[part];
  return typeof value === "string" ? value : fallback;
}

/** Apply data-i18n keys to static DOM content; dynamic object labels use t() directly. */
export function applyTranslations(root = document) {
  root.querySelectorAll("[data-i18n]").forEach(element => {
    element.textContent = t(element.dataset.i18n, element.textContent);
  });
}
