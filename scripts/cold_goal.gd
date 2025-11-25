extends StaticBody2D

@onready var ball: RigidBody2D = %Ball
@onready var hotui: Node2D = %HotTeamUI
@onready var arena = get_tree().current_scene

signal cold_own_goal(player_name: String)
signal cold_player_score(player_name: String)
var players: Array = []
var init_goals: bool

func _ready() -> void:
	#arena = get_tree().current_scene
	self.add_to_group("ColdTeam")
	self.cold_player_score.connect(Callable(hotui, "score"))
	self.cold_own_goal.connect(Callable(hotui, "score"))
	init_goals = true

func _goal(player_name, body) -> void:
	if body == self:
		if init_goals == true:
			for child in arena.get_children():
				if child.is_in_group("players"):
					players.append(child)
			for player in players:
				if player.is_in_group("ColdTeam"):
					self.cold_own_goal.connect(Callable(player, "own_goal"))
				else:
					self.cold_player_score.connect(Callable(player, "player_score"))
			init_goals = false
		match player_name:
			"Blue":
				cold_own_goal.emit(player_name)
			"Green":
				cold_own_goal.emit(player_name)
			"Purple":
				cold_own_goal.emit(player_name)
			"Red":
				cold_player_score.emit(player_name)
			"Yellow":
				cold_player_score.emit(player_name)
			"Orange":
				cold_player_score.emit(player_name)
