extends StaticBody2D

@onready var ball: RigidBody2D = %Ball
signal own_goal(player: String)
signal player_score(player: String)
var player

func _ready() -> void:
	self.add_to_group("ColdTeam")
	pass

func _on_ball_goal(player: String) -> void:
	print(player)
	match player:
		"Blue":
			emit_signal("own_goal", player)
			print("own goal signal emitted")
		"Green":
			emit_signal("own_goal", player)
		"Purple":
			emit_signal("own_goal", player)
		"Red":
			emit_signal("player_score", player)
		"Yellow":
			emit_signal("player_score", player)
		"Orange:":
			emit_signal("player_score", player)
