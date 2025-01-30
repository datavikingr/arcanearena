extends StaticBody2D

@onready var ball: RigidBody2D = %Ball
signal own_goal(player: String)
signal player_score(player: String)
var player

func _ready() -> void:
	self.add_to_group("HotTeam")
	pass

func _on_ball_goal(player: String) -> void:
	print(player)
	match player:
		"Blue":
			emit_signal("player_score", player)
		"Green":
			emit_signal("player_score", player)
		"Purple":
			emit_signal("player_score", player)
		"Red":
			emit_signal("own_goal", player)
		"Yellow":
			emit_signal("own_goal", player)
		"Orange:":
			emit_signal("own_goal", player)
