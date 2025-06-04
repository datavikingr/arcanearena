extends Node2D

@export var slow_time_scale: float = 0.1 # Property to set the time scale for when the node is active
@export var normal_time_scale: float = 1.0 # Property to set the normal time scale when the node is disabled

func _ready():
	if is_visible_in_tree(): # When the node is enabled or disabled, adjust the time scale
		_enable_slow_motion()
	else:
		_disable_slow_motion()

func _enable_slow_motion():
	Engine.time_scale = slow_time_scale # Enable slow-motion by changing the time scale

func _disable_slow_motion(): # Disable slow-motion by resetting the time scale
	Engine.time_scale = normal_time_scale

func _notification(what): # Handle when the node becomes visible (in editor or runtime)
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if is_visible_in_tree():
			_enable_slow_motion()
		else:
			_disable_slow_motion()
