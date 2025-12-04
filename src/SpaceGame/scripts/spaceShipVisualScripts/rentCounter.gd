extends Node

@export var text : Label3D

var rent = 0
var balance = 0
var fuel = 0
var HP = 0

func _process(_delta: float) -> void:
	if !multiplayer.is_server():
		return
	text.text = "Balance: " + str(balance) + "\nMoney Owed: " + str(rent) + "\nFuel Left: " + str(fuel) + "\nHealth: " + str(HP)
