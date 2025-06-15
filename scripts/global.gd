extends Node

var player_scenes = [
	preload("res://scenes/player1.tscn"),
	preload("res://scenes/player2.tscn"),
	preload("res://scenes/player3.tscn"),
	preload("res://scenes/player4.tscn"),
	preload("res://scenes/player5.tscn"),
	preload("res://scenes/player6.tscn")
]
var player_colors = ["Blue", "Red", "Green", "Yellow", "Purple", "Orange"] #TODO global.gd, 12 This order will be chosen at character select screen
var current_players = []
var match_data: Dictionary = {} # Store match-wide state here
var root

signal players_ready(players)

func reset():
	match_data = {}

func ready() -> void:
	root = get_tree().root
	spawn_players(root, 2)

func spawn_players(parent_node: Node, count := 2):
	for i in count:
		var scene = player_scenes[i]
		var player = scene.instantiate()

		player.player_color = player_colors[i] # Set color directly
		player.name = "Player%d" % i

		parent_node.add_child(player)
		current_players.append(player)

func process():
	for player in current_players:
		#TODO global.process() Get their stats: Goals, kills, deaths, shots
		#TODO player_behavior() also implement own goals, saves, touches, ranged, melee, blocks, platforms
		#TODO global.process() Then get those stats
		#TODO we'll cross-analyze these stats in the stats screen, for player % intercomparison; "Player4 had 77% of touches!"
		#TODO among those cross-analyzed stats, pick the 4 largest numbers, display those.
		pass
	pass
