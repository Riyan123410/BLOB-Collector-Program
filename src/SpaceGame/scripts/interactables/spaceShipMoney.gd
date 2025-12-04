extends interactable

@export var raycast : ShapeCast3D
var player = null
var moneyGained := 0
var interacting = false

func _ready() -> void:
	raycast.collide_with_areas = true

func interactAction(_player : CharacterBody3D):
	if interacting:
		return
	interacting = true
	for i in range(raycast.get_collision_count()):
		if raycast.get_collider(i) == null:
			return
		if raycast.get_collider(i).get_parent().has_method("consume"):
			moneyGained = raycast.get_collider(i).get_parent().consume()
			await get_tree().create_timer(5.0).timeout
	interacting = false
	
