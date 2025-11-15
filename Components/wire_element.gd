extends Control

var flowcharter := Flowcharter.new()

var is_dragging_start : bool
var is_dragging_stop : bool
var end : Vector2
var color : Color

func _ready() -> void:
	color = Color(0.773, 0.827, 0.0, 1.0)
	
	end = Vector2(200, -100)
	custom_minimum_size = end.abs()
	reset_size()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var thick = flowcharter.NOMINAL_WIRE_THICK * 2
			if event.position.x < thick and event.position.y < thick:
				is_dragging_start = true
				accept_event()
			elif event.position.x > size.x - thick and event.position.y > size.y - thick:
				is_dragging_stop = true
				accept_event()
		elif is_dragging_start or is_dragging_stop:
			is_dragging_start = false
			is_dragging_stop = false
	
	if event is InputEventMouseMotion:
		if is_dragging_start:
			#position = flowcharter.to_work_coord(event.global_position)
			#custom_minimum_size -= event.position
			#reset_size()
			queue_redraw()
		if is_dragging_stop:
			#var new_size = flowcharter.to_work_coord(event.global_position) - position
			#if new_size.x <= 0 or new_size.y <= 0:
			#	is_dragging_start = true
			#	is_dragging_stop = false
			
			#custom_minimum_size = new_size
			#reset_size()
			end = flowcharter.to_work_coord(event.global_position)
			queue_redraw()


func swap_bend():
	position += end
	end = -end
	$stop.position = end
	queue_redraw()

func _draw() -> void:
	var rect = Rect2(Vector2.ZERO, size)
	draw_rect(rect, Color(0.796, 0.0, 0.0, 1.0), false, 2)
	draw_circle(Vector2(10,10),6, Color(0.827, 0.376, 0.18, 1.0), false, 4)
	draw_circle(size - Vector2(10,10), 6, Color(0.075, 0.553, 0.702, 1.0), false, 4)
	
	draw_circle(end, 10, Color(0.493, 0.661, 0.0, 1.0))
	draw_polyline(get_path_vertices(), color, flowcharter.NOMINAL_WIRE_THICK)

func get_path_vertices() -> Array:
	var ans = [Vector2.ZERO, end]
	var bend := Vector2.ZERO

	var asp = end.aspect()
	var dir = sign(asp)
	asp = abs(asp)
	if is_equal_approx(asp, 1):
		return ans
	elif asp > 1:  # It's a wide box.
		if dir > 0:
			bend.x = end.x - end.y
		else:
			bend.x = end.x - (-end.y)
	elif asp < 1:  # It's a tall box.
		if dir > 0:
			bend.y = end.y - end.x
		else:
			bend.y = end.y - (-end.x)
	
	ans.insert(1, bend)
	return ans
