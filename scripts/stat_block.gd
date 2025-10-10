extends Node2D
class_name StatBlock

@onready var goalstens: Sprite2D = $Goals/Tens
@onready var goalsones: Sprite2D = $Goals/Ones

@onready var killstens: Sprite2D = $Kills/Tens
@onready var killsones: Sprite2D = $Kills/Ones

@onready var deathstens: Sprite2D = $Deaths/Tens
@onready var deathsones: Sprite2D = $Deaths/Ones

@onready var ownstens: Sprite2D = $Owns/Tens
@onready var ownsones: Sprite2D = $Owns/Ones

@onready var shotstens: Sprite2D = $Shots/Tens
@onready var shotsones: Sprite2D = $Shots/Ones

@onready var playerindicator1: Sprite2D = $PlayerIndicator/Player1
@onready var playerindicator2: Sprite2D = $PlayerIndicator/Player2
@onready var playerindicator3: Sprite2D = $PlayerIndicator/Player3
@onready var playerindicator4: Sprite2D = $PlayerIndicator/Player4
@onready var playerindicator5: Sprite2D = $PlayerIndicator/Player5

func _ready():
	pass
