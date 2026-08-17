@tool
extends PointLight2D
class_name SunlightProjection2D

# Pixel-calibrated against the exact repository image
# game/assets/environments/room_shell_neutral.png (1672 x 941).
# The last visible glass row is y=431; y=432 is already the dark lower frame.
@export_group("Visible window aperture")
@export var left_glass_start := Vector2(525.0, 431.0):
    set(value):
        left_glass_start = value
        queue_redraw()
@export var left_glass_end := Vector2(821.0, 431.0):
    set(value):
        left_glass_end = value
        queue_redraw()
@export var right_glass_start := Vector2(839.0, 431.0):
    set(value):
        right_glass_start = value
        queue_redraw()
@export var right_glass_end := Vector2(1126.0, 431.0):
    set(value):
        right_glass_end = value
        queue_redraw()

@export_group("Projection look")
@export_range(0.0, 48.0, 1.0) var edge_softness_px := 16.0:
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
@export var debug_draw_receivers := false:
    set(value):
        debug_draw_receivers = value
        queue_redraw()

# Baked receiver masks for the furniture already present in room_shell_neutral.
# These are NOT new assets. They only tell the 2D projection which visible
# surface has a different height than the floor.
@export_group("Baked receiver surfaces")
@export var sofa_receiver_polygon := PackedVector2Array([
    Vector2(0.0, 558.0), Vector2(82.0, 558.0), Vector2(122.0, 596.0),
    Vector2(218.0, 598.0), Vector2(280.0, 627.0), Vector2(280.0, 848.0),
    Vector2(0.0, 848.0),
])
@export_range(0.25, 1.0, 0.01) var sofa_travel_scale := 0.78

@export var coffee_table_receiver_polygon := PackedVector2Array([
    Vector2(24.0, 849.0), Vector2(441.0, 849.0),
    Vector2(363.0, 940.0), Vector2(0.0, 940.0),
])
@export_range(0.25, 1.0, 0.01) var coffee_table_travel_scale := 0.90

@export var side_cabinet_receiver_polygon := PackedVector2Array([
    Vector2(205.0, 470.0), Vector2(359.0, 470.0),
    Vector2(359.0, 681.0), Vector2(205.0, 681.0),
])
@export_range(0.25, 1.0, 0.01) var side_cabinet_travel_scale := 0.58

@export var bookcase_receiver_polygon := PackedVector2Array([
    Vector2(1400.0, 410.0), Vector2(1672.0, 410.0),
    Vector2(1672.0, 860.0), Vector2(1400.0, 860.0),
])
@export_range(0.25, 1.0, 0.01) var bookcase_travel_scale := 0.72

var _direction := Vector2.DOWN
var _projection_length := 420.0
var _energy := 0.0
var _light_color := Color(1.0, 0.88, 0.63, 1.0)
var _target_direction := Vector2.DOWN
var _target_length := 420.0
var _target_energy := 0.0
var _target_color := Color(1.0, 0.88, 0.63, 1.0)
var _window_sun_glow_light: PointLight2D


func _ready() -> void:
    # The parent LightingRig still addresses this node through the historical
    # PointLight2D contract. Its radial light is culled; only our custom
    # window-aperture projection is visible.
    range_item_cull_mask = 0
    shadow_enabled = false
    position = Vector2.ZERO
    rotation = 0.0
    _resolve_window_sun_glow()
    set_process(true)
    _sync_from_parent(true)
    _apply_window_sun_glow()


func _process(_delta: float) -> void:
    # Keep the aperture fixed in room coordinates. Geometry follows the clock
    # exactly so accelerated animation and manual scrubbing match at each time.
    position = Vector2.ZERO
    rotation = 0.0
    range_item_cull_mask = 0

    _sync_from_parent(false)
    _direction = _target_direction
    _projection_length = _target_length
    _energy = _target_energy
    _light_color = _target_color

    _apply_window_sun_glow()
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

    # Low sun reaches much farther into the room. Around midday the footprint
    # stays closer to the window. This is the dominant depth animation.
    var elevation_factor := pow(clampf(daylight, 0.0, 1.0), 0.62)
    _target_length = lerpf(1080.0, 300.0, elevation_factor)

    # Required room convention: morning/eastern sun projects to the RIGHT.
    # As the sun moves east -> west, the footprint travels right -> left.
    # At room scale the rays remain parallel; only their common direction and
    # reach change. Low sun is deliberately flatter than the previous version.
    var sun_progress := clampf((hour - 5.4) / 15.2, 0.0, 1.0)
    var lateral := lerpf(0.82, -0.82, sun_progress)
    var vertical := lerpf(0.48, 1.20, elevation_factor)
    _target_direction = Vector2(lateral, vertical).normalized()

    _target_color = Color(1.0, 0.94, 0.78, 1.0).lerp(
        Color(1.0, 0.64, 0.29, 1.0),
        clampf(golden * 1.08, 0.0, 1.0)
    )

    if immediate:
        _direction = _target_direction
        _projection_length = _target_length
        _energy = _target_energy
        _light_color = _target_color
        _apply_window_sun_glow()
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
    _apply_window_sun_glow()
    queue_redraw()


func _resolve_window_sun_glow() -> void:
    if is_instance_valid(_window_sun_glow_light):
        return
    var parent := get_parent()
    if parent != null:
        _window_sun_glow_light = parent.get_node_or_null("WindowSunGlowLight") as PointLight2D


func _apply_window_sun_glow() -> void:
    # Direct sun also raises the exposure of glass, frame and nearby wall so a
    # strong floor beam cannot coexist with an implausibly dull grey window.
    _resolve_window_sun_glow()
    if not is_instance_valid(_window_sun_glow_light):
        return

    var glow_energy := clampf(_energy * 0.68, 0.0, 2.25)
    _window_sun_glow_light.color = _light_color.lerp(Color(1.0, 0.985, 0.92, 1.0), 0.35)
    _window_sun_glow_light.energy = glow_energy
    _window_sun_glow_light.enabled = glow_energy > 0.003


func _draw() -> void:
    if _energy > 0.002 and _projection_length > 1.0:
        # Base room surfaces. Splitting them prevents the floor projection from
        # simply painting over the baked furniture at floor depth.
        var wall_center := PackedVector2Array([
            Vector2(360.0, 431.0), Vector2(1400.0, 431.0),
            Vector2(1400.0, 616.0), Vector2(360.0, 616.0),
        ])
        var wall_left_upper := PackedVector2Array([
            Vector2(0.0, 431.0), Vector2(205.0, 431.0),
            Vector2(205.0, 558.0), Vector2(0.0, 558.0),
        ])
        var floor_center := PackedVector2Array([
            Vector2(280.0, 616.0), Vector2(1400.0, 616.0),
            Vector2(1400.0, 860.0), Vector2(1672.0, 860.0),
            Vector2(1672.0, 941.0), Vector2(441.0, 941.0),
            Vector2(441.0, 849.0), Vector2(280.0, 849.0),
        ])

        _draw_both_panes_on_receiver(wall_center, 1.0, 1.0)
        _draw_both_panes_on_receiver(wall_left_upper, 1.0, 0.92)
        _draw_both_panes_on_receiver(floor_center, 1.0, 1.0)

        # Height-aware baked receivers. A higher surface meets the same ray
        # sooner, so its screen-space footprint uses a shorter travel distance.
        _draw_both_panes_on_receiver(side_cabinet_receiver_polygon, side_cabinet_travel_scale, 0.86)
        _draw_both_panes_on_receiver(sofa_receiver_polygon, sofa_travel_scale, 0.88)
        _draw_both_panes_on_receiver(coffee_table_receiver_polygon, coffee_table_travel_scale, 0.96)
        _draw_both_panes_on_receiver(bookcase_receiver_polygon, bookcase_travel_scale, 0.82)

    if debug_draw_aperture:
        draw_line(left_glass_start, left_glass_end, Color(0.1, 1.0, 0.45, 0.95), 1.0)
        draw_line(right_glass_start, right_glass_end, Color(0.1, 1.0, 0.45, 0.95), 1.0)

    if debug_draw_receivers:
        _debug_polygon(sofa_receiver_polygon, Color(0.15, 1.0, 0.55, 0.75))
        _debug_polygon(coffee_table_receiver_polygon, Color(1.0, 0.85, 0.15, 0.75))
        _debug_polygon(side_cabinet_receiver_polygon, Color(0.25, 0.75, 1.0, 0.75))
        _debug_polygon(bookcase_receiver_polygon, Color(0.9, 0.4, 1.0, 0.75))


func _draw_both_panes_on_receiver(receiver: PackedVector2Array, travel_scale: float, strength: float) -> void:
    _draw_pane_projection_on_receiver(left_glass_start, left_glass_end, receiver, travel_scale, strength)
    _draw_pane_projection_on_receiver(right_glass_start, right_glass_end, receiver, travel_scale, strength)


func _draw_pane_projection_on_receiver(
    near_a: Vector2,
    near_b: Vector2,
    receiver: PackedVector2Array,
    travel_scale: float,
    strength: float
) -> void:
    if receiver.size() < 3:
        return

    var travel := _direction * (_projection_length * clampf(travel_scale, 0.05, 1.25))
    var pane_axis := (near_b - near_a).normalized()
    var softness := edge_softness_px

    var halo_polygon := PackedVector2Array([
        near_a,
        near_b,
        near_b + travel + pane_axis * softness,
        near_a + travel - pane_axis * softness,
    ])
    _draw_intersection(
        halo_polygon,
        receiver,
        Color(_light_color.r, _light_color.g, _light_color.b, clampf(_energy * halo_strength * strength, 0.0, 0.48))
    )

    var core_polygon := PackedVector2Array([
        near_a,
        near_b,
        near_b + travel,
        near_a + travel,
    ])
    _draw_intersection(
        core_polygon,
        receiver,
        Color(_light_color.r, _light_color.g, _light_color.b, clampf(_energy * core_strength * strength, 0.0, 0.82))
    )

    var inset := minf(10.0, maxf((near_b.x - near_a.x) * 0.035, 2.0))
    var bright_a := near_a + pane_axis * inset
    var bright_b := near_b - pane_axis * inset
    var bright_polygon := PackedVector2Array([
        bright_a,
        bright_b,
        bright_b + travel,
        bright_a + travel,
    ])
    _draw_intersection(
        bright_polygon,
        receiver,
        Color(1.0, 0.95, 0.82, clampf(_energy * 0.11 * strength, 0.0, 0.32))
    )


func _draw_intersection(projected: PackedVector2Array, receiver: PackedVector2Array, color: Color) -> void:
    if color.a <= 0.001:
        return
    var pieces := Geometry2D.intersect_polygons(projected, receiver)
    for piece in pieces:
        if piece.size() >= 3 and not Geometry2D.is_polygon_clockwise(piece):
            draw_colored_polygon(piece, color)


func _debug_polygon(polygon: PackedVector2Array, color: Color) -> void:
    if polygon.size() < 2:
        return
    var points := polygon.duplicate()
    points.append(polygon[0])
    draw_polyline(points, color, 1.0, false)
