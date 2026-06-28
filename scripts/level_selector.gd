extends Control

@onready var back_button: Button = $Header/BackButton
@onready var title_label: Label = $Header/Title
@onready var path_container: Control = $ScrollContainer/PathContainer
@onready var path_art: Control = $ScrollContainer/PathContainer/PathArt
@onready var scroll_container: ScrollContainer = $ScrollContainer

# Shared font — created once to avoid null font descriptor crashes
var _font: SystemFont = null

func _ready() -> void:
	# Create font once and keep a reference so it doesn't get GC'd
	_font = SystemFont.new()
	_font.font_names = PackedStringArray(["Sans-Serif", "Arial"])
	_font.font_weight = 700
	
	_apply_styling()
	_apply_selected_background()
	_populate_level_grid()
	
	back_button.pressed.connect(_on_back_pressed)

func _apply_styling() -> void:
	var font = _font
	var text_color = Color("#2F241E")
	var text_mute = Color("#7A6758")
	var surface = Color("#FFF7F0")
	var border = Color("#D6C2A9")
	
	title_label.add_theme_font_override("font", font)
	title_label.add_theme_font_size_override("font_size", 34)
	title_label.add_theme_color_override("font_color", text_color)
	
	# Back Button style
	var back_style = StyleBoxFlat.new()
	back_style.bg_color = surface
	back_style.set_corner_radius_all(18)
	back_style.border_width_left = 2
	back_style.border_width_top = 2
	back_style.border_width_right = 2
	# Path container setup — ensure comfortable spacing for the vertical path
	path_container.custom_minimum_size = Vector2(620, 1400)
	back_button.add_theme_font_override("font", font)
	back_button.add_theme_font_size_override("font_size", 22)
	back_button.add_theme_color_override("font_color", text_color)
	back_button.add_theme_stylebox_override("normal", back_style)
	
	var back_hover = back_style.duplicate()
	back_hover.bg_color = surface.lightened(0.04)
	back_button.add_theme_stylebox_override("hover", back_hover)
	back_button.add_theme_stylebox_override("pressed", back_hover)
	
	# Card styling handled dynamically during population

func _populate_level_grid() -> void:
	var font = _font

	# Clear previous cards
	for child in path_container.get_children():
		child.queue_free()

	var levels = LevelData.levels
	var total = levels.size()

	var center_x = path_container.rect_size.x / 2 if path_container.rect_size.x > 0 else 310
	var left_x = center_x - 240
	var right_x = center_x + 40
	var start_y = 40
	var v_spacing = 180

	var points: Array = []

	for i in range(total):
		var lvl = levels[i]
		var is_unlocked = global.is_level_unlocked(i)

		# Create Card Button (platform)
		var card_btn = Button.new()
		card_btn.name = "LevelCard%02d" % i
		card_btn.text = ""
		card_btn.custom_minimum_size = Vector2(260, 300)
		card_btn.mouse_filter = Control.MOUSE_FILTER_PASS
		path_container.add_child(card_btn)

		# Position in staggered zig-zag
		var px = left_x if (i % 2 == 0) else right_x
		var py = start_y + i * v_spacing
		card_btn.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		card_btn.rect_position = Vector2(px, py)

		# Card styling
		var card_style = StyleBoxFlat.new()
		card_style.bg_color = Color("#FFFDF9") if is_unlocked else Color("#ECE5D8")
		card_style.set_corner_radius_all(20)
		card_style.border_width_left = 2
		card_style.border_width_top = 2
		card_style.border_width_right = 2
		card_style.border_width_bottom = 2
		card_style.border_color = Color("#E6DFD3")
		if is_unlocked:
			card_style.shadow_color = Color(0.12, 0.08, 0.04, 0.08)
			card_style.shadow_size = 12
			card_style.shadow_offset = Vector2(0, 6)
		card_btn.add_theme_stylebox_override("normal", card_style)

		var hover_style = card_style.duplicate()
		hover_style.bg_color = card_style.bg_color.lightened(0.03)
		if is_unlocked:
			card_btn.add_theme_stylebox_override("hover", hover_style)
			card_btn.add_theme_stylebox_override("pressed", hover_style)

		# Inner layout
		var margin_container = MarginContainer.new()
		margin_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		margin_container.add_theme_constant_override("margin_left", 16)
		margin_container.add_theme_constant_override("margin_top", 16)
		margin_container.add_theme_constant_override("margin_right", 16)
		margin_container.add_theme_constant_override("margin_bottom", 16)
		card_btn.add_child(margin_container)

		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 8)
		margin_container.add_child(vbox)

		var lvl_title = Label.new()
		lvl_title.text = "LEVEL %d" % (i + 1)
		lvl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lvl_title.add_theme_font_override("font", font)
		lvl_title.add_theme_font_size_override("font_size", 16)
		lvl_title.add_theme_color_override("font_color", Color("#8C7E72") if is_unlocked else Color("#A5998E"))
		vbox.add_child(lvl_title)

		var img_rect = TextureRect.new()
		img_rect.custom_minimum_size = Vector2(220, 130)
		img_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		vbox.add_child(img_rect)

		var img_panel = Panel.new()
		img_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var img_style = StyleBoxFlat.new()
		img_style.set_corner_radius_all(12)
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
			var lock_label = Label.new()
			lock_label.text = "🔒"
			lock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lock_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lock_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			lock_label.add_theme_font_size_override("font_size", 42)
			img_rect.add_child(lock_label)

		var lvl_name = Label.new()
		lvl_name.text = lvl.name.split(":")[1].strip_edges()
		lvl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lvl_name.add_theme_font_override("font", font)
		lvl_name.add_theme_font_size_override("font_size", 14)
		lvl_name.add_theme_color_override("font_color", Color("#2F241E") if is_unlocked else Color("#A5998E"))
		vbox.add_child(lvl_name)

		var lvl_stats = Label.new()
		lvl_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lvl_stats.add_theme_font_override("font", font)
		lvl_stats.add_theme_font_size_override("font_size", 12)
		if global.level_scores.has(i):
			var score_sec = global.level_scores[i]
			lvl_stats.text = "★ BEST: %d:%02d" % [score_sec / 60, score_sec % 60]
			lvl_stats.add_theme_color_override("font_color", Color("#77A87A"))
		elif is_unlocked:
			lvl_stats.text = "PLAY"
			lvl_stats.add_theme_color_override("font_color", Color("#D5CCA8").darkened(0.2))
		else:
			lvl_stats.text = "LOCKED"
			lvl_stats.add_theme_color_override("font_color", Color("#A5998E"))
		vbox.add_child(lvl_stats)

		# Connect button
		card_btn.pressed.connect(_on_card_pressed.bind(i, card_btn, is_unlocked))

		# Draw small connecting tiles between cards
		if i < total - 1:
			var next_y = start_y + (i + 1) * v_spacing
			var steps = 3
			for s in range(steps):
				var t = float(s + 1) / (steps + 1)
				var next_px = left_x if ((i + 1) % 2 == 0) else right_x
				var step_x = lerp(px + card_btn.custom_minimum_size.x / 2, next_px + card_btn.custom_minimum_size.x / 2, t)
				var step_y = lerp(py + card_btn.custom_minimum_size.y, next_y, t) - 20
				var step_panel = Panel.new()
				step_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
				step_panel.rect_position = Vector2(step_x - 24, step_y)
				step_panel.rect_min_size = Vector2(48, 28)
				var sp_style = StyleBoxFlat.new()
				sp_style.bg_color = Color("#6F9D82") if is_unlocked else Color("#A5998E")
				sp_style.set_corner_radius_all(10)
				step_panel.add_theme_stylebox_override("panel", sp_style)
				path_container.add_child(step_panel)

		# collect center point for path art
		var cpt = Vector2(px + card_btn.custom_minimum_size.x * 0.5, py + card_btn.custom_minimum_size.y * 0.45)
		points.append(cpt)

	# Expand container to fit last card
	var total_height = start_y + total * v_spacing + 200
	path_container.custom_minimum_size = Vector2(620, total_height)

	# Draw path art using PathArt Control and highlight the active level
	var active_idx = global.current_level if global.has_method("current_level") else -1
	if path_art != null:
		path_art.set_points(points, Color("#6F9D82"), 18.0, active_idx, Color("#DFAF57"))

	# Stronger active-card styling
	if active_idx >= 0 and active_idx < total:
		var active_card_name = "LevelCard%02d" % active_idx
		var active_card = path_container.get_node_or_null(active_card_name)
		if active_card != null:
			var act_style = StyleBoxFlat.new()
			act_style.bg_color = Color("#FFF8E6")
			act_style.set_corner_radius_all(22)
			act_style.border_width_left = 4
			act_style.border_width_top = 4
			act_style.border_width_right = 4
			act_style.border_width_bottom = 4
			act_style.border_color = Color("#DFAF57")
			act_style.shadow_color = Color(0.15, 0.1, 0.04, 0.12)
			act_style.shadow_size = 18
			act_style.shadow_offset = Vector2(0, 8)
			active_card.add_theme_stylebox_override("normal", act_style)
			# ensure hover/pressed keep the active look
			active_card.add_theme_stylebox_override("hover", act_style)
			active_card.add_theme_stylebox_override("pressed", act_style)

			# Add or update an animated glow panel under the active card
			var glow_name = "ActiveGlow"
			var glow = path_container.get_node_or_null(glow_name)
			if glow == null:
				glow = Panel.new()
				glow.name = glow_name
				path_container.add_child(glow)
				path_container.move_child(glow, 0)
			# size and position slightly larger than card
			var g_size = card_btn.custom_minimum_size * 1.15
			glow.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
			glow.rect_size = g_size
			glow.rect_position = Vector2(px + card_btn.custom_minimum_size.x * 0.5 - g_size.x * 0.5, py + card_btn.custom_minimum_size.y * 0.5 - g_size.y * 0.45)
			var g_style = StyleBoxFlat.new()
			g_style.bg_color = Color("#DFAF57")
			g_style.set_corner_radius_all(int(g_size.x * 0.18))
			g_style.border_width_left = 0
			glow.add_theme_stylebox_override("panel", g_style)
			# animate glow alpha pulse
			glow.modulate = Color(1,1,1,0.0)
			var twp = create_tween()
			twp.set_trans(Tween.TRANS_SINE)
			twp.set_loops(-1)
			twp.tween_property(glow, "modulate:a", 0.36, 0.9)
			twp.tween_property(glow, "modulate:a", 0.08, 0.9)

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
