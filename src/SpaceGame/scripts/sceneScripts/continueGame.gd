extends Node

var sendStartSignal = Node

# START GAME SETTINGS:
var distance = 0.1 # distance is the distance of the final planet from start position
var randSeed = randi() % 101 # seed

func _ready() -> void:
	sendStartSignal = $"/root/sceneSwitcher/startGameSignal"

func _on_button_pressed() -> void:
	# asign values
	sendStartSignal.randSeed = randSeed
	sendStartSignal.distance = distance
	
	# send signal and die
	sendStartSignal.start()
	queue_free()
