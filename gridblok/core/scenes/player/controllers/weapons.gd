class_name PlayerWeaponsController
extends Node3D

@export var tethered_blade_scene: PackedScene

var orbit_radius: float = 0.0
var orbit_speed: float = 0.0
var blade_count: int = 0

var _active_blades: Array[TetheredBlade] = []

# ===
# Built-In
# ===

func _ready() -> void:
	_update_values()
	Session.player_context.owned_upgrades_updated.connect(
		func(_value):
			_update_values()
	)
	EventBus.emit(
		AudioEvent.PlaySFX.new(
			Enums.SFXType.BLADE_ROTATION
		)
	)

func _process(delta: float) -> void:
	rotate_y(orbit_speed * delta)

# ===
# Public
# ===


# ===
# Private
# ===

func _update_values() -> void:
	var p_provider: PlayerProvider = Session.player_provider
	
	var new_count: int = int(p_provider.get_total_stat(Enums.StatType.BLADE_COUNT))
	var new_radius: float = p_provider.get_total_stat(Enums.StatType.ORBIT_RADIUS)
	orbit_speed = p_provider.get_total_stat(Enums.StatType.ORBIT_VELOCITY)
	
	# Check against current state BEFORE updating the variables
	if new_count != blade_count or _active_blades.is_empty():
		blade_count = new_count
		orbit_radius = new_radius
		_rebuild()
	else:
		orbit_radius = new_radius
		# Only update radius if we already have blades
		for tethered_blade: TetheredBlade in _active_blades:
			if not is_instance_valid(tethered_blade): continue
			
			var tween: Tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
			tween.tween_property(tethered_blade, "tether_length", orbit_radius, 0.5)

func _rebuild() -> void:
	if not tethered_blade_scene: return
	
	for blade: TetheredBlade in _active_blades:
		blade.queue_free()
	
	_active_blades.clear()

	for i in range(blade_count):
		var tethered_blade: TetheredBlade = tethered_blade_scene.instantiate() as TetheredBlade
		add_child(tethered_blade)
		_active_blades.append(tethered_blade)
		
		var angle: float = (float(i) / blade_count) * TAU
		tethered_blade.rotation.y = angle
		
		# Length
		var orbit_radius_tween: Tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		orbit_radius_tween.tween_property(tethered_blade, "tether_length", orbit_radius, 0.5)
		
