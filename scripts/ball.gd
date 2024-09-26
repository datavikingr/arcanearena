extends RigidBody2D

const MAX_VELOCITY = 3000.0  # Set this to a value that feels right for your game

func _ready(): # Called when the node enters the scene tree for the first time.
	pass # Replace with function body.

func _process(_delta): # Called every frame. 'delta' is the elapsed time since the previous frame.
	#if self.position.x > 640 or self.position.x < 0 or self.position.y < 0 or self.position.y
	pass

func _integrate_forces(state) -> void:
	velocity_clamp(state)
	debug_statements(state)
	pass

func velocity_clamp(state) -> void:
	var velocity = state.get_linear_velocity() # what it says on the can
	if velocity.length() > MAX_VELOCITY: # If we're exceeding the speed limit
		velocity = velocity.normalized() * MAX_VELOCITY # Clamp the velocity magnitude
	state.set_linear_velocity(velocity) # Hard-write the clamped speed to the object

func debug_statements(state) -> void:
	for i in range(state.get_contact_count()):
		print("We have contact.")
		var collider = state.get_contact_collider_object(i)
		if collider.is_in_group("players"): # assuming the players are in a "players" group
			var contact_impulse = state.get_contact_impulse(i)
			var delta_velocity = state.get_contact_local_normal(i) * contact_impulse
			print("Player touch detected!")
			print("Impulse received: ", str(contact_impulse))
			print("Delta-v: ", str(delta_velocity))
