extends Control

const ROOM_SHELL_PATH := "res://game/assets/environments/room_shell_neutral.png"

@onready var background: TextureRect = %Background
@onready var darkness: ColorRect = %Darkness
@onready var toast: Label = %Toast
@onready var room_shell = %RoomShell
@onready var hotspots: Control = %Hotspots

var toast_tween: Tween


func _ready() -> void:
    room_shell.action_requested.connect(_on_room_action_requested)
    GameState.time_changed.connect(_on_time_changed)
    _load_room_shell()
    _update_lighting()


func _load_room_shell() -> void:
    if ResourceLoader.exists(ROOM_SHELL_PATH, "Texture2D"):
        var texture := load(ROOM_SHELL_PATH) as Texture2D
        if texture != null:
            background.texture = texture
            hotspots.mouse_filter = Control.MOUSE_FILTER_PASS
            _show_toast("GitHub -> Godot Sync erfolgreich. Diese sichtbare Nachricht kam gerade aus meinem Commit.")
            return

    hotspots.mouse_filter = Control.MOUSE_FILTER_IGNORE
    push_warning("Founder Sim: room shell missing at %s" % ROOM_SHELL_PATH)
    _show_toast("Raum-Shell fehlt. Lege die PNG-Datei unter game/assets/environments/room_shell_neutral.png ab.")


func _on_time_changed(_minutes: int) -> void:
    _update_lighting()


func _update_lighting() -> void:
    var hour := float(GameState.minutes) / 60.0
    var darkness_amount := 0.0

    if hour >= 20.0:
        darkness_amount = remap(hour, 20.0, 24.0, 0.10, 0.38)
    elif hour < 6.0:
        darkness_amount = remap(hour, 0.0, 6.0, 0.38, 0.16)
    elif hour < 8.0:
        darkness_amount = remap(hour, 6.0, 8.0, 0.16, 0.0)

    darkness.color = Color(0.025, 0.05, 0.09, clampf(darkness_amount, 0.0, 0.42))


func _on_room_action_requested(action_id: StringName, display_name: String) -> void:
    match action_id:
        &"room.window":
            _show_toast("%s: spaeter Wetter, Tageslicht und Stadtzustand." % display_name)
        &"room.door":
            _show_toast("%s: spaeter Wechsel zu Flur, Stadtkarte und Terminen." % display_name)
        &"room.left_shelves":
            _show_toast("%s: modulare Ablage fuer kleine Gegenstaende." % display_name)
        &"room.bookcase":
            _show_toast("%s: spaeter Dokumente, Wissen und Firmenunterlagen." % display_name)
        &"room.floor":
            _show_toast("%s: hier werden Schreibtisch, Stuhl und weitere Moebel als eigene Godot-Nodes platziert." % display_name)
        _:
            _show_toast(display_name)


func _show_toast(message: String) -> void:
    toast.text = message
    toast.modulate.a = 1.0
    if toast_tween != null and toast_tween.is_valid():
        toast_tween.kill()
    toast_tween = create_tween()
    toast_tween.tween_interval(3.0)
    toast_tween.tween_property(toast, "modulate:a", 0.0, 0.35)
