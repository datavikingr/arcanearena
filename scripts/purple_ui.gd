extends PlayerUI

@onready var spike: Sprite2D = $PlayerSpike
var spike_frame: int = 69

func _ready() -> void:
	spike.frame = spike_frame
	player_color = "Purple"
