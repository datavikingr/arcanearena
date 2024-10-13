extends CharacterBody2D

#######################################################################################################################################################
## DECLARATIONS
@export var player_color: String = "Orange" # This is how we're going to assign players to characters, and a lot of the sprite/animation controls.
# Nodes
@onready var sprite: Sprite2D = get_node("Sprite") # Sprite, player_movement()
@onready var player: AnimationPlayer = get_node("AnimationPlayer") # What it says on the can, player_movement() & player_jump() $ etc.
@onready var raycast:RayCast2D = get_node("TremorSense") # Ball detector, used in physics_collisions()
@onready var attack_cooldown = get_node("AttackCooldown") # Keeps from spamming attacks too bad.
@onready var reticle: Sprite2D = get_node("AimReticle") # Gotta aim somehow
@onready var player_attack_scene = preload("res://scenes/player_attack.tscn") # preload the player attack scene for instantiation later.
@onready var player_missile_scene = preload("res://scenes/player_missile.tscn") # preload the player missile scene for instantiation later.
@onready var player_block_scene = preload("res://scenes/player_block.tscn") # preload the player block scene for instantiation later.
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var magic_layer: Node2D = %MagicLayer
@onready var blue_ui: Node2D = %BlueUI
@onready var green_ui: Node2D = %GreenUI
@onready var purple_ui: Node2D = %PurpleUI
@onready var red_ui: Node2D = %RedUI
@onready var yellow_ui: Node2D = %YellowUI
@onready var orange_ui: Node2D = %OrangeUI
# Exports
@export var hp: int = 3 # Players spawn in with 3 HP.
@export var goals: int = 0
@export var kills: int = 0
@export var deaths: int = 0
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
var ui_layer: Node2D
var collision: KinematicCollision2D # Used in physics_collisions()
var collider: Object # Used in physics_collisions()
var pinch_multiplier: float = 1.15 # Used in physics_collisions()
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity") # gravity = 980, player_movement()
var ball_position: Vector2 = Vector2.ZERO # For nearness, is_ball_near() & player_jump()
var player_position: Vector2 = Vector2.ZERO # For nearness, is_ball_near() & player_jump()
var from_meteor: bool = false # Status flag for preventing automatically triggering player_slide after hitting ground from player_meteor()
var anim_name: String
var anim: Animation
# Animation Controls
var player_start = {"Blue": 0, "Green": 24, "Purple": 48, "Red": 72, "Yellow": 96, "Orange": 120}
# Generics
var idle_frames
var run_frames
var jump_frames
var fall_frames
var side_fall_frames
var slide_frames
var death_frames
var special_frames
var meteor_sprite
# Blue
var blue_idle_frames: Array[int] = [0,1]
var blue_run_frames: Array[int] = [2,3]
var blue_jump_frames: Array[int] = [4,5]
var blue_fall_frames: Array[int] = [6,7]
var blue_side_fall_frames: Array[int] = [8,9]
var blue_slide_frames: Array[int] = [10,11]
var blue_death_frames: Array[int] = [12,13]
var blue_special_frames: Array[int] = [14,15]
var blue_meteor_sprite: int = 20
# Green
var green_idle_frames: Array = blue_idle_frames.map(func(x): return x + player_start["Green"])
var green_run_frames: Array = blue_run_frames.map(func(x): return x + player_start["Green"])
var green_jump_frames: Array = blue_jump_frames.map(func(x): return x + player_start["Green"])
var green_fall_frames: Array = blue_fall_frames.map(func(x): return x + player_start["Green"])
var green_side_fall_frames: Array = blue_side_fall_frames.map(func(x): return x + player_start["Green"])
var green_slide_frames: Array = blue_slide_frames.map(func(x): return x + player_start["Green"])
var green_death_frames: Array = blue_death_frames.map(func(x): return x + player_start["Green"])
var green_special_frames: Array = blue_special_frames.map(func(x): return x + player_start["Green"])
var green_meteor_sprite: int = blue_meteor_sprite + player_start["Green"]
# Purple
var purple_idle_frames: Array = blue_idle_frames.map(func(x): return x + player_start["Purple"])
var purple_run_frames: Array = blue_run_frames.map(func(x): return x + player_start["Purple"])
var purple_jump_frames: Array = blue_jump_frames.map(func(x): return x + player_start["Purple"])
var purple_fall_frames: Array = blue_fall_frames.map(func(x): return x + player_start["Purple"])
var purple_side_fall_frames: Array = blue_side_fall_frames.map(func(x): return x + player_start["Purple"])
var purple_slide_frames: Array = blue_slide_frames.map(func(x): return x + player_start["Purple"])
var purple_death_frames: Array = blue_death_frames.map(func(x): return x + player_start["Purple"])
var purple_special_frames: Array = blue_special_frames.map(func(x): return x + player_start["Purple"])
var purple_meteor_sprite: int = blue_meteor_sprite + player_start["Purple"]
# Red
var red_idle_frames: Array = blue_idle_frames.map(func(x): return x + player_start["Red"])
var red_run_frames: Array = blue_run_frames.map(func(x): return x + player_start["Red"])
var red_jump_frames: Array = blue_jump_frames.map(func(x): return x + player_start["Red"])
var red_fall_frames: Array = blue_fall_frames.map(func(x): return x + player_start["Red"])
var red_side_fall_frames: Array = blue_side_fall_frames.map(func(x): return x + player_start["Red"])
var red_slide_frames: Array = blue_slide_frames.map(func(x): return x + player_start["Red"])
var red_death_frames: Array = blue_death_frames.map(func(x): return x + player_start["Red"])
var red_special_frames: Array = blue_special_frames.map(func(x): return x + player_start["Red"])
var red_meteor_sprite: int = blue_meteor_sprite + player_start["Red"]
# Yellow
var yellow_idle_frames: Array = blue_idle_frames.map(func(x): return x + player_start["Yellow"])
var yellow_run_frames: Array = blue_run_frames.map(func(x): return x + player_start["Yellow"])
var yellow_jump_frames: Array = blue_jump_frames.map(func(x): return x + player_start["Yellow"])
var yellow_fall_frames: Array = blue_fall_frames.map(func(x): return x + player_start["Yellow"])
var yellow_side_fall_frames: Array = blue_side_fall_frames.map(func(x): return x + player_start["Yellow"])
var yellow_slide_frames: Array = blue_slide_frames.map(func(x): return x + player_start["Yellow"])
var yellow_death_frames: Array = blue_death_frames.map(func(x): return x + player_start["Yellow"])
var yellow_special_frames: Array = blue_special_frames.map(func(x): return x + player_start["Yellow"])
var yellow_meteor_sprite: int = blue_meteor_sprite + player_start["Yellow"]
# Orange
var orange_idle_frames: Array = blue_idle_frames.map(func(x): return x + player_start["Orange"])
var orange_run_frames: Array = blue_run_frames.map(func(x): return x + player_start["Orange"])
var orange_jump_frames: Array = blue_jump_frames.map(func(x): return x + player_start["Orange"])
var orange_fall_frames : Array= blue_fall_frames.map(func(x): return x + player_start["Orange"])
var orange_side_fall_frames: Array = blue_side_fall_frames.map(func(x): return x + player_start["Orange"])
var orange_slide_frames: Array = blue_slide_frames.map(func(x): return x + player_start["Orange"])
var orange_death_frames: Array = blue_death_frames.map(func(x): return x + player_start["Orange"])
var orange_special_frames: Array = blue_special_frames.map(func(x): return x + player_start["Orange"])
var orange_meteor_sprite: int= blue_meteor_sprite + player_start["Orange"]
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
		collider = raycast.get_collider()  # Get the collider object
		if collider and collider.is_in_group("ramps"):  # Check if the collider exists and is in the 'ramps' group
			return true  # Return true if the collider is in the 'ramps' group
	return false #false if not

#######################################################################################################################################################
## CONSTRUCTORS
func set_up_animations() -> void:
	pass

#######################################################################################################################################################
## EXECUTION / MAIN
func _ready() -> void: # Called when the node enters the scene tree for the first time.
	self.name = player_color
	match player_color:
		"Blue":
			ui_layer = blue_ui
			self.add_to_group("ColdTeam") # for easier get_collisions() logic later
			collision_layer |= 1 << 9 # Exist on Cold Team collision layer
			collision_mask |= 1 << 13 # Collide with Hot Team layer
			idle_frames = blue_idle_frames
			run_frames = blue_run_frames
			jump_frames = blue_jump_frames
			fall_frames = blue_fall_frames
			side_fall_frames = blue_side_fall_frames
			slide_frames = blue_slide_frames
			death_frames = blue_death_frames
			special_frames = blue_special_frames
			meteor_sprite = blue_meteor_sprite
		"Green":
			ui_layer = green_ui
			self.add_to_group("ColdTeam") # for easier get_collisions() logic later
			collision_layer |= 1 << 9 # Exist on Cold Team collision layer
			collision_mask |= 1 << 13 # Collide with Hot Team layer
			idle_frames = green_idle_frames
			run_frames = green_run_frames
			jump_frames = green_jump_frames
			fall_frames = green_fall_frames
			side_fall_frames = green_side_fall_frames
			slide_frames = green_slide_frames
			death_frames = green_death_frames
			special_frames = green_special_frames
			meteor_sprite = green_meteor_sprite
		"Purple":
			ui_layer = purple_ui
			self.add_to_group("ColdTeam") # for easier get_collisions() logic later
			collision_layer |= 1 << 9 # Exist on Cold Team collision layer
			collision_mask |= 1 << 13 # Collide with Hot Team layer
			idle_frames = purple_idle_frames
			run_frames = blue_run_frames
			jump_frames = blue_jump_frames
			fall_frames = blue_fall_frames
			side_fall_frames = blue_side_fall_frames
			slide_frames = blue_slide_frames
			death_frames = blue_death_frames
			special_frames = blue_special_frames
			meteor_sprite = blue_meteor_sprite
		"Red:":
			ui_layer = red_ui
			self.add_to_group("HotTeam") # for easier get_collisions() logic later
			collision_layer |= 1 << 13 # Exist on Hot Team collision layer
			collision_mask |= 1 << 9 # Collide with Cold Team layer
			idle_frames = red_idle_frames
			run_frames = red_run_frames
			jump_frames = red_jump_frames
			fall_frames = red_fall_frames
			side_fall_frames = red_side_fall_frames
			slide_frames = red_slide_frames
			death_frames = red_death_frames
			special_frames = red_special_frames
			meteor_sprite = red_meteor_sprite
		"Yellow":
			ui_layer = yellow_ui
			self.add_to_group("HotTeam") # for easier get_collisions() logic later
			collision_layer |= 1 << 13 # Exist on Hot Team collision layer
			collision_mask |= 1 << 9 # Collide with Cold Team layer
			idle_frames = yellow_idle_frames
			run_frames = yellow_run_frames
			jump_frames = yellow_jump_frames
			fall_frames = yellow_fall_frames
			side_fall_frames = yellow_side_fall_frames
			slide_frames = yellow_slide_frames
			death_frames = yellow_death_frames
			special_frames = yellow_special_frames
			meteor_sprite = yellow_meteor_sprite
		"Orange":
			ui_layer = orange_ui
			self.add_to_group("HotTeam") # for easier get_collisions() logic later
			collision_layer |= 1 << 13 # Exist on Hot Team collision layer
			collision_mask |= 1 << 9 # Collide with Cold Team layer
			idle_frames = orange_idle_frames
			run_frames = orange_run_frames
			jump_frames = orange_jump_frames
			fall_frames = orange_fall_frames
			side_fall_frames = orange_side_fall_frames
			slide_frames = orange_slide_frames
			death_frames = orange_death_frames
			special_frames = orange_special_frames
			meteor_sprite = orange_meteor_sprite

func _process(_delta: float) -> void: # Called every frame. 'delta' is the elapsed time since the previous frame. Separate thread from _physics_process()
	if Input.is_action_just_released("player1_jump") and velocity.y < 0: # If we let go of jump
		velocity.y = jump_speed / 4 # Let gravity overtake us faster, by skrinking upward velocity, pulling us to the earth sooner.
	update_ui()

func _physics_process(delta: float) -> void: # Called every frame. We're gonna collect input and execute control-functions here. Separate thread from _process().
	left_right = Input.get_axis("player1_left", "player1_right") # Joystick; -1 for left, 1 for right, passing to player_movement() and animation_controller()
	player_movement(delta) # Left/right/idle
	aim_left_right = Input.get_joy_axis(0,JOY_AXIS_RIGHT_X) # Right Joystick X
	aim_up_down = Input.get_joy_axis(0,JOY_AXIS_RIGHT_Y) # Right Joystick X
	player_aim(delta)
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

func player_aim(delta: float) ->void:
	if abs(aim_left_right) < 0.25 and abs(aim_up_down) < 0.25:
		reticle.visible = false
	else:
		reticle.visible = true
		aim_direction = atan2(aim_left_right, -aim_up_down)
		reticle = get_node("AimReticle")
		reticle.rotation = aim_direction
		if Input.is_action_just_pressed("player1_attack"):
			player_missile(delta)

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
	#print("Meteor!") # Debug
	raycast.enabled = false # Turns ball detector OFF [for is_on_top_of_ball()], allowing us to pinch the ball, maybe? Returns to normal on Jump-just released in _physics_process()
	velocity.y = meteor_speed # Drop really fast; 800
	from_meteor = true # Set Flag on. Returns to normal on Jump-just released in _physics_process()

func player_attack(_delta: float) -> void: # Called by player input from _physics_process()
	# NOTE: Players do not collide with melee attacks by default - rather, the attack colides with them. This lets players move their melee attack.
	if attack_cooldown.is_stopped(): # Don't let players spam attack more than once every 0.75 seconds
		attack_cooldown.start() # Start cooldown timer
		print("Attack!") # Debug
		var new_attack = player_attack_scene.instantiate() # Instantiate the preloaded scene
		if sprite.flip_h == false: # If the wiz is facing right.
			new_attack.global_position = get_global_position() + Vector2(16, 0) # Small offset, makes sure it appears outside the player body, on the right side.
		else: # Then the wizard's facing left
			new_attack.global_position = get_global_position() + Vector2(-16, 0) # Small offset, makes sure it appears outside the player body, on the left side.
		new_attack.set("player_color", player_color) # I hope this works. // It totally worked!
		if player_color=="Blue" or player_color=="Green" or player_color=="Purple":
			new_attack.add_to_group("ColdTeam") # for easier get_collisions() logic
			new_attack.collision_layer |= 1 << 9 # Exist on Cold Team collision layer
			new_attack.collision_mask |= 1 << 13 # Collide with Hot Team layer
		else:
			new_attack.add_to_group("HotTeam") # for easier get_collisions() logic
			new_attack.collision_layer |= 1 << 13 # Exist on Hot Team collision layer
			new_attack.collision_mask |= 1 << 9 # Collide with Cold Team layer
	# NOTE: After the above, players will collide with the opposite teams' attacks, and visa versa (from the default)
		magic_layer.add_child(new_attack) # Add the new instance as a child of the magic layer node

func player_missile(_delta: float) -> void:
	if attack_cooldown.is_stopped(): # Don't let players spam attack more than once every 0.75 seconds
		attack_cooldown.start() # Start cooldown timer
		var new_missile = player_missile_scene.instantiate() # Instantiate the preloaded scene
		var projectile_start_pos = global_position + Vector2(cos(aim_direction - PI / 2), sin(aim_direction - PI / 2)) * 24
		new_missile.global_position = projectile_start_pos # place it in the world
		new_missile.set("direction", Vector2(cos(aim_direction- PI / 2), sin(aim_direction - PI / 2))) #.normalized()) # Set the direction of the projectile
		new_missile.set("player_color", player_color) # I hope this works. // It totally worked!
		new_missile.rotation = aim_direction - PI / 2
		if player_color=="Blue" or player_color=="Green" or player_color=="Purple":
			new_missile.add_to_group("ColdTeam") # for easier get_collisions() logic
			new_missile.collision_layer |= 1 << 9 # Exist on Cold Team collision layer
			new_missile.collision_mask |= 1 << 13 # Collide with Hot Team layer
		else:
			new_missile.add_to_group("HotTeam") # for easier get_collisions() logic
			new_missile.collision_layer |= 1 << 13 # Exist on Hot Team collision layer
			new_missile.collision_mask |= 1 << 9 # Collide with Cold Team layer
	# NOTE: After the above, players will collide with the opposite teams' attacks, and visa versa (from the default)
		magic_layer.add_child(new_missile) # Add the new instance as a child of the magic layer node

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
	magic_layer.add_child(new_block) # Add the new instance as a child of the magic layer node

func player_special(_delta: float) -> void: # Called by player input from _physics_process()
	print("Special!") # Log

#######################################################################################################################################################
## CONTROLLERS
func update_ui() -> void: # called from _process()
	ui_layer.set("hp", hp)
	ui_layer.set("goals", goals)
	ui_layer.set("kills", kills)
	ui_layer.set("deaths", deaths)
	pass

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
		if left_right >= -0.25 and left_right <= 0.25: # no horizontal input exceeding deadzone
			if Input.is_action_pressed("player1_down"): # but we're pressing down
				player.play("squat") # tea-bag/flapjack
				#play_squat_animation()
			elif Input.is_action_pressed("player1_up"):# but we're pressing up
				player.play("stretch") #reach for the sky
				#play_stretch_animation()
			else: # no vertical input either
				player.play("idle")
				#play_idle_animation()
		elif left_right < -0.25: # Pressed Left, inner 25% deadzone
			sprite.flip_h = true # toggles mirror on; faces left
			if abs(velocity.x) == 200: # If we're running
				player.play("run") # moving animation
				#play_run_animation()
			elif abs(velocity.x) == 400: # If we're sliding
				player.play("slide")
				#play_slide_animation()
		elif left_right > .25:
			sprite.flip_h = false # toggles mirror off; faces right
			if abs(velocity.x) == 200: # If we're running
				player.play("run") # moving animation
				#play_run_animation()
			elif abs(velocity.x) == 400: # If we're sliding
				player.play("slide")
				#play_slide_animation()
	else: #when the player is not on the floor
		if velocity.y > 400: # NOTE: Y-inverse; Our y is increasing, meaning we're falling fast - it's a meteor
			sprite.flip_v = true
			player.play("jump")
			#play_meteor_animation()
		elif velocity.y > 0 and abs(left_right) < .25 : # NOTE: Y-inverse; Our y is increasing, meaning we're falling, but idle
			player.play("falldown")
			#play_fall_animation()
		elif velocity.y > 0 and left_right > 0.25: # NOTE: Y-inverse; Our y is increasing, meaning we're falling, but directing the fall sideways
			sprite.flip_h = false # toggles mirror off; faces right
			player.play("fallsideways")
			#play_side_fall_animation()
		elif velocity.y > 0 and left_right < -0.25: # NOTE: Y-inverse; Our y is increasing, meaning we're falling, but directing the fall sideways
			sprite.flip_h = true # toggles mirror off; faces right
			player.play("fallsideways")
			#play_side_fall_animation()
		else: # NOTE: Y-inverse; we're ascending eg, jumping
			sprite.flip_v = false
			player.play("jump")
			#play_jump_animation()

#######################################################################################################################################################
## ANIMATIONS

func play_idle_animation():
	#NOTE: 1 second length, half-periodicity
	animation_player.stop()  # Stop any current animations
	anim = animation_player.get_animation("idle") # Get the thing we'd like to play
	if anim: # Check if the animation exists
		# Get the specific track for the sprite frame and collision shape size
		var sprite_track_index = anim.find_track("Sprite:frame", Animation.TYPE_VALUE)
		if sprite_track_index != -1: # Modify the tracks or insert keyframes, if necessary
			anim.track_insert_key(sprite_track_index, 0.00, idle_frames[0]) # Frame 0 at 0 seconds
			anim.track_insert_key(sprite_track_index, 0.5, idle_frames[1]) # Frame 1 at 0.5 seconds
		var spritepos_track_index = anim.find_track("Sprite:position", Animation.TYPE_VALUE)
		if spritepos_track_index != -1:
			anim.track_insert_key(spritepos_track_index, 0.00, Vector2(0,7)) # Frame 0 at 0 seconds
			anim.track_insert_key(spritepos_track_index, 0.5, Vector2(0,7)) # Frame 1 at 0.5 seconds
		var trailleft_track_index = anim.find_track("TrailLeft:position", Animation.TYPE_VALUE)
		if trailleft_track_index != -1:
			anim.track_insert_key(trailleft_track_index, 0.00, Vector2(0.5,-2.5)) # Frame 0 at 0 seconds
			anim.track_insert_key(trailleft_track_index, 0.5, Vector2(0.5,-3.5)) # Frame 1 at 0.5 seconds
		var trailright_track_index = anim.find_track("TrailRight:position", Animation.TYPE_VALUE)
		if trailright_track_index != -1:
			anim.track_insert_key(trailright_track_index, 0.00, Vector2(2.5,-2.5)) # Frame 0 at 0 seconds
			anim.track_insert_key(trailright_track_index, 0.5, Vector2(2.5,-3.5)) # Frame 1 at 0.5 seconds
		var trailleftvis_track_index = anim.find_track("TrailLeft:visibility", Animation.TYPE_VALUE)
		if trailleftvis_track_index != -1:
			anim.track_insert_key(trailleftvis_track_index, 0.00, true) # Frame 0 at 0 seconds
		var trailrightvis_track_index = anim.find_track("TrailRight:visibility", Animation.TYPE_VALUE)
		if trailrightvis_track_index != -1:
			anim.track_insert_key(trailrightvis_track_index, 0.00, true) # Frame 0 at 0 seconds
		var meteorspike_track_index = anim.find_track("MeteorSpike:visible", Animation.TYPE_VALUE)
		if meteorspike_track_index != -1:
			anim.track_insert_key(meteorspike_track_index, 0.00, false)
	animation_player.play("idle") # Play what we just assembled

func play_run_animation():
	#NOTE: .4 second length, half-periodicity
	animation_player.stop()  # Stop any current animations
	anim = animation_player.get_animation("run") # Get the thing we'd like to play
	if anim: # Check if the animation exists
		# Get the specific track for the sprite frame and collision shape size
		var sprite_track_index = anim.find_track("Sprite:frame", Animation.TYPE_VALUE)
		if sprite_track_index != -1: # Modify the tracks or insert keyframes, if necessary
			anim.track_insert_key(sprite_track_index, 0.00, run_frames[0]) # Frame 0 at 0 seconds
			anim.track_insert_key(sprite_track_index, 0.5, run_frames[1]) # Frame 1 at 0.5 seconds
		var spritepos_track_index = anim.find_track("Sprite:position", Animation.TYPE_VALUE)
		if spritepos_track_index != -1:
			anim.track_insert_key(spritepos_track_index, 0.00, Vector2(0,7)) # Frame 0 at 0 seconds
			anim.track_insert_key(spritepos_track_index, 0.5, Vector2(0,8)) # Frame 1 at 0.5 seconds
		var trailleft_track_index = anim.find_track("TrailLeft:position", Animation.TYPE_VALUE)
		if trailleft_track_index != -1:
			anim.track_insert_key(trailleft_track_index, 0.00, Vector2(0.5,-2.5)) # Frame 0 at 0 seconds
			anim.track_insert_key(trailleft_track_index, 0.5, Vector2(0.5,-0.5)) # Frame 1 at 0.5 seconds
		var trailright_track_index = anim.find_track("TrailRight:position", Animation.TYPE_VALUE)
		if trailright_track_index != -1:
			anim.track_insert_key(trailright_track_index, 0.00, Vector2(2.5,-2.5)) # Frame 0 at 0 seconds
			anim.track_insert_key(trailright_track_index, 0.5, Vector2(2.5,-0.5)) # Frame 1 at 0.5 seconds
		var trailleftvis_track_index = anim.find_track("TrailLeft:visibility", Animation.TYPE_VALUE)
		if trailleftvis_track_index != -1:
			anim.track_insert_key(trailleftvis_track_index, 0.00, true) # Frame 0 at 0 seconds
		var trailrightvis_track_index = anim.find_track("TrailRight:visibility", Animation.TYPE_VALUE)
		if trailrightvis_track_index != -1:
			anim.track_insert_key(trailrightvis_track_index, 0.00, true) # Frame 0 at 0 seconds
		var meteorspike_track_index = anim.find_track("MeteorSpike:visible", Animation.TYPE_VALUE)
		if meteorspike_track_index != -1:
			anim.track_insert_key(meteorspike_track_index, 0.00, false)
	animation_player.play("run") # Play what we just assembled

func play_jump_animation():
	#NOTE: 5 second length, no periodicity
	animation_player.stop()  # Stop any current animations
	anim = animation_player.get_animation("jump") # Get the thing we'd like to play
	if anim: # Check if the animation exists
		# Get the specific track for the sprite frame and collision shape size
		var sprite_track_index = anim.find_track("Sprite:frame", Animation.TYPE_VALUE)
		if sprite_track_index != -1: # Modify the tracks or insert keyframes, if necessary
			anim.track_insert_key(sprite_track_index, 0.00, jump_frames[0]) # Frame 0 at 0 seconds
			anim.track_insert_key(sprite_track_index, 0.15, jump_frames[1]) # Frame 1 at 0.5 seconds
		var spritepos_track_index = anim.find_track("Sprite:position", Animation.TYPE_VALUE)
		if spritepos_track_index != -1:
			anim.track_insert_key(spritepos_track_index, 0.00, Vector2(0,9)) # Frame 0 at 0 seconds
			anim.track_insert_key(spritepos_track_index, 0.15, Vector2(0,7)) # Frame 1 at 0.5 seconds
		var trailleft_track_index = anim.find_track("TrailLeft:position", Animation.TYPE_VALUE)
		if trailleft_track_index != -1:
			anim.track_insert_key(trailleft_track_index, 0.00, Vector2(-1.5,1.5)) # Frame 0 at 0 seconds
			anim.track_insert_key(trailleft_track_index, 0.15, Vector2(-1.5,-5.5)) # Frame 1 at 0.5 seconds
		var trailright_track_index = anim.find_track("TrailRight:position", Animation.TYPE_VALUE)
		if trailright_track_index != -1:
			anim.track_insert_key(trailright_track_index, 0.00, Vector2(0.5,1.5)) # Frame 0 at 0 seconds
			anim.track_insert_key(trailright_track_index, 0.15, Vector2(0.5,-5.5)) # Frame 1 at 0.5 seconds
		var trailleftvis_track_index = anim.find_track("TrailLeft:visibility", Animation.TYPE_VALUE)
		if trailleftvis_track_index != -1:
			anim.track_insert_key(trailleftvis_track_index, 0.00, true) # Frame 0 at 0 seconds
		var trailrightvis_track_index = anim.find_track("TrailRight:visibility", Animation.TYPE_VALUE)
		if trailrightvis_track_index != -1:
			anim.track_insert_key(trailrightvis_track_index, 0.00, true) # Frame 0 at 0 seconds
		var meteorspike_track_index = anim.find_track("MeteorSpike:visible", Animation.TYPE_VALUE)
		if meteorspike_track_index != -1:
			anim.track_insert_key(meteorspike_track_index, 0.00, false)
	animation_player.play("jump") # Play what we just assembled

func play_fall_animation():
	#NOTE: .5 second length, half periodicity
	animation_player.stop()  # Stop any current animations
	anim = animation_player.get_animation("falldown") # Get the thing we'd like to play
	if anim: # Check if the animation exists
		# Get the specific track for the sprite frame and collision shape size
		var sprite_track_index = anim.find_track("Sprite:frame", Animation.TYPE_VALUE)
		if sprite_track_index != -1: # Modify the tracks or insert keyframes, if necessary
			anim.track_insert_key(sprite_track_index, 0.00, fall_frames[0]) # Frame 0 at 0 seconds
			anim.track_insert_key(sprite_track_index, 0.50, fall_frames[1]) # Frame 1 at 0.5 seconds
		var spritepos_track_index = anim.find_track("Sprite:position", Animation.TYPE_VALUE)
		if spritepos_track_index != -1:
			anim.track_insert_key(spritepos_track_index, 0.00, Vector2(0,7)) # Frame 0 at 0 seconds
		var trailleft_track_index = anim.find_track("TrailLeft:position", Animation.TYPE_VALUE)
		if trailleft_track_index != -1:
			anim.track_insert_key(trailleft_track_index, 0.00, Vector2(-1.5,5.5)) # Frame 0 at 0 seconds
		var trailright_track_index = anim.find_track("TrailRight:position", Animation.TYPE_VALUE)
		if trailright_track_index != -1:
			anim.track_insert_key(trailright_track_index, 0.00, Vector2(0.5,5.5)) # Frame 0 at 0 seconds
		var trailleftvis_track_index = anim.find_track("TrailLeft:visibility", Animation.TYPE_VALUE)
		if trailleftvis_track_index != -1:
			anim.track_insert_key(trailleftvis_track_index, 0.00, true) # Frame 0 at 0 seconds
		var trailrightvis_track_index = anim.find_track("TrailRight:visibility", Animation.TYPE_VALUE)
		if trailrightvis_track_index != -1:
			anim.track_insert_key(trailrightvis_track_index, 0.00, true) # Frame 0 at 0 seconds
		var meteorspike_track_index = anim.find_track("MeteorSpike:visible", Animation.TYPE_VALUE)
		if meteorspike_track_index != -1:
			anim.track_insert_key(meteorspike_track_index, 0.00, false)
	animation_player.play("falldown") # Play what we just assembled

func play_side_fall_animation():
	#NOTE: .5 second length, half periodicity
	animation_player.stop()  # Stop any current animations
	anim = animation_player.get_animation("fallsideways") # Get the thing we'd like to play
	if anim: # Check if the animation exists
		# Get the specific track for the sprite frame and collision shape size
		var sprite_track_index = anim.find_track("Sprite:frame", Animation.TYPE_VALUE)
		if sprite_track_index != -1: # Modify the tracks or insert keyframes, if necessary
			anim.track_insert_key(sprite_track_index, 0.00, side_fall_frames[0]) # Frame 0 at 0 seconds
			anim.track_insert_key(sprite_track_index, 0.50, side_fall_frames[1]) # Frame 1 at 0.5 seconds
		var spritepos_track_index = anim.find_track("Sprite:position", Animation.TYPE_VALUE)
		if spritepos_track_index != -1:
			anim.track_insert_key(spritepos_track_index, 0.00, Vector2(0,7)) # Frame 0 at 0 seconds
		var trailleft_track_index = anim.find_track("TrailLeft:position", Animation.TYPE_VALUE)
		if trailleft_track_index != -1:
			anim.track_insert_key(trailleft_track_index, 0.00, Vector2(5.5,6.5)) # Frame 0 at 0 seconds
		var trailright_track_index = anim.find_track("TrailRight:position", Animation.TYPE_VALUE)
		if trailright_track_index != -1:
			anim.track_insert_key(trailright_track_index, 0.00, Vector2(5.5,4.5)) # Frame 0 at 0 seconds
		var trailleftvis_track_index = anim.find_track("TrailLeft:visibility", Animation.TYPE_VALUE)
		if trailleftvis_track_index != -1:
			anim.track_insert_key(trailleftvis_track_index, 0.00, true) # Frame 0 at 0 seconds
		var trailrightvis_track_index = anim.find_track("TrailRight:visibility", Animation.TYPE_VALUE)
		if trailrightvis_track_index != -1:
			anim.track_insert_key(trailrightvis_track_index, 0.00, true) # Frame 0 at 0 seconds
		var meteorspike_track_index = anim.find_track("MeteorSpike:visible", Animation.TYPE_VALUE)
		if meteorspike_track_index != -1:
			anim.track_insert_key(meteorspike_track_index, 0.00, false)
	animation_player.play("fallsideways") # Play what we just assembled

func play_slide_animation():
	#NOTE: 0.5 second length, half periodicity
	animation_player.stop()  # Stop any current animations
	anim = animation_player.get_animation("slide") # Get the thing we'd like to play
	if anim: # Check if the animation exists
		# Get the specific track for the sprite frame and collision shape size
		var sprite_track_index = anim.find_track("Sprite:frame", Animation.TYPE_VALUE)
		if sprite_track_index != -1: # Modify the tracks or insert keyframes, if necessary
			anim.track_insert_key(sprite_track_index, 0.00, slide_frames[0]) # Frame 0 at 0 seconds
			anim.track_insert_key(sprite_track_index, 0.25, slide_frames[1]) # Frame 1 at 0.5 seconds
		var spritepos_track_index = anim.find_track("Sprite:position", Animation.TYPE_VALUE)
		if spritepos_track_index != -1:
			anim.track_insert_key(spritepos_track_index, 0.00, Vector2(0,7)) # Frame 0 at 0 seconds
		var trailleft_track_index = anim.find_track("TrailLeft:position", Animation.TYPE_VALUE)
		if trailleft_track_index != -1:
			anim.track_insert_key(trailleft_track_index, 0.00, Vector2(4.5,3.5)) # Frame 0 at 0 seconds
			anim.track_insert_key(trailleft_track_index, 0.25, Vector2(4.5,3.5)) # Frame 1 at 0.5 seconds
		var trailright_track_index = anim.find_track("TrailRight:position", Animation.TYPE_VALUE)
		if trailright_track_index != -1:
			anim.track_insert_key(trailright_track_index, 0.00, Vector2(4.5,5.5)) # Frame 0 at 0 seconds
			anim.track_insert_key(trailright_track_index, 0.25, Vector2(4.5,5.5)) # Frame 1 at 0.5 seconds
		var trailleftvis_track_index = anim.find_track("TrailLeft:visibility", Animation.TYPE_VALUE)
		if trailleftvis_track_index != -1:
			anim.track_insert_key(trailleftvis_track_index, 0.00, true) # Frame 0 at 0 seconds
		var trailrightvis_track_index = anim.find_track("TrailRight:visibility", Animation.TYPE_VALUE)
		if trailrightvis_track_index != -1:
			anim.track_insert_key(trailrightvis_track_index, 0.00, true) # Frame 0 at 0 seconds
		var meteorspike_track_index = anim.find_track("MeteorSpike:visible", Animation.TYPE_VALUE)
		if meteorspike_track_index != -1:
			anim.track_insert_key(meteorspike_track_index, 0.00, false)
	animation_player.play("slide") # Play what we just assembled

func play_death_animation():
	#NOTE: 0.5 second length, half periodicity
	animation_player.stop()  # Stop any current animations
	anim = animation_player.get_animation("death") # Get the thing we'd like to play
	if anim: # Check if the animation exists
		# Get the specific track for the sprite frame and collision shape size
		var sprite_track_index = anim.find_track("Sprite:frame", Animation.TYPE_VALUE)
		if sprite_track_index != -1: # Modify the tracks or insert keyframes, if necessary
			anim.track_insert_key(sprite_track_index, 0.00, death_frames[0]) # Frame 0 at 0 seconds
			anim.track_insert_key(sprite_track_index, 0.25, death_frames[1]) # Frame 1 at 0.5 seconds
		var spritepos_track_index = anim.find_track("Sprite:position", Animation.TYPE_VALUE)
		if spritepos_track_index != -1:
			anim.track_insert_key(spritepos_track_index, 0.00, Vector2(0,7)) # Frame 0 at 0 seconds
		var trailleft_track_index = anim.find_track("TrailLeft:position", Animation.TYPE_VALUE)
		if trailleft_track_index != -1:
			anim.track_insert_key(trailleft_track_index, 0.00, Vector2(4.5,3.5)) # Frame 0 at 0 seconds
		var trailright_track_index = anim.find_track("TrailRight:position", Animation.TYPE_VALUE)
		if trailright_track_index != -1:
			anim.track_insert_key(trailright_track_index, 0.00, Vector2(4.5,5.5)) # Frame 0 at 0 seconds
		var trailleftvis_track_index = anim.find_track("TrailLeft:visibility", Animation.TYPE_VALUE)
		if trailleftvis_track_index != -1:
			anim.track_insert_key(trailleftvis_track_index, 0.00, false) # Frame 0 at 0 seconds
		var trailrightvis_track_index = anim.find_track("TrailRight:visibility", Animation.TYPE_VALUE)
		if trailrightvis_track_index != -1:
			anim.track_insert_key(trailrightvis_track_index, 0.00, false) # Frame 0 at 0 seconds
		var meteorspike_track_index = anim.find_track("MeteorSpike:visible", Animation.TYPE_VALUE)
		if meteorspike_track_index != -1:
			anim.track_insert_key(meteorspike_track_index, 0.00, false)
	animation_player.play("death") # Play what we just assembled

func play_special_animation():
	#NOTE: 0.9 second length, third periodicity
	animation_player.stop()  # Stop any current animations
	anim = animation_player.get_animation("special") # Get the thing we'd like to play
	if anim: # Check if the animation exists
		# Get the specific track for the sprite frame and collision shape size
		var sprite_track_index = anim.find_track("Sprite:frame", Animation.TYPE_VALUE)
		if sprite_track_index != -1: # Modify the tracks or insert keyframes, if necessary
			anim.track_insert_key(sprite_track_index, 0.00, jump_frames[1]) # Frame 0 at 0 seconds
			anim.track_insert_key(sprite_track_index, 0.30, special_frames[0]) # Frame 0 at 0 seconds
			anim.track_insert_key(sprite_track_index, 0.60, special_frames[1]) # Frame 1 at 0.5 seconds
		var spritepos_track_index = anim.find_track("Sprite:position", Animation.TYPE_VALUE)
		if spritepos_track_index != -1:
			anim.track_insert_key(spritepos_track_index, 0.00, Vector2(0,7)) # Frame 0 at 0 seconds
		var trailleft_track_index = anim.find_track("TrailLeft:position", Animation.TYPE_VALUE)
		if trailleft_track_index != -1:
			anim.track_insert_key(trailleft_track_index, 0.00, Vector2(-1.5,-5.5)) # Frame 0 at 0 seconds
		var trailright_track_index = anim.find_track("TrailRight:position", Animation.TYPE_VALUE)
		if trailright_track_index != -1:
			anim.track_insert_key(trailright_track_index, 0.00, Vector2(0.5,-5.5)) # Frame 0 at 0 seconds
		var trailleftvis_track_index = anim.find_track("TrailLeft:visibility", Animation.TYPE_VALUE)
		if trailleftvis_track_index != -1:
			anim.track_insert_key(trailleftvis_track_index, 0.00, true) # Frame 0 at 0 seconds
		var trailrightvis_track_index = anim.find_track("TrailRight:visibility", Animation.TYPE_VALUE)
		if trailrightvis_track_index != -1:
			anim.track_insert_key(trailrightvis_track_index, 0.00, true) # Frame 0 at 0 seconds
		var meteorspike_track_index = anim.find_track("MeteorSpike:visible", Animation.TYPE_VALUE)
		if meteorspike_track_index != -1:
			anim.track_insert_key(meteorspike_track_index, 0.00, false)
	animation_player.play("special") # Play what we just assembled

func play_meteor_animation():
	#NOTE: 5 second length, no periodicity
	animation_player.stop()  # Stop any current animations
	anim = animation_player.get_animation("meteor") # Get the thing we'd like to play
	if anim: # Check if the animation exists
		# Get the specific track for the sprite frame and collision shape size
		var sprite_track_index = anim.find_track("Sprite:frame", Animation.TYPE_VALUE)
		if sprite_track_index != -1: # Modify the tracks or insert keyframes, if necessary
			anim.track_insert_key(sprite_track_index, 0.00, meteor_sprite) # Frame 0 at 0 seconds
		var spritepos_track_index = anim.find_track("Sprite:position", Animation.TYPE_VALUE)
		if spritepos_track_index != -1:
			anim.track_insert_key(spritepos_track_index, 0.00, Vector2(0,9)) # Frame 0 at 0 seconds
		var trailleft_track_index = anim.find_track("TrailLeft:position", Animation.TYPE_VALUE)
		if trailleft_track_index != -1:
			anim.track_insert_key(trailleft_track_index, 0.00, Vector2(-1.5,1.5)) # Frame 0 at 0 seconds
		var trailright_track_index = anim.find_track("TrailRight:position", Animation.TYPE_VALUE)
		if trailright_track_index != -1:
			anim.track_insert_key(trailright_track_index, 0.00, Vector2(0.5,1.5)) # Frame 0 at 0 seconds
		var trailleftvis_track_index = anim.find_track("TrailLeft:visibility", Animation.TYPE_VALUE)
		if trailleftvis_track_index != -1:
			anim.track_insert_key(trailleftvis_track_index, 0.00, true) # Frame 0 at 0 seconds
		var trailrightvis_track_index = anim.find_track("TrailRight:visibility", Animation.TYPE_VALUE)
		if trailrightvis_track_index != -1:
			anim.track_insert_key(trailrightvis_track_index, 0.00, true) # Frame 0 at 0 seconds
		var meteorspike_track_index = anim.find_track("MeteorSpike:visible", Animation.TYPE_VALUE)
		if meteorspike_track_index != -1:
			anim.track_insert_key(meteorspike_track_index, 0.00, true)
	animation_player.play("meteor") # Play what we just assembled

func play_squat_animation():
	#NOTE: 5 second length, no periodicity
	animation_player.stop()  # Stop any current animations
	anim = animation_player.get_animation("squat") # Get the thing we'd like to play
	if anim: # Check if the animation exists
		# Get the specific track for the sprite frame and collision shape size
		var sprite_track_index = anim.find_track("Sprite:frame", Animation.TYPE_VALUE)
		if sprite_track_index != -1: # Modify the tracks or insert keyframes, if necessary
			anim.track_insert_key(sprite_track_index, 0.00, jump_frames[0]) # Frame 0 at 0 seconds
		var spritepos_track_index = anim.find_track("Sprite:position", Animation.TYPE_VALUE)
		if spritepos_track_index != -1:
			anim.track_insert_key(spritepos_track_index, 0.00, Vector2(0,9)) # Frame 0 at 0 seconds
		var trailleft_track_index = anim.find_track("TrailLeft:position", Animation.TYPE_VALUE)
		if trailleft_track_index != -1:
			anim.track_insert_key(trailleft_track_index, 0.00, Vector2(-1.5,1.5)) # Frame 0 at 0 seconds
		var trailright_track_index = anim.find_track("TrailRight:position", Animation.TYPE_VALUE)
		if trailright_track_index != -1:
			anim.track_insert_key(trailright_track_index, 0.00, Vector2(0.5,1.5)) # Frame 0 at 0 seconds
		var trailleftvis_track_index = anim.find_track("TrailLeft:visibility", Animation.TYPE_VALUE)
		if trailleftvis_track_index != -1:
			anim.track_insert_key(trailleftvis_track_index, 0.00, true) # Frame 0 at 0 seconds
		var trailrightvis_track_index = anim.find_track("TrailRight:visibility", Animation.TYPE_VALUE)
		if trailrightvis_track_index != -1:
			anim.track_insert_key(trailrightvis_track_index, 0.00, true) # Frame 0 at 0 seconds
		var meteorspike_track_index = anim.find_track("MeteorSpike:visible", Animation.TYPE_VALUE)
		if meteorspike_track_index != -1:
			anim.track_insert_key(meteorspike_track_index, 0.00, false)
	animation_player.play("squat") # Play what we just assembled

func play_stretch_animation():
	#NOTE: 5 second length, no periodicity
	animation_player.stop()  # Stop any current animations
	anim = animation_player.get_animation("stretch") # Get the thing we'd like to play
	if anim: # Check if the animation exists
		# Get the specific track for the sprite frame and collision shape size
		var sprite_track_index = anim.find_track("Sprite:frame", Animation.TYPE_VALUE)
		if sprite_track_index != -1: # Modify the tracks or insert keyframes, if necessary
			anim.track_insert_key(sprite_track_index, 0.00, jump_frames[1]) # Frame 0 at 0 seconds
		var spritepos_track_index = anim.find_track("Sprite:position", Animation.TYPE_VALUE)
		if spritepos_track_index != -1:
			anim.track_insert_key(spritepos_track_index, 0.00, Vector2(0,6)) # Frame 0 at 0 seconds
		var trailleft_track_index = anim.find_track("TrailLeft:position", Animation.TYPE_VALUE)
		if trailleft_track_index != -1:
			anim.track_insert_key(trailleft_track_index, 0.00, Vector2(-1.5,-6.5)) # Frame 0 at 0 seconds
		var trailright_track_index = anim.find_track("TrailRight:position", Animation.TYPE_VALUE)
		if trailright_track_index != -1:
			anim.track_insert_key(trailright_track_index, 0.00, Vector2(0.5,-6.5)) # Frame 0 at 0 seconds
		var trailleftvis_track_index = anim.find_track("TrailLeft:visibility", Animation.TYPE_VALUE)
		if trailleftvis_track_index != -1:
			anim.track_insert_key(trailleftvis_track_index, 0.00, true) # Frame 0 at 0 seconds
		var trailrightvis_track_index = anim.find_track("TrailRight:visibility", Animation.TYPE_VALUE)
		if trailrightvis_track_index != -1:
			anim.track_insert_key(trailrightvis_track_index, 0.00, true) # Frame 0 at 0 seconds
		var meteorspike_track_index = anim.find_track("MeteorSpike:visible", Animation.TYPE_VALUE)
		if meteorspike_track_index != -1:
			anim.track_insert_key(meteorspike_track_index, 0.00, false)
	animation_player.play("stretch") # Play what we just assembled

func play_cast_animation():
	#NOTE: 0.6 second length, half periodicity
	animation_player.stop()  # Stop any current animations
	anim = animation_player.get_animation("special") # Get the thing we'd like to play
	if anim: # Check if the animation exists
		# Get the specific track for the sprite frame and collision shape size
		var sprite_track_index = anim.find_track("Sprite:frame", Animation.TYPE_VALUE)
		if sprite_track_index != -1: # Modify the tracks or insert keyframes, if necessary
			anim.track_insert_key(sprite_track_index, 0.00, jump_frames[1]) # Frame 0 at 0 seconds
			anim.track_insert_key(sprite_track_index, 0.30, special_frames[0]) # Frame 0 at 0 seconds
		var spritepos_track_index = anim.find_track("Sprite:position", Animation.TYPE_VALUE)
		if spritepos_track_index != -1:
			anim.track_insert_key(spritepos_track_index, 0.00, Vector2(0,7)) # Frame 0 at 0 seconds
		var trailleft_track_index = anim.find_track("TrailLeft:position", Animation.TYPE_VALUE)
		if trailleft_track_index != -1:
			anim.track_insert_key(trailleft_track_index, 0.00, Vector2(-1.5,-5.5)) # Frame 0 at 0 seconds
		var trailright_track_index = anim.find_track("TrailRight:position", Animation.TYPE_VALUE)
		if trailright_track_index != -1:
			anim.track_insert_key(trailright_track_index, 0.00, Vector2(0.5,-5.5)) # Frame 0 at 0 seconds
		var trailleftvis_track_index = anim.find_track("TrailLeft:visibility", Animation.TYPE_VALUE)
		if trailleftvis_track_index != -1:
			anim.track_insert_key(trailleftvis_track_index, 0.00, true) # Frame 0 at 0 seconds
		var trailrightvis_track_index = anim.find_track("TrailRight:visibility", Animation.TYPE_VALUE)
		if trailrightvis_track_index != -1:
			anim.track_insert_key(trailrightvis_track_index, 0.00, true) # Frame 0 at 0 seconds
		var meteorspike_track_index = anim.find_track("MeteorSpike:visible", Animation.TYPE_VALUE)
		if meteorspike_track_index != -1:
			anim.track_insert_key(meteorspike_track_index, 0.00, false)
	animation_player.play("special") # Play what we just assembled
