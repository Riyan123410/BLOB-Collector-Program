extends Obstacle

@export var hitbox : Area3D

var speed = 5
var distance = 50

func _ready() -> void:
	await get_tree().process_frame
	#_deleteInRange(8000, self.global_position)
	sendStartSignal.connect("startGame", Callable(self, "_deleteInRange").bind(hitbox))
	
	var lookAtPosition = spaceShip.global_position - spaceShip.transform.basis.z.normalized() * distance
	self.look_at(lookAtPosition, Vector3.UP)
	
	await get_tree().create_timer(20).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	if !multiplayer.is_server():
		return
	moveTowardShip(delta)
	_collideWithShip(hitbox)

func moveTowardShip(delta):
	# Move forward relative to its facing
	position += -transform.basis.z * speed * delta
