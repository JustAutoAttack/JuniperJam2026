@tool
class_name UIUpgradeCard
extends MarginContainer

signal selected()

@export var colors: Dictionary[Enums.UpgradeCategory, Color] = {}
@export_range(0.0, 1.0, 0.01) var background_alpha: float = 1.0
@export_range(0.0, 1.0, 0.01) var foreground_alpha: float = 1.0
@export_range(0.0, 1.0, 0.01) var border_alpha: float = 1.0

@export var upgrade_category: Enums.UpgradeCategory:
	set(value):
		upgrade_category = value
		if is_node_ready():
			_update()
@export var upgrade_data: UpgradeData
@export var tier_level: Enums.UpgradeTierLevel

@onready var button: Button = %Button

# Base Textures
@onready var background: TextureRect = %Background
@onready var foreground: TextureRect = %Foreground
@onready var border: TextureRect = %Border

# Icons
@onready var stat_icon: TextureRect = %StatIcon
@onready var upgrade_icon: TextureRect = %UpgradeIcon

# Labels
@onready var upgrade_name_label: Label = %UpgradeName
@onready var description_label: Label = %Description
@onready var stat_name_label: Label = %StatName
@onready var stat_value_label: Label = %StatValue

# ===
# Built-In
# ===

func _ready() -> void:
	button.pressed.connect(
		func(): 
			selected.emit()
	)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	focus_mode = Control.FOCUS_ALL
	_update()

# ===
# Public
# ===

func update_card(
	new_data: UpgradeData, 
	new_tier: Enums.UpgradeTierLevel
) -> void:
	upgrade_data = new_data
	tier_level = new_tier
	_update()

# ===
# Private
# ===

func _update() -> void:
	if not is_node_ready(): return
	if not upgrade_data: return
	
	# Color
	var color: Color = colors.get(upgrade_data.category)
	background.self_modulate = color
	background.self_modulate.a = background_alpha
	foreground.self_modulate = color
	foreground.self_modulate.a = foreground_alpha
	border.self_modulate = color
	border.self_modulate.a = border_alpha
	
	# Upgrade
	upgrade_icon.texture = upgrade_data.icon
	upgrade_name_label.text = upgrade_data.display_name
	description_label.text = upgrade_data.description
	
	if Engine.is_editor_hint(): return
	
	# Stat
	var stat: StatData = AssetProvider.get_stat_data(upgrade_data.stat_type)

	stat_name_label.text = stat.display_name
	stat_value_label.text = upgrade_data.get_stat_value_string(tier_level)
	stat_icon.texture = stat.icon

# ===
# Signals
# ===

func _on_focus_entered() -> void:
	if button and button.focus_mode != Control.FOCUS_NONE:
		button.grab_focus()

func _on_focus_exited() -> void:
	if button:
		button.release_focus()
