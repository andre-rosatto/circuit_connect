class_name MainMenu extends CanvasLayer

signal new_game_started(game_size: Vector2i)
signal game_continued(game_size: Vector2i, is_daily: bool)

var enabled: bool = true

@onready var new_3x3: Button = %New3x3
@onready var new_3x4: Button = %New3x4
@onready var continue_3x3: OnOffButton = %Continue3x3
@onready var continue_3x4: OnOffButton = %Continue3x4
@onready var daily_3x3: OnOffButton = %Daily3x3
@onready var daily_3x4: OnOffButton = %Daily3x4
@onready var fader: Fader = %Fader
@onready var help: Control = %Help


func _ready() -> void:
	new_3x3.pressed.connect(_on_new_pressed.bind(3))
	new_3x4.pressed.connect(_on_new_pressed.bind(4))
	continue_3x3.pressed.connect(_on_continue_pressed.bind(3))
	continue_3x4.pressed.connect(_on_continue_pressed.bind(4))
	daily_3x3.pressed.connect(_on_daily_pressed.bind(3))
	daily_3x4.pressed.connect(_on_daily_pressed.bind(4))
	show_menu()


func show_menu() -> void:
	SaveManager.load()
	update_continue_buttons()
	visible = true
	enabled = true
	fader.fade_in()


func update_continue_buttons() -> void:
	var game: Dictionary = SaveManager.random_3x3
	# random 3x3
	if not game.is_empty():
		continue_3x3.disabled = false
		continue_3x3.led_state = Led.State.ON if game.is_complete else Led.State.OFF
	else:
		continue_3x3.disabled = true
		continue_3x3.led_state = Led.State.OFF
	# random 3x4
	game = SaveManager.random_3x4
	if not game.is_empty():
		continue_3x4.disabled = false
		continue_3x4.led_state = Led.State.ON if game.is_complete else Led.State.OFF
	else:
		continue_3x4.disabled = true
		continue_3x4.led_state = Led.State.OFF
	# daily 3x3
	game = SaveManager.daily_3x3
	daily_3x3.led_state = Led.State.ON if not game.is_empty() and game.is_complete else Led.State.OFF
	# random 3x4
	game = SaveManager.daily_3x4
	daily_3x4.led_state = Led.State.ON if not game.is_empty() and game.is_complete else Led.State.OFF


func _on_new_pressed(game_height: int) -> void:
	if not enabled:
		return
	fader.fade_out()
	await fader.fade_finished
	new_game_started.emit(Vector2i(3, game_height))


func _on_continue_pressed(game_height: int) -> void:
	if not enabled:
		return
	fader.fade_out()
	await fader.fade_finished
	game_continued.emit(Vector2i(3, game_height), false)


func _on_daily_pressed(game_height: int) -> void:
	if not enabled:
		return
	fader.fade_out()
	await fader.fade_finished
	game_continued.emit(Vector2i(3, game_height), true)


func _on_how_to_play_button_pressed() -> void:
	help.show_help()
