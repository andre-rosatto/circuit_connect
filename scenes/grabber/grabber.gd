class_name Grabber extends Node2D

signal move_completed

var enabled: bool = true:
	set = _set_enabled
var level: Level
var origin_slot: Variant
var tween: Tween

@onready var chip: Chip = %Chip


func _set_enabled(value: bool) -> void:
	enabled = value
	set_process(enabled)


func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	process_input()


func process_input() -> void:
	if level.is_game_over:
		return
	# pressed
	if Input.is_action_just_pressed("action"):
		var slot: Variant = get_hovered_slot()
		# grab
		if slot and slot.chip.visible and not chip.visible:
			grab_chip(slot)
	
	# released
	elif Input.is_action_just_released("action"):
		var slot: Variant = get_hovered_slot()
		# drop on empty space
		if not slot and chip.visible:
			return_chip()
		# drop on empty slot
		elif slot and chip.visible and not slot.chip.visible:
			drop_chip(slot)
		# drop on filled slot
		elif slot and chip.visible and slot.chip.visible:
			swap_chips(slot)


func get_hovered_slot() -> Variant:
	for slot in level.get_slots():
		if slot.has_mouse:
			return slot
	return null


func grab_chip(slot: Variant) -> void:
	enabled = false
	origin_slot = slot
	chip.global_position = slot.chip.global_position
	chip.out_value = slot.chip.out_value
	chip.in_value = slot.chip.in_value
	chip.visible = true
	slot.remove_chip()
	tween = create_tween()
	tween.tween_property(chip, "position", Vector2.ZERO, Consts.CHIP_TWEEN_DURATION)
	await tween.finished
	enabled = true


func return_chip() -> void:
	enabled = false
	tween = create_tween()
	tween.tween_property(chip, "global_position", origin_slot.chip.global_position, Consts.CHIP_TWEEN_DURATION)
	await tween.finished
	origin_slot.insert_chip(Vector2i(chip.out_value, chip.in_value))
	chip.visible = false
	enabled = true


func drop_chip(slot: Variant) -> void:
	enabled = false
	tween = create_tween()
	tween.tween_property(chip, "global_position", slot.chip.global_position, Consts.CHIP_TWEEN_DURATION)
	await tween.finished
	slot.insert_chip(Vector2i(chip.out_value, chip.in_value))
	chip.visible = false
	enabled = true
	move_completed.emit()


func swap_chips(slot: Variant) -> void:
	enabled = false
	tween = create_tween()
	tween.tween_property(slot.chip, "global_position", origin_slot.chip.global_position, Consts.CHIP_TWEEN_DURATION)
	tween.tween_property(chip, "global_position", slot.chip.global_position, Consts.CHIP_TWEEN_DURATION)
	await tween.finished
	origin_slot.insert_chip(Vector2i(slot.chip.out_value, slot.chip.in_value))
	slot.insert_chip(Vector2i(chip.out_value, chip.in_value))
	chip.visible = false
	enabled = true
	move_completed.emit()
