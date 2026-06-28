extends Node2D

signal drag_started(piece)
signal drag_ended(piece)

@onready var shadow: Polygon2D = $Shadow
@onready var visual: Polygon2D = $Visual
@onready var outline: Line2D = $Outline
@onready var interaction_area: Area2D = $InteractionArea
@onready var collision_polygon: CollisionPolygon2D = $InteractionArea/CollisionPolygon

var UI = preload("res://scripts/ui_style.gd")

# Piece Properties
var cells: Array = [] # Array of Vector2i
var solved_grid_pos: Vector2i = Vector2i.ZERO
var cell_size: float = 120.0
var texture: Texture2D
var board_pixel_size: Vector2 = Vector2(600, 600)  # full board size in pixels

# Drag state
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var snapped_grid_pos: Vector2i = Vector2i(-1, -1)

# Bevel configuration
const CORNER_RADIUS_PCT: float = 0.18
const ARC_POINTS: int = 7

func setup(p_cells: Array, p_solved_grid_pos: Vector2i, p_texture: Texture2D, p_cell_size: float, p_board_pixel_size: Vector2) -> void:
	cells           = p_cells
	solved_grid_pos = p_solved_grid_pos
	texture         = p_texture
	cell_size       = p_cell_size
	board_pixel_size = p_board_pixel_size
	z_index = 5  # Always above board's grid-cell Panels
	_generate_piece_geometry()

func _generate_piece_geometry() -> void:
	if cells.is_empty():
		return

	# 1. Collect all directed boundary edges
	var edges: Array = []
	for cell in cells:
		var cx = cell.x
		var cy = cell.y
		edges.append([Vector2i(cx, cy),     Vector2i(cx + 1, cy)])
		edges.append([Vector2i(cx + 1, cy), Vector2i(cx + 1, cy + 1)])
		edges.append([Vector2i(cx + 1, cy + 1), Vector2i(cx, cy + 1)])
		edges.append([Vector2i(cx, cy + 1), Vector2i(cx, cy)])

	# 2. Remove internal (shared) edges
	var boundary_edges: Array = []
	for edge in edges:
		var s = edge[0]; var e = edge[1]
		var internal = false
		for other in edges:
			if other[0] == e and other[1] == s:
				internal = true; break
		if not internal:
			boundary_edges.append(edge)

	# 3. Chain into ordered vertex list
	var raw_verts: Array[Vector2] = []
	if boundary_edges.is_empty():
		return
	var cur_edge = boundary_edges[0]
	raw_verts.append(Vector2(cur_edge[0]) * cell_size)
	var start_pt = cur_edge[0]
	var cur_pt   = cur_edge[1]
	boundary_edges.remove_at(0)
	while cur_pt != start_pt and not boundary_edges.is_empty():
		raw_verts.append(Vector2(cur_pt) * cell_size)
		var found = false
		for i in range(boundary_edges.size()):
			if boundary_edges[i][0] == cur_pt:
				cur_pt = boundary_edges[i][1]
				boundary_edges.remove_at(i)
				found = true; break
		if not found: break

	# 4. Strip collinear vertices
	var verts: Array[Vector2] = []
	var n = raw_verts.size()
	for i in range(n):
		var prev = raw_verts[(i - 1 + n) % n]
		var curr = raw_verts[i]
		var next = raw_verts[(i + 1) % n]
		if abs((curr - prev).cross(next - curr)) > 0.1:
			verts.append(curr)

	# 5. Round corners with arc bevel
	var rounded: PackedVector2Array = PackedVector2Array()
	var nv = verts.size()
	var r = cell_size * CORNER_RADIUS_PCT
	for i in range(nv):
		var prev = verts[(i - 1 + nv) % nv]
		var curr = verts[i]
		var next = verts[(i + 1) % nv]
		var d_in  = (curr - prev).normalized()
		var d_out = (next - curr).normalized()
		var c = curr - d_in * r + d_out * r
		var a0 = (-d_out).angle()
		var a1 = d_in.angle()
		for j in range(ARC_POINTS):
			var t = float(j) / (ARC_POINTS - 1)
			var a = lerp_angle(a0, a1, t)
			rounded.append(c + Vector2(cos(a), sin(a)) * r)

	# 6. Apply polygon to nodes
	visual.polygon   = rounded
	shadow.polygon   = rounded
	var outline_pts  = rounded.duplicate()
	outline_pts.append(rounded[0])
	outline.points   = outline_pts
	collision_polygon.polygon = rounded

	# 7. UV mapping: map the entire board (0,0)→board_pixel_size to UV (0,0)→(1,1) in texture space
	# This ensures the full level image is spread across the full grid.
	var uv: PackedVector2Array = PackedVector2Array()
	var origin = Vector2(solved_grid_pos) * cell_size
	var tex_size = texture.get_size() if texture != null else board_pixel_size
	for pt in rounded:
		uv.append(((origin + pt) / board_pixel_size) * tex_size)
	visual.uv      = uv
	visual.texture = texture

func _ready() -> void:
	interaction_area.input_event.connect(_on_input_event)
	interaction_area.mouse_entered.connect(_on_mouse_entered)
	interaction_area.mouse_exited.connect(_on_mouse_exited)
	shadow.color = Color(0, 0, 0, 0.28)
	outline.default_color = UIStyle.COLOR_TEXT
	outline.width = 10.0

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not is_dragging:
			_start_dragging()
	elif event is InputEventScreenTouch:
		if event.pressed and not is_dragging:
			_start_dragging()

func _start_dragging() -> void:
	is_dragging  = true
	drag_offset  = global_position - get_global_mouse_position()
	z_index      = 100
	var tw = create_tween().set_parallel(true)
	tw.tween_property(self,   "scale",          Vector2(1.1, 1.1), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(shadow, "offset",         Vector2(0, 28),    0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(shadow, "color:a",        0.35,              0.12)
	drag_started.emit(self)

func _stop_dragging() -> void:
	if not is_dragging:
		return
	is_dragging = false
	z_index     = 10
	var tw = create_tween().set_parallel(true)
	tw.tween_property(shadow, "offset", Vector2(0, 10), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(shadow, "color:a", 0.20,          0.12)
	drag_ended.emit(self)

func _input(event: InputEvent) -> void:
	if is_dragging:
		if event is InputEventMouseMotion or event is InputEventScreenDrag:
			global_position = get_global_mouse_position() + drag_offset
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_stop_dragging()
		elif event is InputEventScreenTouch and not event.pressed:
			_stop_dragging()

# Called when piece snaps to correct grid position
func snap_to(target_pos: Vector2) -> void:
	var tw = create_tween().set_parallel(true)
	tw.tween_property(self, "global_position", target_pos,     0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale",           Vector2(1, 1),  0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# Called when piece drop fails — just reset scale, stay in place
func release_in_place() -> void:
	var tw = create_tween().set_parallel(true)
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_mouse_entered() -> void:
	if not is_dragging:
		create_tween().tween_property(self, "scale", Vector2(1.06, 1.06), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_mouse_exited() -> void:
	if not is_dragging:
		create_tween().tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
