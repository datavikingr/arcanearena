extends Sprite2D

@onready var title_node = %TitleUI
@onready var controls_node = %ControlsUI

func fade_to(target_alpha: float, object, duration := 0.15):
	var tween = object.create_tween()
	tween.tween_property(object, "modulate:a", target_alpha, duration)

func _on_ready() -> void:
	fade_to(1.0, title_node) # init visible
	fade_to(.33, self) # init semi-visible
	fade_to(0.0, controls_node) # init invisible

func _on_player_contact_zone_body_entered(body: Node2D) -> void:
	print(body)
	fade_to(0.0, title_node) # turn off title
	fade_to(1.0, self) # turn on darkness
	fade_to(1.0,controls_node) # turn on controls details

func _on_player_contact_zone_body_exited(_body: Node2D) -> void:
	fade_to(1.0, title_node) # reset to init
	fade_to(.33, self) # reset to init
	fade_to(0.0, controls_node) # reset to init
