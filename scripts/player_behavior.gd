extends CharacterBody2D
class_name PlayerCharacter

@export var player_color: String # This is how we're going to assign players to characters, and a lot of the sprite/animation controls.
var player_index: int # Player 1's script gets device 0, required for player_aim() in input_handling()
var player_setting_deadzone: float # Player-tuned arcade-style on/off stick's deadzone
var player_input_left: String # Called in input_handling(); Player input
var player_input_right: String # Called in input_handling(); Player input
var player_input_down: String # Called in input_handling(); Player input
var player_input_up: String # Called in input_handling(); Player input
var player_input_A: String # Called in input_handling(); Player input
var player_input_X: String # Called in input_handling(); Player input
var player_input_B: String # Called in input_handling(); Player input
var player_input_Y: String # Called in input_handling(); Player input

# Admin settings on Player
@export var hp: int = 3 # Players spawn in with 3 HP, die after 3 hits.
@export var goals: int = 0 # Player goals, for UI & game score
@export var kills: int = 0 # Player Kills, for UI & bragging rights
@export var deaths: int = 0 # Player Deaths, for UI & shame
var run_speed: int = 200 # Feels like a good lateral speed for now - was 200, feedback is better. player_movement()
var jump_speed: float = -400.0 # 400 is a little too high for the maps. 300 feels good. player_jump()
var meteor_speed: int = 800 # 2x jump speed
var slide_speed: int = 400 # Twice as fast as the old run value, player_slide()
var push_force: float = 200.0 # This represents the player's inertia, physics_collisions()
var meteor_force: float = 1000.0 # This represents player inertia when meteor-striking
var near_range: Vector2 = Vector2( 37 , 25 ) # Nearness range in x and y for the ground, is_ball_near() & player_jump()
var far_range: Vector2 = Vector2( 40 , 35 ) # Nearness range in x and y for the air, is_ball_near() & player_jump()
var pinch_threshold: int = 900 # Lower threshold of delta v to trigger pinch state in _physics_collisions()
var max_pinch_force: float = 5000.0 # Upper threshold of pinch force applied in _physics_collisions()
var outside_forces: float = 0.0 # Other players pushing on us, used in physics_collisions() and player_move()
# Scenes/Resources
@onready var player_attack_scene = preload("res://scenes/player_attack.tscn") # preload the player attack scene for instantiation later.
@onready var player_missile_scene = preload("res://scenes/player_missile.tscn") # preload the player missile scene for instantiation later.
@onready var player_block_scene = preload("res://scenes/player_block.tscn") # preload the player block scene for instantiation later.
@onready var player_platform_scene = preload("res://scenes/player_platform.tscn") # preload the player platform scene for instantiation later.
@onready var red_gradient = preload("res://resources/red_gradient.tres") # preload the player eye trail gradient resource for assignment later.
@onready var cyan_gradient = preload("res://resources/cyan_gradient.tres") # preload the player eye trail gradient resource for assignment later.
# Nodes
@onready var sprite: Sprite2D = $Sprite # Sprite, player_movement()
@onready var spike: Sprite2D = $MeteorSpike # Sprite, update_ui()
@onready var player: AnimationPlayer = $AnimationPlayer # What it says on the can, player_movement() & player_jump() $ etc.
@onready var raycast:RayCast2D = $TremorSense # Ball detector, used in physics_collisions()
@onready var attack_cooldown = $AttackCooldown # Keeps from spamming attacks too bad.
@onready var cast_anim_timer = $CastAnimationTimer # Let's Cast animation play out used in input_handling() and state_machine()
@onready var reticle: Sprite2D = $AimReticle # Gotta aim somehow. player_aim(). Sprite object
@onready var magic_layer: Node2D = %MagicLayer # Magic home layer, for the sake of having somewhere objective to put them all
@onready var blue_ui: Node2D = %BlueUI
@onready var blue_ui_sprite: Sprite2D = blue_ui.get_node("PlayerSprite")
@onready var blue_ui_spike: Sprite2D = blue_ui.get_node("PlayerSpike")
@onready var green_ui: Node2D = %GreenUI
@onready var green_ui_sprite: Sprite2D = green_ui.get_node("PlayerSprite")
@onready var green_ui_spike: Sprite2D = green_ui.get_node("PlayerSpike")
@onready var purple_ui: Node2D = %PurpleUI
@onready var purple_ui_sprite: Sprite2D = purple_ui.get_node("PlayerSprite")
@onready var purple_ui_spike: Sprite2D = purple_ui.get_node("PlayerSpike")
@onready var red_ui: Node2D = %RedUI
@onready var red_ui_sprite: Sprite2D = red_ui.get_node("PlayerSprite")
@onready var red_ui_spike: Sprite2D = red_ui.get_node("PlayerSpike")
@onready var yellow_ui: Node2D = %YellowUI
@onready var yellow_ui_sprite: Sprite2D = yellow_ui.get_node("PlayerSprite")
@onready var yellow_ui_spike: Sprite2D = yellow_ui.get_node("PlayerSpike")
@onready var orange_ui: Node2D = %OrangeUI
@onready var orange_ui_sprite: Sprite2D = orange_ui.get_node("PlayerSprite")
@onready var orange_ui_spike: Sprite2D = orange_ui.get_node("PlayerSpike")
@onready var trail_left: Trails = $TrailLeft
@onready var trail_right: Trails = $TrailRight
# Misc
enum State {IDLE, IDLE_LEFT, SQUAT, STRETCH, DEATH, SPECIAL, RUN, RUN_LEFT, ASCEND, ASCEND_LEFT, JUMP, JUMP_LEFT, FALL, FALL_LEFT, FALLSIDE, FALLSIDE_LEFT, SLIDE, SLIDE_LEFT, METEOR, METEOR_LEFT, ATTACK, ATTACK_LEFT, MISSILE, MISSILE_LEFT, BLOCK, BLOCK_LEFT, PLATFORM, PLATFORM_LEFT, CASTING, CASTING_LEFT}
var current_state: State
var ui_layer: Node2D
var ui_sprite: Sprite2D
var ui_spike: Sprite2D
var collision: KinematicCollision2D # Used in physics_collisions()
var collider: Object # Used in physics_collisions()
var pinch_multiplier: float = 1.15 # Used in physics_collisions()
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity") # gravity = 980, player_movement()
var ball_position: Vector2 = Vector2.ZERO # For nearness, is_ball_near() & player_jump()
var player_position: Vector2 = Vector2.ZERO # For nearness, is_ball_near() & player_jump()
var from_meteor: bool = false # Status flag for preventing automatically triggering player_slide after hitting ground from player_meteor()
var last_facing: String # Flag to maintain correct idle directionality after ceasing input Assigned in construct_X_team(), used in state_machine() and sprite_flip()
var anim_name: String # Used in animation construction
var anim: Animation
# Sprite Frame Data
var player_start = {"Blue": 0, "Green": 24, "Purple": 48, "Red": 72, "Yellow": 96, "Orange": 120}
var idle_frames: Array = [0,1]
var run_frames: Array = [2,3]
var jump_frames: Array = [4,5]
var fall_frames: Array = [6,7]
var side_fall_frames: Array = [8,9]
var slide_frames: Array = [10,11]
var death_frames: Array = [12,13]
var special_frames: Array = [14,15]
var attack_frames: Array = [16, 17]
var block_frames: Array = [18,19]
var meteor_sprite: int = 20
var meteor_spike: int = 21
var reticle_frame: int = 22
var ranged_attack: int = 23
var anim_tracks: Array = [
	"Sprite:frame",
	"Sprite:position",
	"TrailLeft:visible",
	"TrailLeft:position",
	"TrailRight:visible",
	"TrailRight:position",
	"MeteorSpike:visible",
	"MeteorSpike:frame"]
var animation_data: Dictionary = {
	"default_anim_data": {
			"frame_timings": [0,0.25],
			"sprite_frames": [idle_frames[0], idle_frames[1]],
			"sprite_positions": [Vector2(0, 7), Vector2(0, 7)],
			"trail_left_vis": true,
			"trail_left_positions": [Vector2(0.5, -2.5), Vector2(0.5, -2.5)],
			"trail_right_vis": true,
			"trail_right_positions": [Vector2(2.5, -2.5), Vector2(2.5, -2.5)],
			"meteor_spike_vis": false,
			"meteor_spike_sprite": meteor_spike
		}}
# Input
var move_left_right: float = 0 # Used by input_handling(); Player input variable
var move_up_down: float = 0 # Used by input_handling(); Player input variable
var input_up_hold: bool = false # Used by input_handling(); Player input variable
var aim_left_right: float = 0 # Used by input_handling, player_is_aiming(), player_aim(), player_missile()
var aim_up_down: float = 0 # Used by input_handling, player_is_aiming(), player_aim(), player_missile()
var aim_direction: float = 0 # Used by player_aim(); Trigonometry for missile casting
var input_jump: bool = false # Used by input_handling(); Player input variable
var input_jump_hold: bool = false # Used by input_handling(); Player input variable
var input_jump_released: bool = false # Used by input_handling(); Player input variable
var input_attack: bool = false # Used by input_handling(); Player input variable
var input_attack_hold: bool = false # Used by input_handling(); Player input variable
var input_block: bool = false # Used by input_handling(); Player input variable
var input_block_hold: bool = false # Used by input_handling(); Player input variable
var input_special: bool = false # Used by input_handling(); Player input variable

#######################################################################################################################################################
## STATUS-CHECK / CALLABLE FUNCTIONS
func get_state_directionality(action: State) -> State: #Called by input_handling(); Checks left/right, returns correct state
	if last_facing == "left": # If pointed left
		match action:
			State.RUN: return State.RUN_LEFT
			State.ASCEND: return State.ASCEND_LEFT
			State.JUMP: return State.JUMP_LEFT
			State.FALL: return State.FALL_LEFT
			State.FALLSIDE: return State.FALLSIDE_LEFT
			State.SLIDE: return State.SLIDE_LEFT
			State.METEOR: return State.METEOR_LEFT
			State.ATTACK: return State.ATTACK_LEFT
			State.MISSILE: return State.MISSILE_LEFT
			State.BLOCK: return State.BLOCK_LEFT
			State.PLATFORM: return State.PLATFORM_LEFT
			State.CASTING: return State.CASTING_LEFT
			State.IDLE: return State.IDLE_LEFT
			State.DEATH: return State.DEATH
			State.SPECIAL: return State.SPECIAL
			State.SQUAT: return State.SQUAT
			State.STRETCH: return State.STRETCH
	return action

func player_is_aiming(): #Called by input_handling, player_aim(); Input detector for aim reticle, melee/missile casting
	return not (abs(aim_left_right) < 0.25 and abs(aim_up_down) < 0.25)

func is_ball_near() -> bool: # Called from player_jump(); Ball radar for 'ball-possession' in air
	ball_position = %Ball.position #Get ball position from transform
	player_position = self.position #Get self position from transform
	if is_on_floor():
		return abs(ball_position.x - player_position.x) < near_range.x and abs(ball_position.y - player_position.y) < near_range.y # If player and ball are within near_range of each other in x and y, return true
	return abs(ball_position.x - player_position.x) < far_range.x and abs(ball_position.y - player_position.y) < far_range.y

func is_on_top_of_ball() -> bool: # called by physics_collisions(); we don't want to pinch due to gravity
	if raycast.is_colliding(): # what is says on the can - is it touching anything?
		return raycast.get_collider().is_in_group("balls")
	return false # false if not

func is_on_ramp() -> bool: # called by is_in_air(), variable_gravity(), _physics_process(); required for proper sliding mechanics
	if raycast.is_colliding(): # what is says on the can - is it touching anything?
		collider = raycast.get_collider()  # Get the collider object
		if collider and collider.is_in_group("ramps"):  # Check if the collider exists and is in the 'ramps' group
			return true  # Return true if the collider is in the 'ramps' group
	return false #false if not

func is_in_air() -> bool: # Called by input_handling(). Opposite of is_on_floor()
	return not is_on_floor() and not is_on_ramp()

func variable_gravity() -> float: # called by player_movement(); Game feel.
	if velocity.y > 0: # If we're falling
		return gravity * 1.4 # return 40% higher gravity and fall faster, snapping back to the ground
	if is_on_ramp():
		return gravity * 2.5 # return 2 times gravity, to keep that player glued to the ramp, on their slide down.
	if input_up_hold: # If the player is holding up
		return gravity * 0.8 # Let them jump higher under lower gravity
	return gravity # Else, return normal gravity

func variable_force() -> float: # called by physics_collisions() controller; How hard we punch the ball.
	if current_state == State.METEOR or current_state == State.METEOR_LEFT: # If we're down+A,
		return meteor_force # hit the ball extra hard @ 1000
	elif current_state == State.SLIDE or current_state == State.SLIDE_LEFT: # If we're sliding; NOTE: is_slide assumes jump is pressed in its other uses cases (player_jump(), for instance)
		return push_force * 2 # 400
	else: # If we're just running
		return push_force # 200

#######################################################################################################################################################
## INIT/CONSTRUCTORS
func player_setup() -> void: # Blank hook for children to override
	pass  # Placeholder, will be overridden by child

func _ready() -> void: # Called when the node enters the scene tree for the first time.
	if has_method("player_setup"):
		player_setup()
	construct_player() # Calls construct_cold/hot_team, as required
	construct_animations() # builds sprite, animation data
	construct_melee()
	current_state = State.IDLE # Initialize the state as idle

func construct_player() -> void: # Called by ready(); Dynanmic-player assignment set up.
	self.name = player_color
	match player_color:
		"Blue":
			ui_layer = blue_ui
			ui_sprite = blue_ui_sprite
			ui_spike = blue_ui_spike
			construct_cold_team(self)
		"Green":
			ui_layer = green_ui
			ui_sprite = green_ui_sprite
			ui_spike = green_ui_spike
			construct_cold_team(self)
		"Purple":
			ui_layer = purple_ui
			ui_sprite = purple_ui_sprite
			ui_spike = purple_ui_spike
			construct_cold_team(self)
		"Red":
			ui_layer = red_ui
			ui_sprite = red_ui_sprite
			ui_spike = red_ui_spike
			construct_hot_team(self)
		"Yellow":
			ui_layer = yellow_ui
			ui_sprite = yellow_ui_sprite
			ui_spike = yellow_ui_spike
			construct_hot_team(self)
		"Orange":
			ui_layer = orange_ui
			ui_sprite = orange_ui_sprite
			ui_spike = orange_ui_spike
			construct_hot_team(self)

func construct_cold_team(object) -> void: # Called by construct_player(); continuing player assignments, but for team-relations.
	object.add_to_group("ColdTeam") # for easier get_collisions() logic later
	object.collision_layer |= 1 << 9 # Exist on Cold Team collision layer
	object.collision_mask |= 1 << 13 # Collide with Hot Team layer
	if object == self:
		trail_left.gradient = red_gradient
		trail_right.gradient = red_gradient
		last_facing = "right"

func construct_hot_team(object) -> void: # Called by construct_player(); continuing player assignments, but for team-relations.
	object.add_to_group("HotTeam") # for easier get_collisions() logic later
	object.collision_layer |= 1 << 13 # Exist on Hot Team collision layer
	object.collision_mask |= 1 << 9 # Collide with Cold Team layer
	if object == self:
		trail_left.gradient = cyan_gradient
		trail_right.gradient = cyan_gradient
		last_facing = "left"

func construct_animations() -> void: # Called by ready(); Dynamic-player assignment means Dynamic Animations. (Unfortunately, this was a slog.)
	# Sprites, per color
	idle_frames = idle_frames.map(func(x): return x + player_start[player_color])
	run_frames = run_frames.map(func(x): return x + player_start[player_color])
	jump_frames = jump_frames.map(func(x): return x + player_start[player_color])
	fall_frames = fall_frames.map(func(x): return x + player_start[player_color])
	side_fall_frames = side_fall_frames.map(func(x): return x + player_start[player_color])
	slide_frames = slide_frames.map(func(x): return x + player_start[player_color])
	death_frames = death_frames.map(func(x): return x + player_start[player_color])
	special_frames = special_frames.map(func(x): return x + player_start[player_color])
	attack_frames = attack_frames.map(func(x): return x + player_start[player_color])
	block_frames = block_frames.map(func(x): return x + player_start[player_color])
	meteor_sprite = meteor_sprite + player_start[player_color]
	meteor_spike = meteor_spike + player_start[player_color]
	reticle_frame = reticle_frame + player_start[player_color]
	ranged_attack = ranged_attack + player_start[player_color]
	# resetting the default meteor_spike anim data, to the proper colored one.
	animation_data["default_anim_data"]["meteor_spike_sprite"] = meteor_spike
	# Idle
	animation_data["idle"] = animation_data["default_anim_data"].duplicate()
	animation_data["idle"]["frame_timings"] = [0,0.5]
	animation_data["idle"]["sprite_frames"] = [idle_frames[0], idle_frames[1]]
	animation_data["idle"]["trail_left_positions"] = [Vector2(0.5, -2.5), Vector2(0.5, -3.5)]
	animation_data["idle"]["trail_right_positions"] = [Vector2(2.5, -2.5), Vector2(2.5, -3.5)]
	# Idle Left
	animation_data["idle_left"] = animation_data["idle"].duplicate()
	animation_data["idle_left"]["trail_left_positions"] = [Vector2(-0.5,-2.5), Vector2(-0.5,-1.5)]
	animation_data["idle_left"]["trail_right_positions"] = [Vector2(-2.5,-2.5), Vector2(-2.5,-1.5)]
	# Run
	animation_data["run"] = animation_data["default_anim_data"].duplicate()
	animation_data["run"]["sprite_frames"] = [run_frames[0], run_frames[1]]
	animation_data["run"]["trail_left_positions"] = [Vector2(0.5,-2.5), Vector2(0.5,-1.5)]
	animation_data["run"]["trail_right_positions"] = [Vector2(2.5,-2.5), Vector2(2.5,-1.5)]
	# Run left
	animation_data["run_left"] = animation_data["run"].duplicate()
	animation_data["run_left"]["trail_left_positions"] = [Vector2(-0.5,-2.5), Vector2(-0.5,-1.5)]
	animation_data["run_left"]["trail_right_positions"] = [Vector2(-2.5,-2.5), Vector2(-2.5,-1.5)]
	# Jump
	animation_data["jump"] = animation_data["default_anim_data"].duplicate()
	animation_data["jump"]["frame_timings"] = [0,0.1]
	animation_data["jump"]["sprite_frames"] = [jump_frames[0],jump_frames[1]]
	animation_data["jump"]["sprite_positions"] = [Vector2(0, 9), Vector2(0, 7)]
	animation_data["jump"]["trail_left_positions"] = [Vector2(-1.5,1.5), Vector2(-1.5,-5.5)]
	animation_data["jump"]["trail_right_positions"] = [Vector2(0.5,1.5), Vector2(0.5,-5.5)]
	# Jump, but Left
	animation_data["jump_left"] = animation_data["jump"].duplicate()
	animation_data["jump_left"]["trail_left_positions"] = [Vector2(-0.5,1.5), Vector2(-0.5,-5.5)]
	animation_data["jump_left"]["trail_right_positions"] = [Vector2(1.5,1.5), Vector2(1.5,-5.5)]
	# Fall down
	animation_data["falldown"] = animation_data["default_anim_data"].duplicate()
	animation_data["falldown"]["sprite_frames"] = [fall_frames[0],fall_frames[1]]
	animation_data["falldown"]["trail_left_positions"]  = [Vector2(-1.5,5.5), Vector2(-1.5,5.5)]
	animation_data["falldown"]["trail_right_positions"]  = [Vector2(0.5,5.5), Vector2(0.5,5.5)]
	# Fall down, Left
	animation_data["falldown_left"] = animation_data["falldown"].duplicate()
	animation_data["falldown_left"]["trail_left_positions"] = [Vector2(-0.5,5.5), Vector2(-0.5,5.5)]
	animation_data["falldown_left"]["trail_right_positions"] = [Vector2(1.5,5.5), Vector2(1.5,5.5)]
	# Fall Sideways
	animation_data["fallsideways"] = animation_data["default_anim_data"].duplicate()
	animation_data["fallsideways"]["sprite_frames"] = [side_fall_frames[0],side_fall_frames[1]]
	animation_data["fallsideways"]["trail_left_positions"] = [Vector2(5.5,6.5), Vector2(5.5,6.5)]
	animation_data["fallsideways"]["trail_right_positions"] = [Vector2(5.5,4.5), Vector2(5.5,4.5)]
	# Fall Sideways, but Left
	animation_data["fallsideways_left"] = animation_data["fallsideways"].duplicate()
	animation_data["fallsideways_left"]["trail_left_positions"] = [Vector2(-5.5,6.5), Vector2(-5.5,6.5)]
	animation_data["fallsideways_left"]["trail_right_positions"] = [Vector2(-5.5,4.5), Vector2(-5.5,4.5)]
	# Slide
	animation_data["slide"] = animation_data["default_anim_data"].duplicate()
	animation_data["slide"]["sprite_frames"] = [slide_frames[0], slide_frames[1]]
	animation_data["slide"]["trail_left_positions"] = [Vector2(4.5,3.5), Vector2(4.5,3.5)]
	animation_data["slide"]["trail_right_positions"] = [Vector2(4.5,5.5), Vector2(4.5,5.5)]
	# Slide Left
	animation_data["slide_left"] = animation_data["slide"].duplicate()
	animation_data["slide_left"]["trail_left_positions"] = [Vector2(-4.5,3.5), Vector2(-4.5,3.5)]
	animation_data["slide_left"]["trail_right_positions"] = [Vector2(-4.5,5.5), Vector2(-4.5,5.5)]
	# Death
	animation_data["death"] = animation_data["default_anim_data"].duplicate()
	animation_data["death"]["sprite_frames"] = [death_frames[0], death_frames[1]]
	animation_data["death"]["trail_left_vis"] = false
	animation_data["death"]["trail_right_vis"] = false
	# Special
	animation_data["special"] = animation_data["default_anim_data"].duplicate()
	animation_data["special"]["frame_timings"] = [0,0.3,0.6]
	animation_data["special"]["sprite_frames"] = [jump_frames[1], special_frames[0], special_frames[1]]
	animation_data["special"]["sprite_positions"] = [Vector2(0, 7), Vector2(0, 7), Vector2(0, 7)]
	animation_data["special"]["trail_left_positions"] = [Vector2(-1.5, -5.5), Vector2(-1.5, -5.5), Vector2(-1.5, -5.5)]
	animation_data["special"]["trail_right_positions"] = [Vector2(0.5, -2.5), Vector2(0.5, -2.5), Vector2(0.5, -2.5)]
	# Meteor
	animation_data["meteor"] = animation_data["default_anim_data"].duplicate()
	animation_data["meteor"]["frame_timings"] = [0]
	animation_data["meteor"]["sprite_frames"] = [meteor_sprite]
	animation_data["meteor"]["sprite_positions"] = [Vector2(0, 9)]
	animation_data["meteor"]["trail_left_positions"] = [Vector2(-1.5, -1.5)]
	animation_data["meteor"]["trail_right_positions"] = [Vector2(0.5, -1.5)]
	animation_data["meteor"]["meteor_spike_vis"] = true
	# Meteor Left
	animation_data["meteor_left"] = animation_data["meteor"].duplicate()
	animation_data["meteor_left"]["trail_left_positions"] = [Vector2(1.5, -1.5)]
	animation_data["meteor_left"]["trail_right_positions"] = [Vector2(-0.5, -1.5)]
	# Squat
	animation_data["squat"] = animation_data["default_anim_data"].duplicate()
	animation_data["squat"]["frame_timings"] = [0]
	animation_data["squat"]["sprite_frames"] = [jump_frames[0]]
	animation_data["squat"]["sprite_positions"] = [Vector2(0, 9)]
	animation_data["squat"]["trail_left_positions"] = [Vector2(-1.5, 1.5)]
	animation_data["squat"]["trail_right_positions"] = [Vector2(0.5,1.5)]
	# Stretch
	animation_data["stretch"] = animation_data["default_anim_data"].duplicate()
	animation_data["stretch"]["frame_timings"] = [0]
	animation_data["stretch"]["sprite_frames"] = [jump_frames[1]]
	animation_data["stretch"]["sprite_positions"] = [Vector2(0, 6)]
	animation_data["stretch"]["trail_left_positions"] = [Vector2(-1.5,-6.5)]
	animation_data["stretch"]["trail_right_positions"] = [Vector2(0.5,-6.5)]
	# Cast
	animation_data["cast"] = animation_data["default_anim_data"].duplicate()
	animation_data["cast"]["frame_timings"] = [0]
	animation_data["cast"]["sprite_frames"] = [special_frames[0]]
	animation_data["cast"]["trail_left_positions"] = [Vector2(-1.5,-5.5)]
	animation_data["cast"]["trail_right_positions"] = [Vector2(0.5,-5.5)]
	# Cast Left
	animation_data["cast_left"] = animation_data["cast"].duplicate()
	animation_data["cast_left"]["trail_left_positions"] = [Vector2(1.5, -5.5)]
	animation_data["cast_left"]["trail_right_positions"] = [Vector2(-0.5,-5.5)]
	var track_index # Place holder var for track-objects we'll use a bunch here.
	for animation in animation_data.keys(): #idle, et al
		if animation == "default_anim_data":
			continue
		anim = player.get_animation(animation) #get_animation("idle")
		var number_of_frames = animation_data[animation]["frame_timings"].size() #scoop number of frames
		#frame_timings - 			for each for # of frames; involved in everything else's timing
		#sprite_frames - 			Sprite:frame
		track_index = anim.find_track("Sprite:frame", Animation.TYPE_VALUE) # How many frames are there?
		for frame in number_of_frames: # Iterate over each frame presented in the animation data
			anim.track_insert_key(track_index, animation_data[animation]["frame_timings"][frame], animation_data[animation]["sprite_frames"][frame])
		#sprite_positions - 		Sprite:position
		track_index = anim.find_track("Sprite:position", Animation.TYPE_VALUE)
		for frame in number_of_frames: # Iterate over each frame presented in the animation data
			anim.track_insert_key(track_index, animation_data[animation]["frame_timings"][frame], animation_data[animation]["sprite_positions"][frame])
		#trail_left_vis - 			TrailLeft:visible
		track_index = anim.find_track("TrailLeft:visible", Animation.TYPE_VALUE)
		anim.track_insert_key(track_index, 0, animation_data[animation]["trail_left_vis"])
		#trail_left_positions -		TrailLeft:position
		track_index = anim.find_track("TrailLeft:position", Animation.TYPE_VALUE)
		for frame in number_of_frames: # Iterate over each frame presented in the animation data
			anim.track_insert_key(track_index, animation_data[animation]["frame_timings"][frame], animation_data[animation]["trail_left_positions"][frame])
		#trail_right_vis - 			TrailRight:visible
		track_index = anim.find_track("TrailRight:visible", Animation.TYPE_VALUE)
		anim.track_insert_key(track_index, 0, animation_data[animation]["trail_right_vis"])
		#trail_right_positions -	TrailRight:position
		track_index = anim.find_track("TrailRight:position", Animation.TYPE_VALUE)
		for frame in number_of_frames: # Iterate over each frame presented in the animation data
			anim.track_insert_key(track_index, animation_data[animation]["frame_timings"][frame], animation_data[animation]["trail_right_positions"][frame])
		#meteor_spike_vis - 		MeteorSpike:visible
		track_index = anim.find_track("MeteorSpike:visible", Animation.TYPE_VALUE)
		anim.track_insert_key(track_index, 0, animation_data[animation]["meteor_spike_vis"])
		#meteor_spike_sprite - 		MeteorSpike:frame
		track_index = anim.find_track("MeteorSpike:frame", Animation.TYPE_VALUE)
		for frame in number_of_frames: # Iterate over each frame presented in the animation data
			anim.track_insert_key(track_index, 0, animation_data[animation]["meteor_spike_sprite"])

func construct_melee() -> void:
	var attack_frames: Array = []
	var blue_attack: Array[int] = [16, 17]
	var green_attack: Array[int] = [40, 41]
	var purple_attack: Array[int] = [64, 65]
	var red_attack: Array[int] = [88, 89]
	var yellow_attack: Array[int] = [112, 113]
	var orange_attack: Array[int] = [136, 137]
	match player_color: # omfg - I'm so glad I figured this match syntax out, this is gonna save my life, if this works right
		"Blue": attack_frames = blue_attack
		"Green": attack_frames = green_attack
		"Purple": attack_frames = purple_attack
		"Red": attack_frames = red_attack
		"Yellow": attack_frames = yellow_attack
		"Orange": attack_frames = orange_attack


#######################################################################################################################################################
## EXECUTION / MAIN
func _physics_process(delta: float) -> void: # Called every frame. We're gonna collect input and execute control-functions here. Separate thread from _process().
	update_ui()
	# Gravity and variable jump
	velocity.y += variable_gravity() * delta # apply variable gravity to character, depending on whether falling
	input_handling(delta) # Gather input, set state, for parsing in state_machine() below.
	state_machine() # Parses states and executes follow up code
	move_and_slide() # Execute the movement accumulated from velocity changes above
	physics_collisions() # React to Physics, as per the movement and contact with other objects.

func input_handling(delta: float) -> void: # Called every frame, by _physics_process()
	# Gathering input data
	move_left_right = Input.get_axis(player_input_left, player_input_right) # D-pad & L-stick X axis
	move_up_down = Input.get_axis(player_input_down, player_input_up) # D-pad & L-stick Y axis
	input_up_hold = Input.is_action_pressed(player_input_up) # D-pad & L-stick Up button hold - for variable_gravity()
	aim_left_right = Input.get_joy_axis(player_index, JOY_AXIS_RIGHT_X) # Right Joystick X
	aim_up_down = Input.get_joy_axis(player_index, JOY_AXIS_RIGHT_Y) # Right Joystick Y
	input_jump = Input.is_action_just_pressed(player_input_A) # A button pulse - for jumps
	input_jump_hold = Input.is_action_pressed(player_input_A) # A button hold - for slides and meteors
	input_jump_released = Input.is_action_just_released(player_input_A) # A button release - for variable jump height, resetting after meteor
	input_attack = Input.is_action_just_pressed(player_input_X) # X Button
	input_attack_hold = Input.is_action_pressed(player_input_X) # X Button hold - for cast ing catch-state (addressing pulse animations)
	input_block = Input.is_action_just_pressed(player_input_B) # B button
	input_block_hold = Input.is_action_pressed(player_input_B) # X Button hold - for cast ing catch-state (addressing pulse animations)
	input_special = Input.is_action_just_pressed(player_input_Y) # Y button

	# This is to establish last facing direction, so when we stop facing left, we can auto-slide that direction instead of defaulting to slide right.
	if move_left_right > 0:
		last_facing = "right"
	elif move_left_right < 0:
		last_facing = "left"
	#NOTE: This deliberately leaves 0 position set to whatever it was last set to.
	# This is for slides-from-IDLE, so they're aimed the right way, and other LEFT states (for eye placements mostly)

	# Player movement and aim
	player_movement() # We want the player to move regardless of state
	player_aim() # We want the player to aim, regardless of state

	# On-ground States
	if abs(move_left_right) > player_setting_deadzone and not is_in_air() and cast_anim_timer.is_stopped(): # Pressed left/right on floor, w/ player-set deadzone
		current_state = get_state_directionality(State.RUN)
	else: # We're in the Dead Zone, check for up/down, if none revert to idle
		if move_up_down < -player_setting_deadzone: # Pressed Down
			current_state = get_state_directionality(State.SQUAT)
		elif move_up_down > player_setting_deadzone: # Pressed Up
			current_state = get_state_directionality(State.STRETCH)
		else: # Then we're directionally idle. Later if/thens will overwrite this with other states, and is expected/desired.
			current_state = get_state_directionality(State.IDLE)

	# In-air States
	if velocity.y >= 0 and not is_on_floor(): # That's falling, because Godot is silly on Y axis
		if abs(move_left_right) > player_setting_deadzone: # That's falling sideways
			current_state = get_state_directionality(State.FALLSIDE)
		else: # There's no input, falling straight down
			current_state = get_state_directionality(State.FALL)
	elif velocity.y < 0 and not is_on_floor(): # We're "falling" up-ways. Used to hold the jump animation.
		current_state = get_state_directionality(State.ASCEND)

	# A Button - Jump/slide/meteor
	if input_jump: # Pressed A, and NOT-Down
		current_state = get_state_directionality(State.JUMP)
	if input_jump_hold and move_up_down <= -player_setting_deadzone: # Pressed A + Down
		if is_on_floor() or is_on_ramp(): # Is on ground or ramp? If yes, we're on the ground.
			current_state = get_state_directionality(State.SLIDE) # Then slide, stupid
			if from_meteor: # We need to screen for this here now and vent to IDLE when from meteor.
				current_state = get_state_directionality(State.IDLE)
		else: #We're in the air, pressing Down+A. METEOR TIME
			current_state = get_state_directionality(State.METEOR) # LINK! LINK! LINK! LINK! LINK!

	# A Button Release - Jump/slide/meteor
	if input_jump_released: # Player let go of A
		from_meteor = false # Reset our flag
		raycast.enabled = true # Turns ball detector back on for is_on_top_of_ball()
		if velocity.y < 0: # We've released jump, and are still ascending
			velocity.y = jump_speed / 4 # Quarter our upward velocity, fall faster.

	# X Button - Attack/Missile
	if input_attack and not player_is_aiming(): # If we're not aiming, our attack is melee
		current_state = get_state_directionality(State.ATTACK) # NOTE CAST animation & player_attack()
	elif input_attack and player_is_aiming(): #But if we are aiming, our attack is ranged
		current_state = get_state_directionality(State.MISSILE) # NOTE CAST animation & player_missile()

	# B Button - Block/Platform
	if input_block and is_on_floor(): # On the floor, we need the wall-block
		current_state = get_state_directionality(State.BLOCK) # NOTE CAST animation & player_block()
	elif input_block and not is_on_floor(): # In the air, we need the platform instead
		current_state = get_state_directionality(State.PLATFORM) # NOTE CAST animation & player_platform() TODO

	# Casting - Either X or B Buttons
	if not cast_anim_timer.is_stopped(): # If the player's castanim timer node is running, we've just cast a spell
		current_state = get_state_directionality(State.CASTING) # Used to hold the cast animation.

	# Y Button - Special TODO: Needs implementation - not here, down at player_special()
	if input_special:
		current_state = get_state_directionality(State.SPECIAL)

	# Death
	if hp <= 0: # Then the player is "D-E-D, Dead"
		current_state = get_state_directionality(State.DEATH)

func state_machine() -> void: # Called every frame, by _physics_process()
	match current_state:
		State.IDLE: # Cold Team default
			sprite_flip("right")
			player.play("idle")
		State.IDLE_LEFT: # Hot Team default
			sprite_flip("left")
			player.play("idle_left")
		State.SQUAT:
			player.play("squat")
		State.STRETCH:
			player.play("stretch")
		State.DEATH:
			player.play("death")
			player_death()
		State.SPECIAL:
			sprite_flip("right")
			player.play("special")
			player_special()
		State.RUN:
			sprite_flip("right")
			player.play("run")
		State.RUN_LEFT:
			sprite_flip("left")
			player.play("run_left")
		State.ASCEND: # to hold jump animation, so we don't immediately revert to idle in the air
			sprite_flip("right")
			player.play("jump")
		State.ASCEND_LEFT: # to hold jump animation, so we don't immediately revert to idle in the air
			sprite_flip("left")
			player.play("jump_left")
		State.JUMP:
			sprite_flip("right")
			player_jump()
			player.play("jump")
		State.JUMP_LEFT:
			sprite_flip("left")
			player_jump()
			player.play("jump_left")
		State.FALL:
			sprite_flip("right")
			player.play("falldown")
		State.FALL_LEFT:
			sprite_flip("left")
			player.play("falldown_left")
		State.FALLSIDE:
			sprite_flip("right")
			player.play("fallsideways")
		State.FALLSIDE_LEFT:
			sprite_flip("left")
			player.play("fallsideways_left")
		State.SLIDE:
			sprite_flip("right")
			player_slide()
			player.play("slide")
		State.SLIDE_LEFT:
			sprite_flip("left")
			player_slide()
			player.play("slide_left")
		State.METEOR:
			sprite_flip("right")
			player_meteor()
			player.play("meteor")
		State.METEOR_LEFT:
			sprite_flip("left")
			player_meteor()
			player.play("meteor_left")
		State.ATTACK:
			sprite_flip("right")
			player_attack()
			player.play("cast")
		State.ATTACK_LEFT:
			sprite_flip("left")
			player_attack()
			player.play("cast_left")
		State.MISSILE:
			sprite_flip("right")
			player_missile()
			player.play("cast")
		State.MISSILE_LEFT:
			sprite_flip("left")
			player_missile()
			player.play("cast_left")
		State.BLOCK:
			sprite_flip("right")
			player_block()
			player.play("cast")
		State.BLOCK_LEFT:
			sprite_flip("left")
			player_block()
			player.play("cast_left")
		State.PLATFORM:
			sprite_flip("right")
			player_platform()
			player.play("cast")
		State.PLATFORM_LEFT:
			sprite_flip("left")
			player_platform()
			player.play("cast_left")
		State.CASTING: # to hold cast animation, so we don't immediately revert to idle after cast
			player.play("cast")
		State.CASTING_LEFT: # to hold cast animation, so we don't immediately revert to idle after cast
			player.play("cast_left")

#######################################################################################################################################################
## PLAYER ACTIONS
func player_movement() -> void: # Called by input_handling(); Player movement
	if move_left_right < -player_setting_deadzone: # Pressed Left w/ 25% deadzone
		velocity.x = -run_speed  + outside_forces # Go Left, considering push forces
	elif move_left_right > player_setting_deadzone: # Pressed Right w/ 25% deadzone
		velocity.x = run_speed + outside_forces # Go Right, considering push forces
	else: # 0 input
		velocity.x = 0 + outside_forces # don't move, except push forces
	outside_forces = 0.0

func player_aim() ->void: # Called by input_handling(); Player aim
	if not player_is_aiming():
		reticle.visible = false
	else:
		reticle.visible = true
		aim_direction = atan2(aim_left_right, -aim_up_down)
		reticle = get_node("AimReticle")
		reticle.frame = reticle_frame
		reticle.rotation = aim_direction

func player_jump() -> void: # Called by state_machine(); Jump!
	velocity.y = jump_speed #omg Godot defines "Up" as -Y and NOT +Y. *sigh*
	if is_ball_near() and !is_on_top_of_ball(): # If ball is in range, but we're not directly on top of it
		%Ball.linear_velocity.y = 1.1 * jump_speed # Apply upward force to ball
	var platform_name = "PlayerPlatform_" + player_color # Search for existing platforms with this name
	for child in magic_layer.get_children(): # Check the magic layer
		if child.name == platform_name: # If we already one of these spawned,
			child.free() # Free the existing platform and kill it, because we kill platforms on jump.

func player_slide() -> void: # Called by state_machine(); Megaman slide!
	if last_facing == "left": # If player is facing left
		velocity.x = -slide_speed # Tune the forces to the left
	else: # else, we're facing right
		velocity.x = slide_speed # Keep the forces tuned to the right

func player_meteor() -> void: 	# Called by state_machine(); Meteor strike downwards from the sky!
	raycast.enabled = false # Turns ball detector OFF [for is_on_top_of_ball()], allowing us to pinch the ball, maybe? Returns to normal on Jump-just released in _physics_process()
	velocity.y = meteor_speed # Drop really fast; 800
	from_meteor = true # Set Flag on. Returns to normal on Jump-just released in _physics_process()

func player_attack() -> void: # Called by state_machine(); Localized magic ball for melee attacks
	# NOTE: Players do not collide with melee attacks by default - rather, the attack colides with them. This lets players move their melee attack.
	if attack_cooldown.is_stopped(): # Don't let players spam attack more than once every 1 seconds
		attack_cooldown.start() # Start cooldown timer
		if cast_anim_timer.is_stopped():
			cast_anim_timer.start()
		var new_attack = player_attack_scene.instantiate() # Instantiate the preloaded scene
		var face_direction: int = 1
		if sprite.flip_h == true: # If the wiz is facing left.
			face_direction = -1
		new_attack.global_position = get_global_position() + Vector2(16 * face_direction, 0) # Small offset, makes sure it appears outside the player body, on the correct side.
		new_attack.set("player_color", player_color) # I hope this works. // It totally worked!
		new_attack.set("attack_frames", attack_frames)
		if player_color=="Blue" or player_color=="Green" or player_color=="Purple":
			construct_cold_team(new_attack)
		else:
			construct_hot_team(new_attack)
	# NOTE: After the above, players will collide with the opposite teams' attacks, and visa versa (from the default)
		var attacksprite = new_attack.get_node("Sprite")
		attacksprite.flip_h = sprite.flip_h # Ensure the attack is the same directionality as the player.
		magic_layer.add_child(new_attack) # Add the new instance as a child of the magic layer node

func player_missile() -> void: # Called by state_machine(); Ranged dart attack
	if attack_cooldown.is_stopped(): # Don't let players spam attack more than once every 0.75 seconds
		attack_cooldown.start() # Start cooldown timer
		if cast_anim_timer.is_stopped():
			cast_anim_timer.start()
		var new_missile = player_missile_scene.instantiate() # Instantiate the preloaded scene
		var projectile_start_pos = global_position + Vector2(cos(aim_direction - PI / 2), sin(aim_direction - PI / 2)) * 24
		new_missile.global_position = projectile_start_pos # place it in the world
		new_missile.set("direction", Vector2(cos(aim_direction- PI / 2), sin(aim_direction - PI / 2))) #.normalized()) # Set the direction of the projectile
		new_missile.set("player_color", player_color) # I hope this works. // It totally worked!
		new_missile.rotation = aim_direction - PI / 2
		if player_color=="Blue" or player_color=="Green" or player_color=="Purple":
			construct_cold_team(new_missile)
		else:
			construct_hot_team(new_missile)
	# NOTE: After the above, players will collide with the opposite teams' attacks, and visa versa (from the default)
		magic_layer.add_child(new_missile) # Add the new instance as a child of the magic layer node

func player_block() -> void: # Called by state_machine(); Localized magic wall for defense #NOTE/FEEDBACK/TODO: It's been suggested to make the block bigger.
	# NOTE: Players collide with blocking walls by default, stopping the players in their tracks.
	if cast_anim_timer.is_stopped():
		cast_anim_timer.start()
	var block_name = "PlayerBlock_" + player_color # Search for existing blocks with the same name
	for child in magic_layer.get_children(): # Check the magic layer
		if child.name == block_name: # If we already one of these spawned,
			child.free() # Free the existing block and kill it, so we can make the new one.
	var new_block = player_block_scene.instantiate() # Instantiate the preloaded scene
	var face_direction: int
	if sprite.flip_h == false: # If the wiz is facing right.
		face_direction = 1
	else:
		face_direction = -1
	new_block.global_position = get_global_position() + Vector2(16 * face_direction, 0) # Small offset, makes sure it appears outside the player body, on the correct side.
	new_block.set("player_color", player_color) # I hope this works. // It totally worked!
	if player_color=="Blue" or player_color=="Green" or player_color=="Purple":
		construct_cold_team(new_block)
	else:
		construct_hot_team(new_block)
	magic_layer.add_child(new_block) # Add the new instance as a child of the magic layer node

func player_platform() -> void: #Called by state_machine(); Localized matgic floor for manuvering
	# NOTE: Players collide with blocking walls by default, stopping the players in their tracks.
	if cast_anim_timer.is_stopped():
		cast_anim_timer.start()
	var platform_name = "PlayerPlatform_" + player_color # Search for existing blocks with the same name
	for child in magic_layer.get_children(): # Check the magic layer
		if child.name == platform_name: # If we already one of these spawned,
			child.free() # Free the existing block and kill it, so we can make the new one.
	var new_platform = player_platform_scene.instantiate() # Instantiate the preloaded scene
	new_platform.global_position = get_global_position() + Vector2(0, 16) # Small offset, makes sure it appears outside the player body, below the player.
	new_platform.set("player_color", player_color) # I hope this works. // It totally worked!
	if player_color=="Blue" or player_color=="Green" or player_color=="Purple":
		construct_cold_team(new_platform)
	else:
		construct_hot_team(new_platform)
	magic_layer.add_child(new_platform) # Add the new instance as a child of the magic layer node

func player_special() -> void: # TODO Called by state_machine(); The Player is spending their 'smash ball' scroll
	pass

func player_knockback() -> void: # TODO
	pass

func player_score() -> void: # TODO
	pass

func player_kill() -> void: # TODO
	pass

func player_death() -> void: # TODO Called by state_machine();
	player.play("death")

#######################################################################################################################################################
## CONTROLLERS
func update_ui() -> void: # called very first _physics_process()
	ui_layer.set("hp", hp)
	ui_layer.set("goals", goals)
	ui_layer.set("kills", kills)
	ui_layer.set("deaths", deaths)
	var current_frame = sprite.frame
	ui_sprite.frame = current_frame
	if last_facing == "left":
		ui_sprite.flip_h = true
		ui_spike.flip_h = true
	else:
		ui_sprite.flip_h = false
		ui_spike.flip_h = false
	if spike.visible == true:
		ui_spike.visible = true
	else:
		ui_spike.visible = false

func physics_collisions() -> void: # Called from _physics_process()
	# after calling move_and_slide()
	for i in range(get_slide_collision_count()): # Get collisions #, loop
		#TODO: Okay, the following line, -here-, creates wall-stick. it's grippier than meatboy.
		#self.velocity.y = 0
		#TODO: I'm going to implement this as a match option, in the future.
		collision = get_slide_collision(i) # Get collision, from # above
		collider = collision.get_collider()
		if collider.is_in_group("balls") and not is_on_top_of_ball() and not collider.is_in_group("ramps"): # if the collision is with the ball, and we're not on top of it.
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
		elif collider.is_in_group("players"):
			var normal = collision.get_normal() # Collision normal vector
			var delta_v = -normal * (variable_force() / 7.5)
			collider.set_velocity(delta_v)
			collider.set("outside_forces", delta_v.x)

func sprite_flip(direction: String) -> void: # Called from state_machine()
	if direction == "right":
		if sprite.flip_h != false:
			sprite.flip_h = false
	elif direction == "left":
		if sprite.flip_h != true:
			sprite.flip_h = true
