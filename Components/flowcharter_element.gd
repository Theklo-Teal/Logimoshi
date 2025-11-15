@tool
extends Control
class_name FlowcharterElement

var flowcharter := Flowcharter.new()

## Return pixel coordinate from a grid coordinate.
func get_cell_pos(grid_pos:Vector2i) -> Vector2:
	var cell = flowcharter.snap
	return Vector2( grid_pos.x * cell.x, grid_pos.y * cell.y )
func cell_size() -> Vector2:
	return flowcharter.snap

@export var default_title : String =  "Element Title"

@export var span := Vector2i(3,3) : ## How tall and wide the element is in multiples of the Flowcharter snap dimensions.
	set(val):
		span = val.maxi(3)
		if is_node_ready():
			custom_minimum_size = get_cell_pos(span)
			reset_size()
			queue_redraw()

func _ready() -> void:
	span = span

func _on_slot_pressed(butt:BaseButton):
	if is_wiring == null:
		is_wiring = butt
	else:
		is_wiring = null

var is_wiring : BaseButton
var is_dragging : bool
var start_pos : Vector2
var drag_start : Vector2
var drag_stop : Vector2
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.is_echo():
		is_dragging = event.is_pressed()
		drag_start = event.global_position
		start_pos = position

func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion and is_dragging:
		drag_stop = flowcharter.to_work_coord(event.position)
		if not is_wiring == null:
			queue_redraw()
		else:
			var drag_vector = event.global_position - drag_start
			position = start_pos + drag_vector / flowcharter.get_work_zoom()
			position = snapped(position, flowcharter.snap)
	
	if event is InputEventMouseButton and not event.is_echo() and event.is_released():
		is_dragging = false
		#if not is_wiring == null:
		#	var junction = ElectroJunction
		#	flowcharter.new_element(junction, drag_stop)
	
	if event is InputEventKey and not event.is_echo() and not is_wiring == null:
		queue_redraw()

const WIRE_CHIRAL_KEY = KEY_SPACE
func _draw() -> void:
	debug_visual()
	#if not is_wiring == null:
		#var slot : FlowcharterSlot = is_wiring.get_meta("slot")
		#var stop = drag_stop - position
		#var path = slot.wire_path(stop, Input.is_key_pressed(WIRE_CHIRAL_KEY))
		#draw_polyline(path, flowcharter.style.wire_hiz_color, flowcharter.style.nominal_thickness * flowcharter.get_work_zoom())

## Draw a visual aid about what's happening to invisible parts of the element.
func debug_visual():
	var rect = Rect2(
		Vector2.ZERO,
		size
	)
	draw_rect(rect, Color.INDIAN_RED, false, 3)
