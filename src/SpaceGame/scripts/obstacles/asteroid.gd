class_name Asteroid extends Obstacle

@export var hitbox : Area3D

func _ready() -> void:
	await get_tree().process_frame
	#_deleteInRange(8000, self.global_position)
	sendStartSignal.connect("startGame", Callable(self, "_deleteInRange").bind(hitbox))

func _physics_process(_delta: float) -> void:
	_collideWithShip(hitbox)
