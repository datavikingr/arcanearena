extends Node2D

# Nodes
@onready var ui_goals: Sprite2D = $GoalsSprite
@onready var hot_win: Node2D = %HotTeamWins
# Local
var win_countdown: Timer
@export var goals: int = 0

func ready() -> void:
	pass

func score(_player_name) -> void:
	goals += 1
	if goals >= 10:
		hot_team_wins()

func _process(_delta) -> void:
	get_goals()

func get_goals() -> void: # Called every frame by _process()
	match goals:
		0:
			ui_goals.frame = 0
			ui_goals.modulate = Color(1, 1, 1)
		1:
			ui_goals.frame = 1
			ui_goals.modulate = Color(1, 1, 1)
		2:
			ui_goals.frame = 2
			ui_goals.modulate = Color(1, 1, 1)
		3:
			ui_goals.frame = 3
			ui_goals.modulate = Color(1, 1, 1)
		4:
			ui_goals.frame = 4
			ui_goals.modulate = Color(1, 1, 1)
		5:
			ui_goals.frame = 5
			ui_goals.modulate = Color(1, 1, 1)
		6:
			ui_goals.frame = 6
			ui_goals.modulate = Color(1, 1, 1)
		7:
			ui_goals.frame = 7
			ui_goals.modulate = Color(1, 1, 1)
		8:
			ui_goals.frame = 8
			ui_goals.modulate = Color(1, 1, 1)
		9:
			ui_goals.frame = 9
			ui_goals.modulate = Color(1, 1, 1)
		10:
			ui_goals.frame = 0
			ui_goals.modulate = Color(1, 1, 0)
		11:
			ui_goals.frame = 1
			ui_goals.modulate = Color(1, 1, 0)
		12:
			ui_goals.frame = 2
			ui_goals.modulate = Color(1, 1, 0)
		13:
			ui_goals.frame = 3
			ui_goals.modulate = Color(1, 1, 0)
		14:
			ui_goals.frame = 4
			ui_goals.modulate = Color(1, 1, 0)
		15:
			ui_goals.frame = 5
			ui_goals.modulate = Color(1, 1, 0)
		16:
			ui_goals.frame = 6
			ui_goals.modulate = Color(1, 1, 0)
		17:
			ui_goals.frame = 7
			ui_goals.modulate = Color(1, 1, 0)
		18:
			ui_goals.frame = 8
			ui_goals.modulate = Color(1, 1, 0)
		19:
			ui_goals.frame = 9
			ui_goals.modulate = Color(1, 1, 0)

func hot_team_wins():
	win_countdown=  hot_win.get_node("Timer")
	win_countdown.start()
