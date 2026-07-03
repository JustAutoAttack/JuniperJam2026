class_name UIPausedView
extends Control

@export var stat_item_scene: PackedScene
@export var upgrade_item_scene: PackedScene

@onready var upgrades_scroll_container: UIAutoScrollContainer = %UpgradesScrollContainer
@onready var stats_scroll_container: UIAutoScrollContainer = %StatsScrollContainer
@onready var upgrades_container: VBoxContainer = %UpgradesContainer
@onready var stats_container: VBoxContainer = %StatsContainer
@onready var version_label: Label = %VersionLabel

var _upgrade_items: Dictionary[Enums.UpgradeType, UIUpgradeMenuUpgradeItem] = {}
var _stat_items: Dictionary[Enums.StatType, UIUpgradeMenuStatItem] = {}


# ===
# Built-In
# ===

func _ready() -> void:
	_setup()
	
	if Engine.is_editor_hint(): return
	
	await get_tree().process_frame
	_setup_context()

# ===
# Private
# ===

func _setup() -> void:
	visibility_changed.connect(_on_visibility_changed)
	version_label.text = Session.full_version_string
	
	# Upgrade Items
	for upgrade_type: Enums.UpgradeType in Enums.UpgradeType.values():
		var upgrade_item: UIUpgradeMenuUpgradeItem = upgrade_item_scene.instantiate()
		upgrade_item.upgrade_type = upgrade_type
		upgrades_container.add_child(upgrade_item)
		_upgrade_items[upgrade_type] = upgrade_item
	
	# Stat items
	for stat_type: Enums.StatType in Enums.StatType.values():
		var stat_item: UIUpgradeMenuStatItem = stat_item_scene.instantiate()
		stat_item.stat_type = stat_type
		stats_container.add_child(stat_item)
		_stat_items[stat_type] = stat_item

func _setup_context() -> void:
	var p_ctx: PlayerContext = Session.player_context
	
	_update_side_items(Session.player_context.owned_upgrades)
	p_ctx.owned_upgrades_updated.connect(_update_side_items)

func _update_side_items(owned_upgrades: Dictionary[Enums.UpgradeType, Enums.UpgradeTierLevel]) -> void:
	# Upgrades
	for upgrade_type: Enums.UpgradeType in Enums.UpgradeType.values():
		var upgrade_item: UIUpgradeMenuUpgradeItem = _upgrade_items.get(upgrade_type)
		var is_owned: bool = owned_upgrades.has(upgrade_type)
		upgrade_item.is_owned = is_owned
		
		if is_owned:
			upgrade_item.tier_level = owned_upgrades[upgrade_type]
		
		upgrades_container.custom_minimum_size.y = upgrades_container.get_combined_minimum_size().y
	
	# Stats
	for stat_type: Enums.StatType in Enums.StatType.values():
		var stat_item: UIUpgradeMenuStatItem = _stat_items.get(stat_type)
		stat_item.update()

# ===
# Signals
# ===

func _on_visibility_changed() -> void:
	if visible:
		upgrades_scroll_container.reset_scroll()
		stats_scroll_container.reset_scroll()
