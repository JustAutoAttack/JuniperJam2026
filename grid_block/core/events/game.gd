class_name GameEvent
extends Event

# --- Title ---
class LoadTitle extends GameEvent: pass
class TitleLoaded extends GameEvent: pass

# --- World ---
class LoadWorld extends GameEvent: pass
class WorldLoaded extends GameEvent: pass

# --- Pause ---
class Paused extends GameEvent: pass
class Resumed extends GameEvent: pass

# --- Save/Load ---
class LoadGame extends GameEvent: pass
class GameLoaded extends GameEvent:
	
	var data: GameSaveData
	
	func _init(
		p_data: GameSaveData
	) -> void:
		data = p_data

class SaveGame extends GameEvent: pass
class GameSaved extends GameEvent: pass
class SaveSettings extends GameEvent: pass
class SettingsSaved extends GameEvent: pass

# --- Life Cycle ---
class GameOver extends GameEvent: pass
class FetchObjectPool extends GameEvent: 
	
	var object: Node
	
	func _init(
		p_object: Node
	) -> void:
		object = p_object

class RecycleEnemy extends WorldEvent:
	
	var enemy: Enemy
	
	func _init(
		p_enemy: Enemy
	) -> void:
		enemy = p_enemy

class RecycleBursterProjectile extends WorldEvent:
	
	var burster_projectile: BursterProjectile
	
	func _init(
		p_burster_projectile: BursterProjectile
	) -> void:
		burster_projectile = p_burster_projectile

class RecycleXPItem extends WorldEvent:
	
	var xp_item: XPItem
	
	func _init(
		p_xp_item: XPItem
	) -> void:
		xp_item = p_xp_item

class RecycleDebris extends WorldEvent:
	
	var debris: DebrisCube
	
	func _init(
		p_debris: DebrisCube
	) -> void:
		debris = p_debris

class RecyclePopupLabel extends WorldEvent:
	
	var popup_label: PopupLabel
	
	func _init(
		p_popup_label: PopupLabel
	) -> void:
		popup_label = p_popup_label
