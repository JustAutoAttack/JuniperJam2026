class_name UpgradeOffer
extends RefCounted

var type: Enums.UpgradeType
var tier_level: Enums.UpgradeTierLevel
var tier_data: UpgradeTier

func _init(
	p_type: Enums.UpgradeType,
	p_tier_level: Enums.UpgradeTierLevel,
	p_tier_data: UpgradeTier
) -> void:
	type = p_type
	tier_level = p_tier_level
	tier_data = p_tier_data
