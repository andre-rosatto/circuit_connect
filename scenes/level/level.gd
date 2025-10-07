class_name Level extends Control

signal level_quit

const BOARD_SLOT: PackedScene = preload("res://scenes/board_slot/board_slot.tscn")
const CONNECTION: PackedScene = preload("res://scenes/connection/connection.tscn")
const REPOSITORY_SLOT: PackedScene = preload("res://scenes/repository_slot/repository_slot.tscn")

var is_game_over: bool = false:
	set = _set_is_game_over
var level_chip_values: Array[Vector2i] = []
var shuffled_chip_values: Array[Vector2i] = []
var level_size: Vector2i = Vector2i(3, 3)
var is_daily: bool = false

@onready var board: Node2D = %Board
@onready var board_slots: Node2D = %BoardSlots
@onready var connections: Node2D = %Connections
@onready var repository_slots: HFlowContainer = %RepositorySlots
@onready var grabber: Grabber = %Grabber
@onready var level_menu: LevelMenu = %LevelMenu
@onready var level_info: Label = %LevelInfo
@onready var particles: GPUParticles2D = %GPUParticles2D
@onready var fader: Fader = %Fader


func _ready() -> void:
	grabber.level = self


func _set_is_game_over(value: bool) -> void:
	is_game_over = value
	if not is_inside_tree():
		await ready
	particles.restart()
	particles.visible = is_game_over
	particles.emitting = is_game_over


func start_new(board_size: Vector2i, is_daily_game: bool = false) -> void:
	visible = true
	is_daily = is_daily_game
	self.is_game_over = false
	grabber.chip.visible = false
	grabber.enabled = false
	level_size = board_size
	var datetime: Dictionary = start_randomizer()
	update_infobar(datetime)
	level_chip_values.clear()
	shuffled_chip_values.clear()
	make_game()
	make_board_slots()
	make_connections()
	make_repository_slots()
	center_board()
	SaveManager.save_game(self)
	fader.fade_in()
	await fader.fade_finished
	grabber.enabled = true


func load_game(game_size: Vector2i, is_daily_game: bool) -> void:
	visible = true
	is_daily = is_daily_game
	level_size = game_size
	grabber.chip.visible = false
	grabber.enabled = false
	
	var game_data: Dictionary
	if is_daily:
		game_data = SaveManager.daily_3x3 if game_size.y == 3 else SaveManager.daily_3x4
		if game_data.is_empty():
			start_new(game_size, true)
			return
		load_data(game_data)
		update_infobar({
			day = int(game_data.date[0]),
			month = int(game_data.date[1]),
			year = int(game_data.date[2])
		})
	else:
		game_data = SaveManager.random_3x3 if game_size.y == 3 else SaveManager.random_3x4
		load_data(game_data)
		update_infobar({})
	
	center_board()
	fader.fade_in()
	await fader.fade_finished
	grabber.enabled = not game_data.is_complete


func load_data(game_data: Dictionary) -> void:
	self.is_game_over = game_data.is_complete
	level_chip_values.clear()
	shuffled_chip_values.clear()
	for chip_value in game_data.level_chips:
		level_chip_values.append(Vector2i(chip_value[0], chip_value[1]))
		shuffled_chip_values.append(Vector2i(chip_value[0], chip_value[1]))
	make_board_slots()
	make_connections()
	make_repository_slots(false)
	for i in game_data.board.size():
		if game_data.board[i] != null:
			get_board_slot_at_grid_pos(index_to_grid_position(i)).insert_chip(Vector2i(game_data.board[i][0], game_data.board[i][1]))
	for i in game_data.repository.size():
		if game_data.repository[i] != null:
			get_repository_slot_at_index(i).insert_chip(Vector2i(game_data.repository[i][0], game_data.repository[i][1]))


func start_randomizer() -> Dictionary:
	if not is_daily:
		randomize()
		return {}
	else:
		var datetime: Dictionary = Time.get_datetime_dict_from_system()
		var day: String = str(datetime.day)
		var month: String = str(datetime.month).pad_zeros(2)
		var year: String = str(datetime.year)
		seed(int(day + month + year))
		return datetime


func update_infobar(datetime: Dictionary) -> void:
	if is_daily:
		level_info.text = "Daily Game "  + str(level_size.x) + "x" + str(level_size.y) + " (" + str(datetime.day).pad_zeros(2) + "/" + str(datetime.month).pad_zeros(2) + "/" + str(datetime.year) + ")"
	else:
		level_info.text = "Random Game " + str(level_size.x) + "x" + str(level_size.y)


func make_game() -> void:
	for row in level_size.y:
		for col in level_size.x:
			level_chip_values.append(Vector2i(
					randi_range(0, Consts.COLORS.size() - 1),
					randi_range(0, Consts.COLORS.size() - 1)
			))
	print("level chips: ", level_chip_values)
	shuffled_chip_values = level_chip_values.duplicate()
	#shuffled_chip_values.shuffle()


func restart_game() -> void:
	for slot in board_slots.get_children():
		slot.remove_chip()
	for i in shuffled_chip_values.size():
		repository_slots.get_child(i).insert_chip(shuffled_chip_values[i])
	self.is_game_over = false
	grabber.chip.visible = false
	grabber.enabled = true


func make_board_slots() -> void:
	for slot in get_slots():
		slot.queue_free()
	for i in level_chip_values.size():
		var grid_pos: Vector2i = Vector2i(i % level_size.x, int(float(i) / level_size.x))
		var new_slot: BoardSlot = BOARD_SLOT.instantiate()
		new_slot.position = grid_pos * Consts.BOARD_SLOT_GAP
		new_slot.grid_position = grid_pos
		board_slots.add_child(new_slot)


func make_connections() -> void:
	for connection in connections.get_children():
		connection.queue_free()
	for i in level_chip_values.size() - 1:
		var grid_pos: Vector2i = Vector2i(i % level_size.x, int(float(i) / level_size.x))
		# horizontal connections
		if grid_pos.x < level_size.x - 1:
			var new_connection: Connection = CONNECTION.instantiate()
			new_connection.out_value = level_chip_values[i].x == level_chip_values[i + 1].x
			new_connection.in_value = level_chip_values[i].y == level_chip_values[i + 1].y
			new_connection.position = grid_pos * Consts.BOARD_SLOT_GAP + Vector2i(Consts.BOARD_SLOT_GAP / 2.0, 0)
			new_connection.board_slots = [get_board_slot_at_grid_pos(grid_pos), get_board_slot_at_grid_pos(grid_pos + Vector2i(1, 0))]
			connections.add_child(new_connection)
		# vertical connections
		if grid_pos.y < level_size.y - 1:
			var new_connection: Connection = CONNECTION.instantiate()
			new_connection.out_value = level_chip_values[i].x == level_chip_values[i + level_size.x].x
			new_connection.in_value = level_chip_values[i].y == level_chip_values[i + level_size.x].y
			new_connection.position = grid_pos * Consts.BOARD_SLOT_GAP + Vector2i(0, Consts.BOARD_SLOT_GAP / 2.0)
			new_connection.board_slots = [get_board_slot_at_grid_pos(grid_pos), get_board_slot_at_grid_pos(grid_pos + Vector2i(0, 1))]
			new_connection.is_vertical = true
			connections.add_child(new_connection)


func make_repository_slots(visible_chip: bool = true) -> void:
	for chip_value in shuffled_chip_values:
		var new_slot: RepositorySlot = REPOSITORY_SLOT.instantiate()
		repository_slots.add_child(new_slot)
		new_slot.insert_chip(chip_value)
		new_slot.chip.visible = visible_chip


func get_board_slot_at_grid_pos(grid_pos: Vector2i) -> BoardSlot:
	for slot in board_slots.get_children():
		if slot.grid_position == grid_pos and not slot.is_queued_for_deletion():
			return slot
	return null


func get_repository_slot_at_index(idx: int) -> RepositorySlot:
	var active_slots: Array = repository_slots.get_children().filter(func(slot): return not slot.is_queued_for_deletion())
	return active_slots[idx]


func center_board() -> void:
	var board_width: float = (level_size.x - 1) * Consts.BOARD_SLOT_GAP
	board.position.x = get_viewport_rect().size.x / 2.0 - board_width / 2.0


func get_slots() -> Array:
	return board_slots.get_children() + repository_slots.get_children()


func index_to_grid_position(idx: int) -> Vector2i:
	return Vector2i(
		idx % level_size.x,
		int(idx / float(level_size.x))
	)


func end_game():
	grabber.enabled = false
	self.is_game_over = true


func _on_level_menu_button_pressed() -> void:
	grabber.enabled = false
	level_menu.fade_in()


func _on_level_menu_menu_closed() -> void:
	if not particles.emitting:
		grabber.enabled = true


func _on_level_menu_restart_pressed() -> void:
	restart_game()
	SaveManager.save_game(self)


func _on_level_menu_quit_pressed() -> void:
	fader.fade_out()
	await fader.fade_finished
	visible = false
	level_quit.emit()


func _on_grabber_move_completed() -> void:
	if connections.get_children().all(func(connection: Connection): return connection.is_completed):
		end_game()
	SaveManager.save_game(self)
