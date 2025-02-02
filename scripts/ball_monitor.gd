extends Node2D

@onready var ball = preload("res://scenes/ball.tscn")
var ball_state: bool = false

func ready() -> void:
	pass

func process() -> void:
	ball_state = false # Zero the scanner
	if get_node("..").get_child_count() > 0: # Don't need to scan, if there's no children, we just need to make a new ball
		for child in get_children(): # scan the children
			if child.is_in_group("balls"): # has ball?
				ball_state = true # Found one
				break # get out of the scan
	if not ball_state: #if there is no ball
		spawn_new_ball()

func spawn_new_ball() -> void:
	if ball:  # Ensure the scene is assigned
		var new_ball = ball.instantiate() # Create the motherfucker
		add_child(new_ball)  # Add the ball as a child of this node
		new_ball.global_position = global_position  # Adjust as needed
