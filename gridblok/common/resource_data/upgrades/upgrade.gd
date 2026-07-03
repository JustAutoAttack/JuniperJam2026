class_name UpgradeData 
extends Resource

@export var type: Enums.UpgradeType
@export var category: Enums.UpgradeCategory
@export var stat_type: Enums.StatType
@export var display_name: String
@export var description: String
@export var icon: Texture2D
@export var is_percentage: bool
@export var is_multiplicative: bool
@export var tiers: Dictionary[Enums.UpgradeTierLevel, UpgradeTier]

@export_category("Predicate")
@export var requires_predicate: bool = false
@export var predicate_upgrade: Enums.UpgradeType
@export var predicate_tier: Enums.UpgradeTierLevel = Enums.UpgradeTierLevel.TIER_2

func get_stat_value_string(tier_level: Enums.UpgradeTierLevel) -> String:
	var tier: UpgradeTier = tiers.get(tier_level)
	if not tier: 
		return ""
	
	if is_percentage:
		return "+" + str(snapped(tier.value * 100.0, 0.1)) + "%"
	
	# Check if the value has a fractional part
	if fmod(tier.value, 1.0) == 0.0:
		return "+" + str(int(tier.value))
	
	return "+" + str(tier.value)

## whether or not this upgrade is available based on dynamic conditions
func meets_predicate(
	owned_upgrades: Dictionary[Enums.UpgradeType, Enums.UpgradeTierLevel]
) -> bool:
	if not requires_predicate: return true
	if not owned_upgrades.has(predicate_upgrade): return false

	return owned_upgrades[predicate_upgrade] >= predicate_tier
