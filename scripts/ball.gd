extends RigidBody2D

var body: Array[Node2D] # bodies the ball is contacting with; used in _physics_process()
var last_contact: String = "" # Keeps track of the last player to touch the ball

func _ready() -> void: # Called when the node enters the scene tree for the first time.
	pass # Replace with function body.

func _process(_delta: float) -> void: # Called every frame. 'delta' is the elapsed time since the previous frame.
	print(last_contact)
	pass

func _physics_process(delta: float) -> void: # Called every frame. We're gonna collect data from collisions here. Separate thread from _process().
	for body in get_colliding_bodies():
		if body.is_in_group("players"):
			#last_contact = body.name
			pass
	pass
