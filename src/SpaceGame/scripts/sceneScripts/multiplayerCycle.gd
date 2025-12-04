extends Node3D

@export var playerScene : PackedScene
@export var spaceShip : Node3D

var rentToBeSent = 0
var balanceToBeSent = 0

func _ready():
	if multiplayer.is_server():
		respawn_players()

func respawn_players():
	# Spawn server player
	add_player(multiplayer.get_unique_id())

	# Spawn all clients
	for id in multiplayer.get_peers():
		add_player(id)

func add_player(id):
	var player = playerScene.instantiate()
	player.name = str(id)
	spaceShip.call_deferred("add_child", player)
