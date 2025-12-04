extends Node
class_name PlayerInput

var inputDir = Vector2.ZERO

func _ready() -> void:
	NetworkTime.before_tick_loop.connect(_gather)

func _gather():
	if not is_multiplayer_authority():
		return
	inputDir = Input.get_vector("left", "right", "forward", "backward")
