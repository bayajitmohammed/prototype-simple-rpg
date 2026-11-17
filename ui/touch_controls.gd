extends Control

const DIRECTIONS: Array[StringName] = [&"left", &"right", &"up", &"down"]
const PAD_COLOR := Color(0.08, 0.12, 0.15, 0.34)
const EDGE_COLOR := Color(0.95, 0.89, 0.73, 0.55)
const ACTIVE_COLOR := Color(0.96, 0.73, 0.45, 0.72)

var move_touch: int = -1
var attack_touch: int = -1
var move_vector: Vector2 = Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = DisplayServer.is_touchscreen_available()
	resized.connect(queue_redraw)

func _exit_tree() -> void:
	_release_movement()
	if attack_touch != -1:
		Input.action_release(&"attack")

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event
		if not visible:
			visible = true
		var point: Vector2 = get_global_transform_with_canvas().affine_inverse() * touch.position
		if touch.pressed:
			if move_touch == -1 and point.distance_to(_pad_center()) <= _unit() * 100.0:
				move_touch = touch.index
				_update_movement(point)
				get_viewport().set_input_as_handled()
			elif attack_touch == -1 and point.distance_to(_attack_center()) <= _unit() * 68.0:
				attack_touch = touch.index
				Input.action_press(&"attack")
				queue_redraw()
				get_viewport().set_input_as_handled()
		elif touch.index == move_touch:
			move_touch = -1
			_release_movement()
			get_viewport().set_input_as_handled()
		elif touch.index == attack_touch:
			attack_touch = -1
			Input.action_release(&"attack")
			queue_redraw()
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		var drag: InputEventScreenDrag = event
		if drag.index == move_touch:
			var point: Vector2 = get_global_transform_with_canvas().affine_inverse() * drag.position
			_update_movement(point)
			get_viewport().set_input_as_handled()

func _unit() -> float:
	return clampf(minf(size.x / 640.0, size.y / 480.0), 0.75, 1.25)

func _pad_center() -> Vector2:
	var u: float = _unit()
	return Vector2(90.0 * u, size.y - 90.0 * u)

func _attack_center() -> Vector2:
	var u: float = _unit()
	return Vector2(size.x - 88.0 * u, size.y - 88.0 * u)

func _update_movement(point: Vector2) -> void:
	var delta: Vector2 = (point - _pad_center()) / (58.0 * _unit())
	move_vector = delta.limit_length()
	var desired: Array[bool] = [
		move_vector.x < -0.28,
		move_vector.x > 0.28,
		move_vector.y < -0.28,
		move_vector.y > 0.28
	]
	for i: int in range(DIRECTIONS.size()):
		if desired[i] and not Input.is_action_pressed(DIRECTIONS[i]):
			Input.action_press(DIRECTIONS[i])
		elif not desired[i] and Input.is_action_pressed(DIRECTIONS[i]):
			Input.action_release(DIRECTIONS[i])
	queue_redraw()

func _release_movement() -> void:
	move_vector = Vector2.ZERO
	for direction: StringName in DIRECTIONS:
		Input.action_release(direction)
	queue_redraw()

func _draw() -> void:
	if not visible:
		return
	var u: float = _unit()
	var pad: Vector2 = _pad_center()
	var attack: Vector2 = _attack_center()
	draw_circle(pad, 62.0 * u, PAD_COLOR)
	draw_arc(pad, 62.0 * u, 0.0, TAU, 64, EDGE_COLOR, 2.0 * u, true)
	draw_circle(pad + move_vector * 34.0 * u, 24.0 * u, ACTIVE_COLOR if move_touch != -1 else EDGE_COLOR)
	draw_circle(attack, 47.0 * u, ACTIVE_COLOR if attack_touch != -1 else PAD_COLOR)
	draw_arc(attack, 47.0 * u, 0.0, TAU, 64, EDGE_COLOR, 2.0 * u, true)
	var font: Font = ThemeDB.fallback_font
	draw_string(font, attack + Vector2(-24.0, 6.0) * u, "ATTACK", HORIZONTAL_ALIGNMENT_LEFT, -1, int(14.0 * u), Color(1, 1, 1, 0.92))
