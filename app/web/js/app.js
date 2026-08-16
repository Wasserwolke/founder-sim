import {loadLocale,t,applyTranslations,registerTranslations} from "./i18n.js";
import {ResourceRegistry} from "./core/resource-registry.js";
import {AssetRegistry} from "./core/asset-registry.js";
import {CatalogRegistry} from "./core/catalog-registry.js";
import {createModAPI} from "./modding/mod-api.js";
import {loadMods} from "./modding/mod-loader.js";

const state = {scene: "desk", minutes: 19 * 60 + 30};
let resources;
let assets;
let catalog;
let sceneData;
let modAPI;

/** Return a required DOM node and fail early when markup and renderer drift apart. */
function requiredElement(id) {
  const element = document.getElementById(id);
  if (!element) throw new Error(`DOM contract violation: #${id} fehlt.`);
  return element;
}

const dom = {
  scene: requiredElement("scene"),
  environment: requiredElement("environment"),
  hotspotLayer: requiredElement("hotspotLayer"),
  backButton: requiredElement("backButton"),
  toast: requiredElement("toast"),
  rainFx: requiredElement("rainFx"),
  darknessFx: requiredElement("darknessFx")
};

/** Format the simulated clock as HH:MM. */
function timeString() {
  const hours = Math.floor(state.minutes / 60) % 24;
  const minutes = state.minutes % 60;
  return `${String(hours).padStart(2, "0")}:${String(minutes).padStart(2, "0")}`;
}

/** Advance simulated time while keeping it inside one 24-hour day. */
function passTime(minutes) {
  state.minutes = (state.minutes + minutes) % (24 * 60);
}

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
  dom.darknessFx.style.opacity = String(Math.min(0.32, lateNight * 0.12 + tiredness * 0.08));
}

/** Show a short non-blocking status message at the bottom of the scene. */
function showToast(text) {
  dom.toast.textContent = text;
  dom.toast.classList.add("show");
  clearTimeout(showToast.timer);
  showToast.timer = setTimeout(() => dom.toast.classList.remove("show"), 1900);
}

/** Add either a normal image or a cropped atlas image to a hotspot button. */
function addAssetVisual(host, reference) {
  if (!reference) return;

  if (typeof reference === "string") {
    const image = document.createElement("img");
    image.src = new URL(reference, document.baseURI).href;
    image.alt = "";
    host.appendChild(image);
    return;
  }

  if (reference.atlas && reference.crop && reference.atlas_size) {
    const [x, y, width, height] = reference.crop;
    const [atlasWidth, atlasHeight] = reference.atlas_size;
    const clip = document.createElement("span");
    const image = document.createElement("img");

    clip.className = "atlas-clip";
    clip.style.aspectRatio = `${width}/${height}`;
    image.src = new URL(reference.atlas, document.baseURI).href;
    image.alt = "";
    image.style.width = `${atlasWidth / width * 100}%`;
    image.style.height = `${atlasHeight / height * 100}%`;
    image.style.left = `${-x / width * 100}%`;
    image.style.top = `${-y / height * 100}%`;

    clip.appendChild(image);
    host.appendChild(clip);
  }
}

/** Build one interactive scene hotspot from the declarative scene configuration. */
function createHotspot(hotspot) {
  const button = document.createElement("button");
  const label = t(hotspot.label_key, hotspot.id);

  button.type = "button";
  button.className = "hotspot";
  button.dataset.action = hotspot.action;
  button.style.left = `${hotspot.x}%`;
  button.style.top = `${hotspot.y}%`;
  button.style.width = `${hotspot.w}%`;
  button.setAttribute("aria-label", label);

  addAssetVisual(button, assets.resolve(hotspot.asset_id, hotspot.variant || "icon"));

  const tip = document.createElement("span");
  tip.className = "tip";
  tip.textContent = [label, hotspot.hint_key ? t(hotspot.hint_key, "") : ""].filter(Boolean).join(" - ");
  button.appendChild(tip);
  return button;
}

/** Render one scene using one stable base image; composited visual layers come later. */
function renderScene() {
  const scene = sceneData.scenes[state.scene];
  if (!scene) throw new Error(`Unknown scene: ${state.scene}`);

  const environment = assets.resolve(scene.environment_asset, "world");
  if (!environment) throw new Error(`Missing environment asset: ${scene.environment_asset}`);

  const environmentUrl = new URL(environment, document.baseURI).href;
  dom.scene.dataset.scene = state.scene;
  dom.environment.style.backgroundImage = `url("${environmentUrl}")`;
  dom.hotspotLayer.replaceChildren(...(scene.hotspots || []).map(createHotspot));
  dom.backButton.hidden = state.scene === "desk";

  // The old procedural rain was only a placeholder and obscured the first visual milestone.
  dom.rainFx.hidden = true;

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

/** Route prototype actions and rerender only the resulting scene state. */
function action(name) {
  switch (name) {
    case "coffee": useItem("coffee_starter_white"); showToast(t("toast.coffee")); break;
    case "phone": showToast(t("toast.phone_placeholder")); break;
    case "notebook": showToast(t("toast.notebook_placeholder")); break;
    case "map": state.scene = "map"; break;
    case "storage": state.scene = "storage"; break;
    case "desk": state.scene = "desk"; break;
    case "vehicle": showToast(t("toast.vehicle")); break;
    case "client": showToast(t("toast.client_placeholder")); break;
    case "hardware": showToast(t("toast.hardware_placeholder")); break;
    case "inspect_vacuum": showToast(t("toast.vacuum")); break;
    case "inspect_caddy": showToast(t("toast.caddy")); break;
    default: return;
  }

  modAPI?.events.emit("action", {name, scene: state.scene});
  renderScene();
}

document.addEventListener("click", event => {
  const target = event.target.closest("[data-action]");
  if (target) action(target.dataset.action);
});

/** Load data registries, mods and translations before the first scene is rendered. */
async function bootstrap() {
  await loadLocale("de");
  applyTranslations();
  document.title = t("app.title", "Founder Sim");

  [resources, assets, catalog, sceneData] = await Promise.all([
    ResourceRegistry.fromUrl("data/resources.json"),
    AssetRegistry.fromUrl("assets/manifest.json"),
    CatalogRegistry.fromUrl("data/catalog/items.json"),
    fetch("data/scenes.json").then(response => response.json())
  ]);

  modAPI = createModAPI({resources, assets, catalog, i18n: {t, registerTranslations, applyTranslations}});
  window.FounderSimModAPI = modAPI;
  await loadMods(modAPI, registerTranslations);
  applyTranslations();

  resources.subscribe(renderHUD);
  renderScene();
}

bootstrap().catch(error => {
  console.error(error);
  showToast(`${t("errors.startup_prefix", "Startfehler")}: ${error.message}`);
});
