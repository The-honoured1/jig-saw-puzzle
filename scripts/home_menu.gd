extends Control

@onready var title_label: Label = $CenterContainer/LogoArea/Title
@onready var subtitle_label: Label = $CenterContainer/LogoArea/Subtitle
@onready var daily_button: Button = $CenterContainer/MenuButtons/DailyButton
@onready var play_button: Button = $CenterContainer/MenuButtons/PlayButton
@onready var mode_selector: OptionButton = $CenterContainer/MenuButtons/ModeSelector
@onready var settings_button: Button = $CenterContainer/MenuButtons/SettingsButton
@onready var exit_button: Button = $CenterContainer/MenuButtons/ExitButton
@onready var bg_forest_button: Button = $CenterContainer/MenuButtons/BackgroundSelector/BG1
@onready var bg_ocean_button: Button = $CenterContainer/MenuButtons/BackgroundSelector/BG2
@onready var bg_desert_button: Button = $CenterContainer/MenuButtons/BackgroundSelector/BG3
@onready var footer_label: Label = $Footer
@onready var decorations: Node2D = $Decorations

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
	
	# Connect ALL button signals — Play and Settings were previously missing
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	daily_button.pressed.connect(_on_daily_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	mode_selector.item_selected.connect(_on_mode_selected)
	bg_forest_button.pressed.connect(_on_bg_forest_pressed)
	bg_ocean_button.pressed.connect(_on_bg_ocean_pressed)
	bg_desert_button.pressed.connect(_on_bg_desert_pressed)
	
	# Create decorative background puzzle shape floaters
	_spawn_decorations()
	_update_background_from_settings()
	_update_mode_selector_from_settings()
	
	# Hide exit button on web builds if applicable, keep it for desktop/mobile
	if OS.get_name() == "Web":
		exit_button.visible = false

func _apply_styling() -> void:
	var font = _font
	var primary = Color("#DFAF57")
	var secondary = Color("#6A8E7C")
	var surface = Color("#FFF8F1")
	var border = Color("#D6C2A9")
	var text_color = Color("#2F241E")
	var text_mute = Color("#7A6758")
	
	# Title
	title_label.add_theme_font_override("font", font)
	title_label.add_theme_font_size_override("font_size", 56)
	title_label.add_theme_color_override("font_color", text_color)
	
	# Subtitle
	subtitle_label.add_theme_font_override("font", font)
	subtitle_label.add_theme_font_size_override("font_size", 16)
	subtitle_label.add_theme_color_override("font_color", text_mute)
	
	# Footer
	footer_label.add_theme_font_override("font", font)
	footer_label.add_theme_font_size_override("font_size", 12)
	footer_label.add_theme_color_override("font_color", text_mute)
	
	daily_button.custom_minimum_size = Vector2(0, 82)
	play_button.custom_minimum_size = Vector2(0, 90)
	settings_button.custom_minimum_size = Vector2(0, 80)
	exit_button.custom_minimum_size = Vector2(0, 62)
	mode_selector.custom_minimum_size = Vector2(0, 62)
	bg_forest_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bg_ocean_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bg_desert_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	_style_button(daily_button, secondary, Color("#FFFDF9"), border)
	_style_button(play_button, primary, text_color, border, 24)
	_style_button(settings_button, surface, text_color, border, 20)
	
	# Exit button ghost style
	exit_button.add_theme_font_override("font", font)
	exit_button.add_theme_font_size_override("font_size", 18)
	exit_button.add_theme_color_override("font_color", text_mute)
	var ghost = StyleBoxEmpty.new()
	exit_button.add_theme_stylebox_override("normal", ghost)
	exit_button.add_theme_stylebox_override("hover", ghost)
	exit_button.add_theme_stylebox_override("pressed", ghost)
	exit_button.add_theme_stylebox_override("focus", ghost)
	
	# Option selector
	var mode_style = StyleBoxFlat.new()
	mode_style.bg_color = surface
	mode_style.set_corner_radius_all(20)
	mode_style.border_width_left = 2
	mode_style.border_width_top = 2
	mode_style.border_width_right = 2
	mode_style.border_width_bottom = 2
	mode_style.border_color = border
	var mode_hover = mode_style.duplicate()
	mode_hover.bg_color = surface.lightened(0.04)
	mode_selector.add_theme_font_override("font", font)
	mode_selector.add_theme_font_size_override("font_size", 18)
	mode_selector.add_theme_color_override("font_color", text_color)
	mode_selector.add_theme_stylebox_override("normal", mode_style)
	mode_selector.add_theme_stylebox_override("hover", mode_hover)
	mode_selector.add_theme_stylebox_override("pressed", mode_hover)
	mode_selector.add_theme_stylebox_override("focus", mode_style)
	
	# Background selector pills
	var bg_labels = ["🌲 Forest", "🌊 Ocean", "🏜 Desert"]
	var bg_btns = [bg_forest_button, bg_ocean_button, bg_desert_button]
	var bg_colors = [Color("#4D7D64"), Color("#3D78A1"), Color("#A7784D")]
	var bg_hover_colors = [Color("#6F9D82"), Color("#5791C4"), Color("#C1946B")]
	for j in range(bg_btns.size()):
		var btn = bg_btns[j]
		var bg_s = StyleBoxFlat.new()
		bg_s.bg_color = bg_colors[j]
		bg_s.set_corner_radius_all(18)
		bg_s.border_width_left = 2
		bg_s.border_width_top = 2
		bg_s.border_width_right = 2
		bg_s.border_width_bottom = 2
		bg_s.border_color = bg_colors[j].darkened(0.24)
		var bg_h = bg_s.duplicate()
		bg_h.bg_color = bg_hover_colors[j]
		btn.text = bg_labels[j]
		btn.add_theme_font_override("font", font)
		btn.add_theme_font_size_override("font_size", 14)
		btn.add_theme_color_override("font_color", Color("#FFFDF9"))
		btn.add_theme_stylebox_override("normal", bg_s)
		btn.add_theme_stylebox_override("hover", bg_h)
		btn.add_theme_stylebox_override("pressed", bg_h)
		btn.add_theme_stylebox_override("focus", bg_s)
	
	# Strong background color for the scene
	$Background.color = Color("#F5E8DD")

func _style_button(btn: Button, bg: Color, fg: Color, border_col: Color, text_size: int = 20) -> void:
	var box = StyleBoxFlat.new()
	box.bg_color = bg
	box.set_corner_radius_all(22)
	box.border_width_left = 2
	box.border_width_top = 2
	box.border_width_right = 2
	box.border_width_bottom = 2
	box.border_color = border_col
	var hover_box = box.duplicate()
	hover_box.bg_color = bg.lightened(0.08)
	btn.add_theme_font_override("font", _font)
	btn.add_theme_font_size_override("font_size", text_size)
	btn.add_theme_color_override("font_color", fg)
	btn.add_theme_stylebox_override("normal", box)
	btn.add_theme_stylebox_override("hover", hover_box)
	btn.add_theme_stylebox_override("pressed", hover_box)
	btn.add_theme_stylebox_override("focus", box)

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
	var unix_time = Time.get_unix_time_from_system()
	global.daily_challenge_seed = int(unix_time / day_seconds)
	# Choose a level based on seed
	var level_count = LevelData.levels.size()
	global.current_level = global.daily_challenge_seed % level_count
	# Go straight to the game scene (skip selector for daily)
	var main_scene = preload("res://scenes/main.tscn")
	get_tree().change_scene_to_packed(main_scene)

func _on_exit_pressed() -> void:
	sound.play_click()
	get_tree().quit()

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

func _update_background_from_settings() -> void:
	match global.current_background:
		"Forest": _apply_background(Color("#A8D5BA"))
		"Ocean": _apply_background(Color("#7FA8C8"))
		"Desert": _apply_background(Color("#D2B48C"))
		_: _apply_background(Color(0.964706, 0.937255, 0.898039, 1))

func _update_mode_selector_from_settings() -> void:
	for i in range(mode_selector.item_count):
		if mode_selector.get_item_text(i) == global.current_mode:
			mode_selector.selected = i
			break
