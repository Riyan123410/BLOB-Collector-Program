extends Node
class_name ShipInput
# input
var usingSpeedLocal = false
var direction = 0
var directionLocal = 0

# references
@export var shipSpeed : Node3D
@export var shipSteer : Node3D

func _ready() -> void:
	NetworkTime.before_tick_loop.connect(_gather)

func _gather():
	usingSpeedLocal = shipSpeed.usingControlLocal
	if shipSteer.usingControlLocal:
		directionLocal = int(Input.is_action_pressed("left")) - int(Input.is_action_pressed("right"))
		rpc("RPCsetDirection", directionLocal)
	elif !shipSteer.usingControl:
		directionLocal = 0
		rpc("RPCsetDirection", 0)

@rpc("any_peer","call_local")
func RPCsetDirection(newDirection : int):
	direction = newDirection
