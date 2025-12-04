extends Node3D
class_name Obstacle

var tween:Tween

@onready var sendStartSignal = $"/root/sceneSwitcher/startGameSignal"
@onready var spaceShip = $"/root/sceneSwitcher/world/stage/SpaceShip"
@onready var spaceShipArea = spaceShip.get_child(11)
@onready var tempArea = spaceShip.get_child(12)

static var start = false


func _deleteInRange(hitbox):
	if hitbox.overlaps_area(tempArea):
		queue_free()
	await get_tree().create_timer(1.0).timeout
	start = true

func _collideWithShip(hitbox):
	if hitbox == null or !start:
		return
	if hitbox.overlaps_area(spaceShipArea):
		sendStartSignal.die()
		shrink_out()

func shrink_out() -> void:
	# Asteroids shirink down to scale 1 before self deleting
	# to make it look better when the asteroid is getting removed,
	# in case the player is looking.
	if tween:
		tween.kill()
	# Shrink down then queue free
	tween = create_tween()
	tween.tween_property(self, 'scale',
		Vector3(1.0, 1.0, 1.0),
		1.0) # 1 seconds
	await tween.finished
	queue_free()

func swell_in(target_scale:float) -> void:
	#targetScale = target_scale
	## Asteroids appear very small and tween their scale up
	## to full size, so it's less noticeable when distant
	## asteroids appear out of nowhere.
	#tween = create_tween()
	#tween.tween_property(self, 'scale',
		#Vector3(target_scale, target_scale, target_scale),
		#5.0) # 5 seconds
	self.scale = Vector3(target_scale,target_scale,target_scale)
