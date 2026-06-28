class_name UIStyle
extends Resource

# Centralized UI palette and helper functions for consistent styling

const COLOR_PRIMARY = Color("#DFAF57")
const COLOR_SECONDARY = Color("#6A8E7C")
const COLOR_SURFACE = Color("#FFF8F1")
const COLOR_BORDER = Color("#D6C2A9")
const COLOR_TEXT = Color("#2F241E")
const COLOR_MUTED = Color("#7A6758")

static func style_button(btn: Button, bg: Color, fg: Color, border_col: Color, text_size: int = 20, radius: int = 20, shadow: bool = true) -> void:
	var font = btn.get_theme_font("font") if btn.has_method("get_theme_font") else null
	var box = StyleBoxFlat.new()
	box.bg_color = bg
	box.set_corner_radius_all(radius)
	box.border_width_left = 2
	box.border_width_top = 2
	box.border_width_right = 2
	box.border_width_bottom = 2
	box.border_color = border_col
	if shadow:
		box.shadow_color = Color(0, 0, 0, 0.08)
		box.shadow_size = 10
		box.shadow_offset = Vector2(0, 4)
	var hover_box = box.duplicate()
	hover_box.bg_color = bg.lightened(0.06)
	btn.add_theme_font_override("font", btn.get_theme_font("font") if btn.has_method("get_theme_font") else null)
	btn.add_theme_font_size_override("font_size", text_size)
	btn.add_theme_color_override("font_color", fg)
	btn.add_theme_stylebox_override("normal", box)
	btn.add_theme_stylebox_override("hover", hover_box)
	btn.add_theme_stylebox_override("pressed", hover_box)
	btn.add_theme_stylebox_override("focus", box)

static func style_card(btn: Button, is_unlocked: bool = true, radius: int = 20) -> void:
	var bg = COLOR_SURFACE if is_unlocked else Color("#ECE5D8")
	var border = COLOR_BORDER
	style_button(btn, bg, COLOR_TEXT, border, 18, radius, shadow=is_unlocked)

static func style_panel(panel: Panel, bg: Color, radius: int = 18, border_col: Color = COLOR_BORDER) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = bg
	style.set_corner_radius_all(radius)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = border_col
	panel.add_theme_stylebox_override("panel", style)
