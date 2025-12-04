extends Node

var nextLevel = null
var globalLevelNum = 0

@onready var currentLevel = $MainMenu
@onready var anim = $AnimationPlayer

func _ready() -> void:
	$MainMenu.connect("levelChanged", Callable(self, "handleLevelChanged"))
	$startGameSignal.connect("endGame", Callable(self, "handleLevelChanged").bind(1))
	$startGameSignal.connect("sendDie", Callable(self, "handleLevelChanged").bind(10))

func handleLevelChanged(currentLevelNum: int):
	var nextLevelName = ""
	globalLevelNum = currentLevelNum
	
	match currentLevelNum:
		0:
			nextLevelName = "game"
		1:
			nextLevelName = "mainMenu"
			await get_tree().create_timer(5.0).timeout
		10:
			nextLevelName = "mainMenu"
		_:
			return
	nextLevel = load("res://scenes/worlds/" + nextLevelName + ".tscn").instantiate()
	anim.play("fadeIn")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"fadeIn":
			add_child(nextLevel)
			if nextLevel.has_signal("levelChanged"):
				nextLevel.connect("levelChanged", Callable(self, "handleLevelChanged"))
			
			transferDataBetweenScenes(currentLevel, nextLevel)
			
			currentLevel.queue_free()
			currentLevel = nextLevel
			nextLevel = null
			anim.play("fadeOut")

func transferDataBetweenScenes(oldScene, newScene):
	match globalLevelNum:
		0:
			newScene.isHost = oldScene.isHost
			newScene.IPclient = oldScene.IPjoin
			newScene.portClient = oldScene.portJoin
			newScene.portHost = oldScene.portHost
		_:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			return
