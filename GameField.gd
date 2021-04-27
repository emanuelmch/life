extends Viewport

const TILE_SIZE = 32
const CELL_DEAD = 0
const CELL_LIVE = 1

# Game Speed
const MAX_GAME_SPEED = 60
export var target_speed = 0 setget set_target_speed
export var actual_speed = 0
signal target_speed_changed(target_speed)
signal actual_speed_changed(actual_speed)

var _next_tick = 0
var _tick_interval = 0 # In seconds

var _fps_counter = 0
var _fps_seconds = 0

# Camera
const DEFAULT_TILE_ZOOM_SIZE = TILE_SIZE / 2
const MIN_ZOOM_SCALE = 0.5
const MAX_ZOOM_SCALE = 10.0
const ZOOM_DURATION = 0.2
const ZOOM_STEP = 0.1

var _initial_zoom = Vector2(0, 0)
var _zoom_scale = 1.0 setget _set_zoom_scale

# Game Logic
var _current_gen = {}

func _ready():
	set_process(target_speed != 0)

	_reset_camera()
	do_the_gun()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if target_speed == 0:
			set_target_speed(MAX_GAME_SPEED)
		else:
			set_target_speed(0)
	elif event.is_action_pressed("ui_up"):
		set_target_speed(target_speed + 1)
	elif event.is_action_pressed("ui_down"):
		set_target_speed(target_speed - 1)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(BUTTON_MIDDLE):
		_move_camera(event.relative)
	elif event.is_action_pressed("zoom_in"):
		_set_zoom_scale(_zoom_scale - ZOOM_STEP)
	elif event.is_action_pressed("zoom_out"):
		_set_zoom_scale(_zoom_scale + ZOOM_STEP)
	elif event.is_action_pressed("toggle_cell"):
		var cell = ($GameField.get_local_mouse_position()/TILE_SIZE).floor()
		if _current_gen.has(cell):
			$GameField.set_cellv(cell, CELL_DEAD)
			_current_gen.erase(cell)
		else:
			$GameField.set_cellv(cell, CELL_LIVE)
			_current_gen[cell] = 0

func _process(delta):
	_next_tick -= delta
	_fps_seconds += delta
	
	if _fps_seconds > 1:
		if (_fps_counter != actual_speed):
			actual_speed = _fps_counter
			emit_signal("actual_speed_changed", actual_speed)
		_fps_counter = 0
		_fps_seconds -= 1

	if _next_tick <= 0:
		_fps_counter += 1
		_next_tick += _tick_interval
		_next_generation()


func _reset_camera():
	var mySize = (get_viewport().size / TILE_SIZE) * (get_viewport().size / DEFAULT_TILE_ZOOM_SIZE)
	$GameFieldCamera.position = mySize / 2
	_initial_zoom = mySize / get_viewport().size
	$GameFieldCamera.zoom = _initial_zoom


func _move_camera(movement):
	$GameFieldCamera.position -= (movement * $GameFieldCamera.zoom)


func _set_zoom_scale(value):
	_zoom_scale = clamp(value, MIN_ZOOM_SCALE, MAX_ZOOM_SCALE)
	$GameFieldCamera/ZoomTween.interpolate_property(
		$GameFieldCamera,
		"zoom",
		$GameFieldCamera.zoom,
		_initial_zoom * _zoom_scale,
		ZOOM_DURATION,
		$GameFieldCamera/ZoomTween.TRANS_SINE,
		$GameFieldCamera/ZoomTween.EASE_OUT
	)
	$GameFieldCamera/ZoomTween.start()


func _next_generation():
	var next_gen = {}
	var new_cells = {}
	for cell in _current_gen:
		var live_neighbors = 0

		for neighbor in _get_neighbors(cell):
			if _current_gen.has(neighbor):
				live_neighbors += 1
			else:
				var count = new_cells.get(neighbor, 0)
				new_cells[neighbor] = count + 1

		# Cells remain alive if they have exactly 2 or 3 live neighbors
		if live_neighbors in [2, 3]:
				next_gen[cell] = 0
				$GameField.set_cellv(cell, CELL_LIVE)
		else:
			$GameField.set_cellv(cell, CELL_DEAD)

	for cell in new_cells:
		# New cells are born on exactly 3 neighbors
		if new_cells.get(cell) == 3:
				next_gen[cell] = 0
				$GameField.set_cellv(cell, CELL_LIVE)

	_current_gen = next_gen

func _get_neighbors(cell):
	var neighbors = []
	for x_off in [-1, 0, 1]:
		for y_off in [-1, 0 ,1]:
			if x_off == 0 and y_off == 0: continue
			neighbors.append(cell + Vector2(x_off, y_off))
	return neighbors

func set_target_speed(new_target_speed):
	if target_speed == new_target_speed:
		return

	target_speed = clamp(new_target_speed, 0, MAX_GAME_SPEED)
	if target_speed > 0:
		_tick_interval = (1.0 / target_speed)
		set_process(true)
	else:
		_tick_interval = 0
		set_process(false)

	emit_signal("target_speed_changed", target_speed)

func reset():
	set_target_speed(0)
	_reset_camera()
	for cell in _current_gen:
		$GameField.set_cellv(cell, CELL_DEAD)
	_current_gen.clear()

func do_the_gun():
	reset()
	var gun_parts = [
		[1,5], [1,6], [2,5], [2, 6],
		[14,3], [13,3], [12,4], [11,5], [11,6], [11,7], [12,8], [13,9],[14,9],
		[15,6], [16,4], [17,5], [17, 6], [18,6], [17,7], [16,8],
		[21,3], [21,4], [21,5], [22,3], [22,4], [22,5], [23,2], [23,6], [25,1], [25,2], [25,6], [25,7],
		[35,3], [35,4], [36,3], [36,4]
	]
	for gun_part in gun_parts:
		var cell = Vector2(gun_part[0], gun_part[1])
		_current_gen[cell] = 0
		$GameField.set_cellv(cell, CELL_LIVE)
