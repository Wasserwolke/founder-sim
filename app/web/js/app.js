import {loadLocale, t, applyTranslations, registerTranslations} from "./i18n.js";
import {state, passTime, timeString} from "./state.js";
import {ResourceRegistry} from "./core/resource-registry.js";
import {AssetRegistry} from "./core/asset-registry.js";
import {CatalogRegistry} from "./core/catalog-registry.js";
import {ObjectRegistry} from "./core/object-registry.js";
import {SceneRenderer} from "./ui/scene-renderer.js";
import {createModAPI} from "./modding/mod-api.js";
import {loadMods} from "./modding/mod-loader.js";

let resources;
let assets;
let catalog;
let objects;
let sceneData;
let modAPI;
let renderer;

/** Return a required DOM node and fail early when markup and renderer drift apart. */
function requiredElement(id) {
  const element = document.getElementById(id);
  if (!element) throw new Error(`DOM contract violation: #${id} fehlt.`);
  return element;
}

const dom = {
  scene: requiredElement("scene"),
  environment: requiredElement("environment"),
  objectLayer: requiredElement("objectLayer"),
  backButton: requiredElement("backButton"),
  toast: requiredElement("toast"),
  rainFx: requiredElement("rainFx"),
  darknessFx: requiredElement("darknessFx")
};

/** Render all resource values that are permanently visible in the top HUD. */
function renderHUD() {
  document.querySelector("#money").textContent = `${resources.get("money")} EUR`;
  document.querySelector("#income").textContent = `${resources.get("income")} EUR`;
  document.querySelector("#expenses").textContent = `${resources.get("expenses")} EUR`;
  document.querySelector("#clock").textContent = timeString();

  for (const id of ["energy", "focus", "health"]) {
    const value = resources.get(id);
    document.querySelector(`#${id}`).textContent = value;
    document.querySelector(`#${id}Bar`).style.width = `${value}%`;
  }

  const lateNight = Math.max(0, (state.minutes - 21 * 60) / 240);
  const tiredness = (100 - resources.get("energy")) / 100;
  renderer?.setDarkness(Math.min(0.32, lateNight * 0.12 + tiredness * 0.08));
}

/** Show a short non-blocking status message at the bottom of the scene. */
function showToast(text) {
  dom.toast.textContent = text;
  dom.toast.classList.add("show");
  clearTimeout(showToast.timer);
  showToast.timer = setTimeout(() => dom.toast.classList.remove("show"), 1900);
}

/** Render the active scene and notify mods after the visual state is ready. */
function renderScene() {
  const scene = sceneData.scenes[state.scene];
  if (!scene) throw new Error(`Unknown scene: ${state.scene}`);
  renderer.render(state.scene, scene);
  renderHUD();
  modAPI?.events.emit("scene:changed", {scene: state.scene});
}

/** Apply a catalog item's configured resource and time effects. */
function useItem(id) {
  const item = catalog.get(id);
  if (!item) return;

  const effects = item.effects || {};
  if (effects.time_minutes) passTime(effects.time_minutes);

  for (const [resource, delta] of Object.entries(effects)) {
    if (resource !== "time_minutes" && resources.getDefinition(resource)) {
      resources.add(resource, delta, `item:${id}`);
    }
  }
}

/** Show the catalog description for inspectable physical objects. */
function inspectObject(objectId) {
  const item = catalog.get(objectId);
  if (!item?.description_key) {
    showToast(objectId || t("toast.inspect_placeholder", "Objekt"));
    return;
  }
  showToast(t(item.description_key, objectId));
}

/** Route prototype interactions without adding object-specific UI handlers for every new asset. */
function action(name, objectId = null) {
  switch (name) {
    case "coffee":
      useItem("coffee_starter_white");
      showToast(t("toast.coffee"));
      break;
    case "phone":
      showToast(t("toast.phone_placeholder"));
      break;
    case "notebook":
      showToast(t("toast.notebook_placeholder"));
      break;
    case "inspect":
      inspectObject(objectId);
      break;
    case "map":
      state.scene = "map";
      break;
    case "storage":
      state.scene = "storage";
      break;
    case "desk":
      state.scene = "desk";
      break;
    case "vehicle":
      showToast(t("toast.vehicle"));
      break;
    case "client":
      showToast(t("toast.client_placeholder"));
      break;
    case "hardware":
      showToast(t("toast.hardware_placeholder"));
      break;
    default:
      return;
  }

  modAPI?.events.emit("action", {name, objectId, scene: state.scene});
  renderScene();
}

document.addEventListener("click", event => {
  const target = event.target.closest("[data-action]");
  if (target) action(target.dataset.action, target.dataset.objectId || null);
});

/** Load registries, mods and translations before constructing the first scene. */
async function bootstrap() {
  await loadLocale("de");
  applyTranslations();
  document.title = t("app.title", "Founder Sim");

  [resources, assets, catalog, objects, sceneData] = await Promise.all([
    ResourceRegistry.fromUrl("data/resources.json"),
    AssetRegistry.fromUrl("assets/manifest.json"),
    CatalogRegistry.fromUrl("data/catalog/items.json"),
    ObjectRegistry.fromUrl("data/objects.json"),
    fetch("data/scenes.json").then(response => response.json())
  ]);

  modAPI = createModAPI({resources, assets, catalog, objects, i18n: {t, registerTranslations, applyTranslations}});
  window.FounderSimModAPI = modAPI;
  await loadMods(modAPI, registerTranslations);
  applyTranslations();

  renderer = new SceneRenderer({dom, assets, objects, translate: t});
  resources.subscribe(renderHUD);
  renderScene();
}

bootstrap().catch(error => {
  console.error(error);
  showToast(`${t("errors.startup_prefix", "Startfehler")}: ${error.message}`);
});
