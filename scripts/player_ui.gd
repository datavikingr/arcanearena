extends Node2D
class_name PlayerUI

@onready var heart_one: Sprite2D = $Hearts/Heart1
@onready var heart_two: Sprite2D = $Hearts/Heart2
@onready var heart_thr: Sprite2D = $Hearts/Heart3
@onready var ui_goals: Sprite2D = $GoalsSprite
@onready var ui_kills: Sprite2D = $KillsSprite
@onready var ui_deaths: Sprite2D = $DeathsSprite

var player_color: String
var hp: int = 0
var goals: int = 0
var kills: int = 0
var deaths: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	get_hp()
	get_goals()
	get_kills()
	get_deaths()
	pass

func get_hp() -> void:
	match hp:
		3:
			heart_one.frame = 10
			heart_two.frame = 10
			heart_thr.frame = 10
		2:
			heart_one.frame = 10
			heart_two.frame = 10
			heart_thr.frame = 11
		1:
			heart_one.frame = 10
			heart_two.frame = 11
			heart_thr.frame = 11
		0:
			heart_one.frame = 11
			heart_two.frame = 11
			heart_thr.frame = 11
		_:
			heart_one.frame = 11
			heart_two.frame = 10
			heart_thr.frame = 11

func get_goals() -> void:
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

func get_kills() -> void:
	match kills:
		0:
			ui_kills.frame = 0
			ui_kills.modulate = Color(1, 1, 1)
		1:
			ui_kills.frame = 1
			ui_kills.modulate = Color(1, 1, 1)
		2:
			ui_kills.frame = 2
			ui_kills.modulate = Color(1, 1, 1)
		3:
			ui_kills.frame = 3
			ui_kills.modulate = Color(1, 1, 1)
		4:
			ui_kills.frame = 4
			ui_kills.modulate = Color(1, 1, 1)
		5:
			ui_kills.frame = 5
			ui_kills.modulate = Color(1, 1, 1)
		6:
			ui_kills.frame = 6
			ui_kills.modulate = Color(1, 1, 1)
		7:
			ui_kills.frame = 7
			ui_kills.modulate = Color(1, 1, 1)
		8:
			ui_kills.frame = 8
			ui_kills.modulate = Color(1, 1, 1)
		9:
			ui_kills.frame = 9
			ui_kills.modulate = Color(1, 1, 1)
		10:
			ui_kills.frame = 0
			ui_kills.modulate = Color(1, 1, 0)
		11:
			ui_kills.frame = 1
			ui_kills.modulate = Color(1, 1, 0)
		12:
			ui_kills.frame = 2
			ui_kills.modulate = Color(1, 1, 0)
		13:
			ui_kills.frame = 3
			ui_kills.modulate = Color(1, 1, 0)
		14:
			ui_kills.frame = 4
			ui_kills.modulate = Color(1, 1, 0)
		15:
			ui_kills.frame = 5
			ui_kills.modulate = Color(1, 1, 0)
		16:
			ui_kills.frame = 6
			ui_kills.modulate = Color(1, 1, 0)
		17:
			ui_kills.frame = 7
			ui_kills.modulate = Color(1, 1, 0)
		18:
			ui_kills.frame = 8
			ui_kills.modulate = Color(1, 1, 0)
		19:
			ui_kills.frame = 9
			ui_kills.modulate = Color(1, 1, 0)

func get_deaths() -> void:
	match deaths:
		0:
			ui_deaths.frame = 0
			ui_deaths.modulate = Color(1, 1, 1)
		1:
			ui_deaths.frame = 1
			ui_deaths.modulate = Color(1, 1, 1)
		2:
			ui_deaths.frame = 2
			ui_deaths.modulate = Color(1, 1, 1)
		3:
			ui_deaths.frame = 3
			ui_deaths.modulate = Color(1, 1, 1)
		4:
			ui_deaths.frame = 4
			ui_deaths.modulate = Color(1, 1, 1)
		5:
			ui_deaths.frame = 5
			ui_deaths.modulate = Color(1, 1, 1)
		6:
			ui_deaths.frame = 6
			ui_deaths.modulate = Color(1, 1, 1)
		7:
			ui_deaths.frame = 7
			ui_deaths.modulate = Color(1, 1, 1)
		8:
			ui_deaths.frame = 8
			ui_deaths.modulate = Color(1, 1, 1)
		9:
			ui_deaths.frame = 9
			ui_deaths.modulate = Color(1, 1, 1)
		10:
			ui_deaths.frame = 0
			ui_deaths.modulate = Color(1, 1, 0)
		11:
			ui_deaths.frame = 1
			ui_deaths.modulate = Color(1, 1, 0)
		12:
			ui_deaths.frame = 2
			ui_deaths.modulate = Color(1, 1, 0)
		13:
			ui_deaths.frame = 3
			ui_deaths.modulate = Color(1, 1, 0)
		14:
			ui_deaths.frame = 4
			ui_deaths.modulate = Color(1, 1, 0)
		15:
			ui_deaths.frame = 5
			ui_deaths.modulate = Color(1, 1, 0)
		16:
			ui_deaths.frame = 6
			ui_deaths.modulate = Color(1, 1, 0)
		17:
			ui_deaths.frame = 7
			ui_deaths.modulate = Color(1, 1, 0)
		18:
			ui_deaths.frame = 8
			ui_deaths.modulate = Color(1, 1, 0)
		19:
			ui_deaths.frame = 9
			ui_deaths.modulate = Color(1, 1, 0)
