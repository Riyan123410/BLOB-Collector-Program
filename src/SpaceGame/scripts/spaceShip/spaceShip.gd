extends CharacterBody3D

# references
@export var steering : Node3D
@export var shipSpeed : Node3D
@export var input : ShipInput
@export var collisionArea : Area3D
@export var rentCounter : MeshInstance3D
@export var shipMoney : Node3D
@onready var rollback_synchronizer = $RollbackSynchronizer
@onready var finalPlanetSpawner = $"../finalPlanetSpawner"
var sendStartSignal = null
var planet = null

var begin = false
var tp = true

# steering
var steeringSpeed = 0.5
var steeringAcc = 5

# movemnt
var speed = 0
var tiltAcc = 0.3
var acceleration = 5
var brakeAcceleration = 0.01
var maxTilt = 0.2
var offset = 87.5

# SHIP VALUES
var rent = 0
var balance = 0
var fuel = 0

func start():
	await get_tree().process_frame
	begin = true
	var asteroidSpawner = $"/root/sceneSwitcher/world/stage/asteroidSpawner"
	asteroidSpawner.generate_field(self)
	global_position = Vector3(offset,offset,offset)
	
func _ready():
	await get_tree().process_frame
	sendStartSignal = $"/root/sceneSwitcher/startGameSignal"
	sendStartSignal.connect("startGame", Callable(self, "start"))
	sendStartSignal.connect("continueCycle", Callable(self, "continueCycle"))
	sendStartSignal.connect("shipValues", Callable(self, "setValues"))
	call_deferred("_init_rollback")

func setValues(inputRent, inputFuel):
	rent = inputRent
	fuel = inputFuel

func _init_rollback():
	rollback_synchronizer.process_settings()

func _rollback_tick(delta, _tick, _is_fresh):
	# Only tp on the first tick
	if tp:
		global_position = Vector3(offset,offset,offset)
		global_rotation = Vector3.ZERO
		tp = false
	movementFromInput(delta)
	# follwing code for server only so no overlaps
	if !multiplayer.is_server():
		return
	if getCollision() == "planet":
		sendStartSignal.checkCycle(rent, balance)
		tp = true
		begin = false
		balance -= rent
	rentCounter.rent = rent
	rentCounter.balance = balance
	rentCounter.HP = sendStartSignal.HP

	# stuff that should update if game hasnt started
	if !begin:
		return
	rentCounter.fuel = int(fuel)
	fuel -= delta
	
	if fuel < 0:
		sendStartSignal.die()
	
func movementFromInput(delta):
	
	if !begin: # or !multiplayer.is_server()
		return
	
	if shipSpeed.usingControl:
		move(delta, 1)
	else:
		move(delta, -1)

	steer(input.direction, delta)
	
	if shipMoney.moneyGained > 0:
		balance += shipMoney.moneyGained
		shipMoney.moneyGained = 0
		

func steer(directionLocal : int, delta : float):
	rotate_y(directionLocal * steeringSpeed * delta)

func move(delta: float, dir: float):
	if dir == 1:
		speed = 500
	else:
		speed = 10

	# -transform.basis.z is the forward dir
	var targetVelocity = -global_transform.basis.z * speed
	if targetVelocity.y > 0:
		targetVelocity.y *= 2

	# move
	if targetVelocity != Vector3.ZERO:
		velocity.x = move_toward(velocity.x, targetVelocity.x, acceleration * delta)
		velocity.y = move_toward(velocity.y, targetVelocity.y, acceleration * delta)
		velocity.z = move_toward(velocity.z, targetVelocity.z, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, targetVelocity.x, delta * brakeAcceleration)
		velocity.y = move_toward(velocity.y, targetVelocity.y, delta * brakeAcceleration)
		velocity.z = move_toward(velocity.z, targetVelocity.z, delta * brakeAcceleration)

	if dir < 1:
		dir = -maxTilt
	else:
		dir = maxTilt
		
	rotation.x = move_toward(rotation.x, dir, tiltAcc * delta)
	
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor

func getCollision():
	if !begin:
		return
	planet = finalPlanetSpawner.get_child(0).get_child(0)
	if planet != null:
		if collisionArea.overlaps_area(planet):
			return "planet"

func continueCycle():
	begin = true
	var buttonScene = load("res://scenes/objects/button.tscn")
	var buttonInstance = buttonScene.instantiate()
	add_child(buttonInstance)
	buttonInstance.position = Vector3(0, 0.134, 2.315)
