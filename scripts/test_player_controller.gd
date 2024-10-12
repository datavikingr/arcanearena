extends CharacterBody2D

#######################################################################################################################################################
## DECLARATIONS
@export var player_color: String = "Purple" # This is how we're going to assign players to characters, and a lot of the sprite/animation controls.
# Nodes
@onready var sprite: Sprite2D = get_node("Sprite") # Sprite, player_movement()
@onready var player: AnimationPlayer = get_node("AnimationPlayer") # What it says on the can, player_movement() & player_jump() $ etc.
@onready var raycast:RayCast2D = get_node("TremorSense") # Ball detector, used in physics_collisions()
@onready var attack_cooldown = get_node("AttackCooldown") # Keeps from spamming attacks too bad.
@onready var reticle: Sprite2D = get_node("AimReticle") # Gotta aim somehow
@onready var player_attack_scene = preload("res://scenes/player_attack.tscn") # preload the player attack scene for instantiation later.
@onready var player_block_scene = preload("res://scenes/player_block.tscn") # preload the player block scene for instantiation later.
@onready var magic_layer: Node2D = %MagicLayer
# Exports
@export var run_speed: int = 200 # Feels like a good lateral speed for now - was 200, feedback is better. player_movement()
@export var jump_speed: int = -400 # 400 is a little too high for the maps. 300 feels good. player_jump()
@export var meteor_speed: int = 800 # 2x jump speed
@export var slide_speed: int = 400 # Twice as fast as the old run value, player_slide()
@export var push_force: float = 200.0 # This represents the player's inertia, physics_collisions()
@export var meteor_force: float = 1000.0 # This represents player inertia when meteor-striking
@export var near_range: Vector2 = Vector2( 37 , 25 ) # Nearness range in x and y for the ground, is_ball_near() & player_jump()
@export var far_range: Vector2 = Vector2( 40 , 35 ) # Nearness range in x and y for the air, is_ball_near() & player_jump()
@export var pinch_threshold: int = 900 # Lower threshold of delta v to trigger pinch state in _physics_collisions()
@export var max_pinch_force: float = 5000.0 # Upper threshold of pinch force applied in _physics_collisions()
# Local
var collision: KinematicCollision2D # Used in physics_collisions()
var collider: Object # Used in physics_collisions()
var pinch_multiplier: float = 1.15 # Used in physics_collisions()
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity") # gravity = 980, player_movement()
var ball_position: Vector2 = Vector2.ZERO # For nearness, is_ball_near() & player_jump()
var player_position: Vector2 = Vector2.ZERO # For nearness, is_ball_near() & player_jump()
var from_meteor: bool = false # Status flag for preventing automatically triggering player_slide after hitting ground from player_meteor()
# Animation Controls
var purple_frames: Array[int] = [] # TODO: This is going to be heavily motherfucking expanded, this is just a placeholder
# Input
var left_right: float = 0 # Control Input, player_movement()
var aim_left_right: float = 0 # Control Input, player_aim()
var aim_up_down: float = 0 # Control Input, player_aim()
var aim_direction: float = 0 # Control Input, player_aim()

#######################################################################################################################################################
## STATUS-CHECK / CALLABLE FUNCTIONS
func is_slide() -> bool: # Called by player_jumps(), variable_force()
	return is_on_floor() and Input.is_action_pressed("player1_down") and not from_meteor

func is_ball_near() -> bool: # Called from player_jump()
	ball_position = %Ball.position #Get ball position from transform
	player_position = self.position #Get self position from transform
	if is_on_floor():
		return abs(ball_position.x - player_position.x) < near_range.x and abs(ball_position.y - player_position.y) < near_range.y # If player and ball are within near_range of each other in x and y, return true
	return abs(ball_position.x - player_position.x) < far_range.x and abs(ball_position.y - player_position.y) < far_range.y

func variable_gravity(): # Game feel method. called by player_movement()
	if velocity.y > 0: # If we're falling
		return gravity * 1.4 # return 40% higher gravity and fall faster, snapping back to the ground
	if is_on_ramp():
		return gravity * 2.5 # return 2 times gravity, to keep that player glued to the ramp, on their slide down.
	if Input.is_action_pressed("player1_up"): # If the player is holding up
		return gravity * 0.8 # Let them jump higher under lower gravity
	return gravity # Else, return normal gravity

func variable_force(): # How hard we punch the ball, called by physics_collisions() controller.
	if from_meteor == true: # If we're down+A,
		return meteor_force # hit the ball extra hard @ 1000
	elif is_slide() and Input.is_action_pressed("player1_jump"): # If we're sliding; NOTE: is_slide assumes jump is pressed in its other uses cases (player_jump(), for instance)
		return push_force * 2 # 400
	else: # If we're just running
		return push_force # 200

func is_on_top_of_ball() -> bool: # called by physics_collisions()
	if raycast.is_colliding(): # what is says on the can - is it touching anything?
		#print("RayCast hit the ball!") # Logs
		return raycast.get_collider().is_in_group("balls")
	return false # false if not

func is_on_ramp() -> bool: # called by player_slide(), variable_gravity(), _physics_process()
	if raycast.is_colliding(): # what is says on the can - is it touching anything?
		var collider = raycast.get_collider()  # Get the collider object
		if collider and collider.is_in_group("ramps"):  # Check if the collider exists and is in the 'ramps' group
			return true  # Return true if the collider is in the 'ramps' group
	return false #false if not

#######################################################################################################################################################
## EXECUTION / MAIN
func _ready() -> void: # Called when the node enters the scene tree for the first time.
	self.name = player_color
	if player_color=="Blue" or player_color=="Green" or player_color=="Purple": # Cold Team
		self.add_to_group("ColdTeam") # for easier get_collisions() logic later
		collision_layer |= 1 << 9 # Exist on Cold Team collision layer
		collision_mask |= 1 << 13 # Collide with Hot Team layer
	else: # Hot Team
		self.add_to_group("HotTeam") # for easier get_collisions() logic later
		collision_layer |= 1 << 13 # Exist on Hot Team collision layer
		collision_mask |= 1 << 9 # Collide with Cold Team layer

func _process(_delta: float) -> void: # Called every frame. 'delta' is the elapsed time since the previous frame. Separate thread from _physics_process()
	if Input.is_action_just_released("player1_jump") and velocity.y < 0: # If we let go of jump
		velocity.y = jump_speed / 4 # Let gravity overtake us faster, by skrinking upward velocity, pulling us to the earth sooner.

func _physics_process(delta: float) -> void: # Called every frame. We're gonna collect input and execute control-functions here. Separate thread from _process().
	left_right = Input.get_axis("player1_left", "player1_right") # Joystick; -1 for left, 1 for right, passing to player_movement() and animation_controller()
	player_movement(delta) # Left/right/idle
	aim_left_right = Input.get_joy_axis(0,JOY_AXIS_RIGHT_X) # Right Joystick X
	aim_up_down = Input.get_joy_axis(0,JOY_AXIS_RIGHT_Y) # Right Joystick X
	player_aim()
	if Input.is_action_just_pressed("player1_jump"): # what it says on the can
		player_jump(delta) # Execute jump
	if Input.is_action_pressed("player1_jump") and Input.is_action_pressed("player1_down"): # This is a slide
		if is_on_floor() or is_on_ramp(): #Places we're allowed to slide
			player_slide(delta) # Execute jump
		else: # if we're not on the floor or a ramp, we're in the air
			player_meteor(delta) # METEOR TIME
	if Input.is_action_just_released("player1_jump"): # This catch is to prevent auto-slide after a meteor. Gotta release jump to slide again (except on ramps).
		from_meteor = false #Reset our flag
		raycast.enabled = true # Turns ball detector back on for is_on_top_of_ball()
	if Input.is_action_just_pressed("player1_attack") and abs(aim_left_right) < 0.25 and abs(aim_up_down) < 0.25:
		player_attack(delta)
	if Input.is_action_just_pressed("player1_attack") and abs(aim_left_right) >= 0.25 and abs(aim_up_down) >= 0.25:
		#player_missile() TODO
		pass
	if Input.is_action_just_pressed("player1_block") and is_on_floor():
		player_block(delta)
	if Input.is_action_just_pressed("player1_special"):
		player_special(delta)
	animation_controller() # Change Animations
	move_and_slide() # Execute movement accumulated above
	physics_collisions() # React to Physics, as per the movement.

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

func player_aim() ->void:
	if abs(aim_left_right) < 0.25 and abs(aim_up_down) < 0.25:
		reticle.visible = false
	else:
		reticle.visible = true
		aim_direction = atan2(aim_left_right, -aim_up_down)
		reticle = get_node("AimReticle")
		reticle.rotation = aim_direction

func player_jump(_delta: float) -> void: # Called by player input from _physics_process()
	if !is_slide(): #Make sure we're not sliding
		velocity.y = jump_speed #omg Godot defines "Up" as -Y and NOT +Y. *sigh*
		#print("Jump!") # Log
		if is_ball_near() and !is_on_top_of_ball(): # If ball is in range, but we're not directly on top of it
			%Ball.linear_velocity.y = 1.1 * jump_speed # Apply upward force to ball

func player_slide(_delta: float) -> void:
	# Without is_slide() here, this creates an air-dash. I think I like this air dash.
	# But, Airie says she doesn't. I'm going to test it with. And I leave it only commented, if I hate it, rather than remove it.
	if (is_slide() and is_on_ramp() and from_meteor) or (is_slide() and not from_meteor):
		if sprite.flip_h == true: # If player is facing left
			left_right = -1 # Tune the forces to the left
		else: # else, we're facing right
			left_right = 1 # Keep the forces tuned to the right
		#print("Slide!") # Log
		velocity.x = left_right * slide_speed # Load forces for move_and_slide()

func player_meteor(_delta: float) -> void: 	# Meteor strike downward
	#print("Meteor!") # Log
	raycast.enabled = false # Turns ball detector OFF [for is_on_top_of_ball()], allowing us to pinch the ball, maybe? Returns to normal on Jump-just released in _physics_process()
	velocity.y = meteor_speed # Drop really fast; 800
	from_meteor = true # Set Flag on. Returns to normal on Jump-just released in _physics_process()

func player_attack(_delta: float) -> void: # Called by player input from _physics_process()
	# NOTE: Players do not collide with melee attacks by default - rather, the attack colides with them. This lets players move their melee attack.
	if attack_cooldown.is_stopped():
		attack_cooldown.start()
		print("Attack!") # Log
		var new_attack = player_attack_scene.instantiate() # Instantiate the preloaded scene
		if sprite.flip_h == false: # If the wiz is facing right.
			new_attack.global_position = get_global_position() + Vector2(16, 0) # Small offset, makes sure it appears outside the player body, on the right side.
		else: # Then the wizard's facing left
			new_attack.global_position = get_global_position() + Vector2(-16, 0) # Small offset, makes sure it appears outside the player body, on the left side.
		new_attack.set("player_color", player_color) # I hope this works.
		if player_color=="Blue" or player_color=="Green" or player_color=="Purple":
			new_attack.add_to_group("ColdTeam") # for easier get_collisions() logic
			new_attack.collision_layer |= 1 << 9 # Exist on Cold Team collision layer
			new_attack.collision_mask |= 1 << 13 # Collide with Hot Team layer
		else:
			new_attack.add_to_group("HotTeam") # for easier get_collisions() logic
			new_attack.collision_layer |= 1 << 13 # Exist on Hot Team collision layer
			new_attack.collision_mask |= 1 << 9 # Collide with Cold Team layer
	# NOTE: After the above, players will collide with the opposite teams' attacks, and visa versa (from the default)
		magic_layer.add_child(new_attack) # Add the new instance as a child of the current node

func player_block(_delta: float) -> void: # Called by player input from _physics_process()
	# NOTE: Players collide with blocking walls by default, stopping the players in their tracks.
	print("Block!") # Log
	var block_name = "PlayerBlock_" + player_color # Search for existing blocks with the same name
	for child in magic_layer.get_children(): # Check the magic layer
		if child.name == block_name: # If we already one of these spawned,
			child.free() # Free the existing block and kill it, so we can make the new one.
	var new_block = player_block_scene.instantiate() # Instantiate the preloaded scene
	if sprite.flip_h == false: # If the wiz is facing right.
		new_block.global_position = get_global_position() + Vector2(16, 0) # Small offset, makes sure it appears outside the player body, on the right side.
	else: # Then the wizard's facing left
		new_block.global_position = get_global_position() + Vector2(-16, 0) # Small offset, makes sure it appears outside the player body, on the left side.
	new_block.set("player_color", player_color) # I hope this works. // It totally worked!
	if player_color=="Blue" or player_color=="Green" or player_color=="Purple":
		new_block.add_to_group("ColdTeam") # for easier get_collisions() logic
		new_block.collision_layer |= 1 << 9 # Exist on Cold Team collision layer
		new_block.collision_mask |= 1 << 13 # Look on Hot Team collision layer
	else:
		new_block.add_to_group("HotTeam") # for easier get_collisions() logic
		new_block.collision_layer |= 1 << 13 # Exist on Hot Team collision layer
		new_block.collision_mask |= 1 << 9 # Look on Cold Team collision layer
	magic_layer.add_child(new_block) # Add the new instance as a child of the current node

func player_special(_delta: float) -> void: # Called by player input from _physics_process()
	print("Special!") # Log

#######################################################################################################################################################
## CONTROLLERS
func physics_collisions() -> void: # Called from _physics_process()
	# after calling move_and_slide()
	for i in range(get_slide_collision_count()): # Get collisions #, loop
		#TODO: Okay, the following line, -here-, creates wall-stick. it's grippier than meatboy.
		#self.velocity.y = 0
		#TODO: I'm going to implement this as a match option, in the future.
		collision = get_slide_collision(i) # Get collision, from # above
		collider = collision.get_collider()
		if collider.is_in_group("balls") and not is_on_top_of_ball() and not collider.is_in_group("ramps"): # if the collision is with the ball, and we're not on top of it.
			#print("Ball!") # Log
			var relative_velocity = collider.linear_velocity - velocity # Relative velocity between player and ball
			var normal = collision.get_normal() # Collision normal vector
			var pinch_factor = relative_velocity.dot(normal) # Pinch factor based on collision speed
			if pinch_factor > pinch_threshold: # Do we exceed the delta-v pinch threshold of 900?
				var pinch_force = pinch_factor * pinch_multiplier # We're adding forces
				pinch_force = clamp(pinch_force, 0, max_pinch_force) # Up to a limit
				var impulse = -normal * pinch_force
				collider.apply_central_impulse(impulse) #
			else:
				collider.apply_central_impulse(-normal * variable_force()) # Apply impulse forces to the ball in the appropriate direction

func animation_controller() -> void: # called by _physics_process(), left_right = input direction
	if is_on_floor(): # what it says on the can
		sprite.flip_v = false
		sprite.rotation = 0
		if left_right >= -0.25 and left_right <= 0.25: # if no input
			idle_squat_stretch()
		elif left_right < -0.25: # Pressed Left, inner 25% deadzone
			sprite.flip_h = true # toggles mirror on; faces left
			run_slide_animation()
		elif left_right > .25:
			sprite.flip_h = false # toggles mirror off; faces right
			run_slide_animation()
	else: #when the player is not on the floor
		jump_fall_meteor()
		# #TODO: Generate those sprites

#######################################################################################################################################################
## SPECIFIC ANIMATION LOGIC
func run_slide_animation() -> void:
	if abs(velocity.x) == 200: # If we're running
		player.play("run") # moving animation
	elif abs(velocity.x) == 400: # If we're sliding
		player.play("slide")

func idle_squat_stretch() -> void:
	if Input.is_action_pressed("player1_down"):
		player.play("squat")
	elif Input.is_action_pressed("player1_up"):
		player.play("stretch")
	else:
		player.play("idle")

func jump_fall_meteor() -> void:
	if velocity.y > 400: # NOTE: Y-inverse; Our y is increasing, meaning we're falling fast - it's a meteor
		#TODO: player.play("meteor")
		sprite.flip_v = true
		player.play("jump")
	elif velocity.y > 0 and abs(left_right) < .25 : # NOTE: Y-inverse; Our y is increasing, meaning we're falling, but idle
		player.play("falldown")
	elif velocity.y > 0 and left_right > 0.25: # NOTE: Y-inverse; Our y is increasing, meaning we're falling, but directing the fall sideways
		sprite.flip_h = false # toggles mirror off; faces right
		player.play("fallsideways")
	elif velocity.y > 0 and left_right < -0.25: # NOTE: Y-inverse; Our y is increasing, meaning we're falling, but directing the fall sideways
		sprite.flip_h = true # toggles mirror off; faces right
		player.play("fallsideways")
	else: # NOTE: Y-inverse; we're ascending eg, jumping
		sprite.flip_v = false
		player.play("jump")
	pass
