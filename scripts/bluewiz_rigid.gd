extends RigidBody2D

@export var speed: int  = 200 # Self evident & pretty quick, too
@export var jump_speed: int = 300 # 400 is a little too high for the maps. 300 feels good.
@onready var sprite = get_node("Sprite")
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") # gravity = 980
var is_holding = false
var left_right: float = 0
var is_grounded: bool = false

func _ready() -> void:
	pass

func _on_body_entered(_body) -> void:
	rotation = 0
	angular_velocity = 0 # No really, don't bloody rotate unless the player says so
	$GroundDetector.enabled = true

func _physics_process(delta) -> void:
	rotation = 0
	player_movement(delta)
	if Input.is_action_just_pressed("blue_jump"):
		player_jump(delta)
	if Input.is_action_just_pressed("blue_attack"):
		player_attack(delta)
	if Input.is_action_just_pressed("blue_special"):
		player_special(delta)
	if Input.is_action_just_pressed("blue_block"):
		player_block(delta)

func player_movement(_delta) -> void:
	#linear_velocity.y += gravity * delta # downward force
	left_right = Input.get_axis("blue_left", "blue_right")# Move direction
	#Perform filter for arcade-like on/off controls
	if left_right < -0.25: #Pressed Left
		sprite.flip_h = true # toggles mirror on; faces left
		#TODO: animation line
		linear_velocity.x = -1 * speed # Go left
	elif left_right > 0.25: #Pressed Right
		sprite.flip_h = false # toggles mirror off; faces right
		#TODO: animation line
		linear_velocity.x = speed
	else: #Standing Still
		#TODO: animation line for ground idle
		#TODO: animation line for falling idle
		linear_velocity.x = 0
	#rotation = 0 # But don't let it spin, yet

func player_jump(_delta) -> void:
	if not is_slide(): # Jump
		#TODO: animation line for jumping
		linear_velocity.y = -1 * jump_speed #omg Godot defines "Up" as -Y and NOT +Y. *sigh* 
		print("Jump!")
	else: # Slide
		if sprite.flip_h == true:
			left_right = -1
		else:
			left_right = 1
		#TODO: animation line for sliding
		linear_velocity.x = left_right * speed * 1.75
		print("Slide!")
	#TODO: Velocity check for falling state

func player_attack(_delta) -> void:
	print("Attack!")

func player_special(_delta) -> void:
	print("Special!")

func player_block(_delta) -> void:
	print("Block!")

func is_slide() -> bool:
	is_grounded = $GroundDetector.is_colliding()
	return Input.is_action_pressed("blue_down") and is_grounded
