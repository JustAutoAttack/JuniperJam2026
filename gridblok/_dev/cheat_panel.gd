class_name DevCheatPanel
extends CanvasLayer

## The UI half of the by-name cheat: a dropdown of every UpgradeType (by
## its real display_name, not the enum's code name) and a button that
## asks DevCheats to grant whatever's selected. This panel only knows how
## to list upgrades and report a selection - DevCheats owns the actual
## granting logic and its rules, same "dumb view, smart owner" split as
## the real UIUpgradeMenu.

signal grant_requested(type: Enums.UpgradeType)

@onready var panel: PanelContainer = %Panel
@onready var upgrade_option: OptionButton = %UpgradeOption
@onready var grant_button: Button = %GrantButton

# ===
# Built-In
# ===

func _ready() -> void:
	panel.visible = false
	_populate_options()
	grant_button.pressed.connect(_on_grant_pressed)

# ===
# Public
# ===

func toggle() -> void:
	panel.visible = not panel.visible

# ===
# Private
# ===

func _populate_options() -> void:
	upgrade_option.clear()

	for type: Enums.UpgradeType in Enums.UpgradeType.values():
		var upgrade_data: UpgradeData = AssetProvider.get_upgrade_data(type)
		var label: String = upgrade_data.display_name if upgrade_data else Enums.UpgradeType.keys()[type]

		upgrade_option.add_item(label)
		upgrade_option.set_item_metadata(upgrade_option.item_count - 1, type)

	if upgrade_option.item_count > 0:
		upgrade_option.select(0)

# ===
# Signals
# ===

func _on_grant_pressed() -> void:
	if upgrade_option.selected < 0: return

	var type: Enums.UpgradeType = upgrade_option.get_item_metadata(upgrade_option.selected)
	grant_requested.emit(type)
