extends Node2D

@onready var timer = get_node("Timer")

func _ready() -> void:
	timer.start()

func _on_timer_timeout() -> void:
	Global.fade_to(0.0, self)
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
