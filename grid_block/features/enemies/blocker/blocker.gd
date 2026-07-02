class_name BlockerEnemy
extends Enemy

@export_range(0.0, 1.0, 0.01) var slow_value: float = 0.5
@export var slow_duration: float = 2.0

@onready var aoe_hitbox: Hitbox = $AOEHitbox
@onready var aoe_indicator: MeshInstance3D = %AOEIndicator

# ===
# Built-In
# ===

func _ready() -> void:
	super()
	aoe_hitbox.hit_landed.connect(_on_aoe_hitbox_hit_landed)
	
func deactivate() -> void:
	aoe_hitbox.set_deferred("monitoring", false)
	aoe_hitbox.set_deferred("monitorable", false)
	aoe_indicator.hide()
	super()

# ===
# Signals
# ===

func _on_aoe_hitbox_hit_landed(
	target_hurtbox: Hurtbox,
	collision_point: Vector3
) -> void:
	var hurtbox_owner: Node = target_hurtbox.get_owner()
	if not hurtbox_owner is Node3D: return
	
	# Slow Status Effect
	var slow_effect = StatusEffectData.new(
		Enums.StatusEffectType.SLOW, 
		0.5, 
		2.0
	)
	CombatService.request_status_effect(
		slow_effect, 
		self, 
		hurtbox_owner
	)
	
	# Damage
	var damage_data: DamageData = DamageData.create_from_sender(
		self,
		collision_point,
		scaled_attack_damage,
		false
	)
	CombatService.request_damage(
		target_hurtbox,
		damage_data
	)
