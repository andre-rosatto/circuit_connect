extends Node

var random_3x3: Dictionary
var random_3x4: Dictionary
var daily_3x3: Dictionary
var daily_3x4: Dictionary


func load() -> void:
	random_3x3 = load_game(3)
	random_3x4 = load_game(4)
	daily_3x3 = load_game(3, true)
	daily_3x4 = load_game(4, true)


func load_game(height: int, is_daily: bool = false) -> Dictionary:
	var file: FileAccess
	file = FileAccess.open("user://daily_3x" + str(height) + ".txt", FileAccess.READ) if is_daily else FileAccess.open("user://random_3x" + str(height) + ".txt", FileAccess.READ)
	if file:
		var data_string: String = file.get_as_text()
		var data: Dictionary = JSON.parse_string(data_string)
		if is_daily and not is_today(data.date):
			return {}
		return data
	else:
		return {}


func save_game(level: Level) -> void:
	var board_chips: Array = vector_array_to_int_array(get_board_chips(level))
	var repository_chips: Array = vector_array_to_int_array(get_repository_chips(level))
	var file: FileAccess = FileAccess.open("user://daily_3x" + str(level.level_size.y) + ".txt", FileAccess.WRITE) if level.is_daily else FileAccess.open("user://random_3x" + str(level.level_size.y) + ".txt", FileAccess.WRITE)
	var data: Dictionary
	if level.is_daily:
		var datetime: Dictionary = Time.get_datetime_dict_from_system()
		data = {
			level_chips = vector_array_to_int_array(level.shuffled_chip_values),
			board = board_chips,
			repository = repository_chips,
			is_complete = level.is_game_over,
			date = [datetime.day, datetime.month, datetime.year]
		}
	else:
		data = {
			level_chips = vector_array_to_int_array(level.shuffled_chip_values),
			board = board_chips,
			repository = repository_chips,
			is_complete = level.is_game_over
		}
	file.store_string(JSON.stringify(data))


func is_today(date: Array) -> bool:
	var datetime: Dictionary = Time.get_datetime_dict_from_system()
	return datetime.day == date[0] and datetime.month == date[1] and datetime.year == date[2]


func vector_array_to_int_array(vector_array: Array) -> Array:
	var result: Array
	for i in vector_array.size():
			if vector_array[i] != null:
				result.append([int(vector_array[i].x), int(vector_array[i].y)])
			else:
				result.append(null)
	return result


func get_board_chips(level: Level) -> Array:
	var result: Array = []
	for slot in level.get_slots():
		if slot is BoardSlot:
			if slot.chip.visible:
				result.append(slot.chip.values)
			else:
				result.append(null)
	return result


func get_repository_chips(level: Level) -> Array:
	var result: Array = []
	for slot in level.get_slots():
		if slot is RepositorySlot:
			if slot.chip.visible:
				result.append(slot.chip.values)
			else:
				result.append(null)
	return result


func get_empty_array(size: int) -> Array:
	var result: Array = []
	result.resize(size)
	return result


func new_random_game(height: int) -> Dictionary:
	var result = {
		board = get_empty_array(3 * height),
		repository = get_empty_array(3 * height),
		is_complete = false
	}
	return result


func new_daily_game(height: int) -> Dictionary:
	var result = new_random_game(height)
	var date: Dictionary = Time.get_datetime_dict_from_system()
	result.date = [date.day, date.month, date.year]
	return result
