extends Node

@onready var spaceShip = $"/root/sceneSwitcher/world/stage/SpaceShip"
var spawnObstacles = false

# comet stuff
var cometWait = 60
var isTimerRunning = false
var cometMinSize = 10
var cometMaxSize = 50

var finalPlanets = [
	preload("res://scenes/objects/obstacles/comets/comet.tscn")
	]


# connect to signal to set seed
func _ready() -> void:
	var sendStartSignal = $"/root/sceneSwitcher/startGameSignal"
	sendStartSignal.connect("syncSeed", Callable(self, "setSeed"))
	sendStartSignal.connect("startGame", Callable(self, "start"))
	sendStartSignal.connect("continueCycle", Callable(self, "stop"))

	
func setSeed(randSeed):
	seed(randSeed)

func start():
	spawnObstacles = true
func stop():
	spawnObstacles = false

func _process(_delta: float) -> void:
	if !multiplayer.is_server() or !spawnObstacles:
		return
	spawnComet()

func spawnComet():
	if isTimerRunning:
		return
	isTimerRunning = true
	await get_tree().create_timer(cometWait).timeout
	cometWait = randf_range(30, 120)
	isTimerRunning = false
	
	var a = finalPlanets.pick_random()
	a = a.instantiate()
	add_child(a)
	a.global_position = spawnInDistance(spaceShip.global_position, 500.0)
	var cometScale = randf_range(cometMinSize, cometMaxSize)
	a.scale = Vector3(cometScale, cometScale, cometScale)
	
func spawnInDistance(center: Vector3, radius: float) -> Vector3:
	var u = randf() * 2.0 - 1.0
	var theta = randf() * TAU

	var s = sqrt(1.0 - u * u)

	var direction = Vector3(
		s * cos(theta),
		u,
		s * sin(theta)
	)

	return center + direction * radius
