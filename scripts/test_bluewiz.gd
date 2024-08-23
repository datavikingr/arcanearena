extends CharacterBody2D

enum States {IDLE, RUNNING, JUMPING, SLIDING, FALLING, ATTACKING, BLOCKING, SPECIAL, DYING}
var state: States = States.IDLE
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") # gravity = 980
@onready var sprite_wiz_blue = get_node("Sprite")
@export var speed_move: int = 150 # Feels like a good lateral speed for now.
@export var speed_jump: int = 300 # 400 is a little too high for the maps. 300 feels good.
@export var speed_slide: int = 225 # Faster than move, less than jump
@export var hit_points: int = 3 # Can get tagged three times before dying
var speed: int = 0 # to conjoin/toggle speed_move & speed_slide easily
var left_right: float = 0 # Left/Right controller input variable


func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	input_handling(delta)
	state_machine(delta)
	move_and_slide()

func input_handling(_delta: float) -> void:
	# Directionality of the Sprite
	if Input.is_action_just_pressed("blue_left"):
		sprite_wiz_blue.flip_h = true
	elif Input.is_action_just_pressed("blue_right"):
		sprite_wiz_blue.flip_h = false
	# Assigning states
	left_right = Input.get_axis("blue_left", "blue_right")
	if is_on_floor(): # SLIDE, RUNNING, & IDLE are exclusive to is_on_floor() = TRUE
		if left_right == 0 and not Input.is_action_just_pressed("blue_jump"): # If we're not moving left/right or jumping, while on the ground, we're idle
			state = States.IDLE
		elif Input.is_action_just_pressed("blue_jump") and Input.is_action_pressed("blue_down"): # Down+Jump on the ground = megaman slide
			state = States.SLIDING
			print("Sliding!")
		else: # If we're neither of the above, we're running around
			state = States.RUNNING
			print("Running!")
	else: # FALLING is exclusive to is_on_floor() = FALSE
		if velocity.y > 0: # If we're travelling downward, while not on the floor, we're falling
			state = States.FALLING
			print("Falling!")
	# These states can and should overwrite the states above
	if Input.is_action_just_pressed("blue_jump"):
		state = States.JUMPING
		print("Jumping!")
	if Input.is_action_just_pressed("blue_attack"): 
		state = States.ATTACKING
		print("Attack!")
	if Input.is_action_just_pressed("blue_block"):
		state = States.BLOCKING
		print("Block!")
	if Input.is_action_just_pressed("blue_special"):
		state = States.SPECIAL
		print("Special!")

func state_machine(delta) -> void:
	velocity.y += gravity * delta # 980 * franctional_frame_rate; Gravity is constant; setting default velocity.y
	if state == States.IDLE:
		#animation_player.play("idle")
		velocity.y += gravity * delta # 980 * franctional_frame_rate; Gravity is constant; setting default velocity.y
	elif state == States.RUNNING:
		#animation_player.play("running")
		velocity.x = speed_move * left_right #150
		velocity.y += gravity * delta # 980 * franctional_frame_rate; Gravity is constant; setting default velocity.y
	elif state == States.JUMPING:
		#animation_player.play("jumping")
		velocity.x = speed_move * left_right #150
		velocity.y = -1 * speed_jump # -300; Godot defines "Up" as -Y and NOT +Y; so 300 Up needs to be -300
	elif state == States.SLIDING:
		#animation_player.play("sliding")
		velocity.x = speed_slide * left_right #225
	elif state == States.FALLING:
		#animation_player.play("falling")
		velocity.x = speed_move * left_right #150
		velocity.y += gravity * delta # 980 * franctional_frame_rate; Gravity is constant; setting default velocity.y
	elif state == States.ATTACKING:
		#animation_player.play("attacking")
		pass
	elif state == States.BLOCKING:
		#animation_player.play("blocking")
		pass
	elif state == States.SPECIAL:
		#animation_player.play("special")
		pass
	elif state == States.DYING: 
		#animation_player.play("dying")
		pass
	move_and_slide()
