# Boot
extends MainState

# TODO Hook into settings context

@export var enabled: bool = true

# ===
# Built-In
# ===

func enter(_prev_state_path: String, _data: Object) -> void:
	print_debug("Main: Enter BOOT")
	
	if enabled:
		_subscribe_events()
		EventBus.emit(
			MainEvent.LoadBootsplash.new()
		)
	else:
		_transition_to(
			StateName.GAME, 
			null
		)

func exit() -> void:
	_unsubscribe_events()
	print_debug("Main: Exit BOOT")

func _subscribe_events() -> void:
	EventBus.subscribe(MainEvent.BootsplashLoaded, _handle_bootsplash_loaded)

func _unsubscribe_events() -> void:
	EventBus.unsubscribe(MainEvent.BootsplashLoaded, _handle_bootsplash_loaded)

# ===
# Events
# ===

func _handle_bootsplash_loaded(_event: MainEvent.BootsplashLoaded) -> void:
	print_debug("Main: Bootsplash Loaded")
	_transition_to(StateName.GAME, null)
