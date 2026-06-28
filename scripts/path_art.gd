extends Control

var points: PackedVector2Array = PackedVector2Array()
var line_color: Color = Color(0.4, 0.7, 0.5)
var line_width: float = 12.0
var active_index: int = -1
var active_color: Color = Color(0.95, 0.75, 0.35)
const SAMPLES_PER_SEGMENT := 12

func _ready() -> void:
	set_process(false)

func set_points(p: Array, color: Color = null, width: float = 12.0, a_idx: int = -1, a_col: Color = null) -> void:
	points = PackedVector2Array()
	for pt in p:
		points.append(Vector2(pt))
	if color != null:
		line_color = color
	if a_col != null:
		active_color = a_col
	line_width = width
	active_index = a_idx
	update()

func _draw() -> void:
	if points.size() == 0:
		return
	# Draw a soft, thick polyline with a shadow
	var shadow_col = Color(0, 0, 0, 0.08)
	var shadow_off = Vector2(0, 6)
	if points.size() >= 2:
		var smooth = _generate_smooth_points(points, SAMPLES_PER_SEGMENT)
		# draw shadow first (slightly wider)
		var _shadow_pts = PackedVector2Array()
		for _pt in smooth:
			_shadow_pts.append(_pt + shadow_off)
		draw_polyline(_shadow_pts, shadow_col, line_width + 8, true)
		# main smooth line
		draw_polyline(smooth, line_color, line_width, true)
		# draw round caps at sampled anchors
		for idx in range(points.size()):
			var sample_idx = min(idx * SAMPLES_PER_SEGMENT, smooth.size() - 1)
			var pt = smooth[sample_idx]
			draw_circle(pt, line_width * 0.5, line_color)
			if idx == active_index:
				# soft outer glow on smoothed position
				draw_circle(pt, line_width * 1.8, Color(active_color.r, active_color.g, active_color.b, 0.14))
				draw_circle(pt, line_width * 1.2, Color(active_color.r, active_color.g, active_color.b, 0.28))
				draw_circle(pt, line_width * 0.6, active_color)


func _generate_smooth_points(pts: PackedVector2Array, samples_per_segment: int = 8) -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	var n = pts.size()
	if n < 2:
		return pts.duplicate()
	for i in range(n - 1):
		var p0 = pts[i - 1] if i - 1 >= 0 else pts[i]
		var p1 = pts[i]
		var p2 = pts[i + 1]
		var p3 = pts[i + 2] if i + 2 < n else pts[i + 1]
		for s in range(samples_per_segment):
			var t = float(s) / float(samples_per_segment)
			var t2 = t * t
			var t3 = t2 * t
			var x = 0.5 * ((2.0 * p1.x) + (-p0.x + p2.x) * t + (2.0 * p0.x - 5.0 * p1.x + 4.0 * p2.x - p3.x) * t2 + (-p0.x + 3.0 * p1.x - 3.0 * p2.x + p3.x) * t3)
			var y = 0.5 * ((2.0 * p1.y) + (-p0.y + p2.y) * t + (2.0 * p0.y - 5.0 * p1.y + 4.0 * p2.y - p3.y) * t2 + (-p0.y + 3.0 * p1.y - 3.0 * p2.y + p3.y) * t3)
			out.append(Vector2(x, y))
	# append final original point
	out.append(pts[n - 1])
	return out

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		update()
