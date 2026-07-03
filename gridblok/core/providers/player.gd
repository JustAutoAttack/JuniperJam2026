class_name PlayerProvider
extends ContextProvider

var context: PlayerContext

# ===
# Built-In
# ===

func _init(
	p_context: PlayerContext
) -> void:
	context = p_context

# ===
# Public
# ===

func reset() -> void:
	context.reset()

func set_player_instance(value: Player) -> void:
	context.player_instance = value

func set_world_location(value: Vector3) -> void:
	context.world_location = value

# --- Combat ---
func update_current_health(delta: float) -> void:
	var new_value: float = context.current_health + delta
	var max_value: float = get_total_stat(Enums.StatType.MAX_HEALTH)
	context.current_health = clamp(
		new_value, 
		0.0, 
		max_value
	)

func update_current_shield_count(delta: int) -> void:
	var new_value: int = context.current_shield_count + delta
	var max_value: int = int(get_total_stat(Enums.StatType.SHIELD_COUNT))
	context.current_shield_count = clamp(
		new_value,
		0,
		max_value
	)

func update_current_shield_regen(delta: float) -> void:
	context.current_shield_regen += delta
	var max_shield_count: int = int(get_total_stat(Enums.StatType.SHIELD_COUNT))
	
	# Emit for every frame of progress so the bar fills smoothly
	context.current_shield_regen_updated.emit(context.current_shield_regen)
	
	if context.current_shield_regen >= 1.0:
		var shields_to_add: int = int(context.current_shield_regen)
		var new_count = clamp(context.current_shield_count + shields_to_add, 0, max_shield_count)
		
		if new_count > context.current_shield_count:
			context.current_shield_count = new_count
			context.current_shield_regen -= shields_to_add
			context.current_shield_count_updated.emit(context.current_shield_count)
			context.current_shield_regen_updated.emit(context.current_shield_regen)
			
	if context.current_shield_count >= max_shield_count:
		context.current_shield_regen = 0.0
		context.current_shield_regen_updated.emit(0.0)

# --- XP & Level ---
func update_xp(delta: float) -> void:
	context.xp += delta
	
	# Level up check
	while context.xp >= get_max_xp():
		context.xp -= get_max_xp()
		context.level += 1
		context.pending_upgrades += 1

func get_max_xp() -> float:
	const BASE_XP: float = 100.0
	const COEFFICIENT: float = 1.15 # Reduced from 1.2
	
	# New: Discount early levels to accelerate initial power spikes
	var early_game_discount: float = max(0.0, 50.0 - (context.level * 5.0))
	
	return (BASE_XP * pow(COEFFICIENT, context.level - 1)) - early_game_discount

# --- Upgrades ---
func add_upgrade(
	type: Enums.UpgradeType, 
	tier_level: Enums.UpgradeTierLevel
) -> void:
	var current = context.owned_upgrades.duplicate()
	current[type] = tier_level
	context.owned_upgrades = current

func update_pending_upgrades(delta: int) -> void:
	context.pending_upgrades += delta

func get_available_upgrade_offers() -> Dictionary:
	var available_offers: Dictionary[Enums.UpgradeCategory, Array] = {}
	var all_tiers = Enums.UpgradeTierLevel.values()
	
	for upgrade_type: Enums.UpgradeType in Enums.UpgradeType.values():
		var upgrade_data: UpgradeData = AssetProvider.get_upgrade_data(upgrade_type)
		var category: Enums.UpgradeCategory = upgrade_data.category
		var next_idx: int = 0
		
		if context.owned_upgrades.has(upgrade_type):
			var current_tier: Enums.UpgradeTierLevel = context.owned_upgrades[upgrade_type]
			next_idx = int(current_tier) + 1
		
		if next_idx >= all_tiers.size(): continue
		
		# Get Tier Data
		var next_level: Enums.UpgradeTierLevel = all_tiers[next_idx]
		var tier_data: UpgradeTier = upgrade_data.tiers.get(next_level)
		
		# Level Requirement + Predicate Check
		if (
			tier_data and
			context.level >= tier_data.level_requirement and
			upgrade_data.meets_predicate(context.owned_upgrades)
		):
			if not available_offers.has(category):
				available_offers[category] = []
			
			var offer: UpgradeOffer = UpgradeOffer.new(
				upgrade_type, 
				next_level, 
				tier_data
			)
			available_offers[category].append(offer)
			
	return available_offers

# --- Stats ---
func get_total_stat(stat: Enums.StatType) -> float:
	var base_value: float = Constants.BASE_STATS.get(stat, 0.0)
	
	var flat_bonus: float = 0.0
	var added_percentage: float = 0.0
	var multiplicative_multiplier: float = 1.0
	
	for upgrade_type: Enums.UpgradeType in context.owned_upgrades:
		var upgrade_data: UpgradeData = AssetProvider.get_upgrade_data(upgrade_type)
		if upgrade_data and upgrade_data.stat_type == stat:
			var tier_level: Enums.UpgradeTierLevel = context.owned_upgrades[upgrade_type]
			var tier_data: UpgradeTier = upgrade_data.tiers.get(tier_level)
			
			if tier_data:
				if upgrade_data.is_multiplicative:
					multiplicative_multiplier *= (1.0 + tier_data.value)
				elif upgrade_data.is_percentage:
					added_percentage += tier_data.value
				else:
					flat_bonus += tier_data.value

	var total: float = (base_value + flat_bonus + added_percentage) * multiplicative_multiplier

	return total

# ===
# Private
# ===

func _is_speed_stat(stat: Enums.StatType) -> bool:
	var stat_data: StatData = AssetProvider.get_stat_data(stat)
	return stat_data and stat_data.display_name.to_lower().contains("speed")
