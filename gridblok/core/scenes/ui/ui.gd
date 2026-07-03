class_name UI
extends Node

@onready var hud: UIHUD = %HUD
@onready var title_background: TextureRect = %TitleBackground
@onready var paused_view: UIPausedView = %PausedView
@onready var menus_layer: CanvasLayer = %MenusLayer
@onready var loading_screen: UILoadingScreen = %LoadingScreen

var menu_type_to_node: Dictionary[Enums.MenuType, UIMenu] = {}

# ===
# Built-In
# ===

func _ready() -> void:
	for child in menus_layer.get_children():
		if child is UIMenu:
			menu_type_to_node[child.type] = child
	
	_hide_all()
	_subscribe()

func _exit_tree() -> void:
	_unsubscribe()

# ===
# Private
# ===

func _subscribe() -> void:
	EventBus.subscribe(GameEvent.WorldLoaded, func(_event): title_background.hide())
	EventBus.subscribe(UIEvent.HideAll, func(_event): _hide_all())
	EventBus.subscribe(UIEvent.ToggleHUD, _handle_toggle_hud)
	EventBus.subscribe(UIEvent.ToggleMenu, _handle_toggle_menu)
	EventBus.subscribe(UIEvent.HideAllMenus, _handle_hide_all_menus)
	EventBus.subscribe(UIEvent.StartLoading, _handle_start_loading)
	EventBus.subscribe(UIEvent.StopLoading, _handle_stop_loading)

func _unsubscribe() -> void:
	EventBus.unsubscribe(GameEvent.WorldLoaded, func(_event): title_background.hide())
	EventBus.unsubscribe(UIEvent.HideAll, func(_event): _hide_all())
	EventBus.unsubscribe(UIEvent.ToggleHUD, _handle_toggle_hud)
	EventBus.unsubscribe(UIEvent.ToggleMenu, _handle_toggle_menu)
	EventBus.unsubscribe(UIEvent.HideAllMenus, _handle_hide_all_menus)
	EventBus.unsubscribe(UIEvent.StartLoading, _handle_start_loading)
	EventBus.unsubscribe(UIEvent.StopLoading, _handle_stop_loading)

func _toggle_hud(is_visible: bool) -> void:
	hud.visible = is_visible

func _toggle_menu(menu_type: Enums.MenuType, should_show: bool) -> void:
	if menu_type_to_node.has(menu_type):
		menu_type_to_node[menu_type].visible = should_show
		Session.ui_provider.set_open_menus(_get_open_menus())
		
		if should_show and menu_type not in [Enums.MenuType.MAIN, Enums.MenuType.GAME_OVER]:
			EventBus.emit(AudioEvent.PlaySFX.new(Enums.SFXType.UI_MENU_OPENED))

func _hide_all_menus() -> void:
	for menu in menu_type_to_node.values():
		menu.visible = false
	
	Session.ui_provider.set_open_menus(_get_open_menus())

func _start_loading() -> void:
	loading_screen.show()

func _stop_loading() -> void:
	loading_screen.hide()

func _hide_all() -> void:
	paused_view.hide()
	_hide_all_menus()
	_toggle_hud(false)
	_stop_loading()

func _get_open_menus() -> Array[Enums.MenuType]:
	var open_menus: Array[Enums.MenuType] = []
	for type in menu_type_to_node:
		var menu: UIMenu = menu_type_to_node[type]
		if menu and menu.visible:
			open_menus.append(type)
	
	return open_menus

# ===
# Events
# ===

func _handle_toggle_hud(event: UIEvent.ToggleHUD) -> void:
	_toggle_hud(
		event.is_visible
	)

func _handle_toggle_menu(event: UIEvent.ToggleMenu) -> void:
	_toggle_menu(event.type, event.is_visible)
	
	var is_any_menu_blocking_hud = (
		menu_type_to_node.get(Enums.MenuType.PAUSE, UIMenu.new()).visible or
		menu_type_to_node.get(Enums.MenuType.UPGRADE, UIMenu.new()).visible or
		menu_type_to_node.get(Enums.MenuType.SETTINGS, UIMenu.new()).visible or
		menu_type_to_node.get(Enums.MenuType.GAME_OVER, UIMenu.new()).visible or 
		menu_type_to_node.get(Enums.MenuType.CREDITS, UIMenu.new()).visible
	)
	
	_toggle_hud(not is_any_menu_blocking_hud)
	
	var is_any_pause_view_active = (
		menu_type_to_node.get(Enums.MenuType.PAUSE, UIMenu.new()).visible or
		menu_type_to_node.get(Enums.MenuType.UPGRADE, UIMenu.new()).visible or
		menu_type_to_node.get(Enums.MenuType.GAME_OVER, UIMenu.new()).visible or
		(menu_type_to_node.get(Enums.MenuType.SETTINGS, UIMenu.new()).visible and Session.is_in_world)
	)
	
	paused_view.visible = is_any_pause_view_active
	title_background.visible = not Session.is_in_world

func _handle_hide_all_menus(_event: UIEvent.HideAllMenus) -> void:
	_hide_all_menus()

func _handle_start_loading(_event: UIEvent.StartLoading) -> void:
	_start_loading()

func _handle_stop_loading(_event: UIEvent.StopLoading) -> void:
	_stop_loading()
