extends Control
class_name Flowcharter

const DEFAULT_SNAP = Vector2(10,10)

@export var style : FlowchartStyle
@export var snap := DEFAULT_SNAP ## The grid constraining child element and wire position.

func _ready() -> void:
	if style == null:
		style = FlowchartStyle.new()
	$Background.color = style.backdrop

#regions Helper Functions
const MIN_ZOOM = 0.2
const MAX_ZOOM = 3.0
var tween : Tween

func get_work_coord(offset:=Vector2.ZERO) -> Vector2:
	var coord : Vector2 = (%Cam.global_position + offset)  # Camera position with optional offset
	coord *= get_work_zoom()  # Account zoom making things closer or farther together in real pixels.
	coord -= get_rect().get_center()  # Convert a top-left position to a center position as the camera's anchor_mode.
	coord += position  # Compensate for displacement of the Flowcharter depending on surrounding UI.
	return coord
	
func get_work_zoom():
	return %Cam.zoom.x

func rezoom(new_val:float):
	var new_zoom = clamp( new_val, MIN_ZOOM, MAX_ZOOM )
	%Cam.zoom = Vector2.ONE * new_zoom
	$Background.queue_redraw()
	queue_redraw()
	%reset_zoom.text = str(roundi(new_zoom * 100)) + "%"

func goto_grid_coord(where:Vector2):
	var period = 1.0
	tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(%Cam, "global_position", -where, period).from_current()
	tween.play()


## Given a coord on the canvas/screen, what is the coordinate on the workspace grid?
func to_work_coord(canvas_coord:Vector2) -> Vector2:
	var ans : Vector2 = get_work_coord()
	ans += canvas_coord
	ans /= get_work_zoom()
	return ans

## What's the coordinate on the canvas/screen, given a coordinate on the workspace grid?
func from_work_coord(grid_coord:Vector2) -> Vector2:
	var ans : Vector2 = -get_work_coord(-grid_coord)
	return ans
	
#endregion

var is_lassoing : bool
var wire_pull : bool
var is_panning : bool
var drag_start : Vector2
var drag_stop : Vector2
var cam_start  : Vector2

#func _unhandled_input(event: InputEvent) -> void:
	#if wire_pull and event is InputEventKey and event.keycode == WIRE_CHIRAL_KEY:  # Change the chirality of wire being edited.
		#loose.bend_first = event.is_pressed()
		#queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.is_echo():
		match event.button_index:
			MOUSE_BUTTON_LEFT:  # Draw wires.
				if is_panning:  # Don't allow panning and wiring at the same time.
					return
				is_lassoing = event.is_pressed()
				if event.is_pressed():
					drag_start = event.position
					$Workspace.mouse_filter = MOUSE_FILTER_IGNORE
				else:  # Clear foreground drawings
					$Workspace.mouse_filter = MOUSE_FILTER_PASS
					queue_redraw()
			MOUSE_BUTTON_MIDDLE:  # Pan Camera
				if wire_pull or is_lassoing:  # Don't allow panning and wiring at the same time.
					return
				is_panning = event.is_pressed()
				if event.is_pressed():
					drag_start = event.position
					cam_start = %Cam.global_position
			MOUSE_BUTTON_RIGHT:  # Open Radial Menu
				if is_panning or is_lassoing:
					$Workspace.mouse_filter = MOUSE_FILTER_IGNORE
					return
				else:  # Clear foreground drawings
					$Workspace.mouse_filter = MOUSE_FILTER_PASS
					queue_redraw()
			MOUSE_BUTTON_WHEEL_UP:  # Zoom in
				rezoom(get_work_zoom() + 0.005)
			MOUSE_BUTTON_WHEEL_DOWN:  # Zoom out
				rezoom(get_work_zoom() - 0.005)
	if event is InputEventMouseMotion:
		drag_stop = event.position
		if wire_pull or is_lassoing:
			queue_redraw()
		if is_panning:
			var mouse_pos : Vector2 = event.global_position
			mouse_pos.x = wrap(mouse_pos.x, global_position.x, global_position.x + size.x)
			mouse_pos.y = wrap(mouse_pos.y, global_position.y, global_position.y + size.y)
			if mouse_pos != event.global_position:
				Input.warp_mouse(mouse_pos)
				#TODO: add up the drag vector according to mouse warp.
			var drag_vector = drag_start - event.position
			%Cam.global_position = cam_start + drag_vector / get_work_zoom()
			$Background.queue_redraw()
			queue_redraw()
		else:
			#TODO Needs a scaling factor so coordinates are sane with grid cell size at certain zoom.
			var coord = get_work_coord(event.position / get_work_zoom())
			coord = coord.snappedf(0.01)
			%cursor_pos_x.text = str(coord.x).pad_decimals(2) + " X"
			%cursor_pos_y.text = str(coord.y).pad_decimals(2) + " Y"


const NOMINAL_WIRE_THICK = 10
const LASSO_THICK = 2

func _draw() -> void:
	var wire_thick : float = NOMINAL_WIRE_THICK * get_work_zoom()
	if wire_thick <= 1:
		wire_thick = -1
	
	if is_lassoing:
		var lasso_color = style.backdrop.inverted()
		var rect = Rect2(drag_start, drag_stop - drag_start)
		draw_rect(rect, lasso_color, false, LASSO_THICK)
		lasso_color.a = 0.15
		draw_rect(rect, lasso_color, true)
	
	#TODO: Draw all lines of connected components
	#for device : ComponentNode in %Components.get_children():
		#if not device.visible:
			#continue
		#for slot : FlowcharterSlot in device.slots:
			#if not slot is ComponentSourceSlot: # Only draw lines of outputing slots
				#continue
			#for path in slot.all_wire_paths():
				#draw_polyline(path, style.wire_high_color, wire_thick)

func _process(_delta: float) -> void:
	if tween != null and tween.is_running():  # We are trying to smoothly move the grid automatically.
		queue_redraw()
		$Background.queue_redraw()

#region Control Handling
func _on_goto_origin_pressed() -> void:
	goto_grid_coord(Vector2.ZERO)

func _on_reset_zoom_pressed() -> void:
	rezoom(1)

func _on_reset_zoom_mouse_entered() -> void:
	%reset_zoom.text = "Reset"

func _on_reset_zoom_mouse_exited() -> void:
	var curr_zoom = get_work_zoom() * 100
	%reset_zoom.text = str(roundi(curr_zoom)) + "%"
#endregion

func new_element(element:Control, pos:=Vector2.INF):
	if pos == Vector2.INF:  # Place in the center of the screen.
		pos = get_rect().get_center() - position  # Position of the screen center?
		pos = get_work_coord(pos)  # Position relative to the origin.
	%Components.add_child(element)
	element.set_position(snapped(pos, snap))
