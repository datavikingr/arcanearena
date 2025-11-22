extends Node2D

var current_players = []
var player_stats = ["player_color", "goals", "own_goals", "kills", "deaths", "shots"]
var match_data: Dictionary = {} # Store match-wide state here
var arena: Node2D
var map: Node2D
var goal_y
var hot_goal
var cold_goal
var platform_configs = [
	"res://scenes/platformconfigs/ball.tscn",
	"res://scenes/platformconfigs/ball_divider.tscn",
	"res://scenes/platformconfigs/battlefield.tscn",
	"res://scenes/platformconfigs/battlefield_vertical.tscn",
	"res://scenes/platformconfigs/divider.tscn",
	"res://scenes/platformconfigs/fourcorners.tscn",
	"res://scenes/platformconfigs/omega.tscn"
]

func _ready() -> void:
	# Grab nodes required for other stuff
	arena = self
	map = arena.get_node("Map")
	# Random selection of platfrom configurations
	var random_index = randi() % platform_configs.size() # Get a random index
	var plat_map = load(platform_configs[random_index]) # Load the platform config from the random index
	var plat_instance = plat_map.instantiate()
	map.add_child(plat_instance)
	# Get player nodes and append current_players with them, so we can gather their states/stats later.
	var players = [
		arena.get_node_or_null("Player1"),
		arena.get_node_or_null("Player2"),
		arena.get_node_or_null("Player3"),
		arena.get_node_or_null("Player4"),
		arena.get_node_or_null("Player5"),
		arena.get_node_or_null("Player6")
	]
	for player in players:
		if player != null:
			current_players.append(player)
	# Random Goal height
	goal_y = randf_range(119, 264)
	hot_goal = map.get_node("Goals").get_node("HotGoal")
	cold_goal = map.get_node("Goals").get_node("ColdGoal")
	hot_goal.position.y = goal_y
	cold_goal.position.y = goal_y
	# Grab Signals
	#TODO if hot_team_wins:
		#TODO hot_team_wins.victory.connect(_game_over)
