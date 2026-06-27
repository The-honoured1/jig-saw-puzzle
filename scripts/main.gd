extends Control

# Scene References
var board_scene: PackedScene = preload("res://scenes/board.tscn")
var piece_scene: PackedScene = preload("res://scenes/piece.tscn")
var confetti_scene: PackedScene = preload("res://scenes/confetti.tscn")

# Node References
@onready var back_button: Button    = $Layout/Header/BackButton
@onready var level_label: Label     = $Layout/Header/LevelLabel
@onready var timer_label: Label     = $Layout/Header/TimerPanel/TimerLabel
@onready var timer_panel: PanelContainer = $Layout/Header/TimerPanel
@onready var restart_button: Button = $Layout/Header/RestartButton
@onready var board_area: Control    = $Layout/BoardArea

# Win Screen
@onready var win_screen: Control = $WinScreen
@onready var win_dialog: Panel   = $WinScreen/Dialog
@onready var win_title: Label    = $WinScreen/Dialog/Title
@onready var win_stats: Label    = $WinScreen/Dialog/StatsLabel
@onready var next_button: Button   = $WinScreen/Dialog/NextButton
@onready var replay_button: Button = $WinScreen/Dialog/ReplayButton

# Timer
@onready var game_timer: Timer = $GameTimer

# State
var current_level_idx: int = 0
var level_info: Dictionary = {}
var board: Node2D = null
var pieces: Array = []
var active_dragged_piece = null
var _active_cell_size: float = 100.0  # Stored so scatter can use it

var timer_seconds: int = 0
var timer_active: bool = false

# Shared font — created once to avoid null font descriptor crashes
var _font: SystemFont = null

func _ready() -> void:
	# Create font once and keep a reference so it doesn't get GC'd
	_font = SystemFont.new()
	_font.font_names = PackedStringArray(["Sans-Serif", "Arial"])
	_font.font_weight = 700

	_apply_premium_styling()

	back_button.pressed.connect(_on_back_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	next_button.pressed.connect(_on_next_button_pressed)
	replay_button.pressed.connect(_on_replay_button_pressed)
	game_timer.timeout.connect(_on_timer_timeout)

	current_level_idx = global.current_level
	# Ensure board_area never blocks mouse events from reaching Area2D nodes
	board_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_load_level(current_level_idx)

func _apply_premium_styling() -> void:
	var font = _font

	level_label.add_theme_font_override("font", font)
	level_label.add_theme_font_size_override("font_size", 26)
	level_label.add_theme_color_override("font_color", Color("#2F241E"))

	# Back Button
	var back_style = StyleBoxFlat.new()
	back_style.bg_color = Color("#FFFDF9")
	back_style.set_corner_radius_all(14)
	back_style.border_width_left = 2; back_style.border_width_top = 2
	back_style.border_width_right = 2; back_style.border_width_bottom = 2
	back_style.border_color = Color("#E6DFD3")
	back_button.add_theme_font_override("font", font)
	back_button.add_theme_font_size_override("font_size", 22)
	back_button.add_theme_color_override("font_color", Color("#2F241E"))
	back_button.add_theme_stylebox_override("normal", back_style)
	var back_hover = back_style.duplicate(); back_hover.bg_color = Color("#ECE5D8")
	back_button.add_theme_stylebox_override("hover", back_hover)
	back_button.add_theme_stylebox_override("pressed", back_hover)

	# Timer Panel
	var timer_style = StyleBoxFlat.new()
	timer_style.bg_color = Color("#FFFDF9")
	timer_style.set_corner_radius_all(16)
	timer_style.border_width_left = 2; timer_style.border_width_top = 2
	timer_style.border_width_right = 2; timer_style.border_width_bottom = 2
	timer_style.border_color = Color("#E6DFD3")
	timer_style.shadow_color = Color(0.18, 0.12, 0.08, 0.06)
	timer_style.shadow_size = 6
	timer_style.shadow_offset = Vector2(0, 3)
	timer_panel.add_theme_stylebox_override("panel", timer_style)
	timer_label.add_theme_font_override("font", font)
	timer_label.add_theme_font_size_override("font_size", 24)
	timer_label.add_theme_color_override("font_color", Color("#2F241E"))

	# Restart Button
	restart_button.text = "⟳"
	restart_button.add_theme_font_override("font", font)
	restart_button.add_theme_font_size_override("font_size", 32)
	restart_button.add_theme_color_override("font_color", Color("#2F241E"))
	var restart_style = StyleBoxFlat.new()
	restart_style.bg_color = Color("#FFFDF9")
	restart_style.set_corner_radius_all(14)
	restart_style.border_width_left = 2; restart_style.border_width_top = 2
	restart_style.border_width_right = 2; restart_style.border_width_bottom = 2
	restart_style.border_color = Color("#E6DFD3")
	restart_button.add_theme_stylebox_override("normal", restart_style)
	var restart_hover = restart_style.duplicate(); restart_hover.bg_color = Color("#ECE5D8")
	restart_button.add_theme_stylebox_override("hover", restart_hover)
	restart_button.add_theme_stylebox_override("pressed", restart_hover)

	# Win Dialog
	var dialog_style = StyleBoxFlat.new()
	dialog_style.bg_color = Color("#FFFDF9")
	dialog_style.set_corner_radius_all(28)
	dialog_style.border_width_left = 3; dialog_style.border_width_top = 3
	dialog_style.border_width_right = 3; dialog_style.border_width_bottom = 3
	dialog_style.border_color = Color("#D5CCA8")
	dialog_style.shadow_color = Color(0, 0, 0, 0.15)
	dialog_style.shadow_size = 20
	dialog_style.shadow_offset = Vector2(0, 10)
	win_dialog.add_theme_stylebox_override("panel", dialog_style)
	win_title.add_theme_font_override("font", font)
	win_title.add_theme_font_size_override("font_size", 30)
	win_title.add_theme_color_override("font_color", Color("#2F241E"))
	win_stats.add_theme_font_override("font", font)
	win_stats.add_theme_font_size_override("font_size", 22)
	win_stats.add_theme_color_override("font_color", Color("#6C5E53"))

	# Win buttons
	var win_btn = StyleBoxFlat.new()
	win_btn.bg_color = Color("#D5CCA8")
	win_btn.set_corner_radius_all(16)
	win_btn.border_width_bottom = 4
	win_btn.border_color = Color("#B4AA86")
	var win_btn_h = win_btn.duplicate(); win_btn_h.bg_color = Color("#E3DAC1")
	next_button.add_theme_font_override("font", font)
	next_button.add_theme_font_size_override("font_size", 20)
	next_button.add_theme_color_override("font_color", Color("#2F241E"))
	next_button.add_theme_stylebox_override("normal", win_btn)
	next_button.add_theme_stylebox_override("hover", win_btn_h)
	next_button.add_theme_stylebox_override("pressed", win_btn_h)

	var replay_btn = StyleBoxFlat.new()
	replay_btn.bg_color = Color("#FFFDF9")
	replay_btn.set_corner_radius_all(16)
	replay_btn.border_width_left = 2; replay_btn.border_width_top = 2
	replay_btn.border_width_right = 2; replay_btn.border_width_bottom = 2
	replay_btn.border_color = Color("#E6DFD3")
	var replay_btn_h = replay_btn.duplicate(); replay_btn_h.bg_color = Color("#ECE5D8")
	replay_button.add_theme_font_override("font", font)
	replay_button.add_theme_font_size_override("font_size", 18)
	replay_button.add_theme_color_override("font_color", Color("#2F241E"))
	replay_button.add_theme_stylebox_override("normal", replay_btn)
	replay_button.add_theme_stylebox_override("hover", replay_btn_h)
	replay_button.add_theme_stylebox_override("pressed", replay_btn_h)

func _load_level(idx: int) -> void:
	if idx >= LevelData.levels.size():
		idx = 0; global.current_level = 0; current_level_idx = 0

	level_info = LevelData.levels[idx]
	level_label.text = level_info.name.to_upper()
	_validate_level_definition(level_info)

	# 1. Clean up
	if board != null:
		board.queue_free(); board = null
	for p in pieces: p.queue_free()
	pieces.clear()
	active_dragged_piece = null

	# Wait for UI to settle so board_area.size is correct
	await get_tree().process_frame
	await get_tree().process_frame

	# 2. Compute cell_size to fill the board area
	var padding   = 20.0
	var avail_w   = board_area.size.x - padding * 2.0
	var avail_h   = board_area.size.y - padding * 2.0
	var cell_size = min(avail_w / float(level_info.grid_cols),
	                    avail_h / float(level_info.grid_rows))
	cell_size = clampf(cell_size, 60.0, 140.0)
	_active_cell_size = cell_size

	# 3. Load texture
	var texture = load(level_info.image_path)

	# 4. Spawn board
	board = board_scene.instantiate()
	board_area.add_child(board)
	board.setup(level_info.grid_cols, level_info.grid_rows, cell_size, texture)

	# Center the board inside board_area
	var board_w = level_info.grid_cols * cell_size
	var board_h = level_info.grid_rows * cell_size
	board.position = (board_area.size - Vector2(board_w, board_h)) / 2.0

	# 5. Spawn pieces as children of board (Node2D) — essential for Area2D input
	var board_pixel_size = Vector2(level_info.grid_cols * cell_size, level_info.grid_rows * cell_size)
	var p_defs = level_info.pieces
	for i in range(p_defs.size()):
		var p_def = p_defs[i]
		var piece = piece_scene.instantiate()
		board.add_child(piece)   # Must be Node2D child so Area2D picking works
		piece.setup(p_def.cells, p_def.solved_grid_pos, texture, cell_size, board_pixel_size)
		piece.drag_started.connect(_on_piece_drag_started)
		piece.drag_ended.connect(_on_piece_drag_ended)
		pieces.append(piece)

	# 6. Scatter pieces randomly across the board area
	_scatter_pieces()

	# 7. Timer
	timer_seconds = 0
	timer_active  = true
	_update_timer_label()
	game_timer.start(1.0)

	win_screen.visible = false

func _scatter_pieces() -> void:
	if pieces.is_empty():
		return

	# Pieces are children of board, so position is in board-local space.
	# The board spans from (0,0) to (board_w, board_h) in local coords.
	var board_w = level_info.grid_cols * _active_cell_size
	var board_h = level_info.grid_rows * _active_cell_size

	var shuffled = pieces.duplicate()
	shuffled.shuffle()
	var n = shuffled.size()
	var cols_div = ceili(sqrt(float(n)))
	var rows_div = ceili(float(n) / float(cols_div))
	var slot_w   = board_w / float(cols_div)
	var slot_h   = board_h / float(rows_div)

	for i in range(n):
		var piece = shuffled[i]
		var col      = i % cols_div
		var row      = i / cols_div
		var jitter_x = randf_range(-slot_w * 0.15, slot_w * 0.15)
		var jitter_y = randf_range(-slot_h * 0.15, slot_h * 0.15)
		# Board-local position: pieces land scattered across the grid
		piece.position = Vector2(
			slot_w * (col + 0.5) + jitter_x,
			slot_h * (row + 0.5) + jitter_y
		)
		piece.scale = Vector2(1.0, 1.0)

func _process(_delta: float) -> void:
	if active_dragged_piece != null and board != null:
		board.update_drag_highlight(active_dragged_piece, get_global_mouse_position())

func _on_piece_drag_started(piece: Node2D) -> void:
	active_dragged_piece = piece
	sound.play_click()
	# If piece was snapped, unsnap it
	if piece.snapped_grid_pos != Vector2i(-1, -1):
		board.clear_piece(piece)

func _on_piece_drag_ended(piece: Node2D) -> void:
	active_dragged_piece = null
	board.clear_highlights()

	# Try to snap to the board grid
	# We need board-local position: board is child of board_area,
	# and piece is also child of board_area, so convert via global
	var local_pos = board.to_local(piece.global_position)
	var grid_pos  = board.local_to_grid(local_pos)

	if board.can_place_piece(piece, grid_pos):
		board.place_piece(piece, grid_pos)
		sound.play_snap()
		# Bounce feedback
		var tw = create_tween()
		tw.tween_property(piece, "scale", Vector2(1.05, 1.05), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(piece, "scale", Vector2(1.0, 1.0),   0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		if board.check_victory():
			_trigger_victory()
	else:
		# Drop failed — piece stays where it is, just reset scale
		piece.release_in_place()
		sound.play_click()

func _trigger_victory() -> void:
	timer_active = false
	game_timer.stop()
	sound.play_win()

	var confetti = confetti_scene.instantiate()
	add_child(confetti)
	confetti.position = size / 2.0
	confetti.emitting = true
	confetti.finished.connect(confetti.queue_free)

	var best_time = global.level_scores.get(current_level_idx, 999999)
	if timer_seconds < best_time:
		global.level_scores[current_level_idx] = timer_seconds
		best_time = timer_seconds
	global.save_progress()

	win_stats.text = "TIME: %s\n\nBEST TIME: %s" % [_format_time(timer_seconds), _format_time(best_time)]

	if current_level_idx < LevelData.levels.size() - 1:
		next_button.visible = true
		next_button.text    = "NEXT LEVEL"
	else:
		next_button.visible = false

	win_screen.visible = true
	win_dialog.scale      = Vector2(0.3, 0.3)
	win_dialog.modulate.a = 0.0
	var tw = create_tween().set_parallel(true)
	tw.tween_property(win_dialog, "scale",      Vector2(1.0, 1.0), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(win_dialog, "modulate:a", 1.0,               0.2)

func _on_back_button_pressed() -> void:
	sound.play_click()
	get_tree().change_scene_to_file("res://scenes/level_selector.tscn")

func _on_restart_button_pressed() -> void:
	sound.play_click()
	_load_level(current_level_idx)

func _on_next_button_pressed() -> void:
	sound.play_click()
	current_level_idx += 1
	global.current_level = current_level_idx
	_load_level(current_level_idx)

func _on_replay_button_pressed() -> void:
	sound.play_click()
	_load_level(current_level_idx)

func _on_timer_timeout() -> void:
	if timer_active:
		timer_seconds += 1
		_update_timer_label()

func _update_timer_label() -> void:
	timer_label.text = _format_time(timer_seconds)

func _format_time(s: int) -> String:
	return "%d:%02d" % [s / 60, s % 60]

func _validate_level_definition(lvl: Dictionary) -> void:
	var total_cells    = 0
	var occupied_cells: Dictionary = {}
	for i in range(lvl.pieces.size()):
		var piece_def   = lvl.pieces[i]
		var solved_orig = piece_def.solved_grid_pos
		for cell in piece_def.cells:
			var target = solved_orig + cell
			if target.x < 0 or target.x >= lvl.grid_cols or target.y < 0 or target.y >= lvl.grid_rows:
				push_error("LEVEL VALIDATION: Level %d piece %d cell %s out of bounds!" % [lvl.id, i, str(target)])
			if occupied_cells.has(target):
				push_error("LEVEL VALIDATION: Level %d cell %s overlaps!" % [lvl.id, str(target)])
			occupied_cells[target] = true
			total_cells += 1
	var expected = lvl.grid_cols * lvl.grid_rows
	if total_cells != expected:
		push_warning("LEVEL VALIDATION: Level %d has %d cells but grid needs %d!" % [lvl.id, total_cells, expected])
