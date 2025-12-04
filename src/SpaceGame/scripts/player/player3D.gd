extends CharacterBody3D

# ===== Movement variables =====
@export var speed = 2.0
@export var jumpVelocity = 4.5
@export var acceleration = 4.0
@export var airAcceleration = 1.0
@export var friction = 5.0
@export var currentFriction = 0
@export var airFriction = 0.5
var enableMovement = true
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# ===== Camera variables =====
@export var mouseSensitivity = 0.002 # radians per pixel
@export var interactTrace : RayCast3D

# ===== Node references =====
@export var head: Node3D
@export var camera: Camera3D
@export var input : PlayerInput
@onready var multiplayerSetup = $"../../../.."
#var spaceShip : CharacterBody3D
var sendStartSignal : Node

# ===== Interaction =====
var lookAt : Node

# ===== Multiplayer =====
func _enter_tree():
	set_multiplayer_authority(get_parent().name.to_int())

func _ready():
	if !is_multiplayer_authority():
		return
	await get_tree().process_frame
	#spaceShip = $"/root/sceneSwitcher/world/stage/SpaceShip"
	sendStartSignal = $"/root/sceneSwitcher/startGameSignal"
	sendStartSignal.connect("startGame", Callable(self, "_setPause").bind(true))
	sendStartSignal.connect("endGame", Callable(self, "die"))
	sendStartSignal.connect("sendDie", Callable(self, "die"))
	self.visible = !is_multiplayer_authority()
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = is_multiplayer_authority()
	
	interactTrace.collide_with_areas = true
	floor_stop_on_slope = true
	
	self.position = Vector3(0, 10, 0)
	velocity = Vector3.ZERO
		
# ===== Mouse input =====
func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouseSensitivity)
		head.rotate_x(-event.relative.y * mouseSensitivity)
		head.rotation.x = clampf(head.rotation.x, deg_to_rad(-89.9), deg_to_rad(89.9))

# ===== Movement =====
func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_just_pressed("debug"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if !is_multiplayer_authority():
		return
	#var floorNormal = get_parent().transform.basis.y.normalized()
	#self.up_direction = floorNormal

	# Convert input into a world space direction using the global transform
	var inputDir = Input.get_vector("left", "right", "forward", "backward")
	var direction = Vector3(inputDir.x, 0, inputDir.y)
	
	# Rotate input direction by the player's global facing 
	direction = global_transform.basis * direction
	direction.y = 0  # Keep movement horizontal
	direction = direction.normalized() if direction.length() > 0 else Vector3.ZERO


	# Movement variables
	var currentAcceleration = acceleration if is_on_floor() else airAcceleration
	currentFriction = friction if is_on_floor() else airFriction
	
	# stop movement
	if !enableMovement:
		direction = Vector3.ZERO
	
	# Apply acceleration/friction
	if direction != Vector3.ZERO:
		velocity.x = move_toward(velocity.x, direction.x * speed, currentAcceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * speed, currentAcceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, currentFriction * delta)
		velocity.z = move_toward(velocity.z, 0, currentFriction * delta)
		
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	# jump
	#if Input.is_action_just_pressed("jump"):
		#velocity.y += gravity * delta * 5

	move_and_slide()

# ===== Interaction =====
func _process(_delta: float) -> void:
	if !is_multiplayer_authority():
		return
	
	lookAt = interactTrace.get_collider()
	if lookAt != null:
		lookAt = lookAt.get_parent()
		if Input.is_action_just_pressed("interact") and lookAt.has_method("interactAction"):
				lookAt.interactAction(self)

# ===== Enable/Disable Movement =====
func _setPause(setPause : bool):
	if (setPause):
		enableMovement = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		enableMovement = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _setCamerPos(pos : Vector3):
	head.position = pos
	
func die():
	if !multiplayer.is_server():
		rpc("sendDieAsServer", get_multiplayer_authority())

@rpc("authority")
func sendDieAsSerer(id):
	multiplayerSetup.exitGame(id)
