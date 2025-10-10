extends Node2D

const main_menu: String = "res://scenes/main_menu.tscn"

func _ready() -> void:
	pass

func _on_timer_timeout() -> void:
	#get_tree().change_scene_to_file(main_menu)
	get_tree().change_scene_to_file("res://scenes/test_arena_empty.tscn")
