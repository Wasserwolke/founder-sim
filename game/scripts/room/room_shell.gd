extends Control

signal action_requested(action_id: StringName, display_name: String)


func _ready() -> void:
    for child in %Hotspots.get_children():
        if child.has_signal("action_requested"):
            child.action_requested.connect(_forward_action)


func _forward_action(action_id: StringName, display_name: String) -> void:
    action_requested.emit(action_id, display_name)
