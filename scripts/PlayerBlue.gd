extends CharacterBody2D

@export var speed: int = 150 # Feels like a good lateral speed for now.
@export var jump_speed: int = 300 # 400 is a little too high for the maps. 300 feels good.
@export var fly_speed: int = 200 # First Taste
@onready var sprite_wiz_blue = get_node("Sprite")
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") # gravity = 980
var is_holding = false
#var up_down: int = 0
#var left_right: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta) -> void:
	player_movement(delta)
	#if Input.is_action_just_pressed("blue_jump"):		## Handled in player_movement()
	#	player_jump(delta)								## Placeholder for clarity
	if Input.is_action_just_pressed("blue_attack"):
		player_attack(delta)
	if Input.is_action_just_pressed("blue_special"):
		player_special(delta)
	if Input.is_action_just_pressed("blue_block"):
		player_block(delta)

func player_movement(delta) -> void:
	############
	# Multi Jump
	############
	velocity.y += gravity * delta
	if Input.is_action_just_pressed("blue_jump"): #and is_on_floor()
		velocity.y = -1 * jump_speed #omg Godot defines "Up" as -Y and NOT +Y. *sigh* 
		print("Jump! Y velocity: ", str(velocity.y))
	# Move direction
	var left_right = Input.get_axis("blue_left", "blue_right")
	velocity.x = left_right * speed
	# Sprite Directionality; sprite faces right by default
	if Input.is_action_just_pressed("blue_left"):
		sprite_wiz_blue.flip_h = true
	elif Input.is_action_just_pressed("blue_right"):
		sprite_wiz_blue.flip_h = false
	# Move
	move_and_slide()

	###################################################
	# Hold and Fly - simply not as good as multi-jump #DEPRECATED
	################################################### 
	#if Input.is_action_just_pressed("blue_jump") and is_on_floor(): # Handle jump input
	#	velocity.y = jump_speed
	#if not is_holding and velocity.y > -0.1 and velocity.y < 0.1 and Input.is_action_pressed("blue_jump"): # Detect the peak of the jump
	#	#velocity.y = 0 # Stop velocity
	#	is_holding = true # Toggle hover flag on - and joystick controls for flight
	#elif not Input.is_action_pressed("blue_jump"): # Release the hold when the jump button is released
	#	is_holding = false  # Toggle flag off - gravity resumes below
	#left_right = Input.get_axis("blue_left", "blue_right") # Apply horizontal movement
	#velocity.x = left_right * speed # gotta go fast
	#if not is_holding:
	#	velocity.y += gravity * delta # gravity on
	#else: # gravity off
	#	up_down = Input.get_axis("blue_up", "blue_down") 
	#	velocity.y = up_down * fly_speed # Setting the joystick in control
	#move_and_slide() # Move the character
	
func player_attack(_delta) -> void:
	print("Attack!")

func player_special(_delta) -> void:
	print("Special!")

func player_block(_delta) -> void:
	print("Block!")
