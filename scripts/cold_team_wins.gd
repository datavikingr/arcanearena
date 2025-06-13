extends Node2D

@onready var screen_dark: Sprite2D = %ScreenDark
var countdown: int = 30

func toggle_visibility() -> void:
	if visible:
		visible = false
	else:
		visible = true

func countdown_timer() -> void:
	countdown -= 1
	if countdown == 27:
		screen_dark.modulate = Color(0,0,0,.2)
	if countdown == 24:
		screen_dark.modulate = Color(0,0,0,.4)
	if countdown == 21:
		screen_dark.modulate = Color(0,0,0,.6)
	if countdown == 18:
		screen_dark.modulate = Color(0,0,0,.8)
	if countdown == 15:
		screen_dark.modulate = Color(0,0,0,1)
	if countdown == 0:
		#get_tree().change_scene_to_file("res://scenes/new_scene.tscn") #TODO
		pass
	pass

func _on_timer_timeout() -> void:
	countdown_timer()
	toggle_visibility()
