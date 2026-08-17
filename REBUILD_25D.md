# Founder Sim — 2.5D Lighting Rebuild

This branch is the clean-room restart for the room rendering pipeline.

## Principle

Do not fake sunlight with hand-drawn 2D beam polygons and do not composite visible shadow-proxy geometry over the art.

Use Godot's real 3D lighting pipeline as the foundation:

- Forward+ renderer
- DirectionalLight3D for sun/moon
- SpotLight3D / OmniLight3D for practical lights
- real 3D geometry for wall, floor, window opening, frame and furniture
- orthographic Camera3D for a flat 2.5D presentation
- Environment + PhysicalSkyMaterial for day/night response
- Global Illumination (initially SDFGI for dynamic testing; LightmapGI can be evaluated for mostly-static rooms)
- pixel-art/stylized textures are presentation, not substitutes for geometry

## Upstream references

Use the official Godot demo projects as implementation references instead of inventing a custom lighting system:

- godotengine/godot-demo-projects/3d/lights_and_shadows
- godotengine/godot-demo-projects/3d/global_illumination

The first milestone is deliberately small: a real 3D empty room with a true window opening, orthographic fixed camera, PhysicalSkyMaterial, DirectionalLight3D and GI. It must produce believable daylight and window shadows with no custom sunlight drawing code.

Only after that works do we add a single simple desk mesh, then one practical lamp, then pixel-art materials.

## Safety

The existing `main` history is preserved. This rebuild happens on `rebuild-25d-lighting` until it is demonstrably better.
