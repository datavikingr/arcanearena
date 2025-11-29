extends Node2D

@onready var solo: Node2D = get_node("Solo")
@onready var one_v_one: Node2D = get_node("1V1")
@onready var two_v_two: Node2D = get_node("2V2")
@onready var three_v_three: Node2D = get_node("3V3")

func _process(_delta: float) -> void: 
	if self.modulate.a < 1.0:
		solo.monitoring = false
		one_v_one.monitoring = false
		two_v_two.monitoring = false
		three_v_three.monitoring = false
	else: 
		solo.monitoring = true
		one_v_one.monitoring = true
		two_v_two.monitoring = true
		three_v_three.monitoring = true

func _on_solo_body_entered(_body: Node2D) -> void:
	get_tree().change_scene_to_file("res://scenes/games/OnePlayer.tscn")

func _on_v_1_body_entered(_body: Node2D) -> void:
	get_tree().change_scene_to_file("res://scenes/games/TwoPlayers.tscn")

func _on_v_2_body_entered(_body: Node2D) -> void:
	get_tree().change_scene_to_file("res://scenes/games/FourPlayers.tscn")

func _on_v_3_body_entered(_body: Node2D) -> void:
	get_tree().change_scene_to_file("res://scenes/games/SixPlayers.tscn")
