class_name BursterProjectile
extends Node3D

@export var base_speed: float = 10.0
@export var max_speed: float = 25.0
@export var acceleration: float = 20.0
@export var damage: float = 10.0

@onready var hitbox: Hitbox = $Hitbox

var _velocity: Vector3 = Vector3.ZERO
var _current_speed: float = 0.0
var _direction: Vector3 = Vector3.ZERO

# ===
# Built-In
# ===

func _ready() -> void:
	hitbox.hit_landed.connect(_on_hitbox_hit_landed)
	deactivate()

func _physics_process(delta: float) -> void:
	
	# Ramp up speed
	if _current_speed < max_speed:
		_current_speed += acceleration * delta
	
	global_position += _direction * _current_speed * delta

# ===
# Public
# ===

func activate(
	origin: Vector3,
	destination: Vector3
) -> void:
	global_position = origin
	reset_physics_interpolation()
	_current_speed = base_speed
	_direction = (destination - origin).normalized()
	look_at(global_position + _direction)
	
	visible = true
	hitbox.set_deferred("monitoring", true)
	hitbox.set_deferred("monitorable", true)
	set_process(true)
	set_physics_process(true)

func deactivate() -> void:
	_current_speed = 0.0
	visible = false
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)
	set_process(false)
	set_physics_process(false)

	EventBus.emit(
		GameEvent.RecycleBursterProjectile.new(
			self
		)
	)

# ===
# Private
# ===

# ===
# Signals
# ===

func _on_hitbox_hit_landed(
	hurtbox: Hurtbox, 
	collision_point: Vector3
) -> void:
	var damage_data: DamageData = DamageData.create_from_sender(
		self,
		collision_point,
		damage,
		false
	)

	CombatService.request_damage(
		hurtbox,
		damage_data
	)
	
	deactivate.call_deferred()
