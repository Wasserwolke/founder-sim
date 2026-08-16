extends PanelContainer

@export var resource_id: StringName
@export var title: String = "STAT"
@export var show_progress: bool = false

@onready var title_label: Label = %Title
@onready var value_label: Label = %Value
@onready var progress_bar: ProgressBar = %Progress


func _ready() -> void:
    title_label.text = title
    progress_bar.visible = show_progress
    GameState.resource_changed.connect(_on_resource_changed)
    _refresh()


func _on_resource_changed(changed_id: StringName, _old_value: float, _new_value: float, _source: StringName) -> void:
    if changed_id == resource_id:
        _refresh()


func _refresh() -> void:
    var value := GameState.get_value(resource_id)
    var definition := GameState.get_definition(resource_id)
    var unit := String(definition.get("unit", ""))

    if unit == "EUR":
        value_label.text = "%0.0f EUR" % value
    else:
        value_label.text = "%0.0f" % value

    if show_progress:
        progress_bar.min_value = float(definition.get("min", 0.0))
        progress_bar.max_value = float(definition.get("max", 100.0))
        progress_bar.value = value
