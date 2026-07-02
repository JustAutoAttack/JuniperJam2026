class_name XPItem
extends Node3D

var value: float

func _ready() -> void:
	deactivate()

func activate(spawn_pos: Vector3, xp_value: float) -> void:
	value = xp_value
	global_position = spawn_pos + Vector3(0, 0.5, 0)
	reset_physics_interpolation()
	visible = true
	set_process(true)

func deactivate() -> void:
	visible = false
	set_process(false)
	
	EventBus.emit(
		GameEvent.RecycleXPItem.new(
			self
		)
	)
