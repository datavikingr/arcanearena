extends StaticBody2D

@onready var ball: RigidBody2D = %Ball
@onready var player1: PlayerCharacter = %Player1
@onready var player2: PlayerCharacter = %Player2
@onready var hotui: Node2D = %HotTeamUI

signal cold_own_goal(player_name: String)
signal cold_player_score(player_name: String)
var player_name: String
var players: Array[PlayerCharacter] = []
var init_goals: bool

func _ready() -> void:
	self.add_to_group("ColdTeam")
	self.cold_player_score.connect(Callable(hotui, "score"))
	self.cold_own_goal.connect(Callable(hotui, "score"))
	init_goals = true

func _goal(player_name, body) -> void:
	if body != self:
		print("Nothing to see here.")
	else:
		print("#2 Signal received! "+player_name+" scored!")
		if init_goals == true:
			players = [player1, player2] #TODO: Replace with dynamic detection of players
			for player in players:
				if player.is_in_group("ColdTeam"):
					print("INIT: "+player.name+" registered cold own-goal.")
					self.cold_own_goal.connect(Callable(player, "own_goal"))
				else:
					print("INIT: "+player.name+" registered cold score.")
					self.cold_player_score.connect(Callable(player, "player_score"))
			init_goals = false
		else:
			pass
		match player_name:
			"Blue":
				cold_own_goal.emit(player_name)
				print("#3 ...on themself.")
			"Green":
				cold_own_goal.emit(player_name)
				print("#3 ...on themself.")
			"Purple":
				cold_own_goal.emit(player_name)
				print("#3 ...on themself from the cold goal.")
			"Red":
				cold_player_score.emit(player_name)
				print("#3 Hell yeah!")
			"Yellow":
				cold_player_score.emit(player_name)
				print("#3 Hell yeah!")
			"Orange":
				cold_player_score.emit(player_name)
				print("#3 Hell yeah!")
