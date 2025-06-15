extends Node2D
class_name TeamUI

# Nodes
@onready var ui_goals: Sprite2D = $GoalsSprite
@onready var cold_win: Node2D = %ColdTeamWins
@onready var hot_win: Node2D = %HotTeamWins
# Local
var win_countdown: Timer
@export var goals: int = 0

func ready() -> void:
	pass

func score(_player_name) -> void: # Blank hook for children to override
	pass # Placeholder, will be overridden by child

func _process(_delta) -> void:
	get_goals()

func get_goals() -> void: # Called every frame by _process()
	match goals:
		0:
			ui_goals.frame = 0
			ui_goals.modulate = Color(1, 1, 1)
		1:
			ui_goals.frame = 1
			ui_goals.modulate = Color(1, 1, .9)
		2:
			ui_goals.frame = 2
			ui_goals.modulate = Color(1, 1, .8)
		3:
			ui_goals.frame = 3
			ui_goals.modulate = Color(1, 1, .7)
		4:
			ui_goals.frame = 4
			ui_goals.modulate = Color(1, 1, .6)
		5:
			ui_goals.frame = 5
			ui_goals.modulate = Color(1, 1, .5)
		6:
			ui_goals.frame = 6
			ui_goals.modulate = Color(1, 1, .4)
		7:
			ui_goals.frame = 7
			ui_goals.modulate = Color(1, 1, .3)
		8:
			ui_goals.frame = 8
			ui_goals.modulate = Color(1, 1, .2)
		9:
			ui_goals.frame = 9
			ui_goals.modulate = Color(1, 1, .1)
		10:
			ui_goals.frame = 0
			ui_goals.modulate = Color(1, 1, 0)
		11:
			ui_goals.frame = 1
			ui_goals.modulate = Color(1, .9, 0)
		12:
			ui_goals.frame = 2
			ui_goals.modulate = Color(1, .8, 0)
		13:
			ui_goals.frame = 3
			ui_goals.modulate = Color(1, .7, 0)
		14:
			ui_goals.frame = 4
			ui_goals.modulate = Color(1, .6, 0)
		15:
			ui_goals.frame = 5
			ui_goals.modulate = Color(1, .5, 0)
		16:
			ui_goals.frame = 6
			ui_goals.modulate = Color(1, .4, 0)
		17:
			ui_goals.frame = 7
			ui_goals.modulate = Color(1, .3, 0)
		18:
			ui_goals.frame = 8
			ui_goals.modulate = Color(1, .2, 0)
		19:
			ui_goals.frame = 9
			ui_goals.modulate = Color(1, .1, 0)
		20:
			ui_goals.frame = 0
			ui_goals.modulate = Color(1, 0, 0)

func hot_team_wins():
	win_countdown=  hot_win.get_node("Timer")
	win_countdown.start()

func cold_team_wins():
	win_countdown=  cold_win.get_node("Timer")
	win_countdown.start()
