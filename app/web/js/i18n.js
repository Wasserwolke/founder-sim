let dict={};
function mergeDeep(target,source){for(const [key,value] of Object.entries(source||{})){if(value&&typeof value==="object"&&!Array.isArray(value)){if(!target[key]||typeof target[key]!=="object")target[key]={};mergeDeep(target[key],value)}else target[key]=value}return target}
export async function loadLocale(code="de"){const r=await fetch(`locales/${code}.json`);if(!r.ok)throw new Error(`Locale ${code} konnte nicht geladen werden`);dict=await r.json();return dict}
export function registerTranslations(locale,data){const active=dict?.meta?.code||"de";if(locale===active)mergeDeep(dict,data)}
export function t(key,fallback=key){let v=dict;for(const p of key.split("."))v=v?.[p];return typeof v==="string"?v:fallback}
export function applyTranslations(root=document){root.querySelectorAll("[data-i18n]").forEach(el=>el.textContent=t(el.dataset.i18n,el.textContent))}
