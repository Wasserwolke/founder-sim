export class SceneRenderer {
  constructor({dom, assets, objects, translate}) {
    this.dom = dom;
    this.assets = assets;
    this.objects = objects;
    this.translate = translate;

    // Scene coordinates are tied to the rendered image, not to the browser viewport.
    // This keeps object placements stable when the window aspect ratio changes.
    this.dom.environment.addEventListener("load", () => this.syncObjectLayer());
    if (typeof ResizeObserver === "function") {
      this.resizeObserver = new ResizeObserver(() => this.syncObjectLayer());
      this.resizeObserver.observe(this.dom.scene);
    } else {
      window.addEventListener("resize", () => this.syncObjectLayer());
    }
  }

  /** Render one scene from declarative environment and object-placement data. */
  render(sceneId, sceneDefinition) {
    const environment = this.assets.resolve(sceneDefinition.environment_asset, "world");
    if (!environment) throw new Error(`Missing environment asset: ${sceneDefinition.environment_asset}`);

    this.dom.scene.dataset.scene = sceneId;
    this.dom.objectLayer.style.visibility = "hidden";
    this.dom.environment.src = new URL(environment, document.baseURI).href;
    this.dom.environment.alt = "";
    this.dom.objectLayer.replaceChildren(...(sceneDefinition.objects || []).map(instance => this.createObject(instance)));
    this.dom.backButton.hidden = sceneId === "desk";

    // Generated weather/light layers will be composed here in a later asset pass.
    this.dom.rainFx.hidden = true;

    if (this.dom.environment.complete) {
      requestAnimationFrame(() => this.syncObjectLayer());
    }
  }

  /** Match the object layer exactly to the visible image area produced by object-fit: contain. */
  syncObjectLayer() {
    const image = this.dom.environment;
    const scene = this.dom.scene;
    if (!image.naturalWidth || !image.naturalHeight || !scene.clientWidth || !scene.clientHeight) return;

    const scale = Math.min(scene.clientWidth / image.naturalWidth, scene.clientHeight / image.naturalHeight);
    const width = image.naturalWidth * scale;
    const height = image.naturalHeight * scale;

    Object.assign(this.dom.objectLayer.style, {
      left: `${(scene.clientWidth - width) / 2}px`,
      top: `${(scene.clientHeight - height) / 2}px`,
      width: `${width}px`,
      height: `${height}px`,
      visibility: "visible"
    });
  }

  /** Apply simulation darkness without changing object coordinates. */
  setDarkness(opacity) {
    this.dom.darknessFx.style.opacity = String(opacity);
  }

  /** Build one interactive visual object from reusable object data plus scene placement. */
  createObject(instance) {
    const object = this.objects.resolve(instance);
    const action = object.action || object.default_action;
    if (!action) throw new Error(`Scene object has no action: ${object.id}`);

    const label = this.translate(object.label_key, object.id);
    const hint = object.hint_key ? this.translate(object.hint_key, "") : "";
    const button = document.createElement("button");
    const visual = document.createElement("span");
    const tooltip = document.createElement("span");

    button.type = "button";
    button.className = `scene-object scene-object--${object.kind || "generic"}`;
    button.dataset.objectId = object.id;
    button.dataset.action = action;
    button.style.left = `${object.x}%`;
    button.style.top = `${object.y}%`;
    button.style.width = `${object.w}%`;
    button.style.zIndex = String(object.z ?? 1);
    button.setAttribute("aria-label", hint ? `${label}: ${hint}` : label);

    visual.className = "object-visual";
    this.addAssetVisual(visual, this.assets.resolve(object.asset_id, object.variant || "icon"));

    tooltip.className = "object-tooltip";
    tooltip.textContent = hint ? `${label} · ${hint}` : label;

    button.append(visual, tooltip);
    return button;
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
