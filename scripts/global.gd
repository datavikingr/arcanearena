extends Node

const splash: String = "res://scenes/splash.tscn"
const main_menu: String = "res://scenes/main_menu.tscn"
const match_arena: String = "res://scenes/test_arena_empty.tscn"

# var current_players = []
# var player_stats = ["player_color", "goals", "own_goals", "kills", "deaths", "shots"]
# var match_data: Dictionary = {} # Store match-wide state here

#TODO @onready var hot_team_wins: Node2D = %HotTeamWins
#TODO @onready var cold_team_wins: Node2D = %ColdTeamWins

func reset():
	# match_data = {}
	pass

func _ready() -> void:
	#get_tree().change_scene_to_file(splash)
	#await get_tree().create_timer(3.0).timeout
	#get_tree().change_scene_to_file(match_arena)
	# _arena_ready()
	pass

func _arena_ready() -> void:
	pass

func process():
	pass

func _game_over(): # signal emitted from xxxx_team_wins.gd at first timer bump
#	for player in current_players:
#		match_data[player] = {} # init nested dictionary
#		for stat in player_stats:
#			match_data[player][stat] = player.get(stat)
	pass

#FUTURE global.process() Get their stats: Goals, kills, murders (total deaths - own goals), shots, own goals
#FUTURE player_behavior() also implement saves, touches, ranged, melee, blocks, platforms && global.process() Then get those stats
#FUTURE we'll cross-analyze these stats in the stats screen, for player % intercomparison; "Player4 had 77% of touches!"
#FUTURE among those cross-analyzed stats, pick the 4 largest numbers, display those.
