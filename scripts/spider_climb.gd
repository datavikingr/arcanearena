extends Node2D

@export var wallstick: bool = false # Global variable storage for spider climb

func _ready():
	if is_visible_in_tree(): # When the node is enabled or disabled, adjust the time scale
		wallstick = true
	else:
		wallstick = false

func _notification(what): # Handle when the node becomes visible (in editor or runtime)
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if is_visible_in_tree():
			wallstick = true
		else:
			wallstick = false
