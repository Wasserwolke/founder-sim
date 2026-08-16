extends PanelContainer

@onready var value_label: Label = %Value


func _ready() -> void:
    GameState.time_changed.connect(_on_time_changed)
    _refresh()


func _on_time_changed(_minutes: int) -> void:
    _refresh()


func _refresh() -> void:
    value_label.text = GameState.time_string()
