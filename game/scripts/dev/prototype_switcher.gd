extends Node

const MAIN_SCENE := "res://game/scenes/main.tscn"
const PROTOTYPE_SCENE := "res://game/scenes/prototypes/room_25d_prototype.tscn"


func _unhandled_key_input(event: InputEvent) -> void:
    if not OS.is_debug_build():
        return
    if not (event is InputEventKey) or not event.pressed or event.echo:
        return
    if event.keycode != KEY_F9:
        return

    var current_path := ""
    if get_tree().current_scene != null:
        current_path = get_tree().current_scene.scene_file_path

    var target := MAIN_SCENE if current_path == PROTOTYPE_SCENE else PROTOTYPE_SCENE
    get_tree().change_scene_to_file(target)
    get_viewport().set_input_as_handled()
