class_name UIUpgradeMenuUpgradeItem
extends HBoxContainer

@export var upgrade_type: Enums.UpgradeType:
	set(value):
		upgrade_type = value
		update()
@export var tier_level: Enums.UpgradeTierLevel:
	set(value):
		tier_level = value
		update()
@export var is_owned: bool = false

@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %Name
@onready var tier_label: Label = %Tier

# ===
# Built-In
# ===

func _ready() -> void:
	update()

# ===
# Public
# ===

func update() -> void:
	visible = is_owned
	if not is_owned: return
	
	var upgrade_data: UpgradeData = AssetProvider.get_upgrade_data(upgrade_type)
	if not upgrade_data: return
	
	icon.texture = upgrade_data.icon
	name_label.text = upgrade_data.display_name
	tier_label.text = str(tier_level + 1)
