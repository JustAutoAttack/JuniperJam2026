extends EnemyState

@export var body_mesh_instance: MeshInstance3D
@export var telegraph_mesh_instance: MeshInstance3D

@export_category("Configs")
@export var telegraph_time: float = 1.0
@export var charge_speed: float = 18.0
@export var overshoot_distance: float = 5.0
@export var squish_amount: float = 0.4

var _charge_target: Vector3
var _timer: float = 0.0
var _start_pos: Vector3
var _orig_scale: Vector3
var _orig_position: Vector3

# ===
# Built-In
# ===

func _ready() -> void:
	super()
	telegraph_mesh_instance.hide()

func enter(_prev_state_path: String, _data: Object) -> void:
	_owner.disable_movement()
	_timer = 0.0
	_start_pos = _owner.global_position
	_orig_scale = body_mesh_instance.scale
	_orig_position = body_mesh_instance.position

	var player: Node3D = get_player()
	if not player:
		return

	# Calculate dash trajectory
	var direction: Vector3 = (player.global_position - _start_pos).normalized()
	_charge_target = player.global_position + (direction * overshoot_distance)

	_update_telegraph_mesh(_charge_target)

	get_tree().create_timer(telegraph_time).timeout.connect(_cleanup_telegraph)

func physics_update(delta: float) -> void:
	_timer += delta
	
	# Telegraph
	if _timer < telegraph_time:
		_perform_windup_squish()
		return

	_reset_model_transform()
	_cleanup_telegraph()

	# Charge
	var direction: Vector3 = (_charge_target - _owner.global_position).normalized()
	_owner.global_position += direction * charge_speed * delta
	_owner.reset_physics_interpolation()
	
	# Chase
	if _owner.global_position.distance_to(_charge_target) < 1.0 or _timer > 2.0:
		_owner.enable_movement()
		_transition_to(StateName.CHASE, null)

func exit() -> void:
	_reset_model_transform()
	_cleanup_telegraph()

# ===
# Private
# ===

func _update_telegraph_mesh(target: Vector3) -> void:
	
	var distance: float = _start_pos.distance_to(target)
	
	telegraph_mesh_instance.mesh.size.z = distance

	# Align mesh transform
	var forward: Vector3 = (target - _start_pos).normalized()
	var up: Vector3 = Vector3.UP
	var right: Vector3 = up.cross(forward).normalized()
	var basis: Basis = Basis(
		right, 
		up, 
		forward
	)
	
	var spawn_pos: Vector3 = _start_pos + Vector3(0, 0.5, 0)
	telegraph_mesh_instance.global_transform = Transform3D(
		basis, 
		spawn_pos + (forward * (distance / 2.0))
	)
	telegraph_mesh_instance.reset_physics_interpolation()
	telegraph_mesh_instance.show()

func _perform_windup_squish() -> void:
	EventBus.emit(
		AudioEvent.PlaySFX.new(
			Enums.SFXType.CHARGER_ATTACK
		)
	)
	var progress: float = _timer / telegraph_time
	var squish_factor: float = 1.0 - (progress * squish_amount)

	# Scale relative to local orientation
	body_mesh_instance.scale.z = _orig_scale.z * squish_factor
	
	# Anchor back face
	var shrink_amount: float = _orig_scale.z * (1.0 - squish_factor)
	body_mesh_instance.position = _orig_position + (body_mesh_instance.global_transform.basis.z * (shrink_amount / 2.0))

func _reset_model_transform() -> void:
	body_mesh_instance.scale = _orig_scale
	body_mesh_instance.position = _orig_position

func _cleanup_telegraph() -> void:
	telegraph_mesh_instance.hide()
