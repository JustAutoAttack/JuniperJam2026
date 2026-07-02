extends EnemyState

@export_category("Configs")
@export var min_duration: float = 3.0
@export var max_duration: float = 6.0
@export var speed: float = 10.0
@export var min_arena_radius_percentage: float = 0.6
@export var max_arena_radius_percentage: float = 0.95

var _target_radius: float
var _current_radius: float
var _orbit_angle: float = 0.0
var _timer: float = 0.0
var _duration: float = 0.0
var _direction_multiplier: float = 1.0

# ===
# Built-In
# ===

func enter(_prev_state_path: String, _data: Object) -> void:
	_timer = 0.0
	_duration = randf_range(
		min_duration, 
		max_duration
	)
	_direction_multiplier = 1.0 if randf() > 0.5 else -1.0
	
	var arena_center: Vector3 = Session.world_context.arena_center
	var arena_radius: float = Session.world_context.arena_radius
	
	_current_radius = _owner.global_position.distance_to(arena_center)
	
	_target_radius = randf_range(
		arena_radius * min_arena_radius_percentage, 
		arena_radius * max_arena_radius_percentage
	)
	
	_orbit_angle = atan2(
		_owner.global_position.z - arena_center.z, 
		_owner.global_position.x - arena_center.x
	)

func physics_update(delta: float) -> void:
	_timer += delta
	
	_current_radius = move_toward(
		_current_radius, 
		_target_radius, 
		delta * 2.0
	)
	
	_orbit_angle += (speed / _current_radius) * delta * _direction_multiplier
	
	var center = Session.world_context.arena_center
	var target_pos = Vector3(
		center.x + cos(_orbit_angle) * _current_radius,
		_owner.global_position.y,
		center.z + sin(_orbit_angle) * _current_radius
	)
	
	_owner.global_position = _owner.global_position.move_toward(
		target_pos, 
		speed * delta
	)
	_owner.reset_physics_interpolation()
	
	# Face forward
	var look_ahead_angle: float = _orbit_angle + (0.1 * _direction_multiplier)
	var look_at_pos: Vector3 = center + Vector3(
		cos(look_ahead_angle), 
		0, 
		sin(look_ahead_angle)
	) * _current_radius
	_owner.look_at(look_at_pos, Vector3.UP)
	
	# Attack
	if _timer >= _duration:
		_transition_to(
			StateName.ATTACK, 
			null
		)
