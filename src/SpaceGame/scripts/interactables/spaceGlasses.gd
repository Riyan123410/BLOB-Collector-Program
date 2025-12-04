extends interactable

var player = null

func interactAction(_player : CharacterBody3D):
	player = _player
	if !usingControl:
		player.enableMovement = false
		player._setCamerPos(Vector3(0, 5, 0))
		usingControlLocal = true
		rpc("RPCusingControlTrue")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if usingControlLocal:
			player.enableMovement = true
			player._setCamerPos(Vector3(0, 0.573, 0))
			usingControlLocal = false
			rpc("RPCusingControlFalse")
