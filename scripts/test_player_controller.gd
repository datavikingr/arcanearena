extends CharacterBody2D

## DEFINITIONS
@onready var sprite = get_node("Sprite") # Sprite, player_movement()
@onready var player = get_node("AnimationPlayer") # What it says on the can, player_movement() & player_jump() $ etc.

@export var run_speed: int = 200 # Feels like a good lateral speed for now. player_movement()
@export var jump_speed: int = 300 # 400 is a little too high for the maps. 300 feels good. player_jump()
@export var slide_speed: int = 400 # Twice as fast as the run, player_jump()
@export var push_force: float = 200.0 # This represents the player's inertia, physics_collisions()
@export var near_range: int = 50 # Nearness range, is_ball_near() & player_jump()

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") # gravity = 980, player_movement()
var is_holding = false #TODO: Implement posession feature?
var ball_position: Vector2 = Vector2.ZERO # For nearness, is_ball_near() & player_jump()
var player_position: Vector2 = Vector2.ZERO # For nearness, is_ball_near() & player_jump()

## INPUTS
var left_right: float = 0 # Control Input, player_movement()

## CALLABLE FUNCTIONS

func is_slide() -> bool: # Called by player_jumps()
	return is_on_floor() and Input.is_action_pressed("blue_down")

func is_ball_near() -> bool: # Called from player_jump()
	ball_position = %Ball.position #Get ball position from transform
	player_position = self.position #Get self position from transform
	#NOTE: If player and ball are within near_range of each other in x and y, return true
	return abs(ball_position.x - player_position.x) < near_range and abs(ball_position.y - player_position.y) < (near_range / 2)

## EXECUTION
func _ready() -> void: # Called when the node enters the scene tree for the first time.
	pass

func _physics_process(delta) -> void: # Called every frame. 'delta' is the elapsed time since the previous frame. 
	# We're gonna collect input here. We'll start by stashing it all in variables to pass it around where needed.
	left_right = Input.get_axis("blue_left", "blue_right") # Joystick; -1 for left, 1 for right, passing to player_movement() and animation_controller()
	#TODO:
	#TODO:
	#TODO: This is what we're working on now. Variables for passing. Booleans.

	
	# Then we're gonan execute with the above
	player_movement(delta, left_right) # Left/right/idle
	if Input.is_action_just_pressed("blue_jump"): # what it says on the can
		player_jump(delta) 
	if Input.is_action_pressed("blue_jump") and Input.is_action_pressed("blue_down"): # This is a slide
		player_slide(delta)
	move_and_slide() # Execute movement accumulated above
	physics_collisions() # React to Physics, as per the movement.
	if Input.is_action_just_pressed("blue_attack"):
		player_attack(delta)
	if Input.is_action_just_pressed("blue_special"):
		player_special(delta)
	if Input.is_action_just_pressed("blue_block"):
		player_block(delta)
	animation_controller(left_right) # Change Animations

func player_movement(delta, left_right) -> void: # Player Controller, called by _physics_process()
	velocity.y += gravity * delta #apply gravity to character
	#Perform filter for arcade-like on/off controls
	# LEFT
	if left_right < -0.25: #Pressed Left, inner 25% deadzone
		velocity.x = -1 * run_speed # Go Left
	# RIGHT
	elif left_right > 0.25: #Pressed Right, inner 25% deadzone
		velocity.x = run_speed # Go Right
	# IDLE
	else: #Standing Still
		velocity.x = 0 # don't move

func player_jump(_delta) -> void: # Called by player input from _physics_process()
	if !is_slide(): #Make sure we're not sliding
		player.play("jump")
		velocity.y = -1 * jump_speed #omg Godot defines "Up" as -Y and NOT +Y. *sigh* 
		#print("Jump!") # Log
		if is_ball_near(): # If ball is in range
			%Ball.linear_velocity.y = -1.1 * jump_speed # Apply upward force to ball

func player_slide(_delta) -> void:
	# Without is_slide() here, this creates an air-dash. I think I like this air dash. 
	# But, Airie says she doesn't. I'm going to test it with. And I leave it only commented, if I hate it, rather than remove it.
	if is_slide():
		if sprite.flip_h == true: # If player is facing left
			left_right = -1 # Tune the forces to the left
		else: # else, we're facing right
			left_right = 1 # Keep the forces tuned to the right
		print("Slide!") # Log
		#TODO: animation line for slide
		velocity.x = left_right * slide_speed # Load forces for move_and_slide()

func physics_collisions() -> void: # Called from _physics_process()
	# after calling move_and_slide()
	for i in range(get_slide_collision_count()): # Get collisions #, loop
		#TODO: Okay, the following line, -here-, creates wall-stick. it's grippier than meatboy.
		#self.velocity.y = 0
		#TODO: I'm going to implement this as a match option, in the future.
		var c = get_slide_collision(i) # Get collision, from # above
		if c.get_collider().is_in_group("balls"): # if the collision is with the ball
			self.velocity.y = 0 # ensure no upward flick of player on ball contact
			print("Ball!") # Log
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force) # Apply impulse forces to the ball in the appropriate direction
			#break # attempts to apply force once, by breaking the loop
	
func player_attack(_delta) -> void: # Called by player input from _physics_process()
	print("Attack!") # Log

func player_special(_delta) -> void: # Called by player input from _physics_process()
	print("Special!") # Log

func player_block(_delta) -> void: # Called by player input from _physics_process()
	print("Block!") # Log

func animation_controller(left_right) -> void: # called by _physics_process(), left_right = input direction
	if is_on_floor(): # what it says on the can
		if left_right == 0: # if no input
			player.play("idle") # animation
		elif left_right < -0.25: # Pressed Left, inner 25% deadzone
			sprite.flip_h = true # toggles mirror on; faces left
			player.play("run") # animation
		elif left_right > .25:
			sprite.flip_h = false # toggles mirror off; faces right
			player.play("run") # animation
	else: #when the player is not on the floor
		#TODO: if velocity.y < 0:
		player.play("jump")
		#TODO: elif velocity.y > 0:
		#TODO:	player.play("fall")

		# #TODO: Generate those sprites
	
	
