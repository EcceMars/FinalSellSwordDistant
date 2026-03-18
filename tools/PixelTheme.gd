class_name PixelTheme
extends RefCounted

## Creates a pixel-perfect theme optimized for small fonts
static func create()->Theme:
	var theme:Theme = Theme.new()
	
	# PanelContainer styling - subtle, non-intrusive background
	var panel_style:StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.12, 0.4)  # Dark semi-transparent
	panel_style.border_color = Color(0.3, 0.3, 0.35, 0.3)
	panel_style.set_border_width_all(1)
	panel_style.set_content_margin_all(2)
	panel_style.corner_radius_top_left = 2
	panel_style.corner_radius_top_right = 2
	panel_style.corner_radius_bottom_left = 2
	panel_style.corner_radius_bottom_right = 2
	theme.set_stylebox("panel", "PanelContainer", panel_style)
	
	# Label styling - crisp pixel fonts
	theme.set_color("font_color", "Label", Color.WHITE)
	theme.set_color("font_outline_color", "Label", Color.BLACK)
	theme.set_constant("outline_size", "Label", 1)  # Outline for readability
	theme.set_constant("shadow_offset_x", "Label", 0)
	theme.set_constant("shadow_offset_y", "Label", 0)
	
	# VBoxContainer spacing
	theme.set_constant("separation", "VBoxContainer", 1)
	
	return theme
