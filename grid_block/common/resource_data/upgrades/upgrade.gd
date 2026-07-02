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
