extends StaticBody2D

func _ready() -> void: # Called when the node enters the scene tree for the first time.
	var instantiator = get_parent() # Get the parent node (the instantiator)
	print("Instantiated by:", instantiator.name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
