class_name Connection extends Node2D

signal connection_completed

var out_value: bool = false:
	set = _set_out_value
var in_value: bool = false:
	set = _set_in_value
var is_vertical: bool = false:
	set = _set_is_vertical
var board_slots: Array[BoardSlot] = []:
	set = _set_board_slots
var is_completed: bool:
	get = _get_is_completed

@onready var out_sprite: Sprite2D = %Out
@onready var in_sprite: Sprite2D = %In
@onready var out_led: Led = %OutLed
@onready var in_led: Led = %InLed


func _set_out_value(value: bool) -> void:
	out_value = value
	if not is_inside_tree():
		await ready
	out_sprite.self_modulate = Consts.ON_COLOR if out_value else Consts.OFF_COLOR


func _set_in_value(value: bool) -> void:
	in_value = value
	if not is_inside_tree():
		await ready
	in_sprite.self_modulate = Consts.ON_COLOR if in_value else Consts.OFF_COLOR


func _set_is_vertical(value: bool) -> void:
	is_vertical = value
	rotation_degrees = 90 if is_vertical else 0


func _set_board_slots(value: Array[BoardSlot]) -> void:
	board_slots = value
	for board_slot in board_slots:
		board_slot.chip_changed.connect(_on_board_slot_chip_changed)


func _get_is_completed() -> bool:
	return out_led.state == Led.State.ON and in_led.state == Led.State.ON


func update_leds() -> void:
	var out_state: Led.State = Led.State.OFF
	var in_state: Led.State = Led.State.OFF
	if board_slots[0].chip.visible and board_slots[1].chip.visible:
		out_state = Led.State.ON if out_value == (board_slots[0].chip.out_value == board_slots[1].chip.out_value) else Led.State.ERROR
		in_state = Led.State.ON if in_value == (board_slots[0].chip.in_value == board_slots[1].chip.in_value) else Led.State.ERROR
	out_led.state = out_state
	in_led.state = in_state


func _on_board_slot_chip_changed() -> void:
	update_leds()
	if self.is_completed:
		connection_completed.emit()
