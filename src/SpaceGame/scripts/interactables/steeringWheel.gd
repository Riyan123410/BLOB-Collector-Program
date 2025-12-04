extends interactable

var direction = 0

func interactAction(_player : CharacterBody3D):
	if !usingControl:
		_player.enableMovement = false
		usingControlLocal = true
		rpc("RPCusingControlTrue")
	elif usingControlLocal:
		_player.enableMovement = true
		usingControlLocal = false
		rpc("RPCusingControlFalse")
