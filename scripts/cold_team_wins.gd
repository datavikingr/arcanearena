extends Node2D
var countdown: int = 30

func toggle_visibility() -> void:
	if visible:
		visible = false
	else:
		visible = true

func countdown_timer() -> void:
	countdown -= 1
	if countdown == 0:
		#get_tree().change_scene_to_file("res://scenes/new_scene.tscn") #TODO
		pass
	pass

func _on_timer_timeout() -> void:
	countdown_timer()
	toggle_visibility()
