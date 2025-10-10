extends Node

const splash: String = "res://scenes/splash.tscn"
const main_menu: String = "res://scenes/main_menu.tscn"
const match_arena: String = "res://scenes/test_arena_empty.tscn"

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

@onready var hot_team_wins: Node2D = %HotTeamWins
@onready var cold_team_wins: Node2D = %ColdTeamWins

func reset():
	match_data = {}

func _ready() -> void:
	get_tree().change_scene_to_file(splash)
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file(match_arena)
	_arena_ready()
	pass

func _arena_ready() -> void:
	# Grab nodes required for other stuff
	arena = get_tree().root.get_node("Arena")
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
	if hot_team_wins:
		hot_team_wins.victory.connect(_game_over)

func process():
	pass

func _game_over(): # signal emitted from xxxx_team_wins.gd at first timer bump
	for player in current_players:
		match_data[player] = {} # init nested dictionary
		for stat in player_stats:
			match_data[player][stat] = player.get(stat)
	pass

#FUTURE global.process() Get their stats: Goals, kills, murders (total deaths - own goals), shots, own goals
#FUTURE player_behavior() also implement saves, touches, ranged, melee, blocks, platforms && global.process() Then get those stats
#FUTURE we'll cross-analyze these stats in the stats screen, for player % intercomparison; "Player4 had 77% of touches!"
#FUTURE among those cross-analyzed stats, pick the 4 largest numbers, display those.
