class_name UIHUD
extends Control

@export var icon_color_material: ShaderMaterial

@export_category("Damage Flash")
@export_range(0.0, 1.0) var low_health_threshold: float = 0.5
@export_range(0.0, 1.0) var min_pulse_intensity: float = 0.4
@export_range(0.0, 1.0) var max_pulse_intensity: float = 1.0
@export var pulse_speed: float = 2.0

@onready var damage_flash: ColorRect = %DamageFlash
@onready var pause_button: Button = %PauseButton

# Tracker
@onready var wave_label: Label = %Wave
@onready var wave_time_label: Label = %WaveTime
@onready var score_label: Label = %Score
@onready var erased_label: Label = %Erased

# Resources
@onready var health_bar: TextureProgressBar = %HealthBar
@onready var low_health_bar: TextureProgressBar = %LowHealthBar
@onready var xp_bar: TextureProgressBar = %XPBar
@onready var level_label: Label = %Level
@onready var shield_bars_container: HBoxContainer = %ShieldBarsContainer

# Upgrade Ready
@onready var upgrade_ready: MarginContainer = %UpgradeReady
@onready var upgrade_button: TextureButton = %UpgradeButton
@onready var upgrade_menu_key: Label = %UpgradeMenuKey

# Audio Controls
@onready var shuffle_playlist_button: TextureButton = %ShufflePlaylistButton
@onready var prev_track_button: TextureButton = %PrevTrackButton
@onready var pause_track_button: TextureButton = %PauseTrackButton
@onready var resume_track_button: TextureButton = %ResumeTrackButton
@onready var next_track_button: TextureButton = %NextTrackButton
@onready var loop_track_button: TextureButton = %LoopTrackButton

# Track Info
@onready var track_paused_label: Label = %TrackPaused
@onready var song_name_label: Label = %SongName
@onready var song_artist_label: Label = %SongArtist
@onready var track_progress_bar: ProgressBar = %TrackProgressBar
@onready var current_playback_time_label: Label = %CurrentPlaybackTime
@onready var track_duration: Label = %TrackDuration

var shield_bars: Array[TextureProgressBar] = []

var _current_song_duration: int = 0
var _current_song_playback_time: int = 0
var _current_shield_regen_idx: int = 0
var _last_health_ratio: float = 1.0
var _damage_impulse_intensity: float = 0.0
var _track_paused: bool = false

# ===
# Built-In
# ===

func _ready() -> void:
	# Shields
	for child in shield_bars_container.get_children():
		if child is TextureProgressBar:
			shield_bars.append(child)
	
	score_label.pivot_offset = score_label.size / 2
	erased_label.pivot_offset = erased_label.size / 2
	
	track_paused_label.visible = _track_paused
	
	_connect_buttons()
	
	if Engine.is_editor_hint(): return
	
	_subscribe()
	_setup_context()

func _process(_delta: float) -> void:
	var is_flash_enabled: bool = Session.settings_context.damage_flash
	var passive_intensity: float = 0.0
	
	if (
		is_flash_enabled and 
		_last_health_ratio < low_health_threshold
	):
		var sine_wave = sin(Time.get_ticks_msec() / 1000.0 * (PI * pulse_speed))
		var peak = remap(
			_last_health_ratio, 
			low_health_threshold, 
			0.0,
			min_pulse_intensity, 
			max_pulse_intensity
		)
		
		# Boost the sine wave calculation
		passive_intensity = (sine_wave * 0.5 + 0.5) * peak
	
	var total_intensity: float = 0.0
	if is_flash_enabled:
		total_intensity = clamp(passive_intensity + _damage_impulse_intensity, 0.0, 1.0)
	
	if damage_flash.material is ShaderMaterial:
		damage_flash.material.set_shader_parameter("intensity", total_intensity)

func _exit_tree() -> void:
	if Engine.is_editor_hint(): return
	
	_unsubscribe()

# ===
# Private
# ===

func _subscribe() -> void:
	EventBus.subscribe(AudioEvent.CurrentSongUpdated, _handle_audio_current_song_updated)
	EventBus.subscribe(AudioEvent.CurrentPlaybackTimeUpdated, _handle_audio_playback_time_updated)
	EventBus.subscribe(AudioEvent.TrackPauseUpdated, _handle_audio_track_pause_updated)
	
func _unsubscribe() -> void:
	EventBus.unsubscribe(AudioEvent.CurrentSongUpdated, _handle_audio_current_song_updated)
	EventBus.unsubscribe(AudioEvent.CurrentPlaybackTimeUpdated, _handle_audio_playback_time_updated)
	EventBus.unsubscribe(AudioEvent.TrackPauseUpdated, _handle_audio_track_pause_updated)

func _connect_buttons() -> void:
	# Actions
	pause_button.pressed.connect(
		func():
			EventBus.emit(
				UIEvent.HUD.new(
					Enums.HUDAction.PAUSE
				)
			)
	)
	upgrade_button.pressed.connect(
		func():
			EventBus.emit(
				UIEvent.HUD.new(
					Enums.HUDAction.UPGRADE_MENU
				)
			)
	)
	
	# Audio Controls
	shuffle_playlist_button.toggled.connect(_on_shuffle_playlist_button_toggled)
	prev_track_button.pressed.connect(_on_prev_track_button_pressed)
	pause_track_button.pressed.connect(_on_pause_track_button_pressed)
	resume_track_button.pressed.connect(_on_resume_track_button_pressed)
	next_track_button.pressed.connect(_on_next_track_button_pressed)
	loop_track_button.toggled.connect(_on_loop_track_button_toggled)

func _setup_context() -> void:
	var p_ctx: PlayerContext = Session.player_context
	var w_ctx: WorldContext = Session.world_context
	
	# --- Wave Info ---
	_update_wave(w_ctx.wave)
	w_ctx.wave_updated.connect(_update_wave)
	
	_update_wave_time(w_ctx.wave_time)
	w_ctx.wave_time_updated.connect(_update_wave_time)
	
	# --- Upgrades Menu ---
	_update_upgrade_ready(p_ctx.pending_upgrades)
	p_ctx.pending_upgrades_updated.connect(_update_upgrade_ready)
	
	# --- Resources ---
	_update_current_health(p_ctx.current_health)
	p_ctx.current_health_updated.connect(_update_current_health)
	
	_update_active_shields(p_ctx.current_shield_count)
	p_ctx.current_shield_count_updated.connect(_update_active_shields)
	
	_update_shield_regen(p_ctx.current_shield_regen)
	p_ctx.current_shield_regen_updated.connect(_update_shield_regen)
	
	_update_xp_bar(p_ctx.xp)
	p_ctx.xp_updated.connect(_update_xp_bar)
	
	_update_level(p_ctx.level)
	p_ctx.level_updated.connect(_update_level)
	
	# --- Ratings ---
	_update_score_rating(w_ctx.score)
	w_ctx.score_updated.connect(_update_score_rating)
	
	_update_erased_rating(w_ctx.enemies_killed)
	w_ctx.enemies_killed_updated.connect(_update_erased_rating)
	
	# --- Stats ---
	_update_stats()
	p_ctx.owned_upgrades_updated.connect(
		func(_value):
			_update_stats()
	)

func _tween_counter(label: Label, new_value: int) -> void:
	var current_value = int(label.text.replace(",", ""))
	
	# Update pivot whenever text changes to keep it centered
	label.pivot_offset = label.size / 2
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Punch effect
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(label, "scale", Vector2.ONE, 0.2).set_delay(0.1)
	
	# Numeric counting
	tween.tween_method(
		func(val): 
			label.text = _format_number(int(val))
			# Re-center pivot as text length changes
			label.pivot_offset = label.size / 2,
		float(current_value),
		float(new_value),
		0.5
	).set_trans(Tween.TRANS_QUART)

func _tween_resource_bar(
	bar: TextureProgressBar, 
	new_value: float, 
	new_max: float
) -> void:
	bar.max_value = new_max
	var tween: Tween = create_tween()
	tween.tween_property(
		bar, 
		"value", 
		new_value, 
		0.3
	).set_trans(
		Tween.TRANS_CUBIC
	)

func _set_icon_color(icon: TextureRect, target_color: Color) -> void:
	if not (icon.material is ShaderMaterial):
		icon.material = icon_color_material.duplicate()
	
	icon.material.set_shader_parameter(
		"target_color", 
		target_color
	)

func _format_number(value: int) -> String:
	var s = str(value)
	var result = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = s[i] + result
		count += 1
	return result

func _format_time(seconds: int) -> String:
	var minutes: int = seconds / 60
	var remaining_seconds: int = seconds % 60
	return "%02d:%02d" % [minutes, remaining_seconds]

func _format_health(value: float) -> String:
	return "%0.2f" % value

func _get_percentage_string(float_value: float) -> String:
	return "%.0f%%" % (float_value * 100.0)

# --- Wave Info ---
func _update_wave(value: int) -> void:
	wave_label.text = str(value)

func _update_wave_time(value: float) -> void:
	wave_time_label.text = _format_time(int(value))
	
	if value <= 10.0:
		wave_time_label.modulate = Constants.SynthColors.CYBER_RED
	else:
		wave_time_label.modulate = Color.WHITE

# --- Upgrade Ready ---
func _update_upgrade_ready(pending_upgrades: int) -> void:
	var was_visible: bool = upgrade_ready.visible
	upgrade_ready.visible = (pending_upgrades > 0)
	if upgrade_ready.visible and not was_visible:
		EventBus.emit(
			AudioEvent.PlaySFX.new(
				Enums.SFXType.UI_NOTIFICATION
			)
		)

# --- Resources ---
func _update_current_health(value: float) -> void:
	var max_hp = Session.player_provider.get_total_stat(Enums.StatType.MAX_HEALTH)
	var new_ratio = value / max_hp
	
	# Ensure visibility logic is strict
	low_health_bar.visible = (new_ratio < low_health_threshold)
	
	# Check for damage
	if new_ratio < _last_health_ratio:
		var damage_delta = _last_health_ratio - new_ratio
		_damage_impulse_intensity = clamp(damage_delta * 20.0, 0.5, 1.0)
		
		# Reset intensity smoothly
		create_tween().tween_property(self, "_damage_impulse_intensity", 0.0, 0.5)
		
	_last_health_ratio = new_ratio
	_update_health_bar(value, max_hp)

func _update_max_health(value: float) -> void:
	_update_health_bar(
		Session.player_context.current_health, 
		value
	)

func _update_health_bar(current_value: float, max_value: float) -> void:
	_tween_resource_bar(
		health_bar, 
		current_value, 
		max_value
	)
	_tween_resource_bar(
		low_health_bar, 
		current_value, 
		max_value
	)

func _update_shield_count(count: int) -> void:
	for i in range(shield_bars.size()):
		shield_bars[i].visible = i < count
		if i < count:
			shield_bars[i].value = shield_bars[i].max_value

func _update_active_shields(current_count: int) -> void:
	for i in range(shield_bars.size()):
		var bar = shield_bars[i]
		# Only visible if it is an active, owned shield
		bar.visible = (i < current_count)
		bar.modulate.a = 1.0
		bar.value = bar.max_value if i < current_count else 0.0

func _update_shield_regen(value: float) -> void:
	var p_ctx = Session.player_context
	var current_count = p_ctx.current_shield_count
	var max_owned_shields = int(Session.player_provider.get_total_stat(Enums.StatType.SHIELD_COUNT))
	var regen_value = p_ctx.current_shield_regen
	
	for i in range(shield_bars.size()):
		var bar = shield_bars[i]
		
		if i >= max_owned_shields:
			bar.visible = false
			continue

		if i < current_count:
			# Full Shields
			bar.visible = true
			bar.modulate.a = 1.0
			bar.value = bar.max_value
		elif i == current_count:
			# Regenerating Slot
			bar.visible = true
			bar.modulate.a = 0.5
			bar.value = bar.max_value * clamp(regen_value, 0.0, 1.0)
		else:
			# Empty Slots
			bar.visible = true
			bar.modulate.a = 0.2
			bar.value = 0.0

func _update_xp_bar(current_value: float) -> void:
	_tween_resource_bar(
		xp_bar, 
		current_value, 
		Session.player_provider.get_max_xp()
	)

func _update_level(value: int) -> void:
	level_label.text = str(value)

# --- Ratings ---
func _update_score_rating(value: int) -> void:
	_tween_counter(score_label, value)

func _update_erased_rating(value: int) -> void:
	_tween_counter(erased_label, value)

# --- Stats ---
func _update_stats() -> void:
	_update_max_health(
		Session.player_provider.get_total_stat(
			Enums.StatType.MAX_HEALTH
		)
	)

# ===
# Events
# ===

func _handle_audio_current_song_updated(event: AudioEvent.CurrentSongUpdated) -> void:
	var song: SongData = event.song_data
	song_name_label.text = song.display_name
	song_artist_label.text = song.artist_name
	
	# Pre-fill bar
	if song.audio_stream:
		_current_song_duration = int(song.audio_stream.get_length())
		track_progress_bar.max_value = float(_current_song_duration)
		track_duration.text = _format_time(_current_song_duration)

func _handle_audio_playback_time_updated(event: AudioEvent.CurrentPlaybackTimeUpdated) -> void:
	_current_song_playback_time = event.value
	track_progress_bar.value = float(_current_song_playback_time)
	current_playback_time_label.text = _format_time(_current_song_playback_time)

func _handle_audio_track_pause_updated(event: AudioEvent.TrackPauseUpdated) -> void:
	pause_track_button.visible = not event.is_paused
	resume_track_button.visible = event.is_paused
	_track_paused = event.is_paused

	if _track_paused:
		track_paused_label.show()
		track_paused_label.modulate.a = 1.0
		
		# Looping Fade
		var tween = create_tween().set_loops()
		tween.tween_property(track_paused_label, "modulate:a", 0.2, 1.0)
		tween.tween_property(track_paused_label, "modulate:a", 1.0, 1.0)
	else:
		create_tween().kill()
		track_paused_label.modulate.a = 0.0
		track_paused_label.hide()

# ===
# Signals
# ===

# --- Pause/Resume ---
func _on_pause_button_pressed() -> void:
	pass

# --- Now Playing ---
func _on_now_playing_control_hover_started(icon_refs: Array) -> void:
	for icon_ref in icon_refs:
		if not (icon_ref is TextureRect): continue
		_set_icon_color(
			icon_ref, 
			Constants.SynthColors.NEON_CYAN
		)

func _on_shuffle_playlist_button_toggled(toggled_on: bool) -> void:
	EventBus.emit(
		AudioEvent.ToggleShuffle.new(
			toggled_on
		)
	)

func _on_prev_track_button_pressed() -> void:
	# Replay Last
	if _current_song_playback_time <= 3:
		EventBus.emit(
			AudioEvent.ReplayLastSong.new()
		)
		
	# Replay Current
	else:
		EventBus.emit(
			AudioEvent.ReplayCurrentSong.new()
		)

func _on_pause_track_button_pressed() -> void:
	EventBus.emit(
		AudioEvent.TogglePaused.new(
			true
		)
	)

func _on_resume_track_button_pressed() -> void:
	EventBus.emit(
		AudioEvent.TogglePaused.new(
			false
		)
	)

func _on_next_track_button_pressed() -> void:
	EventBus.emit(
		AudioEvent.SkipCurrentSong.new()
	)

func _on_loop_track_button_toggled(toggled_on: bool) -> void:
	EventBus.emit(
		AudioEvent.ToggleLoop.new(
			toggled_on
		)
	)
