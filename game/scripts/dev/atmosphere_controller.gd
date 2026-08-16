extends PanelContainer
class_name DeveloperAtmosphereController

@export var lighting_rig_path: NodePath

@onready var time_slider: HSlider = %TimeSlider
@onready var time_value: Label = %TimeValue
@onready var weather_select: OptionButton = %WeatherSelect
@onready var room_light_toggle: CheckButton = %RoomLightToggle
@onready var room_light_strength_slider: HSlider = %RoomLightStrength
@onready var room_light_strength_value: Label = %RoomLightStrengthValue
@onready var sun_ray_strength_slider: HSlider = %SunRayStrength
@onready var sun_ray_strength_value: Label = %SunRayStrengthValue
@onready var city_light_strength_slider: HSlider = %CityLightStrength
@onready var city_light_strength_value: Label = %CityLightStrengthValue
@onready var animate_day_toggle: CheckButton = %AnimateDayToggle
@onready var cycle_seconds_slider: HSlider = %CycleSeconds
@onready var cycle_seconds_value: Label = %CycleSecondsValue
@onready var follow_game_button: Button = %FollowGameButton
@onready var close_button: Button = %CloseButton

var lighting_rig: RoomLightingRig
var _syncing_ui := false


func _ready() -> void:
    if not OS.is_debug_build():
        hide()
        set_process(false)
        set_process_input(false)
        return

    lighting_rig = get_node_or_null(lighting_rig_path) as RoomLightingRig
    if lighting_rig == null:
        push_warning("Founder Sim: DeveloperAtmosphereController could not find LightingRig")
        hide()
        return

    weather_select.clear()
    weather_select.add_item("Clear", RoomLightingRig.WeatherPreset.CLEAR)
    weather_select.add_item("Cloudy", RoomLightingRig.WeatherPreset.CLOUDY)
    weather_select.add_item("Rain", RoomLightingRig.WeatherPreset.RAIN)

    time_slider.value_changed.connect(_on_time_slider_changed)
    weather_select.item_selected.connect(_on_weather_selected)
    room_light_toggle.toggled.connect(_on_room_light_toggled)
    room_light_strength_slider.value_changed.connect(_on_room_light_strength_changed)
    sun_ray_strength_slider.value_changed.connect(_on_sun_ray_strength_changed)
    city_light_strength_slider.value_changed.connect(_on_city_light_strength_changed)
    animate_day_toggle.toggled.connect(_on_animate_day_toggled)
    cycle_seconds_slider.value_changed.connect(_on_cycle_seconds_changed)
    follow_game_button.pressed.connect(_on_follow_game_pressed)
    close_button.pressed.connect(hide)

    _sync_from_rig()
    set_process(true)
    set_process_input(true)


func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F10:
        visible = not visible
        if visible:
            _sync_from_rig()
        get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
    if lighting_rig == null or not animate_day_toggle.button_pressed:
        return

    var seconds_per_day := maxf(float(cycle_seconds_slider.value), 4.0)
    var hour_step := delta * 24.0 / seconds_per_day
    var next_hour := fposmod(lighting_rig.current_hour() + hour_step, 24.0)

    _syncing_ui = true
    time_slider.value = next_hour
    _syncing_ui = false
    _update_time_label(next_hour)
    _apply_debug_state(false)


func _on_time_slider_changed(value: float) -> void:
    if _syncing_ui:
        return
    _update_time_label(value)
    _apply_debug_state(true)


func _on_weather_selected(_index: int) -> void:
    if _syncing_ui:
        return
    _apply_debug_state(true)


func _on_room_light_toggled(enabled: bool) -> void:
    room_light_strength_slider.editable = enabled
    if _syncing_ui:
        return
    _apply_debug_state(true)


func _on_room_light_strength_changed(value: float) -> void:
    room_light_strength_value.text = "%.0f%%" % (value * 100.0)
    if _syncing_ui:
        return
    _apply_debug_state(true)


func _on_sun_ray_strength_changed(value: float) -> void:
    sun_ray_strength_value.text = "%.0f%%" % (value * 100.0)
    if _syncing_ui:
        return
    _apply_debug_state(true)


func _on_city_light_strength_changed(value: float) -> void:
    city_light_strength_value.text = "%.0f%%" % (value * 100.0)
    if _syncing_ui:
        return
    _apply_debug_state(true)


func _on_animate_day_toggled(enabled: bool) -> void:
    if enabled and lighting_rig != null:
        _apply_debug_state(false)


func _on_cycle_seconds_changed(value: float) -> void:
    cycle_seconds_value.text = "%.0fs / day" % value


func _on_follow_game_pressed() -> void:
    animate_day_toggle.button_pressed = false
    lighting_rig.clear_debug_override(GameState.minutes, true)
    _sync_from_rig()


func _apply_debug_state(animated: bool) -> void:
    if lighting_rig == null:
        return
    var weather_id := weather_select.get_selected_id()
    lighting_rig.set_debug_detail_multipliers(
        float(sun_ray_strength_slider.value),
        float(city_light_strength_slider.value)
    )
    lighting_rig.set_debug_state(
        float(time_slider.value),
        weather_id,
        room_light_toggle.button_pressed,
        float(room_light_strength_slider.value),
        animated
    )


func _sync_from_rig() -> void:
    if lighting_rig == null:
        return

    _syncing_ui = true
    time_slider.value = lighting_rig.current_hour()
    weather_select.select(maxi(lighting_rig.current_weather(), 0))
    room_light_toggle.button_pressed = lighting_rig.room_light_is_on()
    room_light_strength_slider.value = lighting_rig.room_light_strength()
    room_light_strength_slider.editable = room_light_toggle.button_pressed
    sun_ray_strength_slider.value = lighting_rig.sun_ray_multiplier()
    city_light_strength_slider.value = lighting_rig.city_light_multiplier()
    _syncing_ui = false

    _update_time_label(float(time_slider.value))
    room_light_strength_value.text = "%.0f%%" % (float(room_light_strength_slider.value) * 100.0)
    sun_ray_strength_value.text = "%.0f%%" % (float(sun_ray_strength_slider.value) * 100.0)
    city_light_strength_value.text = "%.0f%%" % (float(city_light_strength_slider.value) * 100.0)
    cycle_seconds_value.text = "%.0fs / day" % float(cycle_seconds_slider.value)


func _update_time_label(hour: float) -> void:
    var total_minutes := int(round(fposmod(hour, 24.0) * 60.0)) % 1440
    var hours := int(total_minutes / 60)
    var minutes := total_minutes % 60
    time_value.text = "%02d:%02d" % [hours, minutes]
