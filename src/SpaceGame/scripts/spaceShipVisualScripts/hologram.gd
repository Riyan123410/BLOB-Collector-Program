extends Node3D

@export var finalPlanetMesh : MeshInstance3D
@export var cometMesh : MeshInstance3D

@onready var obstacleSpawner = $"/root/sceneSwitcher/world/stage/obstacleSpawner"

var finalAsteroidSpawner = null
var planet = null
var comet = null

var begin = false

func _ready() -> void:
	finalAsteroidSpawner = $"/root/sceneSwitcher/world/stage/finalPlanetSpawner"
	var sendStartSignal = $"/root/sceneSwitcher/startGameSignal"
	sendStartSignal.connect("startGame", Callable(self, "beginFunc"))
func beginFunc():
	begin = true
	await get_tree().process_frame
	planet = finalAsteroidSpawner.get_child(0)

func _process(_delta: float) -> void:
	if !begin:
		return
	if planet != null:
		meshLookAt(finalPlanetMesh, planet.global_position)
	if obstacleSpawner.get_child_count() > 0:
		cometMesh.scale = lerp(cometMesh.scale, Vector3(0.7,0.7,0.7), 0.4)
		meshLookAt(cometMesh, obstacleSpawner.get_child(0).global_position)
	else:
		cometMesh.scale = lerp(cometMesh.scale, Vector3(0.2,0.2,0.2), 0.1)

func meshLookAt(mesh, pos):
	mesh.look_at(pos, Vector3.UP)
