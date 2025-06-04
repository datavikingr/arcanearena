extends Node2D

@export var meatboyslide: bool = false # Global variable storage for spider climb

func _ready():
	if is_visible_in_tree(): # When the node is enabled or disabled, adjust the player's wall-stickiness
		meatboyslide = true
	else:
		meatboyslide = false

func _notification(what): # Handle when the node becomes visible (in editor or runtime)
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if is_visible_in_tree():
			meatboyslide = true
		else:
			meatboyslide = false
