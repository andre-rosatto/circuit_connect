extends Node

const COLORS: Array[Color] = [
	Color(1.0, 0.4, 0.4),
	Color(0.4, 1.0, 0.4),
	Color(0.4, 0.4, 1.0),
	Color(1.0, 1.0, 0.4),
	#Color(1.0, 0.25, 1.0),
	#Color(0.25, 1.0, 1.0)
]

const BOARD_SLOT_GAP: int = 225

const CHIP_TWEEN_DURATION: float = 0.075

const ON_COLOR: Color = Color(0.86, 0.77, 0.47, 1.0)
const OFF_COLOR: Color = Color(0.0, 0.0, 0.0, 1.0)
