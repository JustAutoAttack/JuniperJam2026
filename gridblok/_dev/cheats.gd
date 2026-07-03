class_name DevCheats
extends Node

## Debug-only shortcuts for testing gameplay without grinding for it.
## Everything here goes through the same doors real gameplay does -
## PlayerProvider.add_upgrade(), the same EventBus SFX cue - so a granted
## upgrade is indistinguishable from a real one once it lands. Disabled
## entirely outside a debug build/editor run (see _ready()), so nothing
## here can leak into a real export.
##
## Two ways to grant: F1 grants a random upgrade from whatever's currently
## a legal offer (respects level requirements and prerequisites - it's
## "give me a normal pickup right now"). F2 opens a panel to pick a
## specific upgrade by name and grants it straight to its next tier,
## bypassing both of those gates - "let me test this exact one," useful
## for jumping straight to a prerequisite-gated upgrade like Living Tether
## without manually taking Agility twice first.
##
## Grows past this? Split each shortcut into its own _handle_* and give
## this a short line in PATTERNS.md, same as any other controller.

@onready var cheat_panel: DevCheatPanel = %CheatPanel

# ===
# Built-In
# ===

func _ready() -> void:
	var is_active: bool = OS.is_debug_build()
	set_process_unhandled_input(is_active)

	if is_active:
		cheat_panel.grant_requested.connect(grant_upgrade)
	else:
		cheat_panel.queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cheat_grant_upgrade"):
		_grant_random_upgrade()
	elif event.is_action_pressed("cheat_toggle_panel"):
		cheat_panel.toggle()

# ===
# Public
# ===

## Grants the given upgrade's next tier directly, ignoring its level
## requirement and prerequisite (if any) - the dropdown/by-name path.
## Already at max tier is a no-op with a console note, not an error.
func grant_upgrade(type: Enums.UpgradeType) -> void:
	var upgrade_data: UpgradeData = AssetProvider.get_upgrade_data(type)
	if not upgrade_data:
		push_warning("DevCheats: no UpgradeData registered for %s" % Enums.UpgradeType.keys()[type])
		return

	var all_tiers: Array = Enums.UpgradeTierLevel.values()
	var owned_upgrades: Dictionary = Session.player_context.owned_upgrades
	var next_idx: int = (int(owned_upgrades[type]) + 1) if owned_upgrades.has(type) else 0

	if next_idx >= all_tiers.size():
		print("DevCheats: %s is already at max tier." % upgrade_data.display_name)
		return

	_apply_grant(type, all_tiers[next_idx])

# ===
# Private
# ===

## The "give me anything legal" path - only draws from what
## PlayerProvider would actually offer right now.
func _grant_random_upgrade() -> void:
	var offers_by_category: Dictionary = Session.player_provider.get_available_upgrade_offers()

	var all_offers: Array = []
	for category: Enums.UpgradeCategory in Enums.UpgradeCategory.values():
		all_offers.append_array(offers_by_category.get(category, []))

	if all_offers.is_empty():
		push_warning("DevCheats: no upgrade offers available to grant (all maxed out or prerequisite-gated).")
		return

	var offer: UpgradeOffer = all_offers.pick_random()
	_apply_grant(offer.type, offer.tier_level)

func _apply_grant(type: Enums.UpgradeType, tier_level: Enums.UpgradeTierLevel) -> void:
	Session.player_provider.add_upgrade(type, tier_level)

	var upgrade_data: UpgradeData = AssetProvider.get_upgrade_data(type)
	print(
		"DevCheats: granted %s -> tier %d" % [
			upgrade_data.display_name,
			int(tier_level) + 1
		]
	)

	EventBus.emit(
		AudioEvent.PlaySFX.new(
			Enums.SFXType.UPGRADE_AQCUIRED
		)
	)
