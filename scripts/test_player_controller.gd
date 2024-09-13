extends CharacterBody2D

#######################################################################################################################################################
## DECLARATIONS
# Nodes
@onready var sprite = get_node("Sprite") # Sprite, player_movement()
@onready var player = get_node("AnimationPlayer") # What it says on the can, player_movement() & player_jump() $ etc.
@onready var raycast = get_node("RayCast2D") # Ball detector, used in physics_collisions()
# Exports
@export var run_speed: int = 200 # Feels like a good lateral speed for now - was 200, feedback is better. player_movement()
@export var jump_speed: int = -400 # 400 is a little too high for the maps. 300 feels good. player_jump()
@export var slide_speed: int = 400 # Twice as fast as the old run value, player_slide()
@export var push_force: float = 200.0 # This represents the player's inertia, physics_collisions()
@export var near_range: Vector2 = Vector2( 37 , 25 ) # Nearness range in x and y for the ground, is_ball_near() & player_jump()
@export var far_range: Vector2 = Vector2( 40 , 35 ) # Nearness range in x and y for the air, is_ball_near() & player_jump()
# Local
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") # gravity = 980, player_movement()
var is_holding = false #TODO: Implement ball-posession feature???
var ball_position: Vector2 = Vector2.ZERO # For nearness, is_ball_near() & player_jump()
var player_position: Vector2 = Vector2.ZERO # For nearness, is_ball_near() & player_jump()

# Input
var left_right: float = 0 # Control Input, player_movement()

#######################################################################################################################################################
## CALLABLE CHECK FUNCTIONS
func is_slide() -> bool: # Called by player_jumps()
	return is_on_floor() and Input.is_action_pressed("blue_down")

func is_ball_near() -> bool: # Called from player_jump()
	ball_position = %Ball.position #Get ball position from transform
	player_position = self.position #Get self position from transform
	if is_on_floor():
		return abs(ball_position.x - player_position.x) < near_range.x and abs(ball_position.y - player_position.y) < near_range.y # If player and ball are within near_range of each other in x and y, return true
	return abs(ball_position.x - player_position.x) < far_range.x and abs(ball_position.y - player_position.y) < far_range.y

func variable_gravity(): # Game feel method. called by player_movement()
	if velocity.y > 0: # If we're falling
		return gravity * 1.3 # return double gravity and fall faster, snapping back to the ground
	return gravity # Else, return normal gravity

func is_on_top_of_ball() -> bool: # called by physics_collisions
	if raycast.is_colliding(): # what is says on the can
		var collider = raycast.get_collider() # figure out what's touching the raycast directly under the player
		#print("RayCast hit the ball!") # Logs
		return collider.is_in_group("balls") # True if on top of the ball, false if not
	return false
	        
#######################################################################################################################################################
## EXECUTION / MAIN
func _ready() -> void: # Called when the node enters the scene tree for the first time.
	pass

func _process(_delta: float) -> void:
	if Input.is_action_just_released("blue_jump") and velocity.y < 0:
		velocity.y = jump_speed / 3

func _physics_process(delta: float) -> void: # Called every frame. 'delta' is the elapsed time since the previous frame. 
	# We're gonna collect input here. We'll start by stashing it all in variables to pass it around where needed.
	left_right = Input.get_axis("blue_left", "blue_right") # Joystick; -1 for left, 1 for right, passing to player_movement() and animation_controller()
	#TODO:
	#TODO:
	#TODO: This is what we're working on now. Variables for passing. Booleans.

	
	# Then we're gonan execute with the above
	
	player_movement(delta) # Left/right/idle
	if Input.is_action_just_pressed("blue_jump"): # what it says on the can
		player_jump(delta)
	if Input.is_action_pressed("blue_jump") and Input.is_action_pressed("blue_down"): # This is a slide
		player_slide(delta)
	animation_controller() # Change Animations
	move_and_slide() # Execute movement accumulated above
	physics_collisions() # React to Physics, as per the movement.
	if Input.is_action_just_pressed("blue_attack"):
		player_attack(delta) 
	if Input.is_action_just_pressed("blue_special"):
		player_special(delta)
	if Input.is_action_just_pressed("blue_block"):
		player_block(delta)
	

#######################################################################################################################################################
## PLAYER ACTIONS
func player_movement(delta: float) -> void: # Player Controller, called by _physics_process()
	velocity.y += variable_gravity() * delta # apply variable gravity to character, depending on whether falling
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

func player_jump(_delta: float) -> void: # Called by player input from _physics_process()
	if !is_slide(): #Make sure we're not sliding
		velocity.y = jump_speed #omg Godot defines "Up" as -Y and NOT +Y. *sigh* 
		#print("Jump!") # Log
		if is_ball_near() and !is_on_top_of_ball(): # If ball is in range, but we're not directly on top of it
			%Ball.linear_velocity.y = 1.1 * jump_speed # Apply upward force to ball

func player_slide(_delta: float) -> void:
	# Without is_slide() here, this creates an air-dash. I think I like this air dash. 
	# But, Airie says she doesn't. I'm going to test it with. And I leave it only commented, if I hate it, rather than remove it.
	if is_slide():
		if sprite.flip_h == true: # If player is facing left
			left_right = -1 # Tune the forces to the left
		else: # else, we're facing right
			left_right = 1 # Keep the forces tuned to the right
		#print("Slide!") # Log
		velocity.x = left_right * slide_speed # Load forces for move_and_slide()
	
func player_attack(_delta: float) -> void: # Called by player input from _physics_process()
	print("Attack!") # Log

func player_special(_delta: float) -> void: # Called by player input from _physics_process()
	print("Special!") # Log

func player_block(_delta: float) -> void: # Called by player input from _physics_process()
	print("Block!") # Log

#######################################################################################################################################################
## CONTROLLERS
func physics_collisions() -> void: # Called from _physics_process()
	# after calling move_and_slide()
	for i in range(get_slide_collision_count()): # Get collisions #, loop
		#TODO: Okay, the following line, -here-, creates wall-stick. it's grippier than meatboy.
		#self.velocity.y = 0
		#TODO: I'm going to implement this as a match option, in the future.
		var c = get_slide_collision(i) # Get collision, from # above
		if c.get_collider().is_in_group("balls") and !is_on_top_of_ball(): # if the collision is with the ball, and we're not on top of it.
			self.velocity.y = 0 # ensure no upward flick of player on ball contact (well, mitigate it, there are still edge cases)
			#print("Ball!") # Log
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force) # Apply impulse forces to the ball in the appropriate direction
			#break # attempts to apply force once, by breaking the loop

func animation_controller() -> void: # called by _physics_process(), left_right = input direction
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
	
	
