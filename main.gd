extends Node

@onready var main_menu: MainMenu = %MainMenu
@onready var level: Level = %Level


func _ready() -> void:
	main_menu.new_game_started.connect(_on_game_started)
	main_menu.game_continued.connect(_on_game_continued)
	#_on_game_started(Vector2i(3, 3), false)
	main_menu.show_menu()


func _on_game_started(game_size: Vector2i, is_daily: bool = false) -> void:
	main_menu.visible = false
	level.start_new(game_size, is_daily)


func _on_game_continued(game_size: Vector2i, is_daily: bool) -> void:
	main_menu.visible = false
	level.load_game(game_size, is_daily)


func _on_level_level_hidden() -> void:
	main_menu.show_menu()


func _on_level_level_quit() -> void:
	main_menu.show_menu()
