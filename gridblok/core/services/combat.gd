class_name CombatService
extends RefCounted

# ===
# Public
# ===

static func request_damage(
	hurtbox: Hurtbox,
	damage_data: DamageData
) -> void:
	var sender: Node3D = damage_data.sender
	var receiver: Node3D = hurtbox.get_owner()
	
	damage_data.receiver = receiver
	
	# Enemy Damaged
	if receiver is Enemy:
		receiver.receive_damage(
			damage_data
		)
		
		# Blade
		if sender is Blade:
			
			var player: Player = Session.player_context.player_instance
			
			# Lifesteal
			var lifesteal_chance: float = Session.player_provider.get_total_stat(Enums.StatType.LIFESTEAL_CHANCE)
			if randf() <= lifesteal_chance:
				var lifesteal_amount: float = Session.player_provider.get_total_stat(Enums.StatType.LIFESTEAL_AMOUNT)
				var stolen_hp: float = damage_data.amount * lifesteal_amount
				
				if stolen_hp > 0.0:
					player.receive_heal(HealData.new(stolen_hp))
		
			# Knockback
			var knockback_chance: float = Session.player_provider.get_total_stat(Enums.StatType.KNOCKBACK_CHANCE)
			if randf() <= knockback_chance:
				var knockback_force: float = Session.player_provider.get_total_stat(Enums.StatType.KNOCKBACK_FORCE)
				var knockback_dir: Vector3 = (receiver.global_position - sender.global_position).normalized()
				knockback_dir.y = 0
				
				# Check if a knockback effect is already running on the enemy
				if receiver.active_status_effects.has(Enums.StatusEffectType.KNOCKBACK):
					var effect = receiver.active_status_effects[Enums.StatusEffectType.KNOCKBACK]
					effect.value += knockback_force # Additive stacking
					effect.duration = 0.1           # Reset the impulse timer
					effect.direction = knockback_dir # Update to the most recent hit direction
					print("Knockback stacked! New force: ", effect.value)
				else:
					var knockback_status_effect: StatusEffectData = StatusEffectData.new(
						Enums.StatusEffectType.KNOCKBACK,
						knockback_force,
						0.1,
						knockback_dir
					)
					receiver.apply_status_effect(knockback_status_effect)
					print("Knockback applied! Initial force: ", knockback_force)
			
	# Player Damaged
	elif receiver is Player:
		receiver.receive_damage(
			damage_data
		)

static func request_status_effect(
	status_effect: StatusEffectData,
	from: Node3D,
	to: Node3D
) -> void:
	
	if (
		from is Blade and
		to is Enemy
	):
		_handle_blade_effect_enemy(
			status_effect,
			from as Blade,
			to as Enemy
		)
	
	elif (
		from is Enemy and
		to is Player
	):
		_handle_enemy_effect_player(
			status_effect,
			from as Enemy,
			to as Player
		)

# ===
# Private
# ===

static func _handle_blade_effect_enemy(
	status_effect: StatusEffectData,
	blade: Blade,
	enemy: Enemy
) -> void:
	pass

static func _handle_enemy_effect_player(
	status_effect: StatusEffectData,
	_enemy: Enemy,
	player: Player,
) -> void:
	player.apply_status_effect(
		status_effect
	)
