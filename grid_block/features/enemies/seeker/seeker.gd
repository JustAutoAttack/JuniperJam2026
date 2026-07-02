class_name SeekerEnemy
extends Enemy

@export var body_mesh_instance: MeshInstance3D

var _last_pos: Vector3

func _ready() -> void:
	super()
	_last_pos = global_position

func _physics_process(delta: float) -> void:
	super(delta)
	_update_rolling(delta)

func _update_rolling(delta: float) -> void:
	if not body_mesh_instance or delta == 0:
		return
		
	# Calculate velocity
	var current_pos = global_position
	var velocity = (current_pos - _last_pos) / delta
	_last_pos = current_pos
	
	var speed = velocity.length()
	if speed > 0.1:
		var move_dir = velocity.normalized()
		var rotation_axis = Vector3.UP.cross(move_dir).normalized()
		
		body_mesh_instance.rotate_object_local(rotation_axis, speed * delta)
