@tool
class_name UICreditsMenuItem
extends HBoxContainer

@export var item_title: String:
	set(value):
		item_title = value
		if is_node_ready():
			_update()
@export var item_value: String:
	set(value):
		item_value = value
		if is_node_ready():
			_update()

@onready var title_label: Label = $Title
@onready var value_label: Label = $Value

# ===
# Built-In
# ===

func _ready() -> void:
	_update()

# ===
# Private
# ===

func _update() -> void:
	title_label.text = item_title
	value_label.text = item_value
