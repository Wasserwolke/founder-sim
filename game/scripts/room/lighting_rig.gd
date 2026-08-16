@tool
extends Control
class_name RoomLightingRig

enum WeatherPreset {
    CLEAR,
    CLOUDY,
    RAIN,
}

signal atmosphere_changed(hour: float, weather: int, room_light_on: bool)
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

@export var editor_room_light_on := false:
    set(value):
        editor_room_light_on = value
        _schedule_editor_refresh()

@export_range(0.0, 1.5, 0.01) var editor_room_light_strength := 0.72:
    set(value):
        editor_room_light_strength = clampf(value, 0.0, 1.5)
        _schedule_editor_refresh()

@export_range(0.0, 3.0, 0.01) var editor_sun_ray_multiplier := 1.15:
    set(value):
        editor_sun_ray_multiplier = clampf(value, 0.0, 3.0)
        _schedule_editor_refresh()

@export_range(0.0, 2.5, 0.01) var editor_city_light_multiplier := 1.0:
    set(value):
        editor_city_light_multiplier = clampf(value, 0.0, 2.5)
        _schedule_editor_refresh()

@export_group("Animation")
@export_range(0.05, 3.0, 0.05) var transition_seconds := 0.65

@onready var canvas_modulate: CanvasModulate = %CanvasModulate
@onready var ambient_wash: ColorRect = %AmbientWash
@onready var exterior_response: ColorRect = %ExteriorResponse
@onready var warmth: ColorRect = %Warmth
@onready var window_wash: ColorRect = %WindowWash
@onready var sun_beams: ColorRect = %SunBeams
@onready var city_lights: ColorRect = %CityLights
@onready var room_light_wash: ColorRect = %RoomLightWash
@onready var vignette: ColorRect = %Vignette
@onready var sun_directional: DirectionalLight2D = %SunDirectional
@onready var window_key_light: PointLight2D = %WindowKeyLight
@onready var dynamic_lights: Node2D = %DynamicLights

var _runtime_hour := 19.5
var _runtime_weather: int = WeatherPreset.CLEAR
var _runtime_room_light_on := false
var _runtime_room_light_strength := 0.72
var _runtime_sun_ray_multiplier := 1.15
var _runtime_city_light_multiplier := 1.0
var _manual_override := false
var _visual_state: Dictionary = {}
var _target_state: Dictionary = {}
var _emitters: Dictionary = {}
var _emitter_category_state: Dictionary = {
    &"desk_lamp": {"enabled": true, "multiplier": 1.0},
    &"monitor": {"enabled": true, "multiplier": 1.0},
}


func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    if not is_in_group("room_lighting_rig"):
        add_to_group("room_lighting_rig")
    _resolve_layer_refs()
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
    _set_runtime_state(float(minutes) / 60.0, _runtime_weather, _runtime_room_light_on, _runtime_room_light_strength, animated)


func set_debug_state(hour: float, weather: int, room_light_on: bool, room_light_strength: float, animated := true) -> void:
    _manual_override = true
    _set_runtime_state(hour, weather, room_light_on, room_light_strength, animated)


func set_debug_detail_multipliers(sun_ray_multiplier: float, city_light_multiplier: float) -> void:
    _runtime_sun_ray_multiplier = clampf(sun_ray_multiplier, 0.0, 3.0)
    _runtime_city_light_multiplier = clampf(city_light_multiplier, 0.0, 2.5)
    _set_runtime_state(_runtime_hour, _runtime_weather, _runtime_room_light_on, _runtime_room_light_strength, true)


func clear_debug_override(minutes: int, animated := true) -> void:
    _manual_override = false
    _runtime_weather = WeatherPreset.CLEAR
    _runtime_room_light_on = false
    _runtime_room_light_strength = 0.72
    _runtime_sun_ray_multiplier = 1.15
    _runtime_city_light_multiplier = 1.0
    _set_runtime_state(float(minutes) / 60.0, _runtime_weather, _runtime_room_light_on, _runtime_room_light_strength, animated)


func has_debug_override() -> bool:
    return _manual_override


func current_hour() -> float:
    return _runtime_hour


func current_weather() -> int:
    return _runtime_weather


func room_light_is_on() -> bool:
    return _runtime_room_light_on


func room_light_strength() -> float:
    return _runtime_room_light_strength


func sun_ray_multiplier() -> float:
    return _runtime_sun_ray_multiplier


func city_light_multiplier() -> float:
    return _runtime_city_light_multiplier


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


func set_emitter_enabled(emitter_id: StringName, enabled: bool) -> void:
    var entry = _emitters.get(emitter_id)
    if entry is Dictionary:
        var emitter = entry.get("node")
        if emitter is Light2D:
            emitter.enabled = enabled


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


func _set_runtime_state(hour: float, weather: int, room_light_on: bool, room_light_strength_value: float, animated: bool) -> void:
    _runtime_hour = fposmod(hour, 24.0)
    _runtime_weather = clampi(weather, WeatherPreset.CLEAR, WeatherPreset.RAIN)
    _runtime_room_light_on = room_light_on
    _runtime_room_light_strength = clampf(room_light_strength_value, 0.0, 1.5)
    _set_target_state(
        _calculate_visual_state(
            _runtime_hour,
            _runtime_weather,
            _runtime_room_light_on,
            _runtime_room_light_strength,
            _runtime_sun_ray_multiplier,
            _runtime_city_light_multiplier
        ),
        not animated
    )
    atmosphere_changed.emit(_runtime_hour, _runtime_weather, _runtime_room_light_on)


func _schedule_editor_refresh() -> void:
    if not Engine.is_editor_hint() or not is_node_ready():
        return
    call_deferred("_refresh_editor_preview", false)


func _refresh_editor_preview(immediate := false) -> void:
    if not Engine.is_editor_hint() or not editor_preview_enabled:
        return
    _set_target_state(
        _calculate_visual_state(
            editor_hour,
            editor_weather,
            editor_room_light_on,
            editor_room_light_strength,
            editor_sun_ray_multiplier,
            editor_city_light_multiplier
        ),
        immediate
    )


func _set_target_state(state: Dictionary, immediate: bool) -> void:
    _target_state = state
    if immediate or _visual_state.is_empty():
        _visual_state = state.duplicate(true)
        _apply_visual_state(_visual_state)


func _calculate_visual_state(
    hour: float,
    weather: int,
    room_light_on: bool,
    room_light_strength_value: float,
    sun_ray_multiplier_value: float,
    city_light_multiplier_value: float
) -> Dictionary:
    var h := fposmod(hour, 24.0)
    var daylight := 0.0
    if h >= 5.3 and h <= 20.7:
        daylight = maxf(0.0, sin(((h - 5.3) / 15.4) * PI))

    var dawn := _bell(h, 7.0, 1.55)
    var dusk := _bell(h, 18.6, 1.85)
    var golden := maxf(dawn, dusk)
    var night := 1.0 - daylight

    var cloudiness := 0.0
    if weather == WeatherPreset.CLOUDY:
        cloudiness = 0.45
    elif weather == WeatherPreset.RAIN:
        cloudiness = 0.78

    var day_canvas := Color(0.98, 0.97, 0.93, 1.0)
    var overcast_canvas := Color(0.78, 0.82, 0.84, 1.0)
    var night_canvas := Color(0.31, 0.37, 0.50, 1.0)
    var canvas_color := night_canvas.lerp(day_canvas, daylight)
    canvas_color = canvas_color.lerp(overcast_canvas, cloudiness * (0.45 + daylight * 0.20))

    var ambient_alpha := clampf(0.015 + night * 0.16 + cloudiness * 0.07, 0.0, 0.28)
    var ambient_color := Color(0.025, 0.06, 0.13, ambient_alpha).lerp(
        Color(0.085, 0.10, 0.12, ambient_alpha),
        cloudiness * 0.78
    )

    var warmth_alpha := clampf(golden * (0.13 - cloudiness * 0.06), 0.0, 0.15)
    var warmth_color := Color(1.0, 0.34, 0.08, warmth_alpha)

    var daylight_window := daylight * (0.92 - cloudiness * 0.52)
    var city_night_glow := pow(night, 2.0) * 0.22
    var window_strength := clampf(daylight_window * 0.72 + golden * 0.38 + city_night_glow, 0.0, 1.25)
    var day_window_color := Color(0.82, 0.91, 1.0, 1.0)
    var golden_window_color := Color(1.0, 0.63, 0.27, 1.0)
    var night_window_color := Color(0.30, 0.50, 1.0, 1.0)
    var window_color := day_window_color.lerp(golden_window_color, clampf(golden * 1.25, 0.0, 1.0))
    if daylight < 0.09:
        window_color = night_window_color

    var sun_progress := clampf((h - 6.0) / 13.0, 0.0, 1.0)
    var direct_sun := daylight * (1.0 - cloudiness * 0.96)
    var sun_ray_strength := clampf(
        direct_sun * (0.52 + golden * 1.36) * sun_ray_multiplier_value,
        0.0,
        3.0
    )
    var sun_source_shift := lerpf(-0.045, 0.045, sun_progress)
    var sun_travel := lerpf(-0.78, 0.78, sun_progress)
    var sun_color := day_window_color.lerp(golden_window_color, clampf(golden * 1.35, 0.0, 1.0))
    var sun_direction_energy := clampf(direct_sun * (0.16 + golden * 0.12), 0.0, 0.34)
    var sun_direction_rotation := lerpf(deg_to_rad(-58.0), deg_to_rad(58.0), sun_progress)
    var window_key_energy := clampf(window_strength * (0.40 + golden * 0.20), 0.0, 0.78)

    var exterior_darkness := clampf(pow(night, 1.32) * 0.72 + cloudiness * 0.14, 0.0, 0.84)
    var exterior_tint := Color(0.025, 0.06, 0.14, 1.0).lerp(Color(0.08, 0.10, 0.13, 1.0), cloudiness * 0.72)
    var city_light_strength := clampf(
        pow(night, 2.55) * (1.15 + cloudiness * 0.16) * city_light_multiplier_value,
        0.0,
        2.35
    )

    var artificial_strength := 0.0
    if room_light_on:
        artificial_strength = clampf(room_light_strength_value * (0.55 + night * 0.68), 0.0, 1.7)

    return {
        "canvas_color": canvas_color,
        "ambient_color": ambient_color,
        "warmth_color": warmth_color,
        "window_color": window_color,
        "window_strength": window_strength,
        "sun_color": sun_color,
        "sun_ray_strength": sun_ray_strength,
        "sun_source_shift": sun_source_shift,
        "sun_travel": sun_travel,
        "sun_direction_energy": sun_direction_energy,
        "sun_direction_rotation": sun_direction_rotation,
        "window_key_energy": window_key_energy,
        "exterior_tint": exterior_tint,
        "exterior_darkness": exterior_darkness,
        "city_light_strength": city_light_strength,
        "room_light_color": Color(1.0, 0.62, 0.30, 1.0),
        "room_light_strength": artificial_strength,
        "vignette_strength": clampf(0.055 + night * 0.14 + cloudiness * 0.025, 0.045, 0.24),
    }


func _blend_states(from_state: Dictionary, to_state: Dictionary, weight: float) -> Dictionary:
    var canvas_from: Color = from_state.get("canvas_color", Color.WHITE)
    var canvas_to: Color = to_state.get("canvas_color", Color.WHITE)
    var ambient_from: Color = from_state.get("ambient_color", Color.TRANSPARENT)
    var ambient_to: Color = to_state.get("ambient_color", Color.TRANSPARENT)
    var warmth_from: Color = from_state.get("warmth_color", Color.TRANSPARENT)
    var warmth_to: Color = to_state.get("warmth_color", Color.TRANSPARENT)
    var window_from: Color = from_state.get("window_color", Color.WHITE)
    var window_to: Color = to_state.get("window_color", Color.WHITE)
    var sun_from: Color = from_state.get("sun_color", Color.WHITE)
    var sun_to: Color = to_state.get("sun_color", Color.WHITE)
    var exterior_from: Color = from_state.get("exterior_tint", Color.WHITE)
    var exterior_to: Color = to_state.get("exterior_tint", Color.WHITE)
    var room_from: Color = from_state.get("room_light_color", Color.WHITE)
    var room_to: Color = to_state.get("room_light_color", Color.WHITE)

    return {
        "canvas_color": canvas_from.lerp(canvas_to, weight),
        "ambient_color": ambient_from.lerp(ambient_to, weight),
        "warmth_color": warmth_from.lerp(warmth_to, weight),
        "window_color": window_from.lerp(window_to, weight),
        "window_strength": lerpf(float(from_state.get("window_strength", 0.0)), float(to_state.get("window_strength", 0.0)), weight),
        "sun_color": sun_from.lerp(sun_to, weight),
        "sun_ray_strength": lerpf(float(from_state.get("sun_ray_strength", 0.0)), float(to_state.get("sun_ray_strength", 0.0)), weight),
        "sun_source_shift": lerpf(float(from_state.get("sun_source_shift", 0.0)), float(to_state.get("sun_source_shift", 0.0)), weight),
        "sun_travel": lerpf(float(from_state.get("sun_travel", 0.0)), float(to_state.get("sun_travel", 0.0)), weight),
        "sun_direction_energy": lerpf(float(from_state.get("sun_direction_energy", 0.0)), float(to_state.get("sun_direction_energy", 0.0)), weight),
        "sun_direction_rotation": lerp_angle(float(from_state.get("sun_direction_rotation", 0.0)), float(to_state.get("sun_direction_rotation", 0.0)), weight),
        "window_key_energy": lerpf(float(from_state.get("window_key_energy", 0.0)), float(to_state.get("window_key_energy", 0.0)), weight),
        "exterior_tint": exterior_from.lerp(exterior_to, weight),
        "exterior_darkness": lerpf(float(from_state.get("exterior_darkness", 0.0)), float(to_state.get("exterior_darkness", 0.0)), weight),
        "city_light_strength": lerpf(float(from_state.get("city_light_strength", 0.0)), float(to_state.get("city_light_strength", 0.0)), weight),
        "room_light_color": room_from.lerp(room_to, weight),
        "room_light_strength": lerpf(float(from_state.get("room_light_strength", 0.0)), float(to_state.get("room_light_strength", 0.0)), weight),
        "vignette_strength": lerpf(float(from_state.get("vignette_strength", 0.0)), float(to_state.get("vignette_strength", 0.0)), weight),
    }


func _apply_visual_state(state: Dictionary) -> void:
    _resolve_layer_refs()
    if not is_instance_valid(canvas_modulate) or not is_instance_valid(ambient_wash):
        return

    canvas_modulate.color = state.get("canvas_color", Color.WHITE)
    ambient_wash.color = state.get("ambient_color", Color.TRANSPARENT)
    if is_instance_valid(warmth):
        warmth.color = state.get("warmth_color", Color.TRANSPARENT)

    var exterior_material := _shader_material(exterior_response)
    if exterior_material != null:
        exterior_material.set_shader_parameter("tint", state.get("exterior_tint", Color.WHITE))
        exterior_material.set_shader_parameter("darkness", float(state.get("exterior_darkness", 0.0)))

    var window_material := _shader_material(window_wash)
    if window_material != null:
        window_material.set_shader_parameter("tint", state.get("window_color", Color.WHITE))
        window_material.set_shader_parameter("strength", float(state.get("window_strength", 0.0)))

    var sun_material := _shader_material(sun_beams)
    if sun_material != null:
        sun_material.set_shader_parameter("tint", state.get("sun_color", Color.WHITE))
        sun_material.set_shader_parameter("strength", float(state.get("sun_ray_strength", 0.0)))
        sun_material.set_shader_parameter("source_shift", float(state.get("sun_source_shift", 0.0)))
        sun_material.set_shader_parameter("travel", float(state.get("sun_travel", 0.0)))

    var city_material := _shader_material(city_lights)
    if city_material != null:
        city_material.set_shader_parameter("strength", float(state.get("city_light_strength", 0.0)))

    var room_material := _shader_material(room_light_wash)
    if room_material != null:
        room_material.set_shader_parameter("tint", state.get("room_light_color", Color.WHITE))
        room_material.set_shader_parameter("strength", float(state.get("room_light_strength", 0.0)))

    var vignette_material := _shader_material(vignette)
    if vignette_material != null:
        vignette_material.set_shader_parameter("strength", float(state.get("vignette_strength", 0.0)))

    if is_instance_valid(sun_directional):
        sun_directional.color = state.get("sun_color", Color.WHITE)
        sun_directional.energy = float(state.get("sun_direction_energy", 0.0))
        sun_directional.rotation = float(state.get("sun_direction_rotation", 0.0))
        sun_directional.enabled = sun_directional.energy > 0.005

    if is_instance_valid(window_key_light):
        window_key_light.color = state.get("window_color", Color.WHITE)
        window_key_light.energy = float(state.get("window_key_energy", 0.0))
        window_key_light.enabled = window_key_light.energy > 0.005


func _resolve_layer_refs() -> void:
    if not is_instance_valid(canvas_modulate):
        canvas_modulate = get_node_or_null(NodePath("%CanvasModulate")) as CanvasModulate
    if not is_instance_valid(ambient_wash):
        ambient_wash = get_node_or_null(NodePath("%AmbientWash")) as ColorRect
    if not is_instance_valid(exterior_response):
        exterior_response = get_node_or_null(NodePath("%ExteriorResponse")) as ColorRect
    if not is_instance_valid(warmth):
        warmth = get_node_or_null(NodePath("%Warmth")) as ColorRect
    if not is_instance_valid(window_wash):
        window_wash = get_node_or_null(NodePath("%WindowWash")) as ColorRect
    if not is_instance_valid(sun_beams):
        sun_beams = get_node_or_null(NodePath("%SunBeams")) as ColorRect
    if not is_instance_valid(city_lights):
        city_lights = get_node_or_null(NodePath("%CityLights")) as ColorRect
    if not is_instance_valid(room_light_wash):
        room_light_wash = get_node_or_null(NodePath("%RoomLightWash")) as ColorRect
    if not is_instance_valid(vignette):
        vignette = get_node_or_null(NodePath("%Vignette")) as ColorRect
    if not is_instance_valid(sun_directional):
        sun_directional = get_node_or_null(NodePath("%SunDirectional")) as DirectionalLight2D
    if not is_instance_valid(window_key_light):
        window_key_light = get_node_or_null(NodePath("%WindowKeyLight")) as PointLight2D
    if not is_instance_valid(dynamic_lights):
        dynamic_lights = get_node_or_null(NodePath("%DynamicLights")) as Node2D


func _shader_material(layer: CanvasItem) -> ShaderMaterial:
    if not is_instance_valid(layer):
        return null
    return layer.material as ShaderMaterial


func _bell(hour: float, center: float, width: float) -> float:
    var distance := absf(fposmod(hour - center + 12.0, 24.0) - 12.0)
    return exp(-pow(distance / maxf(width, 0.01), 2.0))
