extends Node

var current_players = []
var match_data: Dictionary = {} # Store match-wide state here
var root: Node2D
var map: Node2D
var platform_configs = [
	"res://scenes/platformconfigs/ball.tscn",
	"res://scenes/platformconfigs/ball_divider.tscn",
	"res://scenes/platformconfigs/battlefield.tscn",
	"res://scenes/platformconfigs/battlefield_vertical.tscn",
	"res://scenes/platformconfigs/divider.tscn",
	"res://scenes/platformconfigs/fourcorners.tscn",
	"res://scenes/platformconfigs/omega.tscn"
]

func reset():
	match_data = {}

func _ready() -> void:
	root = get_tree().root.get_node("TestArenaEmpty")
	map = root.get_node("Map")

	# NOTE: We tried to instance players from here. Too many race conditions, it just didn't work.
	# We'll have to hard-add players in the editor, and keep/maintain 5 arena scenes (2 player, 3 player, etc)
	# So instead, we'll be instancing platform patterns instead, and moving goal positions from here.
	# We still have to figure out which players are present.

	# Get player nodes and append current_players with them, so we can gather their stats later.
	var players = [
		root.get_node_or_null("Player1"),
		root.get_node_or_null("Player2"),
		root.get_node_or_null("Player3"),
		root.get_node_or_null("Player4"),
		root.get_node_or_null("Player5"),
		root.get_node_or_null("Player6")
	]
	for player in players:
		if player != null:
			current_players.append(player)

	# Random selection of platfrom configurations
	var random_index = randi() % platform_configs.size() # Get a random index
	var plat_map = load(platform_configs[random_index]) # Load the platform config from the random index
	var plat_instance = plat_map.instantiate()
	map.add_child(plat_instance)

	# Random Goal height

func process():
	for player in current_players:
		#TODO global.process() Get their stats: Goals, kills, deaths, shots
		#TODO player_behavior() also implement own goals, saves, touches, ranged, melee, blocks, platforms
		#TODO global.process() Then get those stats
		#TODO we'll cross-analyze these stats in the stats screen, for player % intercomparison; "Player4 had 77% of touches!"
		#TODO among those cross-analyzed stats, pick the 4 largest numbers, display those.
		pass
	pass
