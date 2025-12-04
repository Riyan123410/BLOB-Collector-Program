extends Node

var finalPlanets = [
	preload("res://scenes/planets/finalPlanets/finalPlanet.tscn")
	]

# INPUT VARIABLES
var distance = 0
var zeroOffset = 87.5

# connect to signal to set seed
func _ready() -> void:
	var sendStartSignal = $"/root/sceneSwitcher/startGameSignal"
	sendStartSignal.connect("syncSeed", Callable(self, "setSeed"))
	sendStartSignal.connect("finalPlanetDistance", Callable(self, "setDistance"))
	sendStartSignal.connect("startGame", Callable(self, "start"))
func setSeed(randSeed):
	seed(randSeed)
func setDistance(inputDistance):
	distance = inputDistance

func start():
	if get_child_count() != 0:
		get_child(0).queue_free()
	var a = finalPlanets.pick_random()
	a = a.instantiate()
	add_child(a)
	var yDistance = randi_range(-10, 10)
	a.global_position = Vector3(zeroOffset * distance * randi_range(-5, 5), zeroOffset + yDistance,zeroOffset * distance * randi_range(-5, 5))
	#print(a.global_position)
