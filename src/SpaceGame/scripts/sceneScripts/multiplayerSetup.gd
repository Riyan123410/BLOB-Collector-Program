extends Node3D

var isHost = 0
var loop = true
var IPclient = "127.0.0.1"
var portClient = 1024
var portHost = 1024

var peer = ENetMultiplayerPeer.new()
@export var playerScene : PackedScene
@export var spaceShip : Node3D
@onready var sendStartSignal = $"/root/sceneSwitcher/startGameSignal"

func _ready() -> void:
	multiplayer.peer_disconnected.connect(onPeerDisconected)

func _process(_delta: float) -> void:
	if loop:
		if isHost == 1:
			runHost()
			loop = false
		elif isHost == 2:
			runClient()
			loop = false
	
	if Input.is_action_just_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func runHost():
	peer.create_server(portHost)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(addPlayer)
	addPlayer()
	
func runClient():
	peer.create_client(IPclient, portClient)
	multiplayer.multiplayer_peer = peer
	
func addPlayer(id = multiplayer.get_unique_id()):
	var player = playerScene.instantiate()
	player.name = str(id)
	spaceShip.call_deferred("add_child", player)
	
func deletePlayer(id):
	rpc("_deletePlayer", id)

@rpc("any_peer", "call_local")
func _deletePlayer(id):
	get_node("stage/SpaceShip/" + str(id)).queue_free()
	
func exitGame(id):
	deletePlayer(id)

func onPeerDisconected(id):
	if id == 1:
		sendStartSignal.die()
		return
	exitGame(id)
