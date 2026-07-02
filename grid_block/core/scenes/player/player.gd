class_name Player
extends CharacterBody3D

@export var hurt_shader_material: ShaderMaterial
@export var base_move_speed: float = 4.0
@export var shield_regen_delay: float = 3.0

@onready var health: HealthComponent = %Health
@onready var camera_controller: PlayerCameraController = %CameraController
@onready var weapons_controller: PlayerWeaponsController = %WeaponsController
@onready var collection_area: PlayerCollectionArea = %CollectionArea
@onready var attack_radius: PlayerAttackRadius = %AttackRadius
@onready var model_mesh: MeshInstance3D = %ModelMesh
@onready var shields: Node3D = %Shields
@onready var hurtbox: Hurtbox = $Hurtbox

var shield_status: Dictionary[MeshInstance3D, bool] = {}
var move_speed: float = 5.0
var active_status_effects: Dictionary[Enums.StatusEffectType, StatusEffectData] = {}
var grace_period_duration: float = 0.2
var last_attacker: Node3D

var is_ready: bool = false
var is_dead: bool = false
var is_damage_immune: bool = false

var _grace_timer: float = 0.0
var _regen_timer: float = 0.0
var _shield_regen_delay_timer: float = 0.0
var regen_delay: float = 3.0 
var _regen_delay_timer: float = 0.0

# ===
# Built-In
# ===

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	await get_tree().process_frame
	
	# Shields
	for child in shields.get_children():
		if child is MeshInstance3D:
			shield_status[child as MeshInstance3D] = false
	
	_setup_context()
	_subscribe()
	is_ready = true

func _physics_process(delta: float) -> void:
	if is_dead: return
	
	if is_damage_immune:
		_process_grace_period(delta)
	
	if not active_status_effects.is_empty():
		_process_status_effects(delta)
	
	# Unified Regen Delay
	if _regen_delay_timer > 0:
		_regen_delay_timer -= delta
	
	# Only regen if we are outside of the hit delay
	if _regen_delay_timer <= 0:
		# Health Regen
		if (
			health.regen_rate > 0.0 and 
			health.current < health.maximum
		):
			_regen_timer += delta
			if _regen_timer >= 0.2:
				var amount = (health.maximum * health.regen_rate) * 0.2
				Session.player_provider.update_current_health(amount)
				_regen_timer = 0.0
				EventBus.emit(
					WorldEvent.SpawnPopupLabel.new(
						Enums.PopupType.HEAL, 
						str(amount), 
						global_position + Vector3(0, 2, 0)
					)
				)
	
		# Shield Regen
		var max_shields: int = int(Session.player_provider.get_total_stat(Enums.StatType.SHIELD_COUNT))
		var current_shields: int = Session.player_context.current_shield_count
		if max_shields > 0 and current_shields < max_shields:
			var s_regen: float = Session.player_provider.get_total_stat(Enums.StatType.SHIELD_REGEN)
			Session.player_provider.update_current_shield_regen(delta * s_regen)
	
	# Gravity & Movement
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var input_dir := Input.get_vector("player_left", "player_right", "player_forward", "player_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * _get_effective_move_speed()
		velocity.z = direction.z * _get_effective_move_speed()
	else:
		velocity.x = move_toward(velocity.x, 0, _get_effective_move_speed())
		velocity.z = move_toward(velocity.z, 0, _get_effective_move_speed())
	
	move_and_slide()

func _exit_tree() -> void:
	_unsubscribe()

# ===
# Public
# ===

func apply_status_effect(status_effect: StatusEffectData) -> void:
	active_status_effects[status_effect.type] = status_effect

func receive_heal(data: HealData) -> void:
	Session.player_provider.update_current_health(
		data.amount
	)

	EventBus.emit(
		WorldEvent.SpawnPopupLabel.new(
			Enums.PopupType.HEAL,
			str(data.amount),
			global_position + Vector3(0, 2, 0)
		)
	)

func receive_damage(data: DamageData) -> void:
	if (
		is_damage_immune or 
		_attempt_evade(data)
	): return
	
	_process_hit(data)

# ===
# Private
# ===

func _subscribe() -> void:
	pass

func _unsubscribe() -> void:
	pass

func _setup_context() -> void:
	var p_ctx: PlayerContext = Session.player_context
	
	# Health
	_update_current_health(p_ctx.current_health)
	p_ctx.current_health_updated.connect(_update_current_health)
	
	# Shield Count
	_update_shield_count(p_ctx.current_shield_count)
	p_ctx.current_shield_count_updated.connect(_update_shield_count)
	
	# Stats
	_refresh_all_stats()
	p_ctx.owned_upgrades_updated.connect(
		func(_value): 
			_refresh_all_stats()
	)

func _update_current_health(value: float) -> void:
	health.current = value
	_check_if_dead()

func _update_shield_count(value: int) -> void:
	var active_count: int = min(
		value,
		 shield_status.size()
	)
	
	var index: int = 0
	for mesh in shield_status.keys():
		# Toggle visibility: true if within the current shield count
		var shield_visible: bool = (index < active_count)
		mesh.visible = shield_visible
		shield_status[mesh] = shield_visible
		index += 1

func _attempt_evade(damage_data: DamageData) -> bool:
	var chance_to_evade: float = Session.player_provider.get_total_stat(
		Enums.StatType.EVASION
	)
	if randf() < chance_to_evade:
		EventBus.emit(
			WorldEvent.SpawnPopupLabel.new(
				Enums.PopupType.EVADED,
				"Evaded",
				damage_data.collision_position + Vector3(0,1,0)
			)
		)
		return true
	
	return false

func _process_hit(damage_data: DamageData) -> void:
	is_damage_immune = true
	last_attacker = damage_data.sender
	_grace_timer = grace_period_duration
	
	# Reset both regens on any damage
	_regen_delay_timer = regen_delay
	
	if Session.player_context.current_shield_count > 0:
		Session.player_provider.update_current_shield_count(-1)
		EventBus.emit(
			WorldEvent.SpawnPopupLabel.new(
				Enums.PopupType.SHIELD_DAMAGED, 
				"Shield Damaged", 
				damage_data.collision_position + Vector3(0,1,0)
				)
			)
	else:
		Session.player_provider.update_current_health(-damage_data.amount)
		_play_hurt_effect()
		EventBus.emit(
			WorldEvent.SpawnPopupLabel.new(
				Enums.PopupType.CRIT_DAMAGE if damage_data.is_crit else Enums.PopupType.NORMAL_DAMAGE, 
				str(damage_data.amount), 
				damage_data.collision_position + Vector3(0,1,0)
			)
		)

func _refresh_all_stats() -> void:
	var p_provider: PlayerProvider = Session.player_provider
	
	health.maximum = p_provider.get_total_stat(Enums.StatType.MAX_HEALTH)
	health.regen_rate = p_provider.get_total_stat(Enums.StatType.HEALTH_REGEN)
	move_speed = p_provider.get_total_stat(Enums.StatType.MOVE_SPEED)

func _check_if_dead() -> void:
	if not is_ready: return
	
	if health.current <= 0.0:
		is_dead = true
		hide()
		_disable_collisions()
		EventBus.emit(
			WorldEvent.PlayerDied.new(
				last_attacker
			)
		)

func _disable_collisions() -> void:
	set_collision_layer_value(Constants.PhysicsLayer.PLAYER_INDEX, false)
	set_collision_mask_value(Constants.PhysicsLayer.ITEM_MASK, false)
		
	hurtbox.set_deferred("monitoring", false)
	hurtbox.set_deferred("monitorable", false)
	
	collection_area.set_deferred("monitoring", false)
	collection_area.set_deferred("monitorable", false)


func _get_effective_move_speed() -> float:
	var multiplier: float = 1.0
	if active_status_effects.has(Enums.StatusEffectType.SLOW):
		multiplier -= active_status_effects[Enums.StatusEffectType.SLOW].value
	
	return (
		move_speed * 
		base_move_speed * 
		clamp(
			multiplier, 
			0.1, 
			1.0
		)
	)

func _process_status_effects(delta: float) -> void:
	var keys_to_remove = []
	
	for effect_type in active_status_effects:
		var effect: StatusEffectData = active_status_effects[effect_type]
		effect.duration -= delta
		
		if effect.duration <= 0:
			keys_to_remove.append(effect_type)
			
	for key in keys_to_remove:
		active_status_effects.erase(key)
		# NOTE Trigger an event here to update the HUD?

func _process_grace_period(delta: float) -> void:
	if is_damage_immune:
		_grace_timer -= delta
		if _grace_timer <= 0.0:
			is_damage_immune = false
			_grace_timer = 0.0

func _play_hurt_effect(
	color: Color = Color.RED
) -> void:
	if not hurt_shader_material: return
	
	hurt_shader_material.set_shader_parameter(
		"flash_color", 
		color
	)
	
	var tween: Tween = create_tween()
	tween.tween_property(
		hurt_shader_material, 
		"shader_parameter/flash_alpha",
		1.0, 
		0.15
	)
	tween.tween_property(
		hurt_shader_material, 
		"shader_parameter/flash_alpha", 
		0.0, 
		0.25
	)

# ===
# Events
# ===

# ===
# Signals
# ===
