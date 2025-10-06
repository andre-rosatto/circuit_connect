class_name BoardSlot extends Area2D

signal chip_changed

var grid_position: Vector2i = Vector2i.ZERO
var has_mouse: bool = false:
	get = _get_has_mouse

@onready var chip: Chip = %Chip
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _get_has_mouse() -> bool:
	return collision_shape.shape.get_rect().has_point(get_local_mouse_position())


func insert_chip(chip_values: Vector2i) -> void:
	chip.position = Vector2.ZERO
	chip.out_value = chip_values.x
	chip.in_value = chip_values.y
	chip.visible = true
	chip_changed.emit()


func remove_chip() -> void:
	chip.visible = false
	chip_changed.emit()
