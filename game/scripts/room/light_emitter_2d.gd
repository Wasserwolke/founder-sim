extends Node2D
class_name RoomLightEmitter2D

@export var emitter_id: StringName = &"local_light"
@export var category: StringName = &"local"
@export_range(0.0, 4.0, 0.01) var base_energy := 1.0
@export var default_enabled := true

@onready var light: Light2D = $Light


func _ready() -> void:
    if light != null:
        light.enabled = default_enabled
        light.energy = base_energy
    call_deferred("_register_with_room")


func _exit_tree() -> void:
    var rig = get_tree().get_first_node_in_group("room_lighting_rig")
    if rig != null and rig.has_method("unregister_emitter"):
        rig.unregister_emitter(emitter_id)


func _register_with_room() -> void:
    if light == null:
        return
    var rig = get_tree().get_first_node_in_group("room_lighting_rig")
    if rig != null and rig.has_method("register_emitter"):
        rig.register_emitter(emitter_id, light, base_energy, category)


func set_emission_enabled(enabled: bool) -> void:
    if light != null:
        light.enabled = enabled


func set_energy_multiplier(multiplier: float) -> void:
    if light != null:
        light.energy = base_energy * maxf(multiplier, 0.0)
