class_name LevelMenu extends ColorRect

signal quit_pressed
signal restart_pressed
signal menu_closed

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func fade_in() -> void:
	animation_player.play("fade_in")


func fade_out() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	menu_closed.emit()


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("action"):
		fade_out()


func _on_continue_button_pressed() -> void:
	if not animation_player.is_playing():
		fade_out()


func _on_quit_button_pressed() -> void:
	if not animation_player.is_playing():
		fade_out()
		await animation_player.animation_finished
		quit_pressed.emit()


func _on_restart_button_pressed() -> void:
	if not animation_player.is_playing():
		fade_out()
		await animation_player.animation_finished
		restart_pressed.emit()
