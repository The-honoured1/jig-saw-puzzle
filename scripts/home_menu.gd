extends Control

@onready var title_label: Label = $CenterContainer/LogoArea/Title
@onready var subtitle_label: Label = $CenterContainer/LogoArea/Subtitle
@onready var daily_button: Button = $CenterContainer/MenuButtons/DailyButton
@onready var mode_selector: OptionButton = $CenterContainer/MenuButtons/ModeSelector
@onready var bg_forest_button: Button = $CenterContainer/BackgroundSelector/BG1
@onready var bg_ocean_button: Button = $CenterContainer/BackgroundSelector/BG2
@onready var bg_desert_button: Button = $CenterContainer/BackgroundSelector/BG3
@onready var settings_button: Button = $CenterContainer/MenuButtons/SettingsButton
@onready var exit_button: Button = $CenterContainer/MenuButtons/ExitButton
@onready var footer_label: Label = $Footer
@onready var decorations: Node2D = $Decorations
@onready var play_button: Button = $CenterContainer/MenuButtons/PlayButton

# Shared font — created once to avoid null font descriptor crashes
var _font: SystemFont = null

# Decorative floaters
var floaters: Array = []

func _ready() -> void:
	# Create font once and keep a reference so it doesn't get GC'd
	_font = SystemFont.new()
	_font.font_names = PackedStringArray(["Sans-Serif", "Arial"])
	_font.font_weight = 700
	
	_apply_styling()
	
	# Connect new UI elements
	daily_button.pressed.connect(_on_daily_pressed)
	mode_selector.item_selected.connect(_on_mode_selected)
	bg_forest_button.pressed.connect(_on_bg_forest_pressed)
	bg_ocean_button.pressed.connect(_on_bg_ocean_pressed)
	bg_desert_button.pressed.connect(_on_bg_desert_pressed)
	
	# Create decorative background puzzle shape floaters
	_spawn_decorations()
	
	# Hide exit button on web builds if applicable, keep it for desktop/mobile
	if OS.get_name() == "Web":
		exit_button.visible = false

func _apply_styling() -> void:
	var font = _font
	
	# Title
	title_label.add_theme_font_override("font", font)
	title_label.add_theme_font_size_override("font_size", 48)
	title_label.add_theme_color_override("font_color", Color("#2F241E"))
	
	# Subtitle
	subtitle_label.add_theme_font_override("font", font)
	subtitle_label.add_theme_font_size_override("font_size", 14)
	subtitle_label.add_theme_color_override("font_color", Color("#8C7E72"))
	
	# Footer
	footer_label.add_theme_font_override("font", font)
	footer_label.add_theme_font_size_override("font_size", 11)
	footer_label.add_theme_color_override("font_color", Color("#A5998E"))
	
	# Play Button (Premium 3D button)
	var play_style = StyleBoxFlat.new()
	play_style.bg_color = Color("#D5CCA8") # Golden green accent
	play_style.corner_radius_top_left = 18
	play_style.corner_radius_top_right = 18
	play_style.corner_radius_bottom_left = 18
	play_style.corner_radius_bottom_right = 18
	play_style.border_width_bottom = 5
	play_style.border_color = Color("#B4AA86")
	
	var play_hover = play_style.duplicate()
	play_hover.bg_color = Color("#E3DAC1")
	
	play_button.add_theme_font_override("font", font)
	play_button.add_theme_font_size_override("font_size", 24)
	play_button.add_theme_color_override("font_color", Color("#2F241E"))
	play_button.add_theme_stylebox_override("normal", play_style)
	play_button.add_theme_stylebox_override("hover", play_hover)
	play_button.add_theme_stylebox_override("pressed", play_hover)
	
	# Settings Button (Outline button)
	var settings_style = StyleBoxFlat.new()
	settings_style.bg_color = Color("#FFFDF9")
	settings_style.corner_radius_top_left = 18
	settings_style.corner_radius_top_right = 18
	settings_style.corner_radius_bottom_left = 18
	settings_style.corner_radius_bottom_right = 18
	settings_style.border_width_left = 2
	settings_style.border_width_top = 2
	settings_style.border_width_right = 2
	settings_style.border_width_bottom = 2
	settings_style.border_color = Color("#E6DFD3")
	
	var settings_hover = settings_style.duplicate()
	settings_hover.bg_color = Color("#ECE5D8")
	
	settings_button.add_theme_font_override("font", font)
	settings_button.add_theme_font_size_override("font_size", 20)
	settings_button.add_theme_color_override("font_color", Color("#2F241E"))
	settings_button.add_theme_stylebox_override("normal", settings_style)
	settings_button.add_theme_stylebox_override("hover", settings_hover)
	settings_button.add_theme_stylebox_override("pressed", settings_hover)
	
	# Exit Button (Text button)
	exit_button.add_theme_font_override("font", font)
	exit_button.add_theme_font_size_override("font_size", 18)
	exit_button.add_theme_color_override("font_color", Color("#A5998E"))
	
	var flat_style = StyleBoxEmpty.new()
	exit_button.add_theme_stylebox_override("normal", flat_style)
	exit_button.add_theme_stylebox_override("hover", flat_style)
	exit_button.add_theme_stylebox_override("pressed", flat_style)

func _spawn_decorations() -> void:
	# Spawn 6 floating pieces in the background
	var colors = [Color("#D5CCA8", 0.15), Color("#E6DFD3", 0.4), Color("#ECE5D8", 0.35), Color("#E3DAC1", 0.2)]
	var sizes = [Vector2(120, 80), Vector2(100, 100), Vector2(60, 120), Vector2(80, 80)]
	
	for i in range(6):
		var p = Panel.new()
		p.size = sizes[i % sizes.size()]
		p.position = Vector2(randf_range(50, 670), randf_range(50, 1200))
		p.pivot_offset = p.size / 2.0
		
		var style = StyleBoxFlat.new()
		style.bg_color = colors[i % colors.size()]
		style.corner_radius_top_left = 20
		style.corner_radius_top_right = 20
		style.corner_radius_bottom_left = 20
		style.corner_radius_bottom_right = 20
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = Color("#FFFDF9", 0.5)
		
		p.add_theme_stylebox_override("panel", style)
		decorations.add_child(p)
		
		# Store floater info
		floaters.append({
			"panel": p,
			"rot_speed": randf_range(-0.2, 0.2),
			"vel": Vector2(randf_range(-15, 15), randf_range(-15, 15))
		})

func _process(delta: float) -> void:
	# Update decorative floater positions
	for f in floaters:
		var p = f["panel"]
		p.position += f["vel"] * delta
		p.rotation += f["rot_speed"] * delta
		
		# Screen wrap floaters
		if p.position.x < -150: p.position.x = 870
		elif p.position.x > 870: p.position.x = -150
		
		if p.position.y < -150: p.position.y = 1430
		elif p.position.y > 1430: p.position.y = -150

func _on_play_pressed() -> void:
	sound.play_click()
	get_tree().change_scene_to_file("res://scenes/level_selector.tscn")

func _on_settings_pressed() -> void:
	sound.play_click()
	get_tree().change_scene_to_file("res://scenes/settings_menu.tscn")

func _on_daily_pressed() -> void:
	# Compute a deterministic seed based on current day
	var day_seconds = 86400
	var unix_time = OS.get_unix_time()
	global.daily_challenge_seed = int(unix_time / day_seconds)
	# Choose a level based on seed
	var level_count = LevelData.levels.size()
	global.current_level = global.daily_challenge_seed % level_count
	# Go straight to the game scene (skip selector for daily)
	var main_scene = preload("res://scenes/main.tscn")
	get_tree().change_scene_to_packed(main_scene)

func _on_mode_selected(index: int) -> void:
	var mode_text = mode_selector.get_item_text(index)
	global.current_mode = mode_text
	# Optionally hide timer UI in main based on mode – handled in main.gd

func _apply_background(color: Color) -> void:
	$Background.color = color

func _on_bg_forest_pressed() -> void:
	global.current_background = "Forest"
	_apply_background(Color("#A8D5BA"))

func _on_bg_ocean_pressed() -> void:
	global.current_background = "Ocean"
	_apply_background(Color("#7FA8C8"))

func _on_bg_desert_pressed() -> void:
	global.current_background = "Desert"
	_apply_background(Color("#D2B48C"))
