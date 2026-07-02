class_name AudioEvent
extends Event

# --- Music ---
class StartTitlePlaylist extends AudioEvent: pass
class StartWorldPlaylist extends AudioEvent: pass
class PlayGameOverSong extends AudioEvent: pass
class ReplayLastSong extends AudioEvent: pass
class ReplayCurrentSong extends AudioEvent: pass
class SkipCurrentSong extends AudioEvent: pass
class KillAllSFX extends AudioEvent: pass
class TrackPauseUpdated extends AudioEvent:
	
	var is_paused: bool
	
	func _init(
		p_is_paused: bool
	) -> void:
		is_paused = p_is_paused

class TogglePaused extends AudioEvent: 
	
	var is_paused: bool
	
	func _init(
		p_is_paused: bool
	) -> void:
		is_paused = p_is_paused

class ToggleLoop extends AudioEvent:
	
	var enabled: bool
	
	func _init(
		p_enabled: bool
	) -> void:
		enabled = p_enabled

class ToggleShuffle extends AudioEvent:
	
	var enabled: bool
	
	func _init(
		p_enabled: bool
	) -> void:
		enabled = p_enabled

class CurrentSongUpdated extends AudioEvent:
	
	var song_data: SongData
	
	func _init(
		p_song_data: SongData
	) -> void:
		song_data = p_song_data

class CurrentPlaybackTimeUpdated extends AudioEvent:
	
	var value: int
	
	func _init(
		p_value: int
	) -> void:
		value = p_value

# --- SFX ---
class PlaySFX extends AudioEvent:
	
	var sfx_type: Enums.SFXType
	
	func _init(
		p_sfx_type: Enums.SFXType
	) -> void:
		sfx_type = p_sfx_type
