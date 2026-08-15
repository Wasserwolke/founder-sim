import {state, passTime, timeString} from "./state.js";
import {scenes} from "./scenes.js";
import {loadLocale, registerTranslations, applyTranslations, t} from "./i18n.js";
import {ResourceRegistry} from "./core/resource-registry.js";
import {AssetRegistry} from "./core/asset-registry.js";
import {CatalogRegistry} from "./core/catalog-registry.js";
import {createModAPI} from "./modding/mod-api.js";
import {loadMods} from "./modding/mod-loader.js";

const env = document.querySelector("#environment");
const rain = document.querySelector("#rain");
const darkness = document.querySelector("#darkness");
const deskHotspots = document.querySelector("#deskHotspots");
const mapHotspots = document.querySelector("#mapHotspots");
const back = document.querySelector("#backButton");
const toast = document.querySelector("#toast");

let resources;
let assets;
let catalog;
let modAPI;

function setImageWithFallback(path, placeholder) {
  if (!path) {
    env.style.backgroundImage = "none";
    env.classList.add("missing");
    env.dataset.placeholder = placeholder;
    return;
  }
  const img = new Image();
  img.onload = () => {
    env.classList.remove("missing");
    env.style.backgroundImage = `url("${path}")`;
  };
  img.onerror = () => {
    env.style.backgroundImage = "none";
    env.classList.add("missing");
    env.dataset.placeholder = placeholder;
  };
  img.src = path;
}

function renderHUD() {
  document.querySelector("#money").textContent = `${resources.get("money")} EUR`;
  document.querySelector("#income").textContent = `${resources.get("income")} EUR`;
  document.querySelector("#expenses").textContent = `${resources.get("expenses")} EUR`;
  document.querySelector("#clock").textContent = timeString();

  for (const key of ["energy", "focus", "health"]) {
    const value = resources.get(key);
    document.querySelector(`#${key}`).textContent = value;
    document.querySelector(`#${key}Bar`).style.width = `${value}%`;
  }

  const late = Math.max(0, (state.minutes - 21 * 60) / 240);
  const tired = (100 - resources.get("energy")) / 100;
  darkness.style.opacity = String(Math.min(.55, late * .22 + tired * .18));
}

function showToast(text) {
  toast.textContent = text;
  toast.classList.remove("hidden");
  clearTimeout(showToast.timer);
  showToast.timer = setTimeout(() => toast.classList.add("hidden"), 2200);
}

function renderScene() {
  const scene = scenes[state.scene];
  setImageWithFallback(assets.resolve(scene.assetId, "world"), t(scene.placeholderKey));
  deskHotspots.classList.toggle("hidden", state.scene !== "desk");
  mapHotspots.classList.toggle("hidden", state.scene !== "map");
  back.classList.toggle("hidden", state.scene === "desk");
  rain.classList.toggle("hidden", state.scene !== "desk");
  renderHUD();
}

function useCatalogItem(itemId) {
  const item = catalog.get(itemId);
  if (!item) throw new Error(`Unknown catalog item: ${itemId}`);
  const effects = item.effects || {};
  if (effects.time_minutes) passTime(effects.time_minutes);
  for (const [resourceId, delta] of Object.entries(effects)) {
    if (resourceId === "time_minutes") continue;
    if (resources.getDefinition(resourceId)) resources.add(resourceId, delta, `item:${itemId}`);
  }
  modAPI.events.emit("item:used", {itemId, item});
}

function action(name) {
  switch (name) {
    case "coffee":
      useCatalogItem("coffee_starter_white");
      showToast(t("toast.coffee"));
      break;
    case "phone": showToast(t("toast.phone_placeholder")); break;
    case "notebook": showToast(t("toast.notebook_placeholder")); break;
    case "map": state.scene = "map"; break;
    case "storage": state.scene = "storage"; break;
    case "desk": state.scene = "desk"; break;
    case "client": showToast(t("toast.client_placeholder")); break;
    case "hardware": showToast(t("toast.hardware_placeholder")); break;
  }
  modAPI.events.emit("action", {name, scene: state.scene});
  renderScene();
}

document.addEventListener("click", event => {
  const target = event.target.closest("[data-action]");
  if (target) action(target.dataset.action);
});

async function bootstrap() {
  await loadLocale("de");
  document.title = t("app.title", "Founder Sim");
  [resources, assets, catalog] = await Promise.all([
    ResourceRegistry.fromUrl("data/resources.json"),
    AssetRegistry.fromUrl("assets/manifest.json"),
    CatalogRegistry.fromUrl("data/catalog/items.json")
  ]);

  modAPI = createModAPI({
    resources,
    assets,
    catalog,
    i18n: {t, registerTranslations, applyTranslations}
  });
  window.FounderSimModAPI = modAPI;
  await loadMods(modAPI, registerTranslations);
  applyTranslations();
  resources.subscribe(() => renderHUD());
  modAPI.events.emit("game:ready", {apiVersion: modAPI.apiVersion});
  renderScene();
}

bootstrap().catch(error => {
  console.error(error);
  showToast(`${t("errors.startup_prefix", "Startup error")}: ${error.message}`);
});
