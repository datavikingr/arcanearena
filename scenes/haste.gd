extends Node2D

@export var fast_time_scale: float = 2.5 # Property to set the time scale for when the node is active
@export var normal_time_scale: float = 1.0 # Property to set the normal time scale when the node is disabled

func _ready():
	if is_visible_in_tree(): # When the node is enabled or disabled, adjust the time scale
		_enable_fast_motion()
	else:
		_disable_fast_motion()

func _enable_fast_motion():
	Engine.time_scale = fast_time_scale # Enable slow-motion by changing the time scale

func _disable_fast_motion(): # Disable slow-motion by resetting the time scale
	Engine.time_scale = normal_time_scale

func _notification(what): # Handle when the node becomes visible (in editor or runtime)
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if is_visible_in_tree():
			_enable_fast_motion()
		else:
			_disable_fast_motion()
