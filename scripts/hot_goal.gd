extends StaticBody2D

@onready var ball: RigidBody2D = %Ball
@onready var player1: PlayerCharacter = %Player1
@onready var player2: PlayerCharacter = %Player2
@onready var coldui: Node2D = %ColdTeamUI

signal hot_own_goal(player_name: String)
signal hot_player_score(player_name: String)
var player_name: String
var players: Array[PlayerCharacter] = []
var init_goals: bool

func _ready() -> void:
	self.add_to_group("HotTeam")
	self.hot_player_score.connect(Callable(coldui, "score"))
	self.hot_own_goal.connect(Callable(coldui, "score"))
	init_goals = true

func _goal(player_name, body) -> void:
	if body != self:
		print("Nothing to see here.")
	else:
		print("#2 Signal received! "+player_name+" scored!")
		if init_goals == true:
			players = [player1, player2] #TODO: Replace with dynamic detection of players
			for player in players:
				if player.is_in_group("HotTeam"):
					print("INIT: "+player.name+" registered hot own-goal.")
					self.hot_own_goal.connect(Callable(player, "own_goal"))
				else:
					print("INIT: "+player.name+" registered hot score.")
					self.hot_player_score.connect(Callable(player, "player_score"))
			init_goals = false
		else:
			pass
		match player_name:
			"Blue":
				hot_player_score.emit(player_name)
				print("#3 Hell yeah!")
			"Green":
				hot_player_score.emit(player_name)
				print("#3 Hell yeah!")
			"Purple":
				hot_player_score.emit(player_name)
				print("#3 Hell yeah!")
			"Red":
				hot_own_goal.emit(player_name)
				print("#3 ...on themself.")
			"Yellow":
				hot_own_goal.emit(player_name)
				print("#3 ...on themself.")
			"Orange":
				hot_own_goal.emit(player_name)
				print("#3 ...on themself.")
