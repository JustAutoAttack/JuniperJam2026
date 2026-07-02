class_name Blade
extends Node3D

@export var base_speed: float = 3.0
@export var size: float = 0.0:
	set(value):
		size = value
		if is_node_ready():
			_update_size()
@export var speed: float = 0.0:
	set(value):
		speed = value
		if is_node_ready():
			_update_speed()

@onready var hitbox: Hitbox = $Hitbox

var damage: float = 0.0
var crit_chance: float = 0.0

# ===
# Built-In
# ===

func _ready() -> void:
	hitbox.hit_landed.connect(_on_hitbox_hit_landed)
	
	_update_values()
	Session.player_context.owned_upgrades_updated.connect(
		func(_value):
			_update_values()
	)

func _process(delta: float) -> void:
	rotate_y(base_speed * speed * delta)

# ===
# Public
# ===

# ===
# Private
# ===

func _update_values() -> void:
	var p_provider: PlayerProvider = Session.player_provider
	
	# Size
	var target_size: float = p_provider.get_total_stat(Enums.StatType.BLADE_SIZE)
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "size", target_size, 0.4)
	
	# Speed
	speed = p_provider.get_total_stat(Enums.StatType.BLADE_SPEED)
	
	# Damage
	damage = p_provider.get_total_stat(Enums.StatType.DAMAGE)
	
	# Crit Chance
	crit_chance = p_provider.get_total_stat(Enums.StatType.CRIT_CHANCE)

func _update_size() -> void:
	scale = Vector3(
		size,
		1.0,
		size
	)

func _update_speed() -> void:
	hitbox.check_hit_every = speed

# ===
# Signals
# ===

func _on_hitbox_hit_landed(
	hurtbox: Hurtbox,
	collision_point: Vector3
) -> void:
	var final_damage: float = damage
	var is_crit: bool = false
	if randf() <= crit_chance:
		final_damage =  damage * 1.5
		is_crit = true
	
	var damage_data: DamageData = DamageData.create_from_sender(
		self,
		collision_point,
		final_damage,
		is_crit
	)
	
	CombatService.request_damage(
		hurtbox,
		damage_data
	)
	
	EventBus.emit(
		AudioEvent.PlaySFX.new(
			Enums.SFXType.BLADE_HIT
		)
	)
