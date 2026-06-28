extends Control

@onready var back_button: Button = $Header/BackButton
@onready var title_label: Label = $Header/Title
@onready var sound_toggle: Button = $OptionsBox/SoundToggle
@onready var music_toggle: Button = $OptionsBox/MusicToggle
@onready var reset_button: Button = $OptionsBox/ResetButton

# Shared font — created once to avoid null font descriptor crashes
var _font: SystemFont = null

# Overlay nodes
@onready var confirmation_overlay: Control = $ConfirmationOverlay
@onready var confirm_dialog: Panel = $ConfirmationOverlay/ConfirmDialog
@onready var confirm_text: Label = $ConfirmationOverlay/ConfirmDialog/ConfirmText
@onready var yes_button: Button = $ConfirmationOverlay/ConfirmDialog/YesButton
@onready var no_button: Button = $ConfirmationOverlay/ConfirmDialog/NoButton

func _ready() -> void:
	# Create font once and keep a reference so it doesn't get GC'd
	_font = SystemFont.new()
	_font.font_names = PackedStringArray(["Sans-Serif", "Arial"])
	_font.font_weight = 700
	
	_apply_styling()
	_apply_selected_background()
	_update_toggle_buttons()
	
	# Connect signals
	back_button.pressed.connect(_on_back_pressed)
	sound_toggle.pressed.connect(_on_sound_toggle_pressed)
	music_toggle.pressed.connect(_on_music_toggle_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	yes_button.pressed.connect(_on_yes_pressed)
	no_button.pressed.connect(_on_no_pressed)
	
	confirmation_overlay.visible = false

func _apply_styling() -> void:
	var font = _font
	var text_color = Color("#2F241E")
	var text_mute = Color("#7A6758")
	var surface = Color("#FFF7F0")
	var border = Color("#D6C2A9")
	var danger = Color("#D96B6B")
	
	title_label.add_theme_font_override("font", font)
	title_label.add_theme_font_size_override("font_size", 34)
	title_label.add_theme_color_override("font_color", text_color)
	
	var UI = preload("res://scripts/ui_style.gd")
	
	back_button.custom_minimum_size = Vector2(0, 70)
	sound_toggle.custom_minimum_size = Vector2(0, 76)
	music_toggle.custom_minimum_size = Vector2(0, 76)
	reset_button.custom_minimum_size = Vector2(0, 76)
	
	back_button.custom_minimum_size = Vector2(0, 70)
	UIStyle.style_button(back_button, surface, text_color, border, 22, 20)
	sound_toggle.custom_minimum_size = Vector2(0, 76)
	UIStyle.style_button(sound_toggle, Color("#D5CCA8") if global.sound_enabled else Color("#ECE5D8"), text_color, border, 20, 20)
	music_toggle.custom_minimum_size = Vector2(0, 76)
	UIStyle.style_button(music_toggle, Color("#D5CCA8") if global.music_enabled else Color("#ECE5D8"), text_color, border, 20, 20)
	reset_button.custom_minimum_size = Vector2(0, 76)
	UIStyle.style_button(reset_button, danger, Color("#FFFDF9"), danger.darkened(0.12), 18, 18)
	
	# Confirmation dialog styling
	var dialog_style = StyleBoxFlat.new()
	dialog_style.bg_color = surface
	dialog_style.set_corner_radius_all(26)
	dialog_style.border_width_left = 2
	dialog_style.border_width_top = 2
	dialog_style.border_width_right = 2
	dialog_style.border_width_bottom = 2
	dialog_style.border_color = border
	confirm_dialog.add_theme_stylebox_override("panel", dialog_style)
	
	confirm_text.add_theme_font_override("font", font)
	confirm_text.add_theme_font_size_override("font_size", 18)
	confirm_text.add_theme_color_override("font_color", text_color)
	
	# Yes/No style
	yes_button.add_theme_font_override("font", font)
	yes_button.add_theme_font_size_override("font_size", 18)
	UIStyle.style_button(yes_button, danger, Color("#FFFDF9"), danger.darkened(0.12), 18, 16)

	no_button.add_theme_font_override("font", font)
	no_button.add_theme_font_size_override("font_size", 18)
	UIStyle.style_button(no_button, surface, text_color, border, 18, 16)

func _update_toggle_buttons() -> void:
	var font = _font
	
	# Sound Toggle
	sound_toggle.text = "SOUND EFFECTS: " + ("ON" if global.sound_enabled else "OFF")
	var sound_style = StyleBoxFlat.new()
	sound_style.bg_color = Color("#D5CCA8") if global.sound_enabled else Color("#ECE5D8")
	sound_style.corner_radius_top_left = 18
	sound_style.corner_radius_top_right = 18
	sound_style.corner_radius_bottom_left = 18
	sound_style.corner_radius_bottom_right = 18
	sound_style.border_width_bottom = 4
	sound_style.border_color = Color("#B4AA86") if global.sound_enabled else Color("#C5BBAA")
	
	sound_toggle.add_theme_font_override("font", font)
	sound_toggle.add_theme_font_size_override("font_size", 20)
	sound_toggle.add_theme_color_override("font_color", Color("#2F241E"))
	sound_toggle.add_theme_stylebox_override("normal", sound_style)
	sound_toggle.add_theme_stylebox_override("hover", sound_style)
	sound_toggle.add_theme_stylebox_override("pressed", sound_style)
	
	# Music Toggle
	music_toggle.text = "MUSIC: " + ("ON" if global.music_enabled else "OFF")
	var music_style = StyleBoxFlat.new()
	music_style.bg_color = Color("#D5CCA8") if global.music_enabled else Color("#ECE5D8")
	music_style.corner_radius_top_left = 18
	music_style.corner_radius_top_right = 18
	music_style.corner_radius_bottom_left = 18
	music_style.corner_radius_bottom_right = 18
	music_style.border_width_bottom = 4
	music_style.border_color = Color("#B4AA86") if global.music_enabled else Color("#C5BBAA")
	
	music_toggle.add_theme_font_override("font", font)
	music_toggle.add_theme_font_size_override("font_size", 20)
	music_toggle.add_theme_color_override("font_color", Color("#2F241E"))
	music_toggle.add_theme_stylebox_override("normal", music_style)
	music_toggle.add_theme_stylebox_override("hover", music_style)
	music_toggle.add_theme_stylebox_override("pressed", music_style)

func _on_back_pressed() -> void:
	sound.play_click()
	get_tree().change_scene_to_file("res://scenes/home_menu.tscn")

func _on_sound_toggle_pressed() -> void:
	global.sound_enabled = not global.sound_enabled
	_update_toggle_buttons()
	sound.play_click()

func _on_music_toggle_pressed() -> void:
	global.music_enabled = not global.music_enabled
	_update_toggle_buttons()
	sound.play_click()

func _on_reset_pressed() -> void:
	sound.play_click()
	confirmation_overlay.visible = true
	# Animation slide in for dialog
	confirm_dialog.scale = Vector2(0.8, 0.8)
	var tween = create_tween()
	tween.tween_property(confirm_dialog, "scale", Vector2(1.0, 1.0), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_no_pressed() -> void:
	sound.play_click()
	confirmation_overlay.visible = false

func _on_yes_pressed() -> void:
	global.reset_progress()
	_update_toggle_buttons()
	confirmation_overlay.visible = false
	sound.play_win() # Fun celebratory sound to confirm reset!

func _apply_selected_background() -> void:
	match global.current_background:
		"Forest":
			$Background.color = Color("#A8D5BA")
		"Ocean":
			$Background.color = Color("#7FA8C8")
		"Desert":
			$Background.color = Color("#D2B48C")
		_:
			$Background.color = Color(0.964706, 0.937255, 0.898039, 1)
