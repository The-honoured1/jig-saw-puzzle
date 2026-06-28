extends Node

const SAVE_PATH: String = "user://jigsaw_save.cfg"

var current_level: int = 0
var level_scores: Dictionary = {} # level_idx (int) -> best_time_seconds (int)

# Premium UI settings
var _current_mode: String = "Relax"
var current_mode: String setget _set_current_mode, _get_current_mode
var _current_background: String = "Default"
var current_background: String setget _set_current_background, _get_current_background
var daily_challenge_seed: int = 0  # calculated daily

var _sound_enabled: bool = true
var sound_enabled: bool setget _set_sound_enabled, _get_sound_enabled
var _music_enabled: bool = true
var music_enabled: bool setget _set_music_enabled, _get_music_enabled

func _set_current_mode(val: String) -> void:
	_current_mode = val
	save_progress()

func _get_current_mode() -> String:
	return _current_mode

func _set_current_background(val: String) -> void:
	_current_background = val
	save_progress()

func _get_current_background() -> String:
	return _current_background

func _set_sound_enabled(val: bool) -> void:
	_sound_enabled = val
	if has_node("/root/sound"):
		get_node("/root/sound").sound_enabled = val
	save_progress()

func _get_sound_enabled() -> bool:
	return _sound_enabled

func _set_music_enabled(val: bool) -> void:
	_music_enabled = val
	if has_node("/root/sound"):
		get_node("/root/sound").music_enabled = val
	save_progress()

func _get_music_enabled() -> bool:
	return _music_enabled

func _ready() -> void:
	load_progress()

func save_progress() -> void:
	var config = ConfigFile.new()
	config.set_value("settings", "sound_enabled", sound_enabled)
	config.set_value("settings", "music_enabled", music_enabled)
	config.set_value("settings", "current_mode", current_mode)
	config.set_value("settings", "current_background", current_background)
	
	# Convert level_scores dictionary keys to strings since ConfigFile doesn't support int keys directly in some situations,
	# or just store it as is since Godot 4 ConfigFile supports Variant dictionary keys. Variant dictionary is safe!
	config.set_value("progress", "scores", level_scores)
	
	config.save(SAVE_PATH)

func load_progress() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		sound_enabled = config.get_value("settings", "sound_enabled", true)
		music_enabled = config.get_value("settings", "music_enabled", true)
		current_mode = config.get_value("settings", "current_mode", "Relax")
		current_background = config.get_value("settings", "current_background", "Default")
		level_scores = config.get_value("progress", "scores", {})
		
		# Sync with sound manager
		if has_node("/root/sound"):
			var sound_mgr = get_node("/root/sound")
			sound_mgr.sound_enabled = sound_enabled
			sound_mgr.music_enabled = music_enabled

func reset_progress() -> void:
	level_scores.clear()
	current_level = 0
	sound_enabled = true
	music_enabled = true
	save_progress()

func is_level_unlocked(idx: int) -> bool:
	if idx == 0:
		return true
	# Level idx is unlocked if level idx-1 has a completed score
	return level_scores.has(idx - 1)
