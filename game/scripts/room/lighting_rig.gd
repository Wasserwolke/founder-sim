@tool
extends Control
class_name RoomLightingRig

enum WeatherPreset {
    CLEAR,
    CLOUDY,
    RAIN,
}

signal atmosphere_changed(hour: float, weather: int, room_fill_on: bool)
signal emitter_registered(emitter_id: StringName)

@export_group("Editor Preview")
@export var editor_preview_enabled := true:
    set(value):
        editor_preview_enabled = value
        _schedule_editor_refresh()

@export_range(0.0, 24.0, 0.05) var editor_hour := 19.5:
    set(value):
        editor_hour = fposmod(value, 24.0)
        _schedule_editor_refresh()

@export_enum("Clear", "Cloudy", "Rain") var editor_weather: int = WeatherPreset.CLEAR:
    set(value):
        editor_weather = clampi(value, WeatherPreset.CLEAR, WeatherPreset.RAIN)
        _schedule_editor_refresh()

@export var editor_room_fill_on := false:
    set(value):
        editor_room_fill_on = value
        _schedule_editor_refresh()

@export_range(0.0, 1.5, 0.01) var editor_room_fill_strength := 0.55:
    set(value):
        editor_room_fill_strength = clampf(value, 0.0, 1.5)
        _schedule_editor_refresh()

@export_range(0.0, 2.5, 0.01) var editor_sunlight_multiplier := 1.0:
    set(value):
        editor_sunlight_multiplier = clampf(value, 0.0, 2.5)
        _schedule_editor_refresh()

@export_range(0.0, 2.0, 0.01) var editor_window_bounce_multiplier := 1.0:
    set(value):
        editor_window_bounce_multiplier = clampf(value, 0.0, 2.0)
        _schedule_editor_refresh()

@export_group("Animation")
@export_range(0.05, 3.0, 0.05) var transition_seconds := 0.55

@onready var canvas_modulate: CanvasModulate = %CanvasModulate
@onready var ambient_wash: ColorRect = %AmbientWash
@onready var exterior_response: ColorRect = %ExteriorResponse
@onready var window_bounce_light: PointLight2D = %WindowBounceLight
@onready var sun_projection_light: PointLight2D = %SunProjectionLight
@onready var room_fill_light: PointLight2D = %RoomFillLight
@onready var vignette: ColorRect = %Vignette
@onready var dynamic_lights: Node2D = %DynamicLights
@onready var dynamic_occluders: Node2D = %DynamicOccluders

var _runtime_hour := 19.5
var _runtime_weather: int = WeatherPreset.CLEAR
var _runtime_room_fill_on := false
var _runtime_room_fill_strength := 0.55
var _runtime_sunlight_multiplier := 1.0
var _runtime_window_bounce_multiplier := 1.0
var _manual_override := false
var _visual_state: Dictionary = {}
var _target_state: Dictionary = {}
var _emitters: Dictionary = {}
var _emitter_category_state: Dictionary = {}
var _sun_projection_texture: ImageTexture


func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    if not is_in_group("room_lighting_rig"):
        add_to_group("room_lighting_rig")
    _resolve_layer_refs()
    _ensure_sun_projection_texture()
    set_process(true)
    if Engine.is_editor_hint():
        _refresh_editor_preview(true)
    else:
        follow_game_time(GameState.minutes, false)
        call_deferred("_refresh_registered_emitters")


func _process(delta: float) -> void:
    if _target_state.is_empty():
        return
    if _visual_state.is_empty() or transition_seconds <= 0.05:
        _visual_state = _target_state.duplicate(true)
        _apply_visual_state(_visual_state)
        return
    var response := 1.0 - exp(-delta * 6.0 / maxf(transition_seconds, 0.05))
    _visual_state = _blend_states(_visual_state, _target_state, clampf(response, 0.0, 1.0))
    _apply_visual_state(_visual_state)


func follow_game_time(minutes: int, animated := true) -> void:
    if _manual_override:
        return
    _set_runtime_state(float(minutes) / 60.0, _runtime_weather, _runtime_room_fill_on, _runtime_room_fill_strength, animated)


func set_debug_state(hour: float, weather: int, room_fill_on: bool, room_fill_strength: float, animated := true) -> void:
    _manual_override = true
    _set_runtime_state(hour, weather, room_fill_on, room_fill_strength, animated)


func set_debug_detail_multipliers(sunlight_multiplier_value: float, window_bounce_multiplier_value: float) -> void:
    _runtime_sunlight_multiplier = clampf(sunlight_multiplier_value, 0.0, 2.5)
    _runtime_window_bounce_multiplier = clampf(window_bounce_multiplier_value, 0.0, 2.0)
    _set_runtime_state(_runtime_hour, _runtime_weather, _runtime_room_fill_on, _runtime_room_fill_strength, true)


func clear_debug_override(minutes: int, animated := true) -> void:
    _manual_override = false
    _runtime_weather = WeatherPreset.CLEAR
    _runtime_room_fill_on = false
    _runtime_room_fill_strength = 0.55
    _runtime_sunlight_multiplier = 1.0
    _runtime_window_bounce_multiplier = 1.0
    _set_runtime_state(float(minutes) / 60.0, _runtime_weather, _runtime_room_fill_on, _runtime_room_fill_strength, animated)


func has_debug_override() -> bool:
    return _manual_override


func current_hour() -> float:
    return _runtime_hour


func current_weather() -> int:
    return _runtime_weather


func room_light_is_on() -> bool:
    return _runtime_room_fill_on


func room_light_strength() -> float:
    return _runtime_room_fill_strength


func sunlight_multiplier() -> float:
    return _runtime_sunlight_multiplier


func window_bounce_multiplier() -> float:
    return _runtime_window_bounce_multiplier


func register_emitter(
    emitter_id: StringName,
    emitter: Light2D,
    base_energy := 1.0,
    category: StringName = &"local"
) -> void:
    if emitter == null or emitter_id == StringName():
        return
    _emitters[emitter_id] = {
        "node": emitter,
        "base_energy": maxf(float(base_energy), 0.0),
        "category": category,
    }
    _apply_emitter_state(emitter_id)
    emitter_registered.emit(emitter_id)


func unregister_emitter(emitter_id: StringName) -> void:
    _emitters.erase(emitter_id)


func set_emitter_category_state(category: StringName, enabled: bool, multiplier: float) -> void:
    _emitter_category_state[category] = {
        "enabled": enabled,
        "multiplier": clampf(multiplier, 0.0, 3.0),
    }
    for emitter_id in _emitters.keys():
        var entry = _emitters[emitter_id]
        if entry is Dictionary and entry.get("category", &"local") == category:
            _apply_emitter_state(emitter_id)


func emitter_category_enabled(category: StringName) -> bool:
    var state = _emitter_category_state.get(category, {"enabled": true})
    return bool(state.get("enabled", true))


func emitter_category_multiplier(category: StringName) -> float:
    var state = _emitter_category_state.get(category, {"multiplier": 1.0})
    return float(state.get("multiplier", 1.0))


func get_dynamic_light_root() -> Node2D:
    _resolve_layer_refs()
    return dynamic_lights


func get_dynamic_occluder_root() -> Node2D:
    _resolve_layer_refs()
    return dynamic_occluders


func _refresh_registered_emitters() -> void:
    for emitter_id in _emitters.keys():
        _apply_emitter_state(emitter_id)


func _apply_emitter_state(emitter_id: StringName) -> void:
    var entry = _emitters.get(emitter_id)
    if not (entry is Dictionary):
        return
    var emitter = entry.get("node")
    if not (emitter is Light2D) or not is_instance_valid(emitter):
        return
    var category: StringName = entry.get("category", &"local")
    var category_state = _emitter_category_state.get(category, {"enabled": true, "multiplier": 1.0})
    emitter.enabled = bool(category_state.get("enabled", true))
    emitter.energy = float(entry.get("base_energy", 1.0)) * float(category_state.get("multiplier", 1.0))


func _set_runtime_state(hour: float, weather: int, room_fill_on: bool, room_fill_strength_value: float, animated: bool) -> void:
    _runtime_hour = fposmod(hour, 24.0)
    _runtime_weather = clampi(weather, WeatherPreset.CLEAR, WeatherPreset.RAIN)
    _runtime_room_fill_on = room_fill_on
    _runtime_room_fill_strength = clampf(room_fill_strength_value, 0.0, 1.5)
    _set_target_state(_calculate_visual_state(), not animated)
    atmosphere_changed.emit(_runtime_hour, _runtime_weather, _runtime_room_fill_on)


func _schedule_editor_refresh() -> void:
    if not Engine.is_editor_hint() or not is_node_ready():
        return
    call_deferred("_refresh_editor_preview", false)


func _refresh_editor_preview(immediate := false) -> void:
    if not Engine.is_editor_hint() or not editor_preview_enabled:
        return
    _runtime_hour = editor_hour
    _runtime_weather = editor_weather
    _runtime_room_fill_on = editor_room_fill_on
    _runtime_room_fill_strength = editor_room_fill_strength
    _runtime_sunlight_multiplier = editor_sunlight_multiplier
    _runtime_window_bounce_multiplier = editor_window_bounce_multiplier
    _set_target_state(_calculate_visual_state(), immediate)


func _set_target_state(state: Dictionary, immediate: bool) -> void:
    _target_state = state
    if immediate or _visual_state.is_empty():
        _visual_state = state.duplicate(true)
        _apply_visual_state(_visual_state)


func _calculate_visual_state() -> Dictionary:
    var h := fposmod(_runtime_hour, 24.0)
    var daylight := 0.0
    if h >= 5.4 and h <= 20.6:
        daylight = maxf(0.0, sin(((h - 5.4) / 15.2) * PI))

    var dawn := _bell(h, 7.15, 1.45)
    var dusk := _bell(h, 18.45, 1.65)
    var golden := maxf(dawn, dusk)
    var night := 1.0 - daylight

    var cloudiness := 0.0
    if _runtime_weather == WeatherPreset.CLOUDY:
        cloudiness = 0.48
    elif _runtime_weather == WeatherPreset.RAIN:
        cloudiness = 0.80

    var day_canvas := Color(1.0, 0.995, 0.97, 1.0)
    var overcast_canvas := Color(0.84, 0.88, 0.90, 1.0)
    var night_canvas := Color(0.34, 0.40, 0.52, 1.0)
    var canvas_color := night_canvas.lerp(day_canvas, daylight)
    canvas_color = canvas_color.lerp(overcast_canvas, cloudiness * (0.28 + daylight * 0.34))

    var ambient_alpha := clampf(0.008 + night * 0.13 + cloudiness * 0.055, 0.0, 0.22)
    var ambient_color := Color(0.02, 0.05, 0.11, ambient_alpha)

    var direct_sun := daylight * (1.0 - cloudiness * 0.96)
    var sun_progress := clampf((h - 6.0) / 13.0, 0.0, 1.0)
    var sun_color := Color(1.0, 0.93, 0.76, 1.0).lerp(
        Color(1.0, 0.64, 0.29, 1.0),
        clampf(golden * 1.08, 0.0, 1.0)
    )

    # The aperture stays fixed at the visible window. Only the projected
    # direction rotates. This makes the distant floor footprint move much
    # farther than the light at the sill, matching a real window projection.
    var sun_energy := clampf(
        direct_sun * (1.18 + golden * 1.28) * _runtime_sunlight_multiplier,
        0.0,
        4.2
    )
    var sun_rotation := lerpf(deg_to_rad(-24.0), deg_to_rad(24.0), sun_progress)
    var sun_scale := lerpf(1.62, 1.44, sin(sun_progress * PI))

    var window_bounce_energy := clampf(
        daylight * (0.32 + golden * 0.46) * (1.0 - cloudiness * 0.72) * _runtime_window_bounce_multiplier,
        0.0,
        1.45
    )
    var window_bounce_color := Color(0.97, 0.98, 1.0, 1.0).lerp(
        Color(1.0, 0.73, 0.40, 1.0),
        clampf(golden * 1.08, 0.0, 1.0)
    )

    var exterior_darkness := clampf(pow(night, 1.28) * 0.72 + cloudiness * 0.12, 0.0, 0.82)
    var exterior_tint := Color(0.025, 0.055, 0.13, 1.0).lerp(Color(0.08, 0.10, 0.13, 1.0), cloudiness * 0.68)

    var fill_energy := 0.0
    if _runtime_room_fill_on:
        fill_energy = clampf(_runtime_room_fill_strength * (0.34 + night * 0.42), 0.0, 0.95)

    return {
        "canvas_color": canvas_color,
        "ambient_color": ambient_color,
        "sun_color": sun_color,
        "sun_energy": sun_energy,
        "sun_rotation": sun_rotation,
        "sun_scale": sun_scale,
        "window_bounce_color": window_bounce_color,
        "window_bounce_energy": window_bounce_energy,
        "exterior_tint": exterior_tint,
        "exterior_darkness": exterior_darkness,
        "room_fill_energy": fill_energy,
        "vignette_strength": clampf(0.045 + night * 0.13 + cloudiness * 0.018, 0.04, 0.20),
    }


func _blend_states(from_state: Dictionary, to_state: Dictionary, weight: float) -> Dictionary:
    var canvas_from: Color = from_state.get("canvas_color", Color.WHITE)
    var canvas_to: Color = to_state.get("canvas_color", Color.WHITE)
    var ambient_from: Color = from_state.get("ambient_color", Color.TRANSPARENT)
    var ambient_to: Color = to_state.get("ambient_color", Color.TRANSPARENT)
    var sun_from: Color = from_state.get("sun_color", Color.WHITE)
    var sun_to: Color = to_state.get("sun_color", Color.WHITE)
    var bounce_from: Color = from_state.get("window_bounce_color", Color.WHITE)
    var bounce_to: Color = to_state.get("window_bounce_color", Color.WHITE)
    var exterior_from: Color = from_state.get("exterior_tint", Color.WHITE)
    var exterior_to: Color = to_state.get("exterior_tint", Color.WHITE)

    return {
        "canvas_color": canvas_from.lerp(canvas_to, weight),
        "ambient_color": ambient_from.lerp(ambient_to, weight),
        "sun_color": sun_from.lerp(sun_to, weight),
        "sun_energy": lerpf(float(from_state.get("sun_energy", 0.0)), float(to_state.get("sun_energy", 0.0)), weight),
        "sun_rotation": lerp_angle(float(from_state.get("sun_rotation", 0.0)), float(to_state.get("sun_rotation", 0.0)), weight),
        "sun_scale": lerpf(float(from_state.get("sun_scale", 1.5)), float(to_state.get("sun_scale", 1.5)), weight),
        "window_bounce_color": bounce_from.lerp(bounce_to, weight),
        "window_bounce_energy": lerpf(float(from_state.get("window_bounce_energy", 0.0)), float(to_state.get("window_bounce_energy", 0.0)), weight),
        "exterior_tint": exterior_from.lerp(exterior_to, weight),
        "exterior_darkness": lerpf(float(from_state.get("exterior_darkness", 0.0)), float(to_state.get("exterior_darkness", 0.0)), weight),
        "room_fill_energy": lerpf(float(from_state.get("room_fill_energy", 0.0)), float(to_state.get("room_fill_energy", 0.0)), weight),
        "vignette_strength": lerpf(float(from_state.get("vignette_strength", 0.0)), float(to_state.get("vignette_strength", 0.0)), weight),
    }


func _apply_visual_state(state: Dictionary) -> void:
    _resolve_layer_refs()
    _ensure_sun_projection_texture()
    if not is_instance_valid(canvas_modulate) or not is_instance_valid(ambient_wash):
        return

    canvas_modulate.color = state.get("canvas_color", Color.WHITE)
    ambient_wash.color = state.get("ambient_color", Color.TRANSPARENT)

    var exterior_material := _shader_material(exterior_response)
    if exterior_material != null:
        exterior_material.set_shader_parameter("tint", state.get("exterior_tint", Color.WHITE))
        exterior_material.set_shader_parameter("darkness", float(state.get("exterior_darkness", 0.0)))

    if is_instance_valid(window_bounce_light):
        window_bounce_light.color = state.get("window_bounce_color", Color.WHITE)
        window_bounce_light.energy = float(state.get("window_bounce_energy", 0.0))
        window_bounce_light.enabled = window_bounce_light.energy > 0.004

    if is_instance_valid(sun_projection_light):
        sun_projection_light.texture = _sun_projection_texture
        sun_projection_light.color = state.get("sun_color", Color.WHITE)
        sun_projection_light.energy = float(state.get("sun_energy", 0.0))
        sun_projection_light.rotation = float(state.get("sun_rotation", 0.0))
        sun_projection_light.texture_scale = float(state.get("sun_scale", 1.5))
        sun_projection_light.enabled = sun_projection_light.energy > 0.004

    if is_instance_valid(room_fill_light):
        room_fill_light.energy = float(state.get("room_fill_energy", 0.0))
        room_fill_light.enabled = room_fill_light.energy > 0.004

    var vignette_material := _shader_material(vignette)
    if vignette_material != null:
        vignette_material.set_shader_parameter("strength", float(state.get("vignette_strength", 0.0)))


func _ensure_sun_projection_texture() -> void:
    if _sun_projection_texture != null:
        return

    # The texture is centered on the lower middle of the visible window.
    # Everything above the sill is transparent. Below it, the two panes form
    # one broad projection with a deliberately strong center-mullion shadow.
    # Rotating the PointLight2D around the fixed sill makes the far end travel
    # much farther than the near end without moving the light source itself.
    var size := 768
    var center := float(size) * 0.5
    var start_y := center + 5.0
    var end_y := float(size) - 4.0
    var image := Image.create_empty(size, size, false, Image.FORMAT_RGBA8)

    for y in range(size):
        var fy := float(y)
        if fy < start_y:
            continue
        var t := clampf((fy - start_y) / maxf(end_y - start_y, 1.0), 0.0, 1.0)
        var vertical := smoothstep(0.0, 0.035, t) * (1.0 - smoothstep(0.90, 1.0, t))
        var outer_half := lerpf(212.0, 184.0, t)
        var outer_feather := lerpf(10.0, 24.0, t)
        var mullion_half := lerpf(9.0, 18.0, t)
        var mullion_feather := lerpf(3.0, 8.0, t)
        var floor_gain := lerpf(0.82, 1.0, smoothstep(0.10, 0.82, t))

        for x in range(size):
            var dx := absf(float(x) - center)
            var outer := 1.0 - smoothstep(outer_half, outer_half + outer_feather, dx)
            var mullion_shadow := smoothstep(mullion_half, mullion_half + mullion_feather, dx)
            var intensity := clampf(vertical * outer * mullion_shadow * floor_gain, 0.0, 1.0)
            if intensity <= 0.001:
                continue
            image.set_pixel(x, y, Color(intensity, intensity, intensity, intensity))

    _sun_projection_texture = ImageTexture.create_from_image(image)


func _resolve_layer_refs() -> void:
    if not is_instance_valid(canvas_modulate):
        canvas_modulate = get_node_or_null(NodePath("%CanvasModulate")) as CanvasModulate
    if not is_instance_valid(ambient_wash):
        ambient_wash = get_node_or_null(NodePath("%AmbientWash")) as ColorRect
    if not is_instance_valid(exterior_response):
        exterior_response = get_node_or_null(NodePath("%ExteriorResponse")) as ColorRect
    if not is_instance_valid(window_bounce_light):
        window_bounce_light = get_node_or_null(NodePath("%WindowBounceLight")) as PointLight2D
    if not is_instance_valid(sun_projection_light):
        sun_projection_light = get_node_or_null(NodePath("%SunProjectionLight")) as PointLight2D
    if not is_instance_valid(room_fill_light):
        room_fill_light = get_node_or_null(NodePath("%RoomFillLight")) as PointLight2D
    if not is_instance_valid(vignette):
        vignette = get_node_or_null(NodePath("%Vignette")) as ColorRect
    if not is_instance_valid(dynamic_lights):
        dynamic_lights = get_node_or_null(NodePath("%DynamicLights")) as Node2D
    if not is_instance_valid(dynamic_occluders):
        dynamic_occluders = get_node_or_null(NodePath("%DynamicOccluders")) as Node2D


func _shader_material(layer: CanvasItem) -> ShaderMaterial:
    if not is_instance_valid(layer):
        return null
    return layer.material as ShaderMaterial


func _bell(hour: float, center: float, width: float) -> float:
    var distance := absf(fposmod(hour - center + 12.0, 24.0) - 12.0)
    return exp(-pow(distance / maxf(width, 0.01), 2.0))
