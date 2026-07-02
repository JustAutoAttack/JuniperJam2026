class_name UIUpgradeMenuStatItem
extends HBoxContainer

@export var stat_type: Enums.StatType:
	set(value):
		stat_type = value
		if is_node_ready():
			update()

@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %Name
@onready var value_label: Label = %Value

# ===
# Built-In
# ===

func _ready() -> void:
	update()

# ===
# Public
# ===

func update() -> void:
	var stat_data: StatData = AssetProvider.get_stat_data(stat_type)
	if not stat_data: return
	
	icon.texture = stat_data.icon
	name_label.text = stat_data.display_name
	value_label.text = str(Session.player_provider.get_total_stat(stat_type))
