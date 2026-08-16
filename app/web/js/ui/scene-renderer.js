export class SceneRenderer {
  constructor({dom, assets, objects, translate}) {
    this.dom = dom;
    this.assets = assets;
    this.objects = objects;
    this.translate = translate;
    this.currentSceneId = null;
    this.currentEnvironmentUrl = null;
    this.currentCameraId = null;

    // Scene coordinates are tied to the untransformed source image. The complete
    // camera stage is then zoomed as one unit, so visuals and interactions stay aligned.
    this.dom.environment.addEventListener("load", () => {
      this.dom.scene.dataset.environmentReady = "true";
      this.syncObjectLayer();
    });
    this.dom.environment.addEventListener("error", () => {
      this.dom.scene.dataset.environmentReady = "false";
      this.dom.objectLayer.style.visibility = "hidden";
    });

    if (typeof ResizeObserver === "function") {
      this.resizeObserver = new ResizeObserver(() => this.syncObjectLayer());
      this.resizeObserver.observe(this.dom.cameraStage);
    } else {
      window.addEventListener("resize", () => this.syncObjectLayer());
    }
  }

  /** Render one environment and one camera state from declarative scene data. */
  render(sceneId, sceneDefinition, cameraId = null) {
    const environment = this.assets.resolve(sceneDefinition.environment_asset, "world");
    if (!environment) throw new Error(`Missing environment asset: ${sceneDefinition.environment_asset}`);

    const resolvedCamera = cameraId || sceneDefinition.initial_camera || "overview";
    const camera = sceneDefinition.cameras?.[resolvedCamera];
    if (!camera) throw new Error(`Unknown camera preset ${resolvedCamera} in scene ${sceneId}`);

    const environmentUrl = new URL(environment, document.baseURI).href;
    const environmentChanged = environmentUrl !== this.currentEnvironmentUrl;

    this.currentSceneId = sceneId;
    this.currentCameraId = resolvedCamera;
    this.dom.scene.dataset.scene = sceneId;
    this.dom.scene.dataset.camera = resolvedCamera;

    if (environmentChanged) {
      this.dom.scene.dataset.environmentReady = "loading";
      this.dom.objectLayer.style.visibility = "hidden";
      this.currentEnvironmentUrl = environmentUrl;
      this.dom.environment.src = environmentUrl;
      this.dom.environment.alt = "";
    }

    const instances = (sceneDefinition.instances || []).filter(instance => {
      const cameras = instance.cameras;
      return !Array.isArray(cameras) || cameras.length === 0 || cameras.includes(resolvedCamera);
    });
    this.dom.objectLayer.replaceChildren(...instances.map(instance => this.createObject(instance)));

    this.applyCamera(camera);
    this.updateBackButton(sceneId, resolvedCamera, sceneDefinition.initial_camera || "overview");
    this.dom.rainFx.hidden = true;

    if (!environmentChanged && this.dom.environment.complete && this.dom.environment.naturalWidth) {
      this.dom.scene.dataset.environmentReady = "true";
      this.syncObjectLayer();
    }
  }

  /** Animate one camera preset without swapping the environment image. */
  applyCamera(camera) {
    const scale = Number(camera.scale ?? 1);
    const x = Number(camera.x ?? 0);
    const y = Number(camera.y ?? 0);
    const duration = Number(camera.duration_ms ?? 550);

    this.dom.cameraStage.style.setProperty("--camera-scale", String(scale));
    this.dom.cameraStage.style.setProperty("--camera-x", `${x}%`);
    this.dom.cameraStage.style.setProperty("--camera-y", `${y}%`);
    this.dom.cameraStage.style.setProperty("--camera-duration", `${Math.max(0, duration)}ms`);
  }

  /** Match the object layer exactly to the visible source-image rectangle. */
  syncObjectLayer() {
    const image = this.dom.environment;
    const stage = this.dom.cameraStage;
    if (!image.naturalWidth || !image.naturalHeight || !stage.clientWidth || !stage.clientHeight) return;

    const scale = Math.min(stage.clientWidth / image.naturalWidth, stage.clientHeight / image.naturalHeight);
    const width = image.naturalWidth * scale;
    const height = image.naturalHeight * scale;

    Object.assign(this.dom.objectLayer.style, {
      left: `${(stage.clientWidth - width) / 2}px`,
      top: `${(stage.clientHeight - height) / 2}px`,
      width: `${width}px`,
      height: `${height}px`,
      visibility: "visible"
    });
  }

  /** Configure the shared back button for either camera-back or scene-back navigation. */
  updateBackButton(sceneId, cameraId, initialCamera) {
    if (sceneId === "office" && cameraId === initialCamera) {
      this.dom.backButton.hidden = true;
      return;
    }

    this.dom.backButton.hidden = false;
    this.dom.backButton.dataset.action = sceneId === "office" ? `camera:${initialCamera}` : "office";
    this.dom.backButton.dataset.objectId = "";
  }

  /** Apply simulation darkness without changing object coordinates. */
  setDarkness(opacity) {
    this.dom.darknessFx.style.opacity = String(opacity);
  }

  /** Build one interactive object instance from reusable type data plus placement. */
  createObject(instance) {
    const object = this.objects.resolve(instance);
    const action = object.action || object.default_action;
    if (!action) throw new Error(`Scene object has no action: ${object.type_id}`);

    const label = this.translate(object.label_key, object.type_id);
    const hint = object.hint_key ? this.translate(object.hint_key, "") : "";
    const button = document.createElement("button");
    const visual = document.createElement("span");
    const tooltip = document.createElement("span");

    button.type = "button";
    button.className = `scene-object scene-object--${object.kind || "generic"}`;
    button.dataset.objectId = object.type_id;
    button.dataset.instanceId = object.instance_id || "";
    button.dataset.action = action;
    button.style.left = `${object.x}%`;
    button.style.top = `${object.y}%`;
    button.style.width = `${object.w}%`;
    if (object.h != null) button.style.height = `${object.h}%`;
    button.style.zIndex = String(object.z ?? 1);
    button.setAttribute("aria-label", hint ? `${label}: ${hint}` : label);

    visual.className = "object-visual";
    const reference = object.placeholder ? null : this.assets.resolve(object.asset_id, object.variant || "world");
    if (reference) this.addAssetVisual(visual, reference);
    else this.addPlaceholderVisual(visual, label, object);

    tooltip.className = "object-tooltip";
    tooltip.textContent = hint ? `${label} · ${hint}` : label;

    button.append(visual, tooltip);
    return button;
  }

  /** Show a visible functional placeholder until a suitable standalone visual exists. */
  addPlaceholderVisual(host, label, object) {
    host.classList.add("object-visual--placeholder");
    const badge = document.createElement("span");
    badge.className = "placeholder-label";
    badge.textContent = label;
    if (object.expected_asset_path) {
      host.dataset.expectedAsset = object.expected_asset_path;
      host.title = `Asset folgt: ${object.expected_asset_path}`;
    }
    host.appendChild(badge);
  }

  /** Render either a standalone image or one cropped sprite from the shared prototype atlas. */
  addAssetVisual(host, reference) {
    if (!reference) return;

    if (typeof reference === "string") {
      const image = document.createElement("img");
      image.src = new URL(reference, document.baseURI).href;
      image.alt = "";
      image.draggable = false;
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
      image.draggable = false;
      image.style.width = `${atlasWidth / width * 100}%`;
      image.style.height = `${atlasHeight / height * 100}%`;
      image.style.left = `${-x / width * 100}%`;
      image.style.top = `${-y / height * 100}%`;

      clip.appendChild(image);
      host.appendChild(clip);
    }
  }
}
