class_name Help extends Control

@onready var animation_player: AnimationPlayer = %AnimationPlayer


func show_help() -> void:
  animation_player.play("fade_in")


func _on_ok_pressed() -> void:
  animation_player.play("fade_out")
