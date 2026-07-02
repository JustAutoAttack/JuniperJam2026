class_name WorldProvider
extends ContextProvider

var context: WorldContext

# ===
# Built-In
# ===

func _init(
	p_context: WorldContext
) -> void:
	context = p_context

# ===
# Public
# ===

func reset() -> void:
	context.reset()

func set_time(value: float) -> void:
	context.time = value

func set_cpu_time(value: float) -> void:
	context.cpu_time = value

func set_wave(value: int) -> void:
	context.wave = value

func set_wave_time(value: float) -> void:
	context.wave_time = value

func set_arena_radius(value: float) -> void:
	context.arena_radius = value

func set_total_enemies(value: int) -> void:
	context.total_enemies = value

func update_total_enemies(delta: int) -> void:
	context.total_enemies += delta

func update_score(delta: int) -> void:
	context.score += delta

func update_enemies_killed(delta: int) -> void:
	context.enemies_killed += delta
