extends Control

const MAIN_SCENE := "res://game/scenes/main.tscn"

@onready var camera: Camera3D = %Camera3D
@onready var sun: DirectionalLight3D = %Sun
@onready var world_environment: WorldEnvironment = %WorldEnvironment
@onready var desk_lamp: SpotLight3D = %DeskLamp
@onready var monitor_glow: OmniLight3D = %MonitorGlow
@onready var time_slider: HSlider = %TimeSlider
@onready var time_label: Label = %TimeLabel
@onready var sun_slider: HSlider = %SunSlider
@onready var lamp_toggle: CheckButton = %LampToggle
@onready var animate_toggle: CheckButton = %AnimateToggle

var time_hours := 17.4
var sun_strength := 1.0
const DAY_SECONDS := 18.0


func _ready() -> void:
    camera.look_at(Vector3(0.0, 2.45, -0.4), Vector3.UP)
    desk_lamp.look_at(Vector3(-1.25, 1.02, 0.55), Vector3.UP)

    time_slider.value = time_hours
    sun_slider.value = sun_strength
    time_slider.value_changed.connect(_on_time_changed)
    sun_slider.value_changed.connect(_on_sun_strength_changed)
    lamp_toggle.toggled.connect(_on_lamp_toggled)
    animate_toggle.toggled.connect(_on_animate_toggled)

    _apply_time()
    _apply_local_lights()


func _process(delta: float) -> void:
    if animate_toggle.button_pressed:
        time_hours = fposmod(time_hours + delta * (24.0 / DAY_SECONDS), 24.0)
        time_slider.set_value_no_signal(time_hours)
        _apply_time()


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        match event.keycode:
            KEY_ESCAPE:
                get_tree().change_scene_to_file(MAIN_SCENE)
            KEY_1:
                _set_time(7.0)
            KEY_2:
                _set_time(12.5)
            KEY_3:
                _set_time(18.2)
            KEY_4:
                _set_time(22.0)
            KEY_SPACE:
                animate_toggle.button_pressed = not animate_toggle.button_pressed


func _set_time(value: float) -> void:
    time_hours = fposmod(value, 24.0)
    time_slider.set_value_no_signal(time_hours)
    _apply_time()


func _on_time_changed(value: float) -> void:
    time_hours = value
    _apply_time()


func _on_sun_strength_changed(value: float) -> void:
    sun_strength = value
    _apply_time()


func _on_lamp_toggled(_pressed: bool) -> void:
    _apply_local_lights()


func _on_animate_toggled(_pressed: bool) -> void:
    pass


func _apply_time() -> void:
    var daylight := 0.0
    if time_hours >= 5.5 and time_hours <= 20.5:
        daylight = maxf(0.0, sin(((time_hours - 5.5) / 15.0) * PI))

    var dawn := _bell(time_hours, 7.0, 1.55)
    var dusk := _bell(time_hours, 18.7, 1.75)
    var golden := maxf(dawn, dusk)
    var sun_progress := clampf((time_hours - 5.5) / 15.0, 0.0, 1.0)
    var elevation := pow(clampf(daylight, 0.0, 1.0), 0.68)

    # Real 3D sunlight: a single DirectionalLight3D emits parallel rays. The
    # actual wall, window frame, furniture and depth now decide the shadows.
    var lateral := lerpf(0.72, -0.72, sun_progress)
    var downward := lerpf(0.28, 1.15, elevation)
    var ray_direction := Vector3(lateral, -downward, 1.0).normalized()
    sun.look_at(sun.global_position + ray_direction, Vector3.UP)
    sun.light_energy = daylight * (2.0 + golden * 1.25) * sun_strength
    sun.light_color = Color(1.0, 0.97, 0.88, 1.0).lerp(
        Color(1.0, 0.70, 0.42, 1.0),
        clampf(golden * 0.72, 0.0, 1.0)
    )
    sun.visible = sun.light_energy > 0.005

    var env := world_environment.environment
    if env != null:
        env.ambient_light_energy = lerpf(0.16, 0.62, daylight)
        env.ambient_light_color = Color(0.16, 0.21, 0.34, 1.0).lerp(
            Color(0.88, 0.92, 1.0, 1.0),
            daylight
        )
        env.background_color = Color(0.025, 0.035, 0.065, 1.0).lerp(
            Color(0.50, 0.70, 0.91, 1.0),
            daylight
        )

    var hours := int(floor(time_hours))
    var minutes := int(round((time_hours - float(hours)) * 60.0))
    if minutes >= 60:
        hours = (hours + 1) % 24
        minutes = 0
    time_label.text = "%02d:%02d" % [hours, minutes]

    # Artificial light is independent geometry-driven light too; it becomes
    # naturally more apparent as the ambient daylight fades.
    _apply_local_lights(daylight)


func _apply_local_lights(daylight_override: float = -1.0) -> void:
    var daylight := daylight_override
    if daylight < 0.0:
        daylight = 0.0
        if time_hours >= 5.5 and time_hours <= 20.5:
            daylight = maxf(0.0, sin(((time_hours - 5.5) / 15.0) * PI))

    var enabled := lamp_toggle.button_pressed
    desk_lamp.visible = enabled
    desk_lamp.light_energy = (3.2 + (1.0 - daylight) * 1.2) if enabled else 0.0
    monitor_glow.visible = enabled
    monitor_glow.light_energy = (0.42 + (1.0 - daylight) * 0.50) if enabled else 0.0


func _bell(hour: float, center: float, width: float) -> float:
    var distance := absf(fposmod(hour - center + 12.0, 24.0) - 12.0)
    return exp(-pow(distance / maxf(width, 0.01), 2.0))
