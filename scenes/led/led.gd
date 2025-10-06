class_name Led extends Sprite2D

enum State { OFF, ON, ERROR }

@export var state: State = State.OFF:
	set = _set_state


func _set_state(value: State) -> void:
	state = value
	match state:
		State.ON:
			frame = 1
		State.ERROR:
			frame = 2
		_:
			frame = 0
