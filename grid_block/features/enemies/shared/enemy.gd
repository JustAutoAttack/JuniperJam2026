class_name Enemy
extends Node3D

@export var type: Enums.EnemyType
@export var color: Color
@export var grace_period_duration: float = 0.15

@onready var health: HealthComponent = $Health
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var body_hitbox: Hitbox = $BodyHitbox
@onready var state_machine: StateMachine = $StateMachine

var _data: EnemyData
var _player: Player
var _grace_timer: float = 0.0
var _is_movement_disabled: bool = false
var is_damage_immune: bool = false
var is_attacking: bool = false
var can_attack: bool = false
var active_status_effects: Dictionary[Enums.StatusEffectType, StatusEffectData] = {}

var scaled_health: float:
	get: return _data.get_scaled(
		_data.health, 
		Session.world_context.wave
	)

var scaled_body_damage: float:
	get: return _data.get_scaled(
		_data.body_damage, 
		Session.world_context.wave
	)

var scaled_attack_damage: float:
	get: return _data.get_scaled(
		_data.attack_damage, 
		Session.world_context.wave
	)

# ===
# Built-In
# ===

func _ready() -> void:
	_data = AssetProvider.get_enemy_data(type)
	body_hitbox.hit_landed.connect(_on_body_hit_landed)
	deactivate()


func _physics_process(delta: float) -> void:
	_process_grace_period(delta)
	
	# Damage Immunity
	if is_damage_immune:
		_process_grace_period(delta)
	
	# Status Effects
	if not active_status_effects.is_empty():
		_process_status_effects(delta)

# ===
# Public
# ===

func get_scaled_stat(stat_name: String, wave: int) -> float:
	var base_val: float = self.get(stat_name)
	var multiplier: float = 1.0 + (wave * 0.1) # 10% per wave
	return base_val * multiplier

func activate(spawn_position: Vector3) -> void:
	_player = Session.player_context.player_instance
	health.maximum = scaled_health
	health.current = scaled_health
	state_machine.state = state_machine.get_initial_state()
	state_machine.state.enter("", null)
	global_position = spawn_position
	reset_physics_interpolation()
	_is_movement_disabled = false
	visible = true
	set_process(true)
	set_physics_process(true)
	hurtbox.set_deferred("monitoring", true)
	hurtbox.set_deferred("monitorable", true)
	body_hitbox.set_deferred("monitoring", true)
	body_hitbox.set_deferred("monitorable", true)

func deactivate() -> void:
	active_status_effects.clear()
	state_machine.state.exit()
	visible = false
	set_process(false)
	set_physics_process(false)
	hurtbox.set_deferred("monitoring", false)
	hurtbox.set_deferred("monitorable", false)
	body_hitbox.set_deferred("monitoring", false)
	body_hitbox.set_deferred("monitorable", false)

func apply_status_effect(status_effect: StatusEffectData) -> void:
	active_status_effects[status_effect.type] = status_effect

func receive_heal(data: HealData) -> void:
	health.current += data.amount

func receive_damage(data: DamageData) -> void:
	if is_damage_immune: return
	
	is_damage_immune = true
	_grace_timer = grace_period_duration
	health.current -= data.amount
	
	EventBus.emit(
		WorldEvent.SpawnPopupLabel.new(
			Enums.PopupType.CRIT_DAMAGE if data.is_crit else Enums.PopupType.NORMAL_DAMAGE,
			str(data.amount),
			data.collision_position + Vector3(0,1,0)
		)
	)
	
	_check_dead()

func move_towards_player(
	speed: float, 
	delta: float
) -> void:
	if (
		_is_movement_disabled or 
		not _player
	): return
	
	var direction: Vector3 = (_player.global_position - global_position).normalized()
	global_position += direction * speed * delta
	_face_player()

func move_away_from_player(
	speed: float, 
	delta: float
) -> void:
	if (
		_is_movement_disabled or 
		not _player
	): return
	
	var direction: Vector3 = (global_position - _player.global_position).normalized()
	global_position += direction * speed * delta
	_face_player()

func disable_movement() -> void:
	_is_movement_disabled = true

func enable_movement() -> void:
	_is_movement_disabled = false

# ===
# Private
# ===

func _check_dead() -> void:
	if health.current <= 0.0:
		visible = false
		body_hitbox.set_deferred("monitoring", false)
		hurtbox.set_deferred("monitorable", false)
		await get_tree().create_timer(0.05).timeout
		EventBus.emit(
			WorldEvent.EnemyDied.new(
				type, 
				global_position
			)
		)
		EventBus.emit(
			GameEvent.RecycleEnemy.new(
				self
			)
		)

func _process_grace_period(delta: float) -> void:
	_grace_timer -= delta
	if _grace_timer <= 0.0:
		is_damage_immune = false

func _process_status_effects(delta: float) -> void:
	var keys_to_remove = []
	
	for effect_type in active_status_effects:
		var effect: StatusEffectData = active_status_effects[effect_type]
		effect.duration -= delta
		
		if effect_type == Enums.StatusEffectType.KNOCKBACK:
			var decay_factor = effect.duration / 0.1
			var impulse = effect.value * decay_factor
			
			global_position += effect.direction * impulse * delta * 25.0
		
		if effect.duration <= 0:
			keys_to_remove.append(effect_type)
			
	for key in keys_to_remove:
		active_status_effects.erase(key)

func _face_player() -> void:
	look_at(
		Vector3(
			_player.global_position.x, 
			global_position.y, 
			_player.global_position.z
		), 
		Vector3.UP
	)

# ===
# Signals
# ===

func _on_body_hit_landed(
	_hurtbox: Hurtbox,
	collision_point: Vector3
) -> void:
	# Create Data
	var damage_data: DamageData = DamageData.create_from_sender(
		self,
		collision_point,
		scaled_body_damage,
		false
	)
	
	# Send to Service
	CombatService.request_damage(
		hurtbox, 
		damage_data
	)
