extends Node2D

@onready var hot_team_ui: Node2D = %HotTeamUI
@onready var cold_team_ui: Node2D = %ColdTeamUI
@onready var tens_place:Sprite2D = %TensPlace
@onready var ones_place: Sprite2D = %OnesPlace
@onready var timer: Timer = get_node("Timer")
var old_hot_score: int = 0
var old_cold_score: int = 0
var countdown: int = 30

#TODO Currently busted, needs work. hot_team_ui isn't loaded by sudden_death() or something

func _ready():
	if is_visible_in_tree(): # When the node is enabled or disabled, do the thing
		self.global_transform.origin = Vector2(320,90)
		timer.start()
		sudden_death()
	else:
		_disable_sudden_death()

func sudden_death():
	old_hot_score = hot_team_ui.get("goals")
	old_cold_score = cold_team_ui.get("goals")
	hot_team_ui.goals = 9
	cold_team_ui.goals = 9

func _disable_sudden_death():
	visible = false
	hot_team_ui.set("goals", old_hot_score)
	cold_team_ui.set("goals", old_cold_score)

func _notification(what): # Handle when the node becomes visible (in editor or runtime)
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if is_visible_in_tree():
			sudden_death()
		else:
			_disable_sudden_death()

func _on_timer_timeout() -> void:
	countdown -= 1
	if ones_place.frame == 0:
		tens_place.frame -= 1
		ones_place.frame = 9
	else:
		ones_place.frame -= 1
	if countdown == 0:
		_disable_sudden_death()
