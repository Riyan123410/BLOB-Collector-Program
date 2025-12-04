extends Asteroid

#var tween:Tween
#var targetScale = 0
#@export var hitbox : Area3D
#var begin = false

func _ready() -> void:
	#_deleteInRange(8000, self.global_position)
	_deleteInRange(hitbox)

func _physics_process(_delta: float) -> void:
	_collideWithShip(hitbox)

func consume() -> int:
	shrink_out()
	return int(self.scale[0])
