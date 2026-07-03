# World
extends GameState

var _is_game_over: bool = false

# ===
# Built-In
# ===

func enter(_prev_state_path: String, _data: Object) -> void:
	print_debug("Game: Enter WORLD")
	_subscribe()
	EventBus.emit(
		UIEvent.HideAll.new()
	)
	await get_tree().process_frame
	
	Session.is_in_world = true
	Session.player_context.pending_upgrades_updated.connect(
		func(value: int):
			if value == 0:
				EventBus.emit(
					UIEvent.ToggleMenu.new(
						Enums.MenuType.UPGRADE,
						false
					)
				)
				_toggle_pause(false)
	)
	
	# Show HUD
	EventBus.emit(
		UIEvent.ToggleHUD.new(
			true
		)
	)
	
	# Start Music
	EventBus.emit(
		AudioEvent.StartWorldPlaylist.new()
	)
	
	# Start Wave
	EventBus.emit(
		WorldEvent.StartNextWave.new()
	)

func exit() -> void:
	get_tree().paused = false
	EventBus.emit(
		UIEvent.HideAll.new()
	)
	EventBus.emit(
		AudioEvent.KillAllSFX.new()
	)
	Session.reset_game()
	Session.is_in_world = false
	_is_game_over = false
	_unsubscribe()
	print_debug("Game: Exit WORLD")

func handle_input(event: InputEvent) -> void:
	var is_game_over: bool = Session.ui_provider.is_menu_open(Enums.MenuType.GAME_OVER)
	
	if event.is_action_pressed("game_pause_resume"):
		# If Game Over is active, ignore pause request
		if is_game_over: return
		
		# Closing Menu
		if Session.ui_context.open_menus.size() > 0:
			EventBus.emit(
				AudioEvent.PlaySFX.new(
					Enums.SFXType.UI_MENU_CLOSED
				)
			)
			EventBus.emit(
				UIEvent.HideAllMenus.new()
			)
			if get_tree().paused:
				_toggle_pause(false)
			return
		
		# Toggling Pause
		if get_tree().paused:
			_toggle_pause(false)
		else:
			_toggle_pause(true)
	
	if event.is_action_pressed("menu_upgrade"):
		if is_game_over: return
		
		if Session.ui_provider.is_menu_open(Enums.MenuType.UPGRADE):
			EventBus.emit(
				UIEvent.ToggleMenu.new(
					Enums.MenuType.UPGRADE, 
					false
				)
			)
			get_tree().paused = false
		
		elif Session.player_context.pending_upgrades > 0:
			EventBus.emit(
				UIEvent.ToggleMenu.new(
					Enums.MenuType.UPGRADE, 
					true
				)
			)
			get_tree().paused = true

func _subscribe() -> void:
	EventBus.subscribe(GameEvent.GameOver, _handle_game_over)
	EventBus.subscribe(UIEvent.HUD, _handle_hud)
	EventBus.subscribe(UIEvent.PauseMenu, _handle_ui_pause_menu)
	EventBus.subscribe(UIEvent.SettingsMenu, _handle_ui_settings_menu)
	EventBus.subscribe(UIEvent.GameOverMenu, _handle_ui_game_over_menu)
	EventBus.subscribe(UIEvent.CreditsMenu, _handle_ui_credits_menu)
	Session.player_context.pending_upgrades_updated.connect(_on_pending_upgrades_updated)

func _unsubscribe() -> void:
	EventBus.unsubscribe(GameEvent.GameOver, _handle_game_over)
	EventBus.unsubscribe(UIEvent.HUD, _handle_hud)
	EventBus.unsubscribe(UIEvent.PauseMenu, _handle_ui_pause_menu)
	EventBus.unsubscribe(UIEvent.SettingsMenu, _handle_ui_settings_menu)
	EventBus.unsubscribe(UIEvent.GameOverMenu, _handle_ui_game_over_menu)
	EventBus.unsubscribe(UIEvent.CreditsMenu, _handle_ui_credits_menu)
	Session.player_context.pending_upgrades_updated.disconnect(_on_pending_upgrades_updated)

# ===
# Private
# ===

func _emit_toggle_pause_menu(is_paused: bool) -> void:
	EventBus.emit(
		UIEvent.ToggleMenu.new(
			Enums.MenuType.PAUSE, 
			is_paused
		)
	)

func _emit_pause_updated(is_paused: bool) -> void:
	if is_paused:
		EventBus.emit(
			GameEvent.Paused.new()
		)
		return
	
	EventBus.emit(
			GameEvent.Resumed.new()
		)

func _toggle_pause(is_paused: bool) -> void:
	get_tree().paused = is_paused
	if not Session.ui_provider.is_menu_open(Enums.MenuType.GAME_OVER):
		_emit_toggle_pause_menu(is_paused)
		_emit_pause_updated(is_paused)

# ===
# Events
# ===

func _handle_game_over(_event: GameEvent.GameOver) -> void:
	get_tree().paused = true
	
	EventBus.emit(
		AudioEvent.PlayGameOverSong.new()
	)
	
	EventBus.emit(
		GameEvent.Paused.new()
	)
	
	EventBus.emit(
		UIEvent.ToggleHUD.new(
			false
		)
	)
	
	EventBus.emit(
		UIEvent.ToggleMenu.new(
			Enums.MenuType.GAME_OVER, 
			true
		)
	)

# --- UI ---
func _handle_hud(event: UIEvent.HUD) -> void:
	if _is_game_over: return
	
	match event.action:
		Enums.HUDAction.UPGRADE_MENU:
			
			if Session.ui_provider.is_menu_open(Enums.MenuType.UPGRADE):
				EventBus.emit(UIEvent.ToggleMenu.new(Enums.MenuType.UPGRADE, false))
				get_tree().paused = false
			
			elif Session.player_context.pending_upgrades > 0:
				EventBus.emit(UIEvent.ToggleMenu.new(Enums.MenuType.UPGRADE, true))
				get_tree().paused = true
			
		Enums.HUDAction.PAUSE:
			if Session.ui_context.open_menus.size() > 0:
				EventBus.emit(AudioEvent.PlaySFX.new(Enums.SFXType.UI_MENU_CLOSED))
				EventBus.emit(UIEvent.HideAllMenus.new())
				if get_tree().paused:
					_toggle_pause(false)
			else:
				_toggle_pause(!get_tree().paused)

func _handle_ui_pause_menu(event: UIEvent.PauseMenu) -> void:
	var close_menu: bool = false
	
	match event.action:
		Enums.PauseMenuAction.RESUME:
			close_menu = true
			_toggle_pause(false)
		
		Enums.PauseMenuAction.SETTINGS:
			close_menu = true
			
			# Close Pause
			EventBus.emit(
				UIEvent.ToggleMenu.new(
					Enums.MenuType.PAUSE, 
					false
				)
			)
			
			# Open Settings
			EventBus.emit(
				UIEvent.ToggleMenu.new(
					Enums.MenuType.SETTINGS, 
					true
				)
			)
		
		Enums.PauseMenuAction.EXIT:
			close_menu = true

			# Go to Title
			_transition_to(
				StateName.LOAD, 
				GameLoadStateData.new(
					StateName.TITLE, 
					false,
					""
				)
			)
		
		Enums.PauseMenuAction.QUIT:
			get_tree().quit()
	
	# Close
	if close_menu:
		EventBus.emit(
				UIEvent.ToggleMenu.new(
					Enums.MenuType.PAUSE, 
					false
				)
			)

func _handle_ui_settings_menu(event: UIEvent.SettingsMenu) -> void:
	match event.action:
		Enums.SettingsMenuAction.SAVE:
			
			# Close Settings
			EventBus.emit(
				UIEvent.ToggleMenu.new(
					Enums.MenuType.SETTINGS,
					false
				)
			)
			
			# Open Pause
			EventBus.emit(
				UIEvent.ToggleMenu.new(
					Enums.MenuType.PAUSE, 
					true
				)
			)
			
			await get_tree().process_frame
			EventBus.emit(
				UIEvent.ToggleHUD.new(
					false
				)
			)

func _handle_ui_game_over_menu(event: UIEvent.GameOverMenu) -> void:
	
	match event.action:
		Enums.GameOverMenuAction.RESPIN:
			Session.reset_game()
			await get_tree().process_frame
			_toggle_pause(false)
			
			# Re-enter World
			_transition_to(
				StateName.LOAD, 
				GameLoadStateData.new(
					StateName.WORLD, 
					true,
					""
				)
			)
		
		Enums.GameOverMenuAction.TO_MAIN_MENU:
			_toggle_pause(false)
			
			await get_tree().process_frame
			
			# Go to Title
			_transition_to(
				StateName.LOAD, 
				GameLoadStateData.new(
					StateName.TITLE, 
					false,
					""
				)
			)
		
		Enums.GameOverMenuAction.CREDITS:
			# Close Game Over
			EventBus.emit(
				UIEvent.ToggleMenu.new(
					Enums.MenuType.GAME_OVER,
					false
				)
			)
			
			# Open Credits
			EventBus.emit(
				UIEvent.ToggleMenu.new(
					Enums.MenuType.CREDITS,
					true
				)
			)
		
	# Close
	EventBus.emit(
		UIEvent.ToggleMenu.new(
			Enums.MenuType.GAME_OVER, 
			false
		)
	)

func _handle_ui_credits_menu(event: UIEvent.CreditsMenu) -> void:
	match event.action:
		Enums.CreditsMenuAction.DONE:
			# Close Credits
			EventBus.emit(
				UIEvent.ToggleMenu.new(
					Enums.MenuType.CREDITS,
					false
				)
			)
			
			# Open Game Over
			EventBus.emit(
				UIEvent.ToggleMenu.new(
					Enums.MenuType.GAME_OVER,
					true
				)
			)

# ===
# Signals
# ===

func _on_pending_upgrades_updated(value: int) -> void:
	if value <= 0: return
	
	var is_upgrade_menu_open: bool = Session.ui_provider.is_menu_open(Enums.MenuType.UPGRADE)
	var auto_open_enabled: bool = Session.settings_context.auto_open_upgrade
	
	if (
		not is_upgrade_menu_open and 
		auto_open_enabled
	):
		# Open the menu
		EventBus.emit(
			UIEvent.ToggleMenu.new(
				Enums.MenuType.UPGRADE, 
				true
			)
		)
		# Pause the game
		get_tree().paused = true
