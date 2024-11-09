extends PlayerUI

@onready var spike: Sprite2D = $PlayerSpike
var blue_spike: int = 21

func _ready() -> void:
	spike.frame = blue_spike
	player_color = "Blue"
