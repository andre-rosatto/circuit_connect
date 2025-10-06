@tool
class_name Chip extends Node2D

@export var out_value: int = 0:
	set = _set_out_value
@export var in_value: int = 0:
	set = _set_in_value

var values: Vector2i:
	get = _get_values

@onready var out_sprite: Sprite2D = %Out
@onready var in_sprite: Sprite2D = %In


func _ready() -> void:
	_set_out_value(out_value)
	_set_in_value(in_value)


func _set_out_value(value: int) -> void:
	out_value = clampi(value, 0, Consts.COLORS.size() - 1)
	if not is_inside_tree():
		await ready
	out_sprite.modulate = Consts.COLORS[out_value]


func _set_in_value(value: int) -> void:
	in_value = clampi(value, 0, Consts.COLORS.size() - 1)
	if not is_inside_tree():
		await ready
	in_sprite.modulate = Consts.COLORS[in_value]


func _get_values() -> Vector2i:
	return Vector2i(out_value, in_value)
