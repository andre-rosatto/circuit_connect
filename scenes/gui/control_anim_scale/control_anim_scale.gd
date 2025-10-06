class_name ControlAnimScale extends ControlAnim

@export var default_scale: Vector2 = Vector2.ONE
@export var target_scale: Vector2 = Vector2(1.1, 1.05)
@export var duration: float = 0.2
@export var transition: Tween.TransitionType = Tween.TransitionType.TRANS_BACK


func _ready() -> void:
	super()
	parent.mouse_entered.connect(_on_hover_entered)
	parent.mouse_exited.connect(_on_hover_exited)
	parent.pivot_offset = parent.size / 2


func make_tween(scale: Vector2) -> void:
	if parent.disabled:
		return
	var tween: Tween = create_tween()
	tween.tween_property(parent, "scale", scale, duration).set_trans(transition)


func _on_hover_entered() -> void:
	super()
	make_tween(target_scale)


func _on_hover_exited() -> void:
	super()
	make_tween(default_scale)
