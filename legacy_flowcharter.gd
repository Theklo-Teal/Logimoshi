extends ColorRect

@export var style_theme := FlowchartStyle.new()

@onready var Cam : Camera2D = $"../Cam"
const MIN_ZOOM = 0.2
const MAX_ZOOM = 3.0

var tween : Tween

var is_dragging : bool
var drag_start : Vector2
var cam_start : Vector2
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.is_echo():
		if tween != null and tween.is_running():
			tween.kill()  # Cancel any camera animation that might be going on.
		match event.button_index:
			MOUSE_BUTTON_MIDDLE:  # Pan the view
				if event.is_pressed():
					drag_start = event.global_position
					cam_start = Cam.position
					is_dragging = true
				else:
					is_dragging = false
			MOUSE_BUTTON_RIGHT:  # Open Radial Menu
				pass
			MOUSE_BUTTON_WHEEL_UP:  # Zoom in
				rezoom(get_work_zoom() - 0.01)
			MOUSE_BUTTON_WHEEL_DOWN:  # Zoom out
				rezoom(get_work_zoom() + 0.01)
	
	if event is InputEventMouseMotion:
		if is_dragging:
			var drag_vector = drag_start - event.global_position
			Cam.position = cam_start + drag_vector / get_work_zoom()
			queue_redraw()
		
		var coord = get_work_coord() + event.position
		coord = coord.snappedf(0.1)
		var sep = [" :: ", " || "][int(is_dragging)]
		G.cam_ctrl.get_node("%mouse_pos").text = str(coord.x).pad_decimals(1) + sep + str(coord.y).pad_decimals(1)


func _draw() -> void:
	var style = style_theme
	
	if color != style.backdrop:
		color = style.backdrop
	
	# Offset of the geometry due camera transformations
	var curr_zoom = get_work_zoom()
	var pan_coord = get_work_coord()
	var offset : Vector2
	offset.x = -fmod(pan_coord.x, style.nominal_cell_size * curr_zoom)
	offset.y = -fmod(pan_coord.y, style.nominal_cell_size * curr_zoom)
	
	# Figure out what line thickness to use.
	var line_thick = style.nominal_thickness * curr_zoom
	var axis_thick = line_thick * 1.5
	if line_thick <= 1:
		line_thick = -1
	if axis_thick <= 1:
		axis_thick = -1
	
	# Draw vertical lines
	var width_span : float = 0
	while width_span <= size.x + style.nominal_cell_size * curr_zoom:
		var start = Vector2( width_span + offset.x, 0)
		var stop = Vector2( width_span + offset.x, size.y)
		draw_line( start, stop, style.grid_color, line_thick )
		width_span += style.nominal_cell_size * curr_zoom
	
	# Draw horizontal lines
	var height_span : float = 0
	while height_span <= size.y + style.nominal_cell_size * curr_zoom:
		var start = Vector2( 0, height_span + offset.y)
		var stop = Vector2( size.x, height_span + offset.y)
		draw_line( start, stop, style.grid_color, line_thick )
		height_span += style.nominal_cell_size * curr_zoom
	
	# Draw squares indicating origin of graph
	if pan_coord.y <= size.y or pan_coord.x <= size.x:
		var stop = Vector2.ONE * style.nominal_cell_size * curr_zoom  # Rect size, actually
		var start = -stop - pan_coord
		draw_rect(Rect2(start, stop), style.grid_color)
		draw_rect(Rect2(-pan_coord, stop), style.grid_color)
	
	# Draw vertical graph axis
	if pan_coord.x <= size.x:
		var start = Vector2( -pan_coord.x , 0)
		var stop = Vector2( -pan_coord.x , size.y)
		draw_line(start, stop, style.axis_color, axis_thick)
	
	# Draw horizontal graph axis
	if pan_coord.y <= size.y:
		var start = Vector2(0,  -pan_coord.y )
		var stop = Vector2(size.x, -pan_coord.y )
		draw_line(start, stop, style.axis_color, axis_thick)


#regions Helper Functions
func get_work_coord(offset:=Vector2.ZERO) -> Vector2:
	return (Cam.position + offset) * get_work_zoom() - get_rect().get_center()

func get_work_zoom() -> float:
	return Cam.zoom.x

func rezoom(new_val:float):
	var new_zoom = clamp( new_val, MIN_ZOOM, MAX_ZOOM )
	Cam.zoom = Vector2.ONE * new_zoom
	queue_redraw()
	G.cam_ctrl.get_node("%reset_zoom").text = str(roundi(new_zoom * 100)) + "%"

func goto_grid_coord(where:Vector2):
	var period = where.distance_squared_to(Cam.position) * 0.0000005
	tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(Cam, "position", -where, period).from_current()
	#FIXME Allow the grid to also smoothly translate
	await tween.finished
	queue_redraw()
	
#region
