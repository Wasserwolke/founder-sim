extends Node

signal resource_changed(resource_id: StringName, old_value: float, new_value: float, source: StringName)
signal time_changed(minutes: int)

const RESOURCE_PATH := "res://game/data/resources.json"
const MINUTES_PER_DAY := 24 * 60

var definitions: Dictionary = {}
var values: Dictionary = {}
var minutes: int = 19 * 60 + 30


func _ready() -> void:
    _load_resources()


func _load_resources() -> void:
    var file := FileAccess.open(RESOURCE_PATH, FileAccess.READ)
    if file == null:
        push_error("Founder Sim: resources.json could not be opened")
        return

    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("Founder Sim: resources.json is invalid")
        return

    definitions = parsed.get("resources", {})
    values.clear()
    for resource_id in definitions:
        var definition: Dictionary = definitions[resource_id]
        values[resource_id] = clamp_value(resource_id, float(definition.get("initial", 0.0)))


func get_value(resource_id: StringName) -> float:
    return float(values.get(String(resource_id), 0.0))


func get_definition(resource_id: StringName) -> Dictionary:
    return definitions.get(String(resource_id), {})


func set_value(resource_id: StringName, value: float, source: StringName = &"game") -> float:
    var key := String(resource_id)
    if not definitions.has(key):
        push_error("Founder Sim: unknown resource %s" % key)
        return value

    var old_value := get_value(resource_id)
    var new_value := clamp_value(resource_id, value)
    values[key] = new_value
    resource_changed.emit(resource_id, old_value, new_value, source)
    return new_value


func add_value(resource_id: StringName, delta: float, source: StringName = &"game") -> float:
    return set_value(resource_id, get_value(resource_id) + delta, source)


func clamp_value(resource_id: StringName, value: float) -> float:
    var definition := get_definition(resource_id)
    var minimum := float(definition.get("min", -INF))
    var maximum := float(definition.get("max", INF))
    return clampf(value, minimum, maximum)


func pass_time(delta_minutes: int) -> void:
    minutes = posmod(minutes + delta_minutes, MINUTES_PER_DAY)
    time_changed.emit(minutes)


func time_string() -> String:
    var hours := int(minutes / 60)
    var mins := minutes % 60
    return "%02d:%02d" % [hours, mins]
