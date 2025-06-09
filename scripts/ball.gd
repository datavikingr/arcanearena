extends RigidBody2D

# Nodese
@onready var goal_hot: StaticBody2D = %HotGoal
@onready var goal_cold: StaticBody2D = %ColdGoal
@onready var splosion_hot: GPUParticles2D = %HotGoalExplosion
@onready var splosion_cold: GPUParticles2D = %ColdGoalExplosion
@onready var ball_sprite: Sprite2D = get_node("BallSprite")
@onready var countdown_sprite: Sprite2D = get_node("CountdownSprite")
# Local
var last_contact: String = "" # Keeps track of the last player to touch the ball
var penultimate_contact: String = "" #So we can see next previous possession
var force_multiplier
var team: String
var contact_names := [] # Holds up to 5 names
@export var countdown: int = 3
@export var goal_state: bool = false
# Signals
signal goal(player: String)

#######################################################################################################################################################
## STATUS-CHECK / CALLABLE FUNCTIONS
func add_contact_name(new_name: String) -> void:
	match new_name:
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
	if contact_names.size() > 5:
		contact_names.pop_back() # Drop oldest

func detect_team_contacts():
	return contact_names.size() == 5 and contact_names.count(contact_names[0]) == 5

#######################################################################################################################################################
## INIT/CONSTRUCTORS
func _ready() -> void: # Called when the node enters the scene tree for the first time.
	force_multiplier = 1
	self.goal.connect(Callable(goal_hot, "_goal"))
	self.goal.connect(Callable(goal_cold, "_goal"))
	ball_die()
	ball_respawn()

#######################################################################################################################################################
## EXECUTION / MAIN
func _process(_delta: float) -> void: # Called every frame. 'delta' is the elapsed time since the previous frame.
	if last_contact != penultimate_contact:
		print(last_contact)
		penultimate_contact = last_contact
	if detect_team_contacts():
		on_fire()

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

#######################################################################################################################################################
## BALL STUFF
func ball_die():
	if goal_state == false:
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


func write_gitgud_message() -> void: #TODO
	#Strike it!
	#Harder next time!
	#Well, it certainly was a shot.
	#Your weakness disgusts me.
	#gitgud
	#oh, so close!!
	pass
