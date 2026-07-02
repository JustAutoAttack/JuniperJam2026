class_name TetheredBlade
extends Node3D

@export var tether_length: float = 5.0:
	set(value):
		if tether_length == value: return
		tether_length = value
		if is_node_ready():
			_update_length()

@onready var tether_wrapper: Node3D = %TetherWrapper
@onready var tether: MeshInstance3D = %Tether
@onready var blade: Blade = %Blade

# ===
# Built-In
# ===

func _ready() -> void:
	_update_length()

# ===
# Private
# ===

func _update_length() -> void:
	tether.scale.x = tether_length
	tether.position.x = tether_length / 2
	blade.position.x = tether_length
