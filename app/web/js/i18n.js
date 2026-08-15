const dictionaries = new Map();
let activeLocale = "de";

function getNested(obj, key) {
  return key.split(".").reduce((value, part) => value?.[part], obj);
}

function deepMerge(target, source) {
  for (const [key, value] of Object.entries(source || {})) {
    if (value && typeof value === "object" && !Array.isArray(value)) {
      target[key] = deepMerge(target[key] || {}, value);
    } else {
      target[key] = value;
    }
  }
  return target;
}

export async function loadLocale(locale) {
  const response = await fetch(`locales/${locale}.json`);
  if (!response.ok) throw new Error(`Locale not found: ${locale}`);
  dictionaries.set(locale, await response.json());
  activeLocale = locale;
}

export function registerTranslations(locale, values) {
  const current = dictionaries.get(locale) || {};
  dictionaries.set(locale, deepMerge(current, values));
}

export function setLocale(locale) {
  if (!dictionaries.has(locale)) throw new Error(`Locale not loaded: ${locale}`);
  activeLocale = locale;
  document.documentElement.lang = locale;
  applyTranslations();
}

export function getLocale() {
  return activeLocale;
}

export function t(key, fallback = key) {
  return getNested(dictionaries.get(activeLocale) || {}, key) ?? fallback;
}

export function applyTranslations(root = document) {
  document.documentElement.lang = activeLocale;
  root.querySelectorAll("[data-i18n]").forEach(node => {
    node.textContent = t(node.dataset.i18n, node.textContent);
  });
}
