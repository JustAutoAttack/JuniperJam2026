class_name DebrisCube
extends RigidBody3D

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var cleanup_tween: Tween

# ===
# Built-In
# ===

func _ready() -> void:
	deactivate()

# ===
# Public
# ===

func activate(
	spawn_pos: Vector3, 
	force: Vector3,
	material: Material
) -> void:
	if cleanup_tween and cleanup_tween.is_running():
		cleanup_tween.kill()
	
	# Apply the passed material directly
	mesh_instance.set_surface_override_material(0, material)
	
	# Reset Physics
	process_mode = PROCESS_MODE_INHERIT
	freeze = false
	visible = true
	collision_shape.disabled = false
	
	# Reset Transform
	global_position = spawn_pos
	reset_physics_interpolation()
	scale = Vector3.ONE * randf_range(0.5, 1.5)
	rotation = Vector3(randf() * TAU, randf() * TAU, randf() * TAU)
	
	# Apply Forces
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	apply_central_impulse(force)
	constant_torque = Vector3(
		randf_range(-1, 1), 
		randf_range(-1, 1), 
		randf_range(-1, 1)
	) * 5
	
	# Cleanup
	await get_tree().create_timer(2.0).timeout
	_start_cleanup()

func deactivate() -> void:
	if cleanup_tween and cleanup_tween.is_running():
		cleanup_tween.kill()
	
	process_mode = PROCESS_MODE_DISABLED
	freeze = true
	visible = false
	
	EventBus.emit(
		GameEvent.RecycleDebris.new(
			self
		)
	)

# ===
# Private
# ===

func _start_cleanup() -> void:
	collision_shape.disabled = true
	freeze = true
	
	cleanup_tween = create_tween()
	cleanup_tween.tween_property(
		self, 
		"scale", 
		Vector3(
			0.01, 
			0.01, 
			0.01
		), 
		0.5
	)
	cleanup_tween.tween_callback(deactivate)
