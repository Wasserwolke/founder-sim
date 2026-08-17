@tool
extends PointLight2D
class_name SunlightProjection2D

@export_group("Visible window aperture")
@export var left_glass_start := Vector2(503.0, 462.0):
    set(value):
        left_glass_start = value
        queue_redraw()
@export var left_glass_end := Vector2(792.0, 462.0):
    set(value):
        left_glass_end = value
        queue_redraw()
@export var right_glass_start := Vector2(839.0, 462.0):
    set(value):
        right_glass_start = value
        queue_redraw()
@export var right_glass_end := Vector2(1128.0, 462.0):
    set(value):
        right_glass_end = value
        queue_redraw()

@export_group("Projection look")
@export_range(0.0, 48.0, 1.0) var edge_softness_px := 18.0:
    set(value):
        edge_softness_px = maxf(value, 0.0)
        queue_redraw()
@export_range(0.0, 1.0, 0.01) var core_strength := 0.34:
    set(value):
        core_strength = clampf(value, 0.0, 1.0)
        queue_redraw()
@export_range(0.0, 1.0, 0.01) var halo_strength := 0.15:
    set(value):
        halo_strength = clampf(value, 0.0, 1.0)
        queue_redraw()
@export var debug_draw_aperture := false:
    set(value):
        debug_draw_aperture = value
        queue_redraw()

var _direction := Vector2(0.0, 1.0)
var _projection_length := 420.0
var _energy := 0.0
var _light_color := Color(1.0, 0.88, 0.63, 1.0)
var _target_direction := Vector2.DOWN
var _target_length := 420.0
var _target_energy := 0.0
var _target_color := Color(1.0, 0.88, 0.63, 1.0)


func _ready() -> void:
    # Keep compatibility with the parent LightingRig, which still addresses
    # this node as its historical PointLight2D. The real radial light is
    # completely culled; only this script's custom aperture drawing is visible.
    range_item_cull_mask = 0
    shadow_enabled = false
    position = Vector2.ZERO
    rotation = 0.0
    set_process(true)
    _sync_from_parent(true)


func _process(delta: float) -> void:
    # The legacy LightingRig may write rotation/texture values to this node.
    # Neutralize those radial-light transforms every frame so the glass
    # aperture itself remains fixed and horizontal.
    position = Vector2.ZERO
    rotation = 0.0
    range_item_cull_mask = 0
    _sync_from_parent(false)
    var response := 1.0 - exp(-delta * 8.0)
    _direction = _direction.lerp(_target_direction, clampf(response, 0.0, 1.0)).normalized()
    _projection_length = lerpf(_projection_length, _target_length, clampf(response, 0.0, 1.0))
    _energy = lerpf(_energy, _target_energy, clampf(response, 0.0, 1.0))
    _light_color = _light_color.lerp(_target_color, clampf(response, 0.0, 1.0))
    queue_redraw()


func _sync_from_parent(immediate: bool) -> void:
    var rig := get_parent()
    if rig == null or not rig.has_method("current_hour"):
        return

    var hour := float(rig.call("current_hour"))
    var weather := int(rig.call("current_weather")) if rig.has_method("current_weather") else 0
    var multiplier := float(rig.call("sunlight_multiplier")) if rig.has_method("sunlight_multiplier") else 1.0

    var daylight := 0.0
    if hour >= 5.4 and hour <= 20.6:
        daylight = maxf(0.0, sin(((hour - 5.4) / 15.2) * PI))

    var cloudiness := 0.0
    if weather == 1:
        cloudiness = 0.48
    elif weather == 2:
        cloudiness = 0.80

    var dawn := _bell(hour, 7.15, 1.45)
    var dusk := _bell(hour, 18.45, 1.65)
    var golden := maxf(dawn, dusk)
    var direct_sun := daylight * (1.0 - cloudiness * 0.96)

    _target_energy = clampf(direct_sun * (1.05 + golden * 0.95) * multiplier, 0.0, 3.8)
    var elevation_factor := pow(clampf(daylight, 0.0, 1.0), 0.62)
    _target_length = lerpf(720.0, 255.0, elevation_factor)

    # Sun rays are effectively parallel at room scale. Azimuth therefore only
    # introduces a small horizontal drift; solar elevation controls how far
    # the projection reaches into the room.
    var sun_progress := clampf((hour - 5.4) / 15.2, 0.0, 1.0)
    var lateral := lerpf(-0.10, 0.10, sun_progress)
    _target_direction = Vector2(lateral, 1.0).normalized()
    _target_color = Color(1.0, 0.94, 0.78, 1.0).lerp(
        Color(1.0, 0.64, 0.29, 1.0),
        clampf(golden * 1.08, 0.0, 1.0)
    )

    if immediate:
        _direction = _target_direction
        _projection_length = _target_length
        _energy = _target_energy
        _light_color = _target_color
        queue_redraw()


func _bell(hour: float, center: float, width: float) -> float:
    var distance := absf(fposmod(hour - center + 12.0, 24.0) - 12.0)
    return exp(-pow(distance / maxf(width, 0.01), 2.0))


func set_projection(direction: Vector2, projection_length: float, energy: float, light_color: Color) -> void:
    var normalized := direction.normalized()
    if normalized.length_squared() < 0.5:
        normalized = Vector2.DOWN
    _direction = normalized
    _projection_length = maxf(projection_length, 0.0)
    _energy = maxf(energy, 0.0)
    _light_color = light_color
    queue_redraw()


func _draw() -> void:
    if _energy > 0.002 and _projection_length > 1.0:
        _draw_pane_projection(left_glass_start, left_glass_end)
        _draw_pane_projection(right_glass_start, right_glass_end)

    if debug_draw_aperture:
        draw_line(left_glass_start, left_glass_end, Color(0.1, 1.0, 0.45, 0.95), 2.0)
        draw_line(right_glass_start, right_glass_end, Color(0.1, 1.0, 0.45, 0.95), 2.0)


func _draw_pane_projection(near_a: Vector2, near_b: Vector2) -> void:
    var travel := _direction * _projection_length
    var far_a := near_a + travel
    var far_b := near_b + travel

    # The near edge is NEVER widened: direct sunlight can only enter through
    # the actual glass. Softness is introduced progressively away from the
    # aperture, so the frame and center mullion stay readable at the window.
    var pane_axis := (near_b - near_a).normalized()
    var softness := edge_softness_px

    var halo_points := PackedVector2Array([
        near_a,
        near_b,
        far_b + pane_axis * softness,
        far_a - pane_axis * softness,
    ])
    var halo_alpha := clampf(_energy * halo_strength, 0.0, 0.48)
    draw_colored_polygon(halo_points, Color(_light_color.r, _light_color.g, _light_color.b, halo_alpha))

    var core_points := PackedVector2Array([
        near_a,
        near_b,
        far_b,
        far_a,
    ])
    var core_alpha := clampf(_energy * core_strength, 0.0, 0.82)
    draw_colored_polygon(core_points, Color(_light_color.r, _light_color.g, _light_color.b, core_alpha))

    # A narrower brighter center gives the projection a luminous interior
    # without turning the glass boundary itself into a neon line.
    var inset := minf(10.0, maxf((near_b.x - near_a.x) * 0.04, 2.0))
    var bright_a := near_a + pane_axis * inset
    var bright_b := near_b - pane_axis * inset
    var bright_far_a := bright_a + travel
    var bright_far_b := bright_b + travel
    var bright_points := PackedVector2Array([bright_a, bright_b, bright_far_b, bright_far_a])
    var bright_alpha := clampf(_energy * 0.12, 0.0, 0.34)
    draw_colored_polygon(bright_points, Color(1.0, 0.94, 0.79, bright_alpha))
