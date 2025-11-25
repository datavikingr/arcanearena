extends Node2D

var current_players = []
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

func reset():
	match_data = {}

func _ready() -> void:
	arena = self #arena = get_tree().current_scene
	map = arena.get_node("Map")

	# Random selection of platfrom configurations
#TODO	var random_index = randi() % platform_configs.size() # Get a random index
#TODO	var plat_map = load(platform_configs[random_index]) # Load the platform config from the random index
#TODO	var plat_instance = plat_map.instantiate()
#TODO	map.add_child(plat_instance)

	# Random Goal height
#TODO	goal_y = randf_range(119, 264)
#TODO	hot_goal = map.get_node("Goals").get_node("HotGoal")
#TODO	cold_goal = map.get_node("Goals").get_node("ColdGoal")
#TODO	hot_goal.position.y = goal_y
#TODO	cold_goal.position.y = goal_y

	# Get player nodes and append current_players with them, so we can gather their states/stats later.
	await get_tree().process_frame
	update_players()

func process():
	for player in current_players:
		#TODO global.process() Get their stats: Goals, kills, murders (total deaths - own goals), shots, own goals
		#TODO player_behavior() also implement saves, touches, ranged, melee, blocks, platforms && global.process() Then get those stats
		#TODO we'll cross-analyze these stats in the stats screen, for player % intercomparison; "Player4 had 77% of touches!"
		#TODO among those cross-analyzed stats, pick the 4 largest numbers, display those.
		pass
	pass

func update_players():
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