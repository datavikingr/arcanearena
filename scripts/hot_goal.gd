extends StaticBody2D

@onready var ball: RigidBody2D = %Ball
@onready var coldui: Node2D = %ColdTeamUI

signal hot_own_goal(player_name: String)
signal hot_player_score(player_name: String)
var players: Array = []
var init_goals: bool
var arena: Node2D

func _ready() -> void:
	arena = get_tree().current_scene
	self.add_to_group("HotTeam")
	self.hot_player_score.connect(Callable(coldui, "score"))
	self.hot_own_goal.connect(Callable(coldui, "score"))
	init_goals = true

func _goal(player_name, body) -> void:
	if body == self:
		if init_goals == true:
			players = arena.current_players
			for player in players:
				if player.is_in_group("HotTeam"):
					self.hot_own_goal.connect(Callable(player, "own_goal"))
				else:
					self.hot_player_score.connect(Callable(player, "player_score"))
			init_goals = false
		else:
			pass
		match player_name:
			"Blue":
				hot_player_score.emit(player_name)
			"Green":
				hot_player_score.emit(player_name)
			"Purple":
				hot_player_score.emit(player_name)
			"Red":
				hot_own_goal.emit(player_name)
			"Yellow":
				hot_own_goal.emit(player_name)
			"Orange":
				hot_own_goal.emit(player_name)
