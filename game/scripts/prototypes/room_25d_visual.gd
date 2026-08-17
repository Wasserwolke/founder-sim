extends Control

const MAIN_2D_SCENE := "res://game/scenes/main.tscn"
const ART_PATH := "res://game/assets/reference/pixelart_homeoffice_target.jpg"
const ART_SIZE := Vector2(1672.0, 941.0)
const CARD_WIDTH := 16.0
const CARD_HEIGHT := CARD_WIDTH * ART_SIZE.y / ART_SIZE.x
const DAY_SECONDS := 22.0

@onready var viewport: SubViewport = %Viewport3D
@onready var world: Node3D = %World
@onready var camera: Camera3D = %Camera3D
@onready var sun: DirectionalLight3D = %Sun
@onready var world_environment: WorldEnvironment = %WorldEnvironment
@onready var time_label: Label = %TimeLabel
@onready var state_label: Label = %StateLabel

var art_texture: Texture2D
var time_hours := 7.2
var autoplay := true
var sun_strength := 1.0

var base_art_material: StandardMaterial3D
var window_glow_material: StandardMaterial3D
var receiver_materials: Array[StandardMaterial3D] = []

var desk_lamp: SpotLight3D
var monitor_glow_left: OmniLight3D
var monitor_glow_right: OmniLight3D
var globe_glow: OmniLight3D
var shelf_glow: OmniLight3D


func _ready() -> void:
    art_texture = load(ART_PATH) as Texture2D
    if art_texture == null:
        push_error("2.5D prototype: missing art texture at %s" % ART_PATH)
        return

    camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    camera.size = CARD_HEIGHT
    camera.position = Vector3(0.0, 0.0, 12.0)
    camera.look_at(Vector3.ZERO, Vector3.UP)

    _build_visible_art()
    _build_light_receivers()
    _build_shadow_proxy_geometry()
    _build_window_aperture_shadows()
    _build_local_lights()
    _apply_time()


func _process(delta: float) -> void:
    if autoplay:
        time_hours = fposmod(time_hours + delta * (24.0 / DAY_SECONDS), 24.0)
        _apply_time()


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        match event.keycode:
            KEY_SPACE:
                autoplay = not autoplay
                _update_hud()
            KEY_LEFT:
                autoplay = false
                time_hours = fposmod(time_hours - 0.25, 24.0)
                _apply_time()
            KEY_RIGHT:
                autoplay = false
                time_hours = fposmod(time_hours + 0.25, 24.0)
                _apply_time()
            KEY_1:
                _set_time(7.0)
            KEY_2:
                _set_time(12.5)
            KEY_3:
                _set_time(18.0)
            KEY_4:
                _set_time(22.0)
            KEY_R:
                time_hours = 7.2
                autoplay = true
                _apply_time()
            KEY_F9:
                get_tree().change_scene_to_file(MAIN_2D_SCENE)


func _set_time(value: float) -> void:
    autoplay = false
    time_hours = fposmod(value, 24.0)
    _apply_time()


func _build_visible_art() -> void:
    # The artwork is rendered once, intact. No visible furniture cutouts are
    # layered over it. 3D geometry below is shadows-only, so a bad proxy can
    # affect a shadow but can never erase or replace the source pixel art.
    base_art_material = _add_textured_polygon(
        "PixelArtBase",
        PackedVector2Array([
            Vector2(0, 0),
            Vector2(1672, 0),
            Vector2(1672, 941),
            Vector2(0, 941),
        ]),
        -0.12,
        Vector3(0, 0, 1),
        false,
        true
    )
    base_art_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
    base_art_material.albedo_color = Color.WHITE

    # Mild window response: daylight can bloom without repainting the city.
    window_glow_material = _add_overlay_receiver(
        "WindowGlow",
        PackedVector2Array([
            Vector2(498, 96),
            Vector2(1197, 96),
            Vector2(1197, 513),
            Vector2(498, 513),
        ]),
        -0.02,
        Vector3(0, 0, 1),
        0.035
    )
    window_glow_material.emission_enabled = true
    window_glow_material.emission = Color(0.95, 0.94, 0.88)
    window_glow_material.emission_energy_multiplier = 0.0


func _build_light_receivers() -> void:
    # Nearly transparent receiver surfaces are the 2.5D composite layer.
    # They receive real 3D lights and real 3D shadows while the artwork stays
    # fully visible below them.
    _add_overlay_receiver(
        "WallLightReceiver",
        PackedVector2Array([
            Vector2(0, 100), Vector2(1672, 100),
            Vector2(1672, 625), Vector2(0, 625),
        ]),
        0.00,
        Vector3(0, 0, 1),
        0.055
    )
    _add_overlay_receiver(
        "FloorLightReceiver",
        PackedVector2Array([
            Vector2(0, 625), Vector2(1672, 625),
            Vector2(1672, 941), Vector2(0, 941),
        ]),
        0.015,
        Vector3(0.0, 0.58, 0.815),
        0.105
    )


func _build_shadow_proxy_geometry() -> void:
    # Every mesh below is SHADOWS_ONLY. It is never drawn on top of the art.
    # Coordinates are in the 1672x941 reference space.
    _shadow_poly("Door", [Vector2(42, 101), Vector2(223, 113), Vector2(223, 558), Vector2(42, 574)], 0.18)
    _shadow_poly("ShelfTop", [Vector2(239, 150), Vector2(438, 150), Vector2(438, 201), Vector2(239, 201)], 0.20)
    _shadow_poly("ShelfMid", [Vector2(244, 232), Vector2(436, 232), Vector2(436, 283), Vector2(244, 283)], 0.20)
    _shadow_poly("ShelfBottom", [Vector2(244, 319), Vector2(435, 319), Vector2(435, 387), Vector2(244, 387)], 0.22)
    _shadow_poly("SideCabinet", [Vector2(211, 482), Vector2(384, 480), Vector2(386, 652), Vector2(214, 657)], 0.42)
    _shadow_poly("Sofa", [Vector2(0, 545), Vector2(73, 544), Vector2(100, 570), Vector2(148, 589), Vector2(235, 593), Vector2(281, 625), Vector2(285, 773), Vector2(251, 805), Vector2(0, 810)], 0.95)
    _shadow_poly("SofaPillow", [Vector2(75, 592), Vector2(129, 588), Vector2(158, 613), Vector2(159, 685), Vector2(126, 723), Vector2(82, 717), Vector2(67, 660)], 1.08)
    _shadow_poly("CoffeeTableTop", [Vector2(105, 782), Vector2(422, 783), Vector2(487, 820), Vector2(462, 873), Vector2(134, 873), Vector2(73, 838)], 1.18)
    _shadow_poly("DeskTop", [Vector2(500, 506), Vector2(1178, 506), Vector2(1249, 600), Vector2(1192, 647), Vector2(506, 648), Vector2(449, 611)], 0.82)
    _shadow_poly("DeskLeftPedestal", [Vector2(491, 646), Vector2(637, 646), Vector2(637, 832), Vector2(491, 832)], 0.88)
    _shadow_poly("DeskRightTower", [Vector2(1096, 645), Vector2(1208, 645), Vector2(1208, 830), Vector2(1094, 830)], 0.88)
    _shadow_poly("MonitorLeft", [Vector2(642, 328), Vector2(843, 328), Vector2(843, 495), Vector2(642, 495)], 1.03)
    _shadow_poly("MonitorRight", [Vector2(844, 329), Vector2(1035, 329), Vector2(1035, 497), Vector2(844, 497)], 1.03)
    _shadow_poly("Keyboard", [Vector2(725, 535), Vector2(948, 535), Vector2(972, 580), Vector2(715, 580)], 1.04)
    _shadow_poly("DeskLamp", [Vector2(513, 369), Vector2(540, 365), Vector2(576, 390), Vector2(609, 375), Vector2(641, 392), Vector2(623, 432), Vector2(595, 438), Vector2(578, 515), Vector2(526, 515), Vector2(535, 456)], 1.16)
    _shadow_poly("Chair", [Vector2(779, 594), Vector2(925, 594), Vector2(970, 621), Vector2(976, 775), Vector2(925, 804), Vector2(927, 865), Vector2(956, 888), Vector2(949, 923), Vector2(739, 923), Vector2(731, 890), Vector2(765, 862), Vector2(770, 802), Vector2(741, 780), Vector2(739, 641)], 1.34)
    _shadow_poly("BigPlant", [Vector2(1230, 340), Vector2(1284, 356), Vector2(1308, 329), Vector2(1342, 369), Vector2(1372, 353), Vector2(1398, 423), Vector2(1360, 471), Vector2(1361, 588), Vector2(1326, 647), Vector2(1268, 637), Vector2(1245, 575)], 0.62)
    _shadow_poly("Bookcase", [Vector2(1380, 403), Vector2(1672, 405), Vector2(1672, 806), Vector2(1601, 810), Vector2(1548, 772), Vector2(1489, 744), Vector2(1382, 719)], 0.72)
    _shadow_poly("GlobeLamp", [Vector2(1440, 318), Vector2(1516, 318), Vector2(1527, 385), Vector2(1434, 385)], 0.90)


func _build_window_aperture_shadows() -> void:
    # These define the window aperture but are also shadows-only.
    _shadow_rect("WallLeftOfWindow", Rect2(0, 100, 498, 525), 0.32)
    _shadow_rect("WallRightOfWindow", Rect2(1197, 100, 475, 525), 0.32)
    _shadow_rect("WallBelowWindow", Rect2(498, 513, 699, 112), 0.34)
    _shadow_rect("WindowMullion", Rect2(832, 102, 20, 392), 0.48)
    _shadow_rect("WindowFrameLeft", Rect2(498, 96, 20, 417), 0.42)
    _shadow_rect("WindowFrameRight", Rect2(1177, 96, 20, 417), 0.42)
    _shadow_rect("WindowFrameBottom", Rect2(498, 493, 699, 20), 0.46)


func _build_local_lights() -> void:
    desk_lamp = SpotLight3D.new()
    desk_lamp.name = "DeskLampLight"
    desk_lamp.light_color = Color(1.0, 0.70, 0.36)
    desk_lamp.light_energy = 0.8
    desk_lamp.spot_range = 5.8
    desk_lamp.spot_angle = 52.0
    desk_lamp.spot_attenuation = 0.9
    desk_lamp.shadow_enabled = true
    desk_lamp.position = _px_to_world(Vector2(605, 410), 2.7)
    desk_lamp.look_at(_px_to_world(Vector2(640, 585), 0.35), Vector3.UP)
    world.add_child(desk_lamp)

    monitor_glow_left = _make_omni("MonitorGlowLeft", Vector2(743, 410), Color(0.35, 0.67, 1.0), 2.1)
    monitor_glow_right = _make_omni("MonitorGlowRight", Vector2(934, 410), Color(0.30, 0.60, 1.0), 2.1)
    globe_glow = _make_omni("GlobeGlow", Vector2(1480, 352), Color(1.0, 0.55, 0.20), 2.4)
    shelf_glow = _make_omni("ShelfGlow", Vector2(404, 252), Color(1.0, 0.54, 0.18), 1.7)


func _make_omni(node_name: String, px: Vector2, color: Color, range_value: float) -> OmniLight3D:
    var light := OmniLight3D.new()
    light.name = node_name
    light.light_color = color
    light.light_energy = 0.35
    light.omni_range = range_value
    light.shadow_enabled = true
    light.position = _px_to_world(px, 2.1)
    world.add_child(light)
    return light


func _apply_time() -> void:
    var daylight := 0.0
    if time_hours >= 5.5 and time_hours <= 20.5:
        daylight = maxf(0.0, sin(((time_hours - 5.5) / 15.0) * PI))

    var dawn := _bell(time_hours, 7.1, 1.6)
    var dusk := _bell(time_hours, 18.6, 1.7)
    var golden := maxf(dawn, dusk)
    var progress := clampf((time_hours - 5.5) / 15.0, 0.0, 1.0)
    var elevation := pow(clampf(daylight, 0.0, 1.0), 0.65)

    var lateral := lerpf(0.86, -0.86, progress)
    var downward := lerpf(0.24, 1.18, elevation)
    var ray_direction := Vector3(lateral, -downward, 1.0).normalized()
    sun.look_at(sun.global_position + ray_direction, Vector3.UP)
    sun.light_energy = daylight * (1.15 + golden * 0.72) * sun_strength
    sun.light_color = Color(1.0, 0.97, 0.89).lerp(
        Color(1.0, 0.74, 0.46),
        clampf(golden * 0.62, 0.0, 1.0)
    )
    sun.visible = sun.light_energy > 0.005

    var env := world_environment.environment
    if env != null:
        env.ambient_light_energy = lerpf(0.035, 0.15, daylight)
        env.ambient_light_color = Color(0.08, 0.12, 0.22).lerp(Color(0.58, 0.64, 0.72), daylight)
        env.background_color = Color(0.01, 0.015, 0.03).lerp(Color(0.20, 0.28, 0.40), daylight)

    if base_art_material != null:
        var night_color := Color(0.22, 0.28, 0.42, 1.0)
        var day_color := Color(0.95, 0.96, 0.98, 1.0)
        var exposure := night_color.lerp(day_color, pow(daylight, 0.55))
        exposure = exposure.lerp(Color(1.0, 0.91, 0.78, 1.0), golden * 0.14)
        base_art_material.albedo_color = exposure

    if window_glow_material != null:
        window_glow_material.albedo_color = Color(1.0, 0.96, 0.84, 0.018 + daylight * 0.035)
        window_glow_material.emission = Color(0.78, 0.86, 1.0).lerp(Color(1.0, 0.83, 0.54), golden)
        window_glow_material.emission_energy_multiplier = daylight * (0.04 + golden * 0.12)

    for material in receiver_materials:
        var alpha := material.albedo_color.a
        material.albedo_color = Color(1.0, 0.95 + golden * 0.025, 0.90 + golden * 0.04, alpha)

    var practical := clampf((0.72 - daylight) / 0.62, 0.0, 1.0)
    desk_lamp.light_energy = 0.12 + 1.55 * practical
    monitor_glow_left.light_energy = 0.08 + 0.52 * practical
    monitor_glow_right.light_energy = 0.07 + 0.48 * practical
    globe_glow.light_energy = 0.10 + 0.72 * practical
    shelf_glow.light_energy = 0.06 + 0.48 * practical

    _update_hud()


func _update_hud() -> void:
    var hours := int(floor(time_hours))
    var minutes := int(round((time_hours - float(hours)) * 60.0))
    if minutes >= 60:
        hours = (hours + 1) % 24
        minutes = 0
    time_label.text = "%02d:%02d" % [hours, minutes]
    state_label.text = ("AUTO · SPACE Pause" if autoplay else "MANUELL · ←/→ Zeit") + " · 1/2/3/4 Tageszeiten · F9 alte 2D-Szene"


func _add_textured_polygon(node_name: String, points_px: PackedVector2Array, depth: float, normal: Vector3, cast_shadow: bool, unshaded: bool = false) -> StandardMaterial3D:
    var array_mesh := _mesh_from_polygon(points_px, depth, normal, true)
    var material := StandardMaterial3D.new()
    material.albedo_texture = art_texture
    material.roughness = 1.0
    material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    if unshaded:
        material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

    var instance := MeshInstance3D.new()
    instance.name = node_name
    instance.mesh = array_mesh
    instance.material_override = material
    instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if cast_shadow else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    world.add_child(instance)
    return material


func _add_overlay_receiver(node_name: String, points_px: PackedVector2Array, depth: float, normal: Vector3, alpha: float) -> StandardMaterial3D:
    var array_mesh := _mesh_from_polygon(points_px, depth, normal, false)
    var material := StandardMaterial3D.new()
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.albedo_color = Color(1.0, 1.0, 1.0, alpha)
    material.roughness = 1.0
    material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL

    var instance := MeshInstance3D.new()
    instance.name = node_name
    instance.mesh = array_mesh
    instance.material_override = material
    instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    world.add_child(instance)
    receiver_materials.append(material)
    return material


func _mesh_from_polygon(points_px: PackedVector2Array, depth: float, normal: Vector3, include_uv: bool) -> ArrayMesh:
    var indices := Geometry2D.triangulate_polygon(points_px)
    var array_mesh := ArrayMesh.new()
    if indices.is_empty():
        push_warning("2.5D: triangulation failed")
        return array_mesh

    var vertices := PackedVector3Array()
    var normals := PackedVector3Array()
    var uvs := PackedVector2Array()
    for point in points_px:
        vertices.append(_px_to_world(point, depth))
        normals.append(normal.normalized())
        if include_uv:
            uvs.append(Vector2(point.x / ART_SIZE.x, point.y / ART_SIZE.y))

    var arrays := []
    arrays.resize(Mesh.ARRAY_MAX)
    arrays[Mesh.ARRAY_VERTEX] = vertices
    arrays[Mesh.ARRAY_NORMAL] = normals
    if include_uv:
        arrays[Mesh.ARRAY_TEX_UV] = uvs
    arrays[Mesh.ARRAY_INDEX] = indices
    array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
    return array_mesh


func _shadow_poly(node_name: String, point_list: Array, depth: float) -> void:
    var polygon := PackedVector2Array()
    for point in point_list:
        polygon.append(point)
    var mesh := MeshInstance3D.new()
    mesh.name = node_name
    mesh.mesh = _mesh_from_polygon(polygon, depth, Vector3(0, 0, 1), false)
    mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
    world.add_child(mesh)


func _shadow_rect(node_name: String, rect_px: Rect2, depth: float) -> void:
    var center := rect_px.position + rect_px.size * 0.5
    var mesh := MeshInstance3D.new()
    mesh.name = node_name
    var box := BoxMesh.new()
    box.size = Vector3(
        rect_px.size.x / ART_SIZE.x * CARD_WIDTH,
        rect_px.size.y / ART_SIZE.y * CARD_HEIGHT,
        0.16
    )
    mesh.mesh = box
    mesh.position = _px_to_world(center, depth)
    mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
    world.add_child(mesh)


func _px_to_world(point: Vector2, depth: float) -> Vector3:
    return Vector3(
        (point.x / ART_SIZE.x - 0.5) * CARD_WIDTH,
        (0.5 - point.y / ART_SIZE.y) * CARD_HEIGHT,
        depth
    )


func _bell(hour: float, center: float, width: float) -> float:
    var distance := absf(fposmod(hour - center + 12.0, 24.0) - 12.0)
    return exp(-pow(distance / maxf(width, 0.01), 2.0))
