extends RigidBody2D

# Nodes
@onready var goal_hot: StaticBody2D = %HotGoal
@onready var goal_cold: StaticBody2D = %ColdGoal
@onready var splosion_hot: GPUParticles2D = %HotGoalExplosion
@onready var splosion_cold: GPUParticles2D = %ColdGoalExplosion
@onready var cold_team_ui: Node2D = %ColdTeamUI
@onready var hot_team_ui: Node2D = %HotTeamUI
@onready var raycast_hot = $HotGoalFinder
@onready var raycast_cold = $ColdGoalFinder
@onready var miami = $HotLine
@onready var alaska = $ColdLine
@onready var ball_sprite: Sprite2D = $BallSprite
@onready var countdown_sprite: Sprite2D = $CountdownSprite
var players: Array[PlayerCharacter] = []

# Local
var last_contact: String = "" # Keeps track of the last player to touch the ball
var penultimate_contact: String = "" #So we can see next previous possession
var force_multiplier
var team: String
var contact_names := [] # Holds up to 5 names
var goal_radar_distance: int = 124 # used on the raycasts in aim_goal_finder()
@export var countdown: int = 3
@export var goal_state: bool = false
var hot_goal_hit: bool = false
var cold_goal_hit: bool = false

# Signals
signal goal(player: String)
signal miamishot(player: String) # shot on hot net
signal alaskashot(player: String) # shot on cold net

#######################################################################################################################################################
## STATUS-CHECK / CALLABLE FUNCTIONS
func add_contact_name(new_name: String) -> void:
	match new_name: # parse who belongs to what team
		"Blue":
			team = "cold"
		"Green":
			team = "cold"
		"Purple":
			team = "cold"
		"Red":
			team = "hot"
		"Yellow":
			team = "hot"
		"Orange":
			team = "hot"
	contact_names.insert(0, team) # Add to front
	if contact_names.size() > 5: # Detect size so we can trim the fucker
		contact_names.pop_back() # Drop oldest

func match_is_over():
	return cold_team_ui.goals == 20 or hot_team_ui.goals == 20

func detect_team_contacts():
	return contact_names.size() == 5 and contact_names.count(contact_names[0]) == 5

#######################################################################################################################################################
## INIT/CONSTRUCTORS
func _ready() -> void: # Called when the node enters the scene tree for the first time.
	force_multiplier = 1
	self.goal.connect(Callable(goal_hot, "_goal"))
	self.goal.connect(Callable(goal_cold, "_goal"))
	# TODO shot signals to players; see cold_goal._goal() for reference.
	for player in Global.current_players:
		if player.is_in_group("ColdTeam"):
			self.miamishot.connect(Callable(player, "player_shot"))
		else:
			self.alaskashot.connect(Callable(player, "player_shot"))
	ball_die()
	ball_respawn()

#######################################################################################################################################################
## EXECUTION / MAIN
func _process(_delta: float) -> void: # Called every frame. 'delta' is the elapsed time since the previous frame.
	aim_goal_finders()
	if last_contact != penultimate_contact:
		#print(last_contact)
		penultimate_contact = last_contact
	if detect_team_contacts():
		on_fire()
	if match_is_over():
		self.global_transform.origin = Vector2(4000,-1100)
		ball_sprite.visible = false

func _physics_process(_delta: float) -> void: # Called every frame. We're gonna collect data from collisions here. Separate thread from _process().
	if contact_monitor == true:
		for body in get_colliding_bodies():
			if body.is_in_group("goals"):
				var goal_position = self.global_position # Cache the position BEFORE ball_die()
				if body.is_in_group("coldteam"):
					splosion_hot.global_position = goal_position
					splosion_hot.emitting = true
				else:
					splosion_cold.global_position = goal_position
					splosion_cold.emitting = true
				goal.emit(last_contact, body)
				contact_monitor = false
				ball_die()
			if body.is_in_group("players"):
				add_contact_name(last_contact)
	shot_detection()

#######################################################################################################################################################
## BALL STUFF
func ball_die():
	if not goal_state:
		self.global_transform.origin = Vector2(320,90)
		self.freeze = true
		goal_state = true
		ball_sprite.visible = false
		countdown_sprite.visible = true
		countdown_sprite.modulate = Color(1, 0, 0)
		linear_velocity = Vector2(0,0)
		angular_velocity = 0.0
		rotation = 0
		gravity_scale = 0
		if match_is_over():
			self.global_transform.origin = Vector2(4000,-1100)
		else:
			var ball_timer = Timer.new()
			ball_timer.wait_time = 1
			ball_timer.one_shot = true
			ball_timer.name = "BallTimer"
			add_child(ball_timer)
			ball_timer.timeout.connect(ball_respawn)
			ball_timer.start()

func ball_respawn():
	var balltimer = get_node("BallTimer")
	if countdown > 0:
		countdown -= 1
		countdown_sprite.frame -= 1
		balltimer.start()
	elif countdown <= 0:
		countdown_sprite.frame = 3
		countdown_sprite.visible = false
		balltimer.queue_free()
		contact_monitor = true
		countdown = 3
		goal_state = false
		ball_sprite.visible = true
		gravity_scale = 1
		self.freeze = false
		#print("Contact Monitor should be back on.")

func on_fire() -> void:
	#TODO : what happens when we're on fire?
	pass

func aim_goal_finders() -> void:
	# Hot goal
	var direction_to_hot = goal_hot.global_position - global_position
	var local_target_hot = direction_to_hot.normalized() * goal_radar_distance
	raycast_hot.rotation = -rotation
	raycast_hot.target_position = local_target_hot
	miami.points = [raycast_hot.position, raycast_hot.target_position]
	miami.rotation = -rotation
	# Cold goal
	var direction_to_cold = goal_cold.global_position - global_position
	var local_target_cold = direction_to_cold.normalized() * goal_radar_distance
	raycast_cold.rotation = -rotation
	raycast_cold.target_position = local_target_cold
	alaska.points = [raycast_cold.position, raycast_cold.target_position]
	alaska.rotation = -rotation

func shot_detection():
	if raycast_hot.is_colliding() and raycast_hot.get_collider() == goal_hot: # Hot Goal Shot Detection
		if not hot_goal_hit: # if the flag is currently off, we're not actively spamming shot-contact a thousand times
			#print("Shot toward Hot Goal!") # meaning we have a new a shot on our hands
			hot_goal_hit = true # and we're gonna stop detecting more shots.
			miamishot.emit(last_contact)
	else:
		hot_goal_hit = false # reset the flag once we've stopped contacting the goals, so we can detect new shots
	if raycast_cold.is_colliding() and raycast_cold.get_collider() == goal_cold: # Cold Goal Shot Detection
		if not cold_goal_hit: # if the flag is currently off, we're not actively spamming shot-contact a thousand times
			#print("Shot toward Cold Goal!") # meaning we have a new a shot on our hands
			cold_goal_hit = true # and we're gonna stop detecting more shots.
			alaskashot.emit(last_contact)
	else:
		cold_goal_hit = false # reset the flag once we've stopped contacting the goals, so we can detect new shots

func write_gitgud_message() -> void: #TODO
	#NOTE This requires 2 raycast2Ds, one aimed at each goal
	# They should be long, min 64 length
	# if contact with goal, record team score, start 1s timer
	# if recorded team score = team score now, this was (only) a shot.

	# EXAMPLES
	#Strike it!
	#Harder next time!
	#Well, it certainly was a shot.
	#Your weakness disgusts me.
	#gitgud
	#oh, so close!!
	pass
