@tool
extends PointLight2D
class_name SunlightProjection2D

# Pixel-calibrated against:
# game/assets/environments/room_shell_neutral.png (1672 x 941).
# The last visible glass row is y=431; y=432 is already the dark lower frame.
# The receiver coordinates below are deliberately tied to this exact shell.

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
@export var glass_top_y := 47.0:
    set(value):
        glass_top_y = value
        queue_redraw()

@export_group("Projection look")
@export_range(0.0, 48.0, 1.0) var edge_softness_px := 14.0:
    set(value):
        edge_softness_px = maxf(value, 0.0)
        queue_redraw()
@export_range(0.0, 1.0, 0.01) var core_strength := 0.22:
    set(value):
        core_strength = clampf(value, 0.0, 1.0)
        queue_redraw()
@export_range(0.0, 1.0, 0.01) var halo_strength := 0.08:
    set(value):
        halo_strength = clampf(value, 0.0, 1.0)
        queue_redraw()
@export_range(0.0, 1.0, 0.01) var bright_core_strength := 0.055:
    set(value):
        bright_core_strength = clampf(value, 0.0, 1.0)
        queue_redraw()
@export var debug_draw_aperture := false:
    set(value):
        debug_draw_aperture = value
        queue_redraw()
@export var debug_draw_receivers := false:
    set(value):
        debug_draw_receivers = value
        queue_redraw()

# Pixel-measured surfaces already baked into room_shell_neutral. These are not
# new assets; they only tell the 2D sunlight where a higher visible surface is.
# Coordinates are mirrored in docs/ROOM_GEOMETRY.md.
@export_group("Baked furniture receivers")
@export var side_cabinet_top := PackedVector2Array([
    Vector2(205.0, 491.0), Vector2(350.0, 491.0),
    Vector2(384.0, 470.0), Vector2(239.0, 470.0),
])
@export_range(0.25, 1.0, 0.01) var side_cabinet_travel_scale := 0.54

@export var sofa_arm_surface := PackedVector2Array([
    Vector2(176.0, 636.0), Vector2(276.0, 636.0),
    Vector2(278.0, 804.0), Vector2(241.0, 820.0),
    Vector2(192.0, 844.0), Vector2(154.0, 865.0),
    Vector2(154.0, 813.0), Vector2(204.0, 781.0),
    Vector2(219.0, 742.0), Vector2(217.0, 704.0),
])
@export_range(0.25, 1.0, 0.01) var sofa_arm_travel_scale := 0.73

@export var pillow_surface := PackedVector2Array([
    Vector2(35.0, 632.0), Vector2(219.0, 615.0),
    Vector2(302.0, 691.0), Vector2(236.0, 756.0),
    Vector2(114.0, 780.0), Vector2(33.0, 716.0),
])
@export_range(0.25, 1.0, 0.01) var pillow_travel_scale := 0.66

@export var coffee_table_top := PackedVector2Array([
    Vector2(24.0, 817.0), Vector2(441.0, 817.0),
    Vector2(363.0, 941.0), Vector2(0.0, 941.0),
])
@export_range(0.25, 1.0, 0.01) var coffee_table_travel_scale := 0.86

@export var bookcase_top := PackedVector2Array([
    Vector2(1405.0, 409.0), Vector2(1530.0, 409.0),
    Vector2(1672.0, 447.0), Vector2(1672.0, 491.0),
    Vector2(1520.0, 475.0), Vector2(1405.0, 432.0),
])
@export_range(0.25, 1.0, 0.01) var bookcase_travel_scale := 0.43

var _direction := Vector2.DOWN
var _projection_length := 420.0
var _energy := 0.0
var _light_color := Color(1.0, 0.94, 0.84, 1.0)
var _window_glare_alpha := 0.0
var _sill_glow_alpha := 0.0

var _target_direction := Vector2.DOWN
var _target_length := 420.0
var _target_energy := 0.0
var _target_color := Color(1.0, 0.94, 0.84, 1.0)
var _target_window_glare_alpha := 0.0
var _target_sill_glow_alpha := 0.0

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
    # Geometry follows the clock directly so manual scrubbing and accelerated
    # 24h animation show the same footprint at the same clock time.
    position = Vector2.ZERO
    rotation = 0.0
    range_item_cull_mask = 0

    _sync_from_parent(false)
    _direction = _target_direction
    _projection_length = _target_length
    _energy = _target_energy
    _light_color = _target_color
    _window_glare_alpha = _target_window_glare_alpha
    _sill_glow_alpha = _target_sill_glow_alpha

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

    # Keep the direct beam readable without letting it look like an opaque
    # orange decal. Window glare uses the same direct-sun signal separately.
    _target_energy = clampf(direct_sun * (0.86 + golden * 0.72) * multiplier, 0.0, 3.0)

    # Low sun travels farther and flatter; high sun lands closer to the window.
    var elevation_factor := pow(clampf(daylight, 0.0, 1.0), 0.62)
    _target_length = lerpf(1080.0, 300.0, elevation_factor)

    # Room convention: morning/eastern sun projects to the RIGHT. As the sun
    # moves east -> west, the common parallel direction moves right -> left.
    var sun_progress := clampf((hour - 5.4) / 15.2, 0.0, 1.0)
    var lateral := lerpf(0.82, -0.82, sun_progress)
    var vertical := lerpf(0.48, 1.20, elevation_factor)
    _target_direction = Vector2(lateral, vertical).normalized()

    # Neutral daylight first; warm golden-hour tint is deliberately restrained.
    _target_color = Color(1.0, 0.975, 0.90, 1.0).lerp(
        Color(1.0, 0.79, 0.55, 1.0),
        clampf(golden * 0.90, 0.0, 1.0)
    )

    var glare_multiplier := clampf(sqrt(maxf(multiplier, 0.0)), 0.0, 1.65)
    _target_window_glare_alpha = clampf(
        direct_sun * (0.055 + golden * 0.055) * glare_multiplier * (1.0 - cloudiness * 0.45),
        0.0,
        0.16
    )
    _target_sill_glow_alpha = clampf(
        direct_sun * (0.045 + golden * 0.040) * glare_multiplier * (1.0 - cloudiness * 0.40),
        0.0,
        0.12
    )

    if immediate:
        _direction = _target_direction
        _projection_length = _target_length
        _energy = _target_energy
        _light_color = _target_color
        _window_glare_alpha = _target_window_glare_alpha
        _sill_glow_alpha = _target_sill_glow_alpha
        _apply_window_sun_glow()
        queue_redraw()


func _bell(hour: float, center: float, width: float) -> float:
    var distance := absf(fposmod(hour - center + 12.0, 24.0) - 12.0)
    return exp(-pow(distance / maxf(width, 0.01), 2.0))


func set_projection(direction: Vector2, projection_length: float, energy: float, light_color: Color) -> void:
    # Compatibility entry point for the parent LightingRig. The authoritative
    # values are recalculated from the parent's clock every process frame.
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
    # A real bright window lifts the frame and the nearby wall as well. This is
    # local spill, not the direct beam itself.
    _resolve_window_sun_glow()
    if not is_instance_valid(_window_sun_glow_light):
        return

    var glow_energy := clampf(_energy * 0.48, 0.0, 1.55)
    _window_sun_glow_light.color = _light_color.lerp(Color(1.0, 0.99, 0.95, 1.0), 0.55)
    _window_sun_glow_light.energy = glow_energy
    _window_sun_glow_light.enabled = glow_energy > 0.003


func _draw() -> void:
    _draw_window_response()

    if _energy > 0.002 and _projection_length > 1.0:
        # Wall immediately below / beside the window.
        var wall_center := PackedVector2Array([
            Vector2(360.0, 431.0), Vector2(1400.0, 431.0),
            Vector2(1400.0, 616.0), Vector2(360.0, 616.0),
        ])
        var wall_left_upper := PackedVector2Array([
            Vector2(0.0, 431.0), Vector2(205.0, 431.0),
            Vector2(205.0, 558.0), Vector2(0.0, 558.0),
        ])

        # Floor is split around the baked furniture instead of drawing one
        # giant polygon across objects. This removes the stray horizontal cuts
        # seen at the coffee table and bookcase edges.
        var floor_main := PackedVector2Array([
            Vector2(360.0, 616.0), Vector2(1400.0, 616.0),
            Vector2(1400.0, 860.0), Vector2(1672.0, 860.0),
            Vector2(1672.0, 941.0), Vector2(441.0, 941.0),
            Vector2(441.0, 817.0), Vector2(360.0, 817.0),
        ])
        var floor_left_mid := PackedVector2Array([
            Vector2(280.0, 648.0), Vector2(360.0, 648.0),
            Vector2(360.0, 817.0), Vector2(280.0, 817.0),
        ])

        _draw_both_panes_on_receiver(wall_center, 1.0, 0.86)
        _draw_both_panes_on_receiver(wall_left_upper, 1.0, 0.78)
        _draw_both_panes_on_receiver(floor_main, 1.0, 0.92)
        _draw_both_panes_on_receiver(floor_left_mid, 1.0, 0.92)

        # Height-aware top-facing surfaces already visible in the background.
        _draw_both_panes_on_receiver(side_cabinet_top, side_cabinet_travel_scale, 0.72)
        _draw_both_panes_on_receiver(sofa_arm_surface, sofa_arm_travel_scale, 0.58)
        _draw_both_panes_on_receiver(pillow_surface, pillow_travel_scale, 0.54)
        _draw_both_panes_on_receiver(coffee_table_top, coffee_table_travel_scale, 0.72)
        _draw_both_panes_on_receiver(bookcase_top, bookcase_travel_scale, 0.60)

    if debug_draw_aperture:
        draw_line(left_glass_start, left_glass_end, Color(0.1, 1.0, 0.45, 0.95), 1.0)
        draw_line(right_glass_start, right_glass_end, Color(0.1, 1.0, 0.45, 0.95), 1.0)

    if debug_draw_receivers:
        _debug_polygon(side_cabinet_top, Color(0.25, 0.75, 1.0, 0.85))
        _debug_polygon(sofa_arm_surface, Color(0.15, 1.0, 0.55, 0.85))
        _debug_polygon(pillow_surface, Color(0.50, 1.0, 0.20, 0.85))
        _debug_polygon(coffee_table_top, Color(1.0, 0.85, 0.15, 0.85))
        _debug_polygon(bookcase_top, Color(0.9, 0.4, 1.0, 0.85))


func _draw_window_response() -> void:
    if _window_glare_alpha <= 0.001 and _sill_glow_alpha <= 0.001:
        return

    # Strong direct sun partially washes out the exterior view instead of
    # leaving a dull, perfectly readable city behind a bright interior beam.
    var glare_color := Color(1.0, 0.985, 0.94, _window_glare_alpha)
    var left_glass := PackedVector2Array([
        Vector2(left_glass_start.x, glass_top_y),
        Vector2(left_glass_end.x, glass_top_y),
        left_glass_end,
        left_glass_start,
    ])
    var right_glass := PackedVector2Array([
        Vector2(right_glass_start.x, glass_top_y),
        Vector2(right_glass_end.x, glass_top_y),
        right_glass_end,
        right_glass_start,
    ])
    draw_colored_polygon(left_glass, glare_color)
    draw_colored_polygon(right_glass, glare_color)

    # The lower metal/wood frame catches some of the same direct sun.
    var sill_color := Color(1.0, 0.96, 0.86, _sill_glow_alpha)
    draw_rect(Rect2(Vector2(498.0, 431.0), Vector2(646.0, 22.0)), sill_color)


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
        Color(_light_color.r, _light_color.g, _light_color.b, clampf(_energy * halo_strength * strength, 0.0, 0.26))
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
        Color(_light_color.r, _light_color.g, _light_color.b, clampf(_energy * core_strength * strength, 0.0, 0.52))
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
        Color(1.0, 0.985, 0.93, clampf(_energy * bright_core_strength * strength, 0.0, 0.16))
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
