# Title
extends GameState

# ===
# Built-In
# ===

func enter(_prev_state_path: String, _data: Object) -> void:
	print_debug("Game: Enter TITLE")
	_subscribe()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	await get_tree().process_frame
	
	EventBus.emit(
		UIEvent.ToggleHUD.new(
			false
		)
	)
	EventBus.emit(
		UIEvent.HideAll.new()
	)
	
	await get_tree().process_frame
	
	# Show Main Menu
	EventBus.emit(
		UIEvent.ToggleMenu.new(
			Enums.MenuType.MAIN, 
			true
		)
	)
	
	# Start Music
	EventBus.emit(
		AudioEvent.StartTitlePlaylist.new()
	)

func exit() -> void:
	EventBus.emit(
		UIEvent.HideAll.new()
	)
	_unsubscribe()
	
	print_debug("Game: Exit TITLE")

func _subscribe() -> void:
	EventBus.subscribe(UIEvent.MainMenu, _handle_ui_main_menu)
	EventBus.subscribe(UIEvent.SettingsMenu, _handle_ui_settings_menu)
	
func _unsubscribe() -> void:
	EventBus.unsubscribe(UIEvent.MainMenu, _handle_ui_main_menu)
	EventBus.unsubscribe(UIEvent.SettingsMenu, _handle_ui_settings_menu)

# ===
# Private
# ===


# ===
# Signals
# ===

# --- UI ---
func _handle_ui_main_menu(event: UIEvent.MainMenu) -> void:
	match event.action:
		# Spin
		Enums.MainMenuAction.SPIN:
			_transition_to(
				StateName.LOAD, 
				GameLoadStateData.new(
					StateName.WORLD, 
					true,
					""
				)
			)
		
		# Settings
		Enums.MainMenuAction.SETTINGS:
			# Close Main
			EventBus.emit(
				UIEvent.ToggleMenu.new(
					Enums.MenuType.MAIN, 
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
			
		
		# Quit
		Enums.MainMenuAction.QUIT:
			get_tree().quit()

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
			# Open Main
			EventBus.emit(
				UIEvent.ToggleMenu.new(
					Enums.MenuType.MAIN, 
					true
				)
			)
			await get_tree().process_frame
			EventBus.emit(
				UIEvent.ToggleHUD.new(
					false
				)
			)
