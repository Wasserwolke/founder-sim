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

@export_range(0.0, 2.0, 0.01) var editor_sun_ray_multiplier := 1.0:
    set(value):
        editor_sun_ray_multiplier = clampf(value, 0.0, 2.0)
        _schedule_editor_refresh()

@export_range(0.0, 2.0, 0.01) var editor_city_light_multiplier := 1.0:
    set(value):
        editor_city_light_multiplier = clampf(value, 0.0, 2.0)
        _schedule_editor_refresh()

@export_group("Animation")
@export_range(0.05, 3.0, 0.05) var transition_seconds := 0.75

@onready var ambient_shade: ColorRect = %AmbientShade
@onready var exterior_response: ColorRect = %ExteriorResponse
@onready var warmth: ColorRect = %Warmth
@onready var window_wash: ColorRect = %WindowWash
@onready var sun_beams: ColorRect = %SunBeams
@onready var city_lights: ColorRect = %CityLights
@onready var room_light_wash: ColorRect = %RoomLightWash
@onready var vignette: ColorRect = %Vignette
@onready var dynamic_lights: Node2D = %DynamicLights

var _runtime_hour := 19.5
var _runtime_weather: int = WeatherPreset.CLEAR
var _runtime_room_light_on := false
var _runtime_room_light_strength := 0.72
var _runtime_sun_ray_multiplier := 1.0
var _runtime_city_light_multiplier := 1.0
var _manual_override := false
var _visual_state: Dictionary = {}
var _target_state: Dictionary = {}
var _emitters: Dictionary = {}


func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_process(true)
    if Engine.is_editor_hint():
        _refresh_editor_preview(true)
    else:
        follow_game_time(GameState.minutes, false)


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
    _runtime_sun_ray_multiplier = clampf(sun_ray_multiplier, 0.0, 2.0)
    _runtime_city_light_multiplier = clampf(city_light_multiplier, 0.0, 2.0)


func clear_debug_override(minutes: int, animated := true) -> void:
    _manual_override = false
    _runtime_weather = WeatherPreset.CLEAR
    _runtime_room_light_on = false
    _runtime_room_light_strength = 0.72
    _runtime_sun_ray_multiplier = 1.0
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


func register_emitter(emitter_id: StringName, emitter: Light2D) -> void:
    if emitter == null:
        return
    _emitters[emitter_id] = emitter
    emitter_registered.emit(emitter_id)


func unregister_emitter(emitter_id: StringName) -> void:
    _emitters.erase(emitter_id)


func set_emitter_enabled(emitter_id: StringName, enabled: bool) -> void:
    var emitter = _emitters.get(emitter_id)
    if emitter is Light2D:
        emitter.enabled = enabled


func get_dynamic_light_root() -> Node2D:
    return dynamic_lights


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
    if h >= 5.5 and h <= 20.5:
        daylight = maxf(0.0, sin(((h - 5.5) / 15.0) * PI))

    var dawn := _bell(h, 6.6, 1.35)
    var dusk := _bell(h, 19.1, 1.55)
    var golden := maxf(dawn, dusk)
    var night := 1.0 - daylight

    var cloudiness := 0.0
    if weather == WeatherPreset.CLOUDY:
        cloudiness = 0.42
    elif weather == WeatherPreset.RAIN:
        cloudiness = 0.72

    var ambient_alpha := clampf(0.025 + night * 0.34 + cloudiness * 0.10, 0.0, 0.52)
    var ambient_blue := Color(0.035, 0.075, 0.14, ambient_alpha)
    var ambient_gray := Color(0.085, 0.105, 0.125, ambient_alpha)
    var ambient_color := ambient_blue.lerp(ambient_gray, cloudiness * 0.72)

    var warmth_alpha := clampf(golden * (0.12 - cloudiness * 0.06), 0.0, 0.14)
    var warmth_color := Color(0.94, 0.39, 0.16, warmth_alpha)

    var daylight_window := daylight * (0.82 - cloudiness * 0.48)
    var city_night_glow := pow(night, 2.2) * 0.16
    var window_strength := clampf(daylight_window * 0.56 + golden * 0.30 + city_night_glow, 0.0, 0.92)
    var day_window_color := Color(0.74, 0.86, 1.0, 1.0)
    var golden_window_color := Color(1.0, 0.56, 0.28, 1.0)
    var night_window_color := Color(0.40, 0.58, 0.95, 1.0)
    var window_color := day_window_color.lerp(golden_window_color, clampf(golden * 1.35, 0.0, 1.0))
    if daylight < 0.08:
        window_color = night_window_color

    var sun_progress := clampf((h - 6.0) / 13.0, 0.0, 1.0)
    var direct_sun := daylight * (1.0 - cloudiness * 0.92)
    var sun_ray_strength := clampf(
        direct_sun * (0.20 + golden * 0.80) * sun_ray_multiplier_value,
        0.0,
        1.65
    )
    var sun_shift := lerpf(-0.32, 0.32, sun_progress)
    var sun_slope := lerpf(0.58, -0.52, sun_progress)
    var sun_color := day_window_color.lerp(golden_window_color, clampf(golden * 1.45, 0.0, 1.0))

    var exterior_darkness := clampf(pow(night, 1.35) * 0.64 + cloudiness * 0.12, 0.0, 0.78)
    var exterior_tint := Color(0.035, 0.075, 0.14, 1.0).lerp(Color(0.09, 0.11, 0.13, 1.0), cloudiness * 0.70)
    var city_light_strength := clampf(
        pow(night, 2.85) * (0.92 + cloudiness * 0.12) * city_light_multiplier_value,
        0.0,
        1.75
    )

    var artificial_strength := 0.0
    if room_light_on:
        artificial_strength = clampf(room_light_strength_value * (0.65 + night * 0.55), 0.0, 1.6)

    return {
        "ambient_color": ambient_color,
        "warmth_color": warmth_color,
        "window_color": window_color,
        "window_strength": window_strength,
        "sun_color": sun_color,
        "sun_ray_strength": sun_ray_strength,
        "sun_shift": sun_shift,
        "sun_slope": sun_slope,
        "exterior_tint": exterior_tint,
        "exterior_darkness": exterior_darkness,
        "city_light_strength": city_light_strength,
        "room_light_color": Color(1.0, 0.66, 0.36, 1.0),
        "room_light_strength": artificial_strength,
        "vignette_strength": clampf(0.07 + night * 0.15 + cloudiness * 0.025, 0.05, 0.26),
    }


func _blend_states(from_state: Dictionary, to_state: Dictionary, weight: float) -> Dictionary:
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
        "ambient_color": ambient_from.lerp(ambient_to, weight),
        "warmth_color": warmth_from.lerp(warmth_to, weight),
        "window_color": window_from.lerp(window_to, weight),
        "window_strength": lerpf(float(from_state.get("window_strength", 0.0)), float(to_state.get("window_strength", 0.0)), weight),
        "sun_color": sun_from.lerp(sun_to, weight),
        "sun_ray_strength": lerpf(float(from_state.get("sun_ray_strength", 0.0)), float(to_state.get("sun_ray_strength", 0.0)), weight),
        "sun_shift": lerpf(float(from_state.get("sun_shift", 0.0)), float(to_state.get("sun_shift", 0.0)), weight),
        "sun_slope": lerpf(float(from_state.get("sun_slope", 0.0)), float(to_state.get("sun_slope", 0.0)), weight),
        "exterior_tint": exterior_from.lerp(exterior_to, weight),
        "exterior_darkness": lerpf(float(from_state.get("exterior_darkness", 0.0)), float(to_state.get("exterior_darkness", 0.0)), weight),
        "city_light_strength": lerpf(float(from_state.get("city_light_strength", 0.0)), float(to_state.get("city_light_strength", 0.0)), weight),
        "room_light_color": room_from.lerp(room_to, weight),
        "room_light_strength": lerpf(float(from_state.get("room_light_strength", 0.0)), float(to_state.get("room_light_strength", 0.0)), weight),
        "vignette_strength": lerpf(float(from_state.get("vignette_strength", 0.0)), float(to_state.get("vignette_strength", 0.0)), weight),
    }


func _apply_visual_state(state: Dictionary) -> void:
    if ambient_shade == null or warmth == null:
        return

    ambient_shade.color = state.get("ambient_color", Color.TRANSPARENT)
    warmth.color = state.get("warmth_color", Color.TRANSPARENT)

    var exterior_material := exterior_response.material as ShaderMaterial
    if exterior_material != null:
        exterior_material.set_shader_parameter("tint", state.get("exterior_tint", Color.WHITE))
        exterior_material.set_shader_parameter("darkness", float(state.get("exterior_darkness", 0.0)))

    var window_material := window_wash.material as ShaderMaterial
    if window_material != null:
        window_material.set_shader_parameter("tint", state.get("window_color", Color.WHITE))
        window_material.set_shader_parameter("strength", float(state.get("window_strength", 0.0)))

    var sun_material := sun_beams.material as ShaderMaterial
    if sun_material != null:
        sun_material.set_shader_parameter("tint", state.get("sun_color", Color.WHITE))
        sun_material.set_shader_parameter("strength", float(state.get("sun_ray_strength", 0.0)))
        sun_material.set_shader_parameter("shift", float(state.get("sun_shift", 0.0)))
        sun_material.set_shader_parameter("slope", float(state.get("sun_slope", 0.0)))

    var city_material := city_lights.material as ShaderMaterial
    if city_material != null:
        city_material.set_shader_parameter("strength", float(state.get("city_light_strength", 0.0)))

    var room_material := room_light_wash.material as ShaderMaterial
    if room_material != null:
        room_material.set_shader_parameter("tint", state.get("room_light_color", Color.WHITE))
        room_material.set_shader_parameter("strength", float(state.get("room_light_strength", 0.0)))

    var vignette_material := vignette.material as ShaderMaterial
    if vignette_material != null:
        vignette_material.set_shader_parameter("strength", float(state.get("vignette_strength", 0.0)))


func _bell(hour: float, center: float, width: float) -> float:
    var distance := absf(fposmod(hour - center + 12.0, 24.0) - 12.0)
    return exp(-pow(distance / maxf(width, 0.01), 2.0))
