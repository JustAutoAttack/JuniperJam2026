class_name UIUpgradeMenu
extends UIMenu

@onready var upgrades_remaining_label: Label = %UpgradesRemaining
@onready var offense_card: UIUpgradeCard = %OffenseCard
@onready var defense_card: UIUpgradeCard = %DefenseCard
@onready var utility_card: UIUpgradeCard = %UtilityCard

var upgrade_cache: Dictionary[Enums.UpgradeCategory, UpgradeOffer] = {}
var last_known_pending_upgrades: int = 0
var active_offers: Dictionary[UIUpgradeCard, UpgradeOffer] = {}

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
	
	# Buttons
	offense_card.selected.connect(_on_card_selected.bind(offense_card))
	defense_card.selected.connect(_on_card_selected.bind(defense_card))
	utility_card.selected.connect(_on_card_selected.bind(utility_card))

func _setup_context() -> void:
	var p_ctx: PlayerContext = Session.player_context
	
	last_known_pending_upgrades = p_ctx.pending_upgrades
	
	_update_upgrades_remaining(p_ctx.pending_upgrades)
	p_ctx.pending_upgrades_updated.connect(_update_upgrades_remaining)

func _update_upgrades_remaining(value: int) -> void:
	upgrades_remaining_label.text = str(value)
	
	if (
		last_known_pending_upgrades == 0 and 
		value > 0
	):
		_refresh_cache()
	
	elif (
		last_known_pending_upgrades > 0 and 
		value == 0
	):
		upgrade_cache.clear()
	
	last_known_pending_upgrades = value

func _refresh_cache() -> void:
	upgrade_cache.clear() 
	
	var all_offers: Dictionary = Session.player_provider.get_available_upgrade_offers()
	
	for category: Enums.UpgradeCategory in Enums.UpgradeCategory.values():
		var category_offers: Array = all_offers.get(category, [])
		if not category_offers.is_empty():
			var random_item: UpgradeOffer = category_offers.pick_random()
			upgrade_cache[category] = random_item
	
	_update_card_displays()

func _update_card_displays() -> void:
	_apply_to_card(offense_card)
	_apply_to_card(defense_card)
	_apply_to_card(utility_card)

func _apply_to_card(card: UIUpgradeCard) -> void:
	if not upgrade_cache.has(card.upgrade_category):
		card.button.disabled = true
		return
	
	card.button.disabled = false
	var offer: UpgradeOffer = upgrade_cache.get(card.upgrade_category)
	active_offers[card] = offer
	
	var data: UpgradeData = AssetProvider.get_upgrade_data(offer.type)
	
	card.update_card(
		data, 
		offer.tier_level
	)
	

# ===
# Signals
# ===

func _on_card_selected(card: UIUpgradeCard) -> void:
	if not active_offers.has(card): return
	
	var offer: UpgradeOffer = active_offers.get(card)
	
	Session.player_provider.add_upgrade(
		offer.type, 
		offer.tier_level
	)
	Session.player_provider.update_pending_upgrades(-1)
	EventBus.emit(
		AudioEvent.PlaySFX.new(
			Enums.SFXType.UPGRADE_AQCUIRED
		)
	)
	
	upgrade_cache.erase(card.upgrade_category)
	active_offers.erase(card)
	
	upgrade_cache.clear()
	_refresh_cache()

func _on_visibility_changed() -> void:
	if visible:
		_refresh_cache()
