class_name RepositorySlot extends Panel

@onready var chip: Chip = $Chip
var has_mouse: bool = false:
	get = _get_has_mouse


func _get_has_mouse() -> bool:
	return get_global_rect().has_point(get_global_mouse_position())


func insert_chip(chip_values: Vector2i) -> void:
	chip.position = Vector2(50.0, 50.0)
	if not is_inside_tree():
		await ready
	chip.out_value = chip_values.x
	chip.in_value = chip_values.y
	chip.visible = true


func remove_chip() -> void:
	chip.visible = false
