const BUILD_VERSION = document.documentElement.dataset.build || "dev";
const versioned = path => `${path}?v=${encodeURIComponent(BUILD_VERSION)}`;

/** Minimal fallback used even when one of the runtime modules itself cannot be imported. */
function reportModuleLoadError(error) {
  const root = document.documentElement;
  const status = document.getElementById("startupStatus");
  const message = error?.message || String(error);
  console.error(error);
  root.dataset.runtime = "error";
  if (status) {
    status.hidden = false;
    status.classList.add("startup-status--error");
    status.textContent = `Startfehler: ${message}`;
  }
}

async function startRuntime() {
  const [
    i18nModule,
    stateModule,
    resourceModule,
    assetModule,
    catalogModule,
    objectModule,
    rendererModule,
    modApiModule,
    modLoaderModule
  ] = await Promise.all([
    import(versioned("./i18n.js")),
    import(versioned("./state.js")),
    import(versioned("./core/resource-registry.js")),
    import(versioned("./core/asset-registry.js")),
    import(versioned("./core/catalog-registry.js")),
    import(versioned("./core/object-registry.js")),
    import(versioned("./ui/scene-renderer.js")),
    import(versioned("./modding/mod-api.js")),
    import(versioned("./modding/mod-loader.js"))
  ]);

  const {loadLocale, t, applyTranslations, registerTranslations} = i18nModule;
  const {state, passTime, timeString} = stateModule;
  const {ResourceRegistry} = resourceModule;
  const {AssetRegistry} = assetModule;
  const {CatalogRegistry} = catalogModule;
  const {ObjectRegistry} = objectModule;
  const {SceneRenderer} = rendererModule;
  const {createModAPI} = modApiModule;
  const {loadMods} = modLoaderModule;

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
    cameraStage: requiredElement("cameraStage"),
    environment: requiredElement("environment"),
    objectLayer: requiredElement("objectLayer"),
    startupStatus: requiredElement("startupStatus"),
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

  /** Keep startup/render failures visible instead of leaving the player with a black scene. */
  function reportRuntimeError(error) {
    const message = error?.message || String(error);
    console.error(error);
    document.documentElement.dataset.runtime = "error";
    dom.startupStatus.hidden = false;
    dom.startupStatus.classList.add("startup-status--error");
    dom.startupStatus.textContent = `${t("errors.startup_prefix", "Startfehler")}: ${message}`;
  }

  /** Return the active scene definition and normalize an invalid camera to its default. */
  function activeScene() {
    const scene = sceneData.scenes[state.scene];
    if (!scene) throw new Error(`Unknown scene: ${state.scene}`);
    const defaultCamera = scene.initial_camera || "overview";
    if (!scene.cameras?.[state.camera]) state.camera = defaultCamera;
    return scene;
  }

  /** Render the active environment and camera state. */
  function renderScene() {
    const scene = activeScene();
    renderer.render(state.scene, scene, state.camera);
    renderHUD();
    modAPI?.events.emit("scene:changed", {scene: state.scene, camera: state.camera});
  }

  /** Enter another environment and always start at that environment's declared camera. */
  function enterScene(sceneId) {
    const scene = sceneData.scenes[sceneId];
    if (!scene) throw new Error(`Unknown scene: ${sceneId}`);
    state.scene = sceneId;
    state.camera = scene.initial_camera || "overview";
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

  /** Show the catalog description associated with a reusable object type. */
  function inspectObject(typeId) {
    const definition = objects.get(typeId);
    const catalogId = definition?.catalog_id;
    const item = catalogId ? catalog.get(catalogId) : null;
    if (!item?.description_key) {
      showToast(typeId || t("toast.inspect_placeholder", "Objekt"));
      return;
    }
    showToast(t(item.description_key, typeId));
  }

  /** Route prototype interactions without adding UI handlers for every individual instance. */
  function action(name, typeId = null, instanceId = null) {
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
      case "workspace:operations":
        showToast(t("toast.operations_placeholder"));
        break;
      case "workspace:management":
        showToast(t("toast.management_placeholder"));
        break;
      case "computer":
        showToast(t("toast.computer_placeholder"));
        break;
      case "inspect":
        inspectObject(typeId);
        break;
      case "camera:desk":
        state.camera = "desk";
        break;
      case "camera:overview":
        state.camera = "overview";
        break;
      case "map":
        enterScene("map");
        break;
      case "storage":
        enterScene("storage");
        break;
      case "office":
        enterScene("office");
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

    modAPI?.events.emit("action", {
      name,
      objectId: typeId,
      instanceId,
      scene: state.scene,
      camera: state.camera
    });
    renderScene();
  }

  document.addEventListener("click", event => {
    const target = event.target.closest("[data-action]");
    if (target) {
      action(target.dataset.action, target.dataset.objectId || null, target.dataset.instanceId || null);
    }
  });

  dom.environment.addEventListener("load", () => {
    document.documentElement.dataset.runtime = "ready";
    dom.startupStatus.hidden = true;
    dom.startupStatus.classList.remove("startup-status--error");
  });

  dom.environment.addEventListener("error", () => {
    reportRuntimeError(new Error(`Environment-Bild konnte nicht geladen werden: ${dom.environment.src}`));
  });

  /** Load registries, mods and translations before constructing the first environment. */
  async function bootstrap() {
    await loadLocale("de", BUILD_VERSION);
    applyTranslations();
    document.title = t("app.title", "Founder Sim");

    const sceneResponsePromise = fetch(versioned("data/scenes.json"), {cache: "no-store"});

    [resources, assets, catalog, objects, sceneData] = await Promise.all([
      ResourceRegistry.fromUrl(versioned("data/resources.json")),
      AssetRegistry.fromUrl(versioned("assets/manifest.json")),
      CatalogRegistry.fromUrl(versioned("data/catalog/items.json")),
      ObjectRegistry.fromUrl(versioned("data/objects.json")),
      sceneResponsePromise.then(async response => {
        if (!response.ok) throw new Error(`Scene data not found: ${response.url}`);
        return response.json();
      })
    ]);

    modAPI = createModAPI({resources, assets, catalog, objects, i18n: {t, registerTranslations, applyTranslations}});
    window.FounderSimModAPI = modAPI;
    await loadMods(modAPI, registerTranslations);
    applyTranslations();

    renderer = new SceneRenderer({dom, assets, objects, translate: t});
    resources.subscribe(renderHUD);
    renderScene();
  }

  try {
    await bootstrap();
  } catch (error) {
    reportRuntimeError(error);
  }
}

startRuntime().catch(reportModuleLoadError);
