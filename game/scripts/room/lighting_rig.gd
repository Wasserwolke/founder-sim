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

@export_group("Animation")
@export_range(0.05, 3.0, 0.05) var transition_seconds := 0.75

@onready var ambient_shade: ColorRect = %AmbientShade
@onready var warmth: ColorRect = %Warmth
@onready var window_wash: ColorRect = %WindowWash
@onready var room_light_wash: ColorRect = %RoomLightWash
@onready var vignette: ColorRect = %Vignette
@onready var dynamic_lights: Node2D = %DynamicLights

var _runtime_hour := 19.5
var _runtime_weather: int = WeatherPreset.CLEAR
var _runtime_room_light_on := false
var _runtime_room_light_strength := 0.72
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


func clear_debug_override(minutes: int, animated := true) -> void:
    _manual_override = false
    _runtime_weather = WeatherPreset.CLEAR
    _runtime_room_light_on = false
    _runtime_room_light_strength = 0.72
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


func _set_runtime_state(hour: float, weather: int, room_light_on: bool, room_light_strength: float, animated: bool) -> void:
    _runtime_hour = fposmod(hour, 24.0)
    _runtime_weather = clampi(weather, WeatherPreset.CLEAR, WeatherPreset.RAIN)
    _runtime_room_light_on = room_light_on
    _runtime_room_light_strength = clampf(room_light_strength, 0.0, 1.5)
    _set_target_state(
        _calculate_visual_state(_runtime_hour, _runtime_weather, _runtime_room_light_on, _runtime_room_light_strength),
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
        _calculate_visual_state(editor_hour, editor_weather, editor_room_light_on, editor_room_light_strength),
        immediate
    )


func _set_target_state(state: Dictionary, immediate: bool) -> void:
    _target_state = state
    if immediate or _visual_state.is_empty():
        _visual_state = state.duplicate(true)
        _apply_visual_state(_visual_state)


func _calculate_visual_state(hour: float, weather: int, room_light_on: bool, room_light_strength_value: float) -> Dictionary:
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
    var window_strength := clampf(daylight_window * 0.62 + golden * 0.28 + city_night_glow, 0.0, 0.92)
    var day_window_color := Color(0.74, 0.86, 1.0, 1.0)
    var golden_window_color := Color(1.0, 0.56, 0.28, 1.0)
    var night_window_color := Color(0.40, 0.58, 0.95, 1.0)
    var window_color := day_window_color.lerp(golden_window_color, clampf(golden * 1.35, 0.0, 1.0))
    if daylight < 0.08:
        window_color = night_window_color

    var artificial_strength := 0.0
    if room_light_on:
        artificial_strength = clampf(room_light_strength_value * (0.65 + night * 0.55), 0.0, 1.6)

    return {
        "ambient_color": ambient_color,
        "warmth_color": warmth_color,
        "window_color": window_color,
        "window_strength": window_strength,
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
    var room_from: Color = from_state.get("room_light_color", Color.WHITE)
    var room_to: Color = to_state.get("room_light_color", Color.WHITE)

    return {
        "ambient_color": ambient_from.lerp(ambient_to, weight),
        "warmth_color": warmth_from.lerp(warmth_to, weight),
        "window_color": window_from.lerp(window_to, weight),
        "window_strength": lerpf(float(from_state.get("window_strength", 0.0)), float(to_state.get("window_strength", 0.0)), weight),
        "room_light_color": room_from.lerp(room_to, weight),
        "room_light_strength": lerpf(float(from_state.get("room_light_strength", 0.0)), float(to_state.get("room_light_strength", 0.0)), weight),
        "vignette_strength": lerpf(float(from_state.get("vignette_strength", 0.0)), float(to_state.get("vignette_strength", 0.0)), weight),
    }


func _apply_visual_state(state: Dictionary) -> void:
    if ambient_shade == null or warmth == null:
        return

    ambient_shade.color = state.get("ambient_color", Color.TRANSPARENT)
    warmth.color = state.get("warmth_color", Color.TRANSPARENT)

    var window_material := window_wash.material as ShaderMaterial
    if window_material != null:
        window_material.set_shader_parameter("tint", state.get("window_color", Color.WHITE))
        window_material.set_shader_parameter("strength", float(state.get("window_strength", 0.0)))

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
