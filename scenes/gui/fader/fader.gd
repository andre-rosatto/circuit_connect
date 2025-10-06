class_name Fader extends ColorRect

signal fade_finished

@onready var animation_player: AnimationPlayer = %AnimationPlayer


func fade_in() -> void:
	if not is_inside_tree():
		await ready
	animation_player.play("fade_in")
	await animation_player.animation_finished
	fade_finished.emit()


func fade_out() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	fade_finished.emit()
