extends RigidBody2D

var body: Array[Node2D] # bodies the ball is contacting with; used in _physics_process()
var last_contact: String = "" # Keeps track of the last player to touch the ball
var penultimate_contact: String = "" #So we can see next previous possession
var current_team_possession: PlayerCharacter
var last_team_possession: PlayerCharacter
var penult_team_possession: PlayerCharacter
signal goal(player: String)
var force_multiplier


func _ready() -> void: # Called when the node enters the scene tree for the first time.
	force_multiplier = 1
	pass # Replace with function body.

func _process(_delta: float) -> void: # Called every frame. 'delta' is the elapsed time since the previous frame.
	if last_contact != penultimate_contact:
		print(last_contact)
		penultimate_contact = last_contact
	pass

func _physics_process(_delta: float) -> void: # Called every frame. We're gonna collect data from collisions here. Separate thread from _process().
	for body in get_colliding_bodies():
		if body.is_in_group("goals"):
			emit_signal("goal", last_contact)
			print("Goal Signal emitted")
			#TODO: Ball explosion
		if body.is_in_group("players"):
			#TODO: We gotta figure out this possession and on fire idea
			pass


func on_fire() -> void:
	# Ball on fire animation
	pass
