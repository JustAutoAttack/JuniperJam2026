class_name UIEvent
extends Event

class StartLoading extends UIEvent: pass
class StopLoading extends UIEvent: pass
class StartSaving extends UIEvent: pass
class StopSaving extends UIEvent: pass
class HideAll extends UIEvent: pass
class HideAllMenus extends UIEvent: pass

class ToggleMenu extends UIEvent:
	
	var type: Enums.MenuType
	var is_visible: bool
	
	func _init(
		p_type: Enums.MenuType, 
		p_is_visible: bool
	):
		type = p_type
		is_visible = p_is_visible

class ToggleHUD extends UIEvent:
	
	var is_visible: bool
	
	func _init(
		p_is_visible: bool
	):
		is_visible = p_is_visible

# ===
# Title Menu
# ===

class MainMenu extends UIEvent:
	
	var action: Enums.MainMenuAction
	
	func _init(
		p_action: Enums.MainMenuAction
	) -> void:
		action = p_action

# ===
# World Menu
# ===

class HUD extends UIEvent:
	
	var action: Enums.HUDAction
	
	func _init(
		p_action: Enums.HUDAction
	) -> void:
		action = p_action

class PauseMenu extends UIEvent:
	
	var action: Enums.PauseMenuAction
	
	func _init(
		p_action: Enums.PauseMenuAction
	) -> void:
		action = p_action

class GameOverMenu extends UIEvent:
	
	var action: Enums.GameOverMenuAction
	
	func _init(
		p_action: Enums.GameOverMenuAction
	) -> void:
		action = p_action

class SettingsMenu extends UIEvent:
	
	var action: Enums.SettingsMenuAction
	
	func _init(
		p_action: Enums.SettingsMenuAction
	) -> void:
		action = p_action

class CreditsMenu extends UIEvent:
	
	var action: Enums.CreditsMenuAction
	
	func _init(
		p_action: Enums.CreditsMenuAction
	) -> void:
		action = p_action
