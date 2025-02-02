extends RigidBody2D

# Nodese
@onready var goal_hot: StaticBody2D = %HotGoal
@onready var goal_cold: StaticBody2D = %ColdGoal
@onready var ball_sprite: Sprite2D = get_node("BallSprite")
@onready var countdown_sprite: Sprite2D = get_node("CountdownSprite")
# Local
var last_contact: String = "" # Keeps track of the last player to touch the ball
var penultimate_contact: String = "" #So we can see next previous possession
var current_team_possession: PlayerCharacter
var last_team_possession: PlayerCharacter
var penult_team_possession: PlayerCharacter
var force_multiplier
@export var countdown: int = 3
@export var goal_state: bool = false
# Signals
signal goal(player: String)

func _ready() -> void: # Called when the node enters the scene tree for the first time.
	force_multiplier = 1
	self.goal.connect(Callable(goal_hot, "_goal"))
	self.goal.connect(Callable(goal_cold, "_goal"))
	pass # Replace with function body.

func _process(_delta: float) -> void: # Called every frame. 'delta' is the elapsed time since the previous frame.
	if last_contact != penultimate_contact:
		print(last_contact)
		penultimate_contact = last_contact
	pass

func _physics_process(_delta: float) -> void: # Called every frame. We're gonna collect data from collisions here. Separate thread from _process().
	if contact_monitor == true:
		for body in get_colliding_bodies():
			if body.is_in_group("goals"):
				goal.emit(last_contact, body)
				contact_monitor = false
				ball_die()
				#TODO We need the ball to stop interacting with physics, disappear, and reset position.
			if body.is_in_group("players"):
				#TODO: We gotta figure out this possession and on fire idea
				pass

func ball_die():
	if goal_state == false:
		self.global_transform.origin = Vector2(320,90)
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
		#TODO: Ball explosion

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
		print("Contact Monitor should be back on.")
	pass

func on_fire() -> void:
	# Ball on fire animation
	pass
