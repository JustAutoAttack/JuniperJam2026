extends EnemyState

@export var body_hitbox: Hitbox
@export var health: HealthComponent
@export var telegraph_mesh_instance: MeshInstance3D

@export_category("Configs")
@export var speed: float = 25.0
@export var telegraph_time: float = 1.5
@export var duration: float = 2.0

var _seek_direction: Vector3
var _timer: float = 0.0
var _is_seeking: bool = false

# ===
# Built-In
# ===

func _ready() -> void:
	super()
	telegraph_mesh_instance.hide()

func enter(_prev_state_path: String, _data: Object) -> void:
	_timer = 0.0
	_is_seeking = false
	_owner.disable_movement()
	_subscribe()
	
	var player = get_player()
	if player:
		_seek_direction = (player.global_position - _owner.global_position).normalized()
		_owner.look_at(
			_owner.global_position + 
			_seek_direction, 
			Vector3.UP
		)
		_update_telegraph_mesh(player.global_position)
	else:
		_seek_direction = Vector3.FORWARD

func physics_update(delta: float) -> void:
	_timer += delta
	
	if _timer < telegraph_time: return
	if not _is_seeking:
		_is_seeking = true
		telegraph_mesh_instance.hide()
	
	var move_step: Vector3 = _seek_direction * speed * delta
	var next_pos: Vector3 = _owner.global_position + move_step
	
	var arena_center: Vector3 = Session.world_context.arena_center
	var arena_radius: float = Session.world_context.arena_radius
	
	# Boundary Check
	if Vector2(
		next_pos.x, 
		next_pos.z
	).distance_to(Vector2(
		arena_center.x, 
		arena_center.z
	)) >= arena_radius:
		_transition_to(StateName.PATROL, null)
	else:
		_owner.global_position = next_pos
		_owner.reset_physics_interpolation()
	
	if _timer >= (telegraph_time + duration):
		_transition_to(StateName.PATROL, null)

func exit() -> void:
	_owner.enable_movement()
	telegraph_mesh_instance.hide()
	_unsubscribe()

func _subscribe() -> void:
	body_hitbox.hit_landed.connect(_on_hit)

func _unsubscribe() -> void:
	body_hitbox.hit_landed.disconnect(_on_hit)

# ===
# Private
# ===

func _update_telegraph_mesh(_target_pos: Vector3) -> void:
	telegraph_mesh_instance.show()
	
	var arena_center: Vector3 = Session.world_context.arena_center
	var arena_radius: float = Session.world_context.arena_radius
	
	var attack_direction: Vector3 = _seek_direction
	var vector_to_center: Vector3 = _owner.global_position - arena_center
	
	var projection_on_direction: float = vector_to_center.dot(attack_direction)
	var squared_distance_to_center: float = vector_to_center.dot(vector_to_center)
	
	var discriminant: float = (projection_on_direction * projection_on_direction) - (squared_distance_to_center - (arena_radius * arena_radius))
	var distance_to_wall: float = -projection_on_direction + sqrt(max(0.0, discriminant))
	
	telegraph_mesh_instance.mesh.size.z = distance_to_wall
	
	var right_vector: Vector3 = Vector3.UP.cross(attack_direction).normalized()
	var telegraph_basis: Basis = Basis(
		right_vector, 
		Vector3.UP, 
		attack_direction
	)
	
	var spawn_offset: Vector3 = Vector3(
		0.0, 
		0.5, 
		0.0
	)
	var mesh_center_point: Vector3 = _owner.global_position + spawn_offset + (attack_direction * (distance_to_wall / 2.0))
	
	telegraph_mesh_instance.global_transform = Transform3D(
		telegraph_basis, 
		mesh_center_point
	)
	telegraph_mesh_instance.reset_physics_interpolation()

# ===
# Signals
# ===

func _on_hit(
	hurtbox: Hurtbox, 
	collision_position: Vector3
) -> void:
	# Damage Target
	var target_damage_data: DamageData = DamageData.create_from_sender(
		_owner,
		collision_position,
		_owner.scaled_attack_damage,
		false
	)
	CombatService.request_damage(
		hurtbox,
		target_damage_data
	)
	
	# Damage Self
	EventBus.emit(
		AudioEvent.PlaySFX.new(
			Enums.SFXType.SEEKER_EXPLOSION
		)
	)
	_owner.health.current -= _owner.health.maximum
	_owner._check_dead()
