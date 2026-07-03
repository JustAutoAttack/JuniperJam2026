@tool
class_name UISettingsMenuToggleItem
extends HBoxContainer

signal toggled(toggled_on: bool)

@export var title: String = "":
	set(value):
		title = value
		if is_node_ready():
			_update()

@onready var title_label: Label = %Title
@onready var check_box: TextureButton = %CheckBox

# ===
# Built-In
# ===

func _ready() -> void:
	check_box.toggled.connect(
		func(toggled_on: bool): 
			toggled.emit(toggled_on)
	)
	_update()

# ===
# Public
# ===

func toggle(on: bool) -> void:
	check_box.button_pressed = on

# ===
# Private
# ===

func _update() -> void:
	title_label.text = title
