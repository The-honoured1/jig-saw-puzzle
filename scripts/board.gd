extends Node2D

var cols: int = 5
var rows: int = 5
var cell_size: float = 120.0

# Tracks which piece occupies which cell: Vector2i -> Piece (or null)
var grid_cells: Dictionary = {}

@onready var cells_container: Node2D = $CellsContainer
@onready var highlights_container: Node2D = $HighlightsContainer

# Ghost reference image (faint solved-state preview)
var ghost_image: Sprite2D = null

func setup(p_cols: int, p_rows: int, p_cell_size: float, p_texture: Texture2D = null) -> void:
	cols = p_cols
	rows = p_rows
	cell_size = p_cell_size
	grid_cells.clear()
	
	# Clear old children
	for child in cells_container.get_children():
		child.queue_free()
	for child in highlights_container.get_children():
		child.queue_free()
	
	# Add ghost preview image (very faint) so player can see the target layout
	if ghost_image == null:
		ghost_image = Sprite2D.new()
		ghost_image.centered = false
		ghost_image.modulate = Color(1, 1, 1, 0.22)
		ghost_image.z_index = -1
		add_child(ghost_image)
		move_child(ghost_image, 0)
	
	if p_texture != null:
		ghost_image.texture = p_texture
		# Scale sprite to fit the board exactly
		var board_size = Vector2(p_cols * p_cell_size, p_rows * p_cell_size)
		var tex_size = p_texture.get_size()
		ghost_image.scale = board_size / tex_size
	ghost_image.position = Vector2.ZERO
	
	# Draw background grid cells
	for r in range(rows):
		for c in range(cols):
			grid_cells[Vector2i(c, r)] = null
			
			var cell_panel = Panel.new()
			cell_panel.size = Vector2(cell_size - 6, cell_size - 6)
			cell_panel.position = Vector2(c * cell_size + 3, r * cell_size + 3)
			
			var style = StyleBoxFlat.new()
		style.bg_color = Color(0.92, 0.88, 0.82, 0.68) # Warm translucent slot
		style.corner_radius_top_left = 18
		style.corner_radius_top_right = 18
		style.corner_radius_bottom_left = 18
		style.corner_radius_bottom_right = 18
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = Color(0.72, 0.66, 0.58, 0.55)
		style.shadow_color = Color(0, 0, 0, 0.06)
		style.shadow_size = 10
		style.shadow_offset = Vector2(0, 4)
			cells_container.add_child(cell_panel)

func local_to_grid(local_pos: Vector2) -> Vector2i:
	var gx = roundi(local_pos.x / cell_size)
	var gy = roundi(local_pos.y / cell_size)
	return Vector2i(gx, gy)

func grid_to_local(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos) * cell_size

func is_within_bounds(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < cols and grid_pos.y >= 0 and grid_pos.y < rows

func can_place_piece(piece, target_grid_pos: Vector2i) -> bool:
	for cell in piece.cells:
		var board_cell = target_grid_pos + cell
		if not is_within_bounds(board_cell):
			return false
		# The cell must either be empty or occupied by this piece itself
		var occupying_piece = grid_cells.get(board_cell)
		if occupying_piece != null and occupying_piece != piece:
			return false
	return true

func place_piece(piece, target_grid_pos: Vector2i) -> void:
	clear_piece(piece) # Clear previous placement if any
	
	piece.snapped_grid_pos = target_grid_pos
	for cell in piece.cells:
		var board_cell = target_grid_pos + cell
		grid_cells[board_cell] = piece
		
	# Snap the piece visually
	var target_local = grid_to_local(target_grid_pos)
	piece.snap_to(to_global(target_local))

func clear_piece(piece) -> void:
	for key in grid_cells.keys():
		if grid_cells[key] == piece:
			grid_cells[key] = null
	piece.snapped_grid_pos = Vector2i(-1, -1)

func clear_highlights() -> void:
	for child in highlights_container.get_children():
		child.queue_free()

func update_drag_highlight(piece, drag_global_pos: Vector2) -> void:
	clear_highlights()
	
	var local_drag = to_local(drag_global_pos)
	var grid_pos = local_to_grid(local_drag)
	
	# Determine if placing is valid
	var is_valid = can_place_piece(piece, grid_pos)
	
	# We draw highlights for each cell of the piece
	for cell in piece.cells:
		var cell_pos = grid_pos + cell
		if is_within_bounds(cell_pos):
			var hl = Panel.new()
			hl.size = Vector2(cell_size - 8, cell_size - 8)
			hl.position = Vector2(cell_pos.x * cell_size + 4, cell_pos.y * cell_size + 4)
			
			var style = StyleBoxFlat.new()
			if is_valid:
				style.bg_color = Color(0.46, 0.76, 0.47, 0.3) # Soft green overlay
				style.border_color = Color(0.46, 0.76, 0.47, 0.8)
			else:
				style.bg_color = Color(0.86, 0.44, 0.44, 0.3) # Soft red overlay
				style.border_color = Color(0.86, 0.44, 0.44, 0.8)
				
			style.border_width_left = 3
			style.border_width_top = 3
			style.border_width_right = 3
			style.border_width_bottom = 3
			style.corner_radius_top_left = 16
			style.corner_radius_top_right = 16
			style.corner_radius_bottom_left = 16
			style.corner_radius_bottom_right = 16
			
			hl.add_theme_stylebox_override("panel", style)
			highlights_container.add_child(hl)

func check_victory() -> bool:
	# The board is solved if every single grid cell is occupied by some piece
	for key in grid_cells.keys():
		if grid_cells[key] == null:
			return false
	return true
