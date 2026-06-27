extends Control

@onready var back_button: Button = $Header/BackButton
@onready var title_label: Label = $Header/Title
@onready var grid_container: GridContainer = $ScrollContainer/GridContainer
@onready var scroll_container: ScrollContainer = $ScrollContainer

# Shared font — created once to avoid null font descriptor crashes
var _font: SystemFont = null

func _ready() -> void:
	# Create font once and keep a reference so it doesn't get GC'd
	_font = SystemFont.new()
	_font.font_names = PackedStringArray(["Sans-Serif", "Arial"])
	_font.font_weight = 700
	
	_apply_styling()
	_populate_level_grid()
	
	back_button.pressed.connect(_on_back_pressed)

func _apply_styling() -> void:
	var font = _font
	
	title_label.add_theme_font_override("font", font)
	title_label.add_theme_font_size_override("font_size", 30)
	title_label.add_theme_color_override("font_color", Color("#2F241E"))
	
	# Back Button style
	var back_style = StyleBoxFlat.new()
	back_style.bg_color = Color("#FFFDF9")
	back_style.corner_radius_top_left = 14
	back_style.corner_radius_top_right = 14
	back_style.corner_radius_bottom_left = 14
	back_style.corner_radius_bottom_right = 14
	back_style.border_width_left = 2
	back_style.border_width_top = 2
	back_style.border_width_right = 2
	back_style.border_width_bottom = 2
	back_style.border_color = Color("#E6DFD3")
	back_button.add_theme_font_override("font", font)
	back_button.add_theme_font_size_override("font_size", 22)
	back_button.add_theme_color_override("font_color", Color("#2F241E"))
	back_button.add_theme_stylebox_override("normal", back_style)
	
	var back_hover = back_style.duplicate()
	back_hover.bg_color = Color("#ECE5D8")
	back_button.add_theme_stylebox_override("hover", back_hover)
	back_button.add_theme_stylebox_override("pressed", back_hover)
	
	# Stylize grid column structure dynamically for mobile portrait layout
	grid_container.columns = 2

func _populate_level_grid() -> void:
	var font = _font
	
	# Clear previous cards
	for child in grid_container.get_children():
		child.queue_free()
		
	var levels = LevelData.levels
	for i in range(levels.size()):
		var lvl = levels[i]
		var is_unlocked = global.is_level_unlocked(i)
		
		# 1. Create Card Button
		var card_btn = Button.new()
		card_btn.custom_minimum_size = Vector2(270, 310)
		card_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid_container.add_child(card_btn)
		
		# Card styling
		var card_style = StyleBoxFlat.new()
		card_style.bg_color = Color("#FFFDF9")
		card_style.corner_radius_top_left = 22
		card_style.corner_radius_top_right = 22
		card_style.corner_radius_bottom_left = 22
		card_style.corner_radius_bottom_right = 22
		card_style.border_width_left = 2
		card_style.border_width_top = 2
		card_style.border_width_right = 2
		card_style.border_width_bottom = 2
		card_style.border_color = Color("#E6DFD3")
		
		if is_unlocked:
			card_style.shadow_color = Color(0.2, 0.15, 0.1, 0.04)
			card_style.shadow_size = 6
			card_style.shadow_offset = Vector2(0, 3)
		else:
			card_style.bg_color = Color("#ECE5D8") # Grayed out background for locked
			
		card_btn.add_theme_stylebox_override("normal", card_style)
		
		var card_hover = card_style.duplicate()
		if is_unlocked:
			card_hover.bg_color = Color("#FFFDF9").darkened(0.02)
			card_btn.add_theme_stylebox_override("hover", card_hover)
			card_btn.add_theme_stylebox_override("pressed", card_hover)
		
		# 2. Add layout container inside Card
		var margin_container = MarginContainer.new()
		margin_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		margin_container.add_theme_constant_override("margin_left", 14)
		margin_container.add_theme_constant_override("margin_top", 14)
		margin_container.add_theme_constant_override("margin_right", 14)
		margin_container.add_theme_constant_override("margin_bottom", 14)
		margin_container.mouse_filter = Control.MOUSE_FILTER_PASS
		card_btn.add_child(margin_container)
		
		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 10)
		vbox.mouse_filter = Control.MOUSE_FILTER_PASS
		margin_container.add_child(vbox)
		
		# 3. Card Title (e.g. LEVEL 1)
		var lvl_title = Label.new()
		lvl_title.text = "LEVEL %d" % (i + 1)
		lvl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lvl_title.add_theme_font_override("font", font)
		lvl_title.add_theme_font_size_override("font_size", 16)
		lvl_title.add_theme_color_override("font_color", Color("#8C7E72") if is_unlocked else Color("#A5998E"))
		vbox.add_child(lvl_title)
		
		# 4. Level Thumbnail or Lock Illustration
		var img_rect = TextureRect.new()
		img_rect.custom_minimum_size = Vector2(200, 140)
		img_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
		img_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		vbox.add_child(img_rect)
		
		# Thumbnail styling (rounded image borders)
		var img_panel = Panel.new()
		img_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		img_panel.mouse_filter = Control.MOUSE_FILTER_PASS
		var img_style = StyleBoxFlat.new()
		img_style.corner_radius_top_left = 12
		img_style.corner_radius_top_right = 12
		img_style.corner_radius_bottom_left = 12
		img_style.corner_radius_bottom_right = 12
		img_style.draw_center = false
		img_style.border_width_left = 1
		img_style.border_width_top = 1
		img_style.border_width_right = 1
		img_style.border_width_bottom = 1
		img_style.border_color = Color("#E6DFD3")
		img_panel.add_theme_stylebox_override("panel", img_style)
		img_rect.add_child(img_panel)
		
		if is_unlocked:
			img_rect.texture = load(lvl.image_path)
		else:
			# Draw Lock procedurally
			img_rect.texture = null
			var lock_label = Label.new()
			lock_label.text = "🔒"
			lock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lock_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lock_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			lock_label.add_theme_font_size_override("font_size", 42)
			img_rect.add_child(lock_label)
			
			# Give lock area a darker panel bg
			var lock_bg = Panel.new()
			lock_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			lock_bg.mouse_filter = Control.MOUSE_FILTER_PASS
			var lock_style = StyleBoxFlat.new()
			lock_style.bg_color = Color(0.2, 0.15, 0.1, 0.08)
			lock_style.corner_radius_top_left = 12
			lock_style.corner_radius_top_right = 12
			lock_style.corner_radius_bottom_left = 12
			lock_style.corner_radius_bottom_right = 12
			lock_bg.add_theme_stylebox_override("panel", lock_style)
			img_rect.add_child(lock_bg)
			img_rect.move_child(lock_bg, 0)
			
		# 5. Level Name (e.g. Farm Cows)
		var lvl_name = Label.new()
		lvl_name.text = lvl.name.split(":")[1].strip_edges()
		lvl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lvl_name.add_theme_font_override("font", font)
		lvl_name.add_theme_font_size_override("font_size", 14)
		lvl_name.add_theme_color_override("font_color", Color("#2F241E") if is_unlocked else Color("#A5998E"))
		vbox.add_child(lvl_name)
		
		# 6. Level Stats (e.g. Best time or LOCKED status)
		var lvl_stats = Label.new()
		lvl_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lvl_stats.add_theme_font_override("font", font)
		lvl_stats.add_theme_font_size_override("font_size", 12)
		
		if global.level_scores.has(i):
			var score_sec = global.level_scores[i]
			lvl_stats.text = "★ BEST: %d:%02d" % [score_sec / 60, score_sec % 60]
			lvl_stats.add_theme_color_override("font_color", Color("#77A87A")) # Soft green for completed
		elif is_unlocked:
			lvl_stats.text = "PLAY"
			lvl_stats.add_theme_color_override("font_color", Color("#D5CCA8").darkened(0.2))
		else:
			lvl_stats.text = "LOCKED"
			lvl_stats.add_theme_color_override("font_color", Color("#A5998E"))
			
		vbox.add_child(lvl_stats)
		
		# Connect button click
		card_btn.pressed.connect(_on_card_pressed.bind(i, card_btn, is_unlocked))

func _on_card_pressed(idx: int, card: Button, is_unlocked: bool) -> void:
	if is_unlocked:
		sound.play_click()
		global.current_level = idx
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	else:
		# Play locked synth buzzer
		sound._play_synth_beep(150.0, 0.15)
		
		# Shake card animation
		var original_pos = card.position
		var shake_tween = create_tween()
		shake_tween.tween_property(card, "position:x", original_pos.x - 8, 0.05)
		shake_tween.tween_property(card, "position:x", original_pos.x + 8, 0.05)
		shake_tween.tween_property(card, "position:x", original_pos.x - 6, 0.05)
		shake_tween.tween_property(card, "position:x", original_pos.x + 6, 0.05)
		shake_tween.tween_property(card, "position:x", original_pos.x, 0.05)

func _on_back_pressed() -> void:
	sound.play_click()
	get_tree().change_scene_to_file("res://scenes/home_menu.tscn")
