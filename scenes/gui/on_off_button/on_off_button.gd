@tool
class_name OnOffButton extends Button

@onready var label: Label = %Label
@onready var led: Led = %Led


@export var label_text: String = "":
	set = _set_label_text
@export var led_state: Led.State = Led.State.OFF:
	set = _set_led_state


func _set_label_text(value: String) -> void:
	label_text = value
	if not is_inside_tree():
		await ready
	label.text = label_text


func _set_led_state(value: Led.State) -> void:
	led.state = value
