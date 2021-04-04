extends TileMap

const MAX_GAME_SPEED = 60
const TILE_SIZE = 32
const CELL_DEAD = 0
const CELL_LIVE = 1

# FIXME: INFINITY!!!
const width = 50
const height = 37

var game_speed = 0 setget set_game_speed
var _next_tick = 0
var _tick_interval = 0 # In seconds

func _ready():
	set_process(game_speed != 0)

	_ready_camera()
	_ready_cells()
	_do_the_gun()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		set_game_speed(0)
	elif event.is_action_pressed("ui_up"):
		set_game_speed(game_speed + 1)
	elif event.is_action_pressed("ui_down"):
		set_game_speed(game_speed - 1)
	elif event.is_action_pressed("toggle_cell"):
		var pos = (get_local_mouse_position()/TILE_SIZE).floor()
		set_cellv(pos, 1-get_cellv(pos))

func _process(delta):
	_next_tick -= delta
	if _next_tick > 0: return
	
	_next_tick += _tick_interval
	_next_generation()

func _ready_camera():
	var width_px = width * TILE_SIZE
	var height_px = height * TILE_SIZE
	
	$GameFieldCamera.position = Vector2(width_px, height_px)/2
	$GameFieldCamera.zoom = Vector2(width_px, height_px) / get_viewport().size

func _ready_cells():
	for x in range(width):
		for y in range(height):
			set_cell(x, y, CELL_DEAD)

func _do_the_gun():
	var gun_parts = [
		[1,5], [1,6], [2,5], [2, 6],
		[14,3], [13,3], [12,4], [11,5], [11,6], [11,7], [12,8], [13,9],[14,9],
		[15,6], [16,4], [17,5], [17, 6], [18,6], [17,7], [16,8],
		[21,3], [21,4], [21,5], [22,3], [22,4], [22,5], [23,2], [23,6], [25,1], [25,2], [25,6], [25,7],
		[35,3], [35,4], [36,3], [36,4]
	]
	for gun_part in gun_parts:
		set_cell(gun_part[0], gun_part[1], CELL_LIVE)

func _next_generation():
	var next_gen_buffer = []
	for x in range(width):
		var next_gen_column = []
		for y in range(height):
			var live_neighbors = _count_live_neighbors(x, y)
			if get_cell(x, y) == CELL_LIVE:
				next_gen_column.append(live_neighbors in [2, 3])
			else:
				next_gen_column.append(live_neighbors == 3)
		
		next_gen_buffer.append(next_gen_column)

	for x in range(width):
		for y in range(height):
			set_cell(x, y, CELL_LIVE if next_gen_buffer[x][y] else CELL_DEAD)

func _count_live_neighbors(x, y):
	var live_neighbors = 0
	for x_off in [-1, 0, 1]:
		for y_off in [-1, 0 ,1]:
			if x_off == 0 and y_off == 0: continue
			if get_cell(x+x_off, y+y_off) == CELL_LIVE:
				live_neighbors += 1
	return live_neighbors

func set_game_speed(new_game_speed):
	game_speed = clamp(new_game_speed, 0, MAX_GAME_SPEED)
	if game_speed > 0:
		_tick_interval = (1.0 / game_speed)
		set_process(true)
	else:
		_tick_interval = 0
		set_process(false)
	print("New game speed is %d" % game_speed)
	




