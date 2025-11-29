extends Node

func fade_to(target_alpha: float, object, duration := 0.15):
	var tween = object.create_tween()
	tween.tween_property(object, "modulate:a", target_alpha, duration)

func _ready() -> void:
	pass
