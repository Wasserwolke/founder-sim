extends Button

signal action_requested(action_id: StringName, display_name: String)

@export var action_id: StringName
@export var display_name: String = "Objekt"
@export_multiline var hint: String = ""


func _ready() -> void:
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)
    pressed.connect(_on_pressed)
    tooltip_text = hint if not hint.is_empty() else display_name
    modulate.a = 0.0


func _on_mouse_entered() -> void:
    modulate.a = 1.0


func _on_mouse_exited() -> void:
    modulate.a = 0.0


func _on_pressed() -> void:
    action_requested.emit(action_id, display_name)
