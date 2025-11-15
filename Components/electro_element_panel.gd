extends Control

@export var panel_style : StyleBox = preload("res://Themes/electro_panel_style.tres")

func _draw():
	var cell_size = get_parent().cell_size()
	var rect = Rect2(
		Vector2.ONE * cell_size *0.5,
		size - Vector2.ONE * cell_size
	)
	draw_style_box(panel_style, rect)
