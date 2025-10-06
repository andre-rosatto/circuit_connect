@tool
class_name MenuGroup extends HBoxContainer

enum Type { NEW, CONTINUE, DAILY }

@export var type: Type = Type.NEW:
	set = _set_type
@onready var label: Label = %Label


func _set_type(value: Type) -> void:
	type = value
	if not is_inside_tree():
		await ready
	match type:
		Type.CONTINUE:
			label.text = "Continue"
		Type.DAILY:
			label.text = "Daily"
		_:
			label.text = "New"
