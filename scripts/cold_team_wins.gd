extends Node2D

@onready var screen_dark: Sprite2D = %ScreenDark
var countdown_total: int = 30
var countdown: int = countdown_total
var visibility_decay_rate: int = 2

func toggle_visibility() -> void:
	if visible:
		visible = false
	else:
		visible = true

func countdown_timer() -> void:
	countdown -= 1
	if countdown == countdown_total - (visibility_decay_rate * 1):
		screen_dark.modulate = Color(0,0,0,.2)
	if countdown == countdown_total - (visibility_decay_rate * 2):
		screen_dark.modulate = Color(0,0,0,.4)
	if countdown == countdown_total - (visibility_decay_rate * 3):
		screen_dark.modulate = Color(0,0,0,.6)
	if countdown == countdown_total - (visibility_decay_rate * 4):
		screen_dark.modulate = Color(0,0,0,.8)
	if countdown == countdown_total - (visibility_decay_rate * 5):
		screen_dark.modulate = Color(0,0,0,1)
		#TODO prevent player movement & switch to menu controls
	if countdown == 0:
		#get_tree().change_scene_to_file("res://scenes/new_scene.tscn") #TODO
		pass
	pass

func _on_timer_timeout() -> void:
	countdown_timer()
	toggle_visibility()
