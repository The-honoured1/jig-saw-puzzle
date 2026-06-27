extends Node

const SAVE_PATH: String = "user://jigsaw_save.cfg"

var current_level: int = 0
var level_scores: Dictionary = {} # level_idx (int) -> best_time_seconds (int)

var sound_enabled: bool = true:
	set(val):
		sound_enabled = val
		if has_node("/root/sound"):
			get_node("/root/sound").sound_enabled = val
		save_progress()

var music_enabled: bool = true:
	set(val):
		music_enabled = val
		if has_node("/root/sound"):
			get_node("/root/sound").music_enabled = val
		save_progress()

func _ready() -> void:
	load_progress()

func save_progress() -> void:
	var config = ConfigFile.new()
	config.set_value("settings", "sound_enabled", sound_enabled)
	config.set_value("settings", "music_enabled", music_enabled)
	
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
